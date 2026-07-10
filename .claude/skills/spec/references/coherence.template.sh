#!/usr/bin/env bash
# coherence.template.sh — a skeleton for a CLOSURE-INVARIANT (coherence) probe.
#
# A gate probe (probe.template.sh) asks "is THIS truth true?" A *coherence*
# probe asks "does the gate SET / requirement SET still match the spec?" — the
# closure invariants /spec defines in SKILL.md Step 6 ("Reconcile the probe SET
# to the CHANGED spec"). These are what keep the drift-detector itself from
# drifting: a green board is worth nothing if the probes test a superseded spec.
#
# Three invariants a project should hold (instantiate one probe per invariant —
# this template shows the shared shape; real instances live at
# .spec/probes/G<n>-*.sh):
#
#   spec <-> probe:  every [locked] requirement whose Method references a
#            .spec/probes/<X>.sh has that file; no probe file is orphaned by a
#            superseded requirement. (Reference impl: eval/cn-novel/.spec/probes/_coherence.sh)
#   review trace:    every review-requiring [locked] requirement (carries a
#            *Review:* field, or names an independent review) has a cited
#            .spec/evidence/review-<Rn>-*.md that reckons the recorded Intent AND
#            quotes a concrete artifact passage. A hollow trace (only names SPEC +
#            artifact) is the cheapest forgery and goes RED. (Reference impl shape:
#            eval/cn-novel/.spec/probes/_review-coherence.sh; this template hardens the citation
#            bar so the forgery is the negative control.)
#   requirement:     every [locked] requirement carries Intent + Method
#            (Probed/OPEN/WEAK), never Acceptance alone — the defect class where
#            the spec's own format rule is silently unmet. (references/probes.md
#            "Every load-bearing acceptance needs a method".)
#
# All three are parameterized by (SPEC, PROBES, EVID) so --selftest can exercise
# them on fixtures. A coherence probe, like any probe, MUST be able to go red.

set -euo pipefail

# ---- requirement-entry parser (shared) ---------------------------------------
# Joins wrapped continuation lines of a "- **Rn.**" entry into one line, then
# filters to [locked]. Reused from eval/cn-novel/.spec/probes/_coherence.sh.
#
# PARSER CONTRACT (what this awk assumes — keep SPEC.md requirements in this shape
# or the coherence checks silently mis-parse): a requirement is a markdown list
# item whose first line matches `^- **R<n>.**` and carries the literal tag
# `[locked]`; its *Intent:* / *Acceptance:* / *Method:* / *Review:* fields may wrap
# onto indented continuation lines (which get joined into one). The field tokens
# the checks grep for are `*Intent:`/`*意图:`, `*Method:`/`*方法:`,
# `*Review:` (L1|L2|independent), and `Phase|deferred|⤳|OPEN|WEAK|实例化` for
# "not-yet-instantiated". Free-form rewording of those tokens (e.g. `*PROBE*`
# instead of `*Method: ... Probed`) is a silent false-red/green — the SPEC.template
# format is the contract; a project that drifts from it must update these greps too.
locked_reqs() {
  awk '
    /^- \*\*R/    { if(e!="") print e; e=$0; next }
    /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
    { if(e!=""){ print e; e="" } }
    END { if(e!="") print e }
  ' "$1" | grep -F '[locked]'
}

# ---- parser-health guard (anti-vacuous-green) --------------------------------
# locked_reqs() is a brittle awk heuristic bound to the PARSER CONTRACT above. If a
# project's SPEC.md drifts from that shape (headings instead of `- **R**` list items,
# a different bullet, fields wrapped across a blank line), locked_reqs() silently
# matches ZERO entries — and the `while read` loops in check_*() never execute, so
# the check prints a bare header and exits 0: a GREEN over a spec the probe never
# actually parsed. That is the drift-detector's OWN vacuous-green (the very failure
# this kit exists to catch), so it must be its own negative control: if the raw SPEC
# still contains the `[locked]` token but locked_reqs() recognized none, the parser
# is blind -> RED, never a quiet green. (probes.md "A gate is a proxy for an intent";
# consistency-lens law 5, referential integrity.) A SPEC that genuinely has no
# `[locked]` reqs is legitimately empty -> GREEN (nothing to check).
assert_parser_sane() {
  local SPEC="$1" n
  n=$(locked_reqs "$SPEC" | grep -c . || true)
  if [ "$n" -eq 0 ] && grep -qF '[locked]' "$SPEC"; then
    echo "  RED  parser recognized ZERO locked reqs yet SPEC contains '[locked]' — requirement shape unrecognized (probe is blind, not green); align SPEC.md's requirement markdown with the PARSER CONTRACT or extend locked_reqs()"
    return 1
  fi
  return 0
}

# ---- (NEW) requirement coherence: Intent + Method present --------------------
# A [locked] requirement is complete iff it carries BOTH an Intent field and a
# Method field (Probed/OPEN/WEAK). Bilingual tokens (English pin | Chinese pin).
# RED if a [locked] req has Acceptance alone — the "incomplete requirement"
# defect (probes.md: "the same defect as a gate with no evidence").
check_requirement_coherence() {
  local SPEC="$1" fail=0 entry has_intent has_method
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r entry; do
    has_intent=0; has_method=0
    grep -qiE '\*Intent:|\*意图:' <<<"$entry" && has_intent=1
    grep -qiE '\*Method:|\*方法:'   <<<"$entry" && has_method=1
    if [ "$has_intent" -eq 0 ] || [ "$has_method" -eq 0 ]; then
      echo "  RED  [locked] req missing $( [ $has_intent -eq 0 ] && echo -n 'Intent ' )$( [ $has_method -eq 0 ] && echo -n 'Method' ): ${entry:0:70}…"; fail=1
    else
      echo "  OK   $(printf '%s' "$entry" | grep -oE '\*\*R[0-9]+' | head -1 | tr -d '*') has Intent + Method"
    fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

# ---- (D-57) spec <-> probe coherence -----------------------------------------
# (1) every [locked] req's referenced .spec/probes/<X>.sh exists (unless the line
# marks it deferred/Phase/OPEN/WEAK); (2) no probe file is orphaned (referenced
# by nothing in SPEC). RED on either — a stale set is a false green.
check_spec_probe_coherence() {
  local SPEC="$1" PROBES="$2" fail=0 line refs deferred r base f
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r line; do
    refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
    [ -z "$refs" ] && continue
    # "not-yet-instantiated" markers: a req whose probe is deliberately unbuilt
    # yet — Phase/deferred/⤳/OPEN/WEAK, plus `实例化` ("instantiate [at construction]",
    # the cn-novel eval project's convention). These are waited on, not RED.
    deferred=0; grep -qE 'Phase|实例化|OPEN|WEAK|deferred' <<<"$line" && deferred=1
    for r in $refs; do
      base=$(basename "$r")
      if [ -f "$PROBES/$base" ]; then echo "  OK   locked req -> $base exists"
      elif [ "$deferred" -eq 1 ]; then echo "  wait locked req -> $base missing but marked deferred/Phase"
      else echo "  RED  locked req -> $base MISSING, not deferred — UNGATED"; fail=1; fi
    done
  done < <(locked_reqs "$SPEC")
  for f in "$PROBES"/*.sh; do
    [ -e "$f" ] || continue
    base=$(basename "$f"); case "$base" in _*) continue;; esac
    if ! grep -qF "$base" "$SPEC"; then echo "  RED  orphan probe $base — referenced by no requirement/gate (stale?)"; fail=1; fi
  done
  return "$fail"
}

# ---- (D-65) review-trace coherence -------------------------------------------
# A [locked] req is "review-requiring" iff it carries a *Review:* field (L1/L2) or
# names an independent review. It must have a cited .spec/evidence/review-<Rn>-*.md
# that reckons the recorded Intent AND quotes a concrete artifact passage — not
# merely names SPEC + artifact (that hollow trace is the cheapest forgery: a fake
# review; it goes RED, and is the selftest's negative control). Honest limit: a
# well-formed trace makes the closure auditable + forgery-resistant, not certain.
check_review_coherence() {
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited is_l2 eng prod revw
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r entry; do
    # review-requiring? structured *Review:* field (with a value), or the legacy phrase
    grep -qiE '\*Review:\*?[[:space:]]*\S|独立.{0,8}评审|independent[ -]?review' <<<"$entry" || continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$entry" | head -1 | tr -d '*')
    [ -z "$rid" ] && continue
    is_l2=0
    grep -qiE '\*Review:\*?[[:space:]]*L2' <<<"$entry" && is_l2=1
    found=0; cited=0; eng=0
    for trace in "$EVID"/review-"$rid"-*.md; do
      [ -e "$trace" ] || continue
      found=1
      grep -qiE '^level:[[:space:]]*L2\b' "$trace" && is_l2=1
      # cited iff it anchors to SPEC AND reckons Intent AND quotes a concrete passage
      if grep -qi 'SPEC\.md' "$trace" && grep -qiE 'intent:|意图:' "$trace" \
         && grep -qE '^[[:space:]]*> |quote:|引用:|anchor:|line[[:space:]]*:|§|ch[0-9]+|章节|manuscript/|src/|[a-z0-9_-]+/[a-z0-9_.-]+\.(md|txt)' "$trace"; then
        cited=1
      fi
      # L2 (judgment-independent) must name a DISTINCT reviewer engine vs producer — the
      # machine-checkable proxy for "a different judgment basis." Relabeling an L1 (same
      # model, clean context) as L2 is the forgery this catches. (A2; floor, not certainty
      # — the engine strings can still be lied about; see probes.md Honest limit.)
      if [ "$is_l2" -eq 1 ]; then
        prod=$(grep -oiE '^producer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        revw=$(grep -oiE '^reviewer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        { [ -n "$prod" ] && [ -n "$revw" ] && [ "$prod" != "$revw" ]; } && eng=1
      fi
    done
    if   [ "$found" -eq 0 ]; then echo "  RED  $rid needs an independent review but has NO review-$rid-*.md trace"; fail=1
    elif [ "$cited" -eq 0 ]; then echo "  RED  $rid trace exists but is hollow — must cite SPEC + reckon Intent + quote a concrete artifact passage"; fail=1
    elif [ "$is_l2" -eq 1 ] && [ "$eng" -eq 0 ]; then echo "  RED  $rid is *Review:* L2 (judgment-independent) but no trace declares distinct producer-engine: and reviewer-engine: — relabeling an L1 (same model) as L2 is the forgery this catches"; fail=1
    else echo "  OK   $rid -> review trace reckons Intent + cites SPEC + quotes artifact$([ "$is_l2" -eq 1 ] && echo " + distinct L2 engines")"; fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

# ---- selftest: every check must be able to go red ----------------------------
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/probes" "$tmp/evid" "$tmp/pb"
  rc=0

  # parser-blindness (the drift-detector's OWN vacuous-green): a SPEC whose
  # [locked] req is in an UNRECOGNIZED shape (heading, not a `- **R**` list item)
  # must turn every check RED — not GREEN because locked_reqs() matched zero and
  # the loop body never ran. This is the assert_parser_sane guard's negative control.
  printf '%s\n' '### R1 [locked] a thing in heading form the awk parser does not match' \
                 '*Intent:* [auto] x. *Acceptance:* works. *Method:* WEAK(cited).' > "$tmp/blind.md"
  if check_requirement_coherence "$tmp/blind.md" >/dev/null 2>&1; then echo "  NEG FAIL: parser-blind SPEC passed requirement check (silent green)"; rc=1
  else echo "  neg-control ok: parser-blind SPEC -> requirement RED"; fi
  if check_spec_probe_coherence  "$tmp/blind.md" "$tmp/pb" >/dev/null 2>&1; then echo "  NEG FAIL: parser-blind SPEC passed spec<->probe (silent green)"; rc=1
  else echo "  neg-control ok: parser-blind SPEC -> spec<->probe RED"; fi
  if check_review_coherence      "$tmp/blind.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: parser-blind SPEC passed review-trace (silent green)"; rc=1
  else echo "  neg-control ok: parser-blind SPEC -> review-trace RED"; fi
  # legitimately-empty (no [locked] at all) stays GREEN — the guard must not
  # false-positive on a spec that genuinely has only provisional requirements.
  printf '%s\n' '### R1 [provisional] not locked yet.' > "$tmp/empty.md"
  if check_requirement_coherence "$tmp/empty.md" >/dev/null 2>&1; then echo "  pos-control ok: SPEC with zero [locked] -> GREEN (nothing to check)"
  else echo "  POS FAIL: legitimately-empty SPEC flagged"; rc=1; fi

  # requirement coherence: a [locked] req with only Acceptance -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Acceptance:* it works. *(D1)*' > "$tmp/S.md"
  if check_requirement_coherence "$tmp/S.md" >/dev/null 2>&1; then echo "  NEG FAIL: Acceptance-only locked req not caught"; rc=1
  else echo "  neg-control ok: Acceptance-only -> RED"; fi
  printf '%s\n' '- **R1** [locked] a thing. *Intent:* [auto] x. *Acceptance:* it works. *Method:* WEAK(cited). *(D1)*' > "$tmp/S.md"
  if check_requirement_coherence "$tmp/S.md" >/dev/null 2>&1; then echo "  pos-control ok: Intent+Method -> GREEN"
  else echo "  POS FAIL: complete req flagged"; rc=1; fi

  # spec<->probe: a locked req referencing a missing probe -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Method:* Probed(.spec/probes/G-missing.sh). *Intent:* [auto] x.' > "$tmp/S.md"
  if check_spec_probe_coherence "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1; then echo "  NEG FAIL: ungated locked req not caught"; rc=1
  else echo "  neg-control ok: missing referenced probe -> RED"; fi
  printf '#!/usr/bin/env bash\n' > "$tmp/probes/G-real.sh"
  printf '%s\n' '- **R1** [locked] a thing. *Method:* Probed(.spec/probes/G-real.sh). *Intent:* [auto] x.' > "$tmp/S.md"
  if check_spec_probe_coherence "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1; then echo "  pos-control ok: referenced probe exists -> GREEN"
  else echo "  POS FAIL: coherent set flagged"; rc=1; fi

  # review-trace: a *Review:* req with no trace -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Method:* WEAK(cited). *Review:* L1. *Intent:* [auto] x.' > "$tmp/S.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: missing review trace not caught"; rc=1
  else echo "  neg-control ok: review-requiring req with no trace -> RED"; fi
  # FORGERY (the new negative control): a hollow trace that only names SPEC + artifact -> RED
  printf 'ref: SPEC.md R1\nartifact: manuscript/ch1.md\nlooks fine\n' > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: hollow/forget trace not caught"; rc=1
  else echo "  neg-control ok: hollow trace (no Intent reckoning, no quote) -> RED"; fi
  # honest trace: reckons Intent + quotes a passage -> GREEN
  printf 'ref: SPEC.md R1\nintent: the purpose is met, not metric-gamed\n> "the concrete quoted passage from ch1"\n' > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: trace reckons Intent + quotes artifact -> GREEN"
  else echo "  POS FAIL: cited trace flagged"; rc=1; fi
  # L2 (judgment-independent) forgery (A2): an L2 review whose trace reuses the SAME
  # engine as the producer (relabeling an L1 as L2) -> RED; distinct engines -> GREEN.
  printf '%s\n' '- **R2** [locked] generated quality. *Method:* WEAK(cited). *Review:* L2. *Intent:* [auto] x.' > "$tmp/S2.md"
  printf 'ref: SPEC.md R2\nlevel: L2\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-sonnet-5\nintent: met\n> "passage"\n' > "$tmp/evid/review-R2-x.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: L2 trace with SAME producer/reviewer engine not caught"; rc=1
  else echo "  neg-control ok: L2 same-engine (relabeled L1) -> RED"; fi
  printf 'ref: SPEC.md R2\nlevel: L2\nintent: met\n> "passage"\n' > "$tmp/evid/review-R2-x.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: L2 trace with no engine fields not caught"; rc=1
  else echo "  neg-control ok: L2 missing engines -> RED"; fi
  printf 'ref: SPEC.md R2\nlevel: L2\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-opus-4-8\nintent: met\n> "passage"\n' > "$tmp/evid/review-R2-x.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: L2 distinct engines -> GREEN"
  else echo "  POS FAIL: L2 distinct-engine trace flagged"; rc=1; fi

  [ "$rc" -eq 0 ] && echo "RESULT: coherence.template self-test passed (all three checks non-vacuous)" || echo "RESULT: self-test FAILED"
  exit "$rc"
fi

echo "coherence.template.sh is a TEMPLATE — copy a check_*() into .spec/probes/G<n>-*.sh and call it."
echo "run with --selftest to verify the checks can go red."
exit 0
