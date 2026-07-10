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
# the checks grep for are `*Revision:`, `*Changed:`, `*Intent:`, `*Acceptance:`,
# and `*Methods:`. Methods use the closed vocabulary Probed/CitedFact/
# HumanApproval/Judged:L1|L2/OPEN. Free-form rewording is a false-red — the SPEC.template
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
# still has a requirement tagged `[locked]` (an R<n>…[locked] line, not a prose mention)
# but locked_reqs() recognized none, the parser
# is blind -> RED, never a quiet green. (probes.md "A gate is a proxy for an intent";
# consistency-lens law 5, referential integrity.) A SPEC that genuinely has no
# `[locked]` reqs is legitimately empty -> GREEN (nothing to check).
assert_parser_sane() {
  local SPEC="$1" n
  n=$(locked_reqs "$SPEC" | grep -c . || true)
  if [ "$n" -eq 0 ] && grep -qE 'R[0-9]+.*\[locked\]|\[locked\].*R[0-9]+' "$SPEC"; then
    echo "  RED  parser recognized ZERO locked reqs yet SPEC has a requirement tagged '[locked]' — requirement shape unrecognized (probe is blind, not green); align SPEC.md's requirement markdown with the PARSER CONTRACT or extend locked_reqs()"
    return 1
  fi
  return 0
}

# ---- requirement coherence: identity + Intent + Acceptance + Methods --------
# A locked requirement is complete only with its evidence identity and a method
# from the closed vocabulary defined by SPEC.template.md.
# RED if a [locked] req has Acceptance alone — the "incomplete requirement"
# defect (probes.md: "the same defect as a gate with no evidence").
check_requirement_coherence() {
  local SPEC="$1" fail=0 entry missing methods
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r entry; do
    missing=""
    grep -qiE '\*Revision:\*?[[:space:]]*[0-9]+' <<<"$entry" || missing="$missing Revision"
    grep -qiE '\*Changed:\*?[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' <<<"$entry" || missing="$missing Changed"
    grep -qiE '\*Intent:|\*意图:' <<<"$entry" || missing="$missing Intent"
    grep -qiE '\*Acceptance:|\*验收:' <<<"$entry" || missing="$missing Acceptance"
    methods=$(grep -oiE '\*Methods?:\*?[^*]+' <<<"$entry" | head -1 || true)
    [ -n "$methods" ] || missing="$missing Methods"
    if [ -n "$methods" ] && ! grep -qE 'Probed|CitedFact|HumanApproval|Judged:L[12]|OPEN' <<<"$methods"; then missing="$missing valid-Method"; fi
    if [ -n "$missing" ]; then echo "  RED  [locked] req missing/invalid:$missing: ${entry:0:70}…"; fail=1
    else echo "  OK   $(printf '%s' "$entry" | grep -oE '\*\*R[0-9]+' | head -1 | tr -d '*') has evidence identity + Intent + Acceptance + Methods"; fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

# ---- (D-57) spec <-> probe coherence -----------------------------------------
# (1) every locked requirement's referenced probe exists and binds its revision;
# another Method never exempts that reference; (2) no probe file is orphaned
# by nothing in SPEC). RED on either — a stale set is a false green.
check_spec_probe_coherence() {
  local SPEC="$1" PROBES="$2" fail=0 line refs r base f rid rev
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r line; do
    refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
    [ -z "$refs" ] && continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$line" | head -1 | tr -d '*')
    rev=$(grep -oiE '\*Revision:\*?[[:space:]]*[0-9]+' <<<"$line" | grep -oE '[0-9]+' | tail -1 || true)
    for r in $refs; do
      base=$(basename "$r")
      if [ ! -f "$PROBES/$base" ]; then echo "  RED  locked req -> $base MISSING — a referenced probe is never exempted by another Method"; fail=1
      elif [ -z "$rev" ] || ! grep -qE "requirement:[[:space:]]*$rid@$rev|requirement=$rid@$rev" "$PROBES/$base"; then echo "  RED  $base does not bind current $rid@$rev"; fail=1
      else echo "  OK   locked req -> $base exists and binds $rid@$rev"; fi
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
# A locked req is review-requiring iff Methods carries Judged:L1|L2 (legacy
# *Review:* is accepted during migration). It needs review-<Rn>-*.md
# that reckons the recorded Intent AND quotes a concrete artifact passage — not
# merely names SPEC + artifact (that hollow trace is the cheapest forgery: a fake
# review; it goes RED, and is the selftest's negative control). Honest limit: a
# well-formed trace makes the closure auditable + forgery-resistant, not certain.
check_review_coherence() {
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited is_l2 eng prod revw root declared artifact_path artifact_kind artifact_root actual trace_cited trace_eng manifest_ok expected rel artifact_count safe actual_set declared_set
  if [ "$(basename "$(dirname "$EVID")")" = .spec ]; then root=$(cd "$EVID/../.." && pwd)
  else root=$(cd "$EVID/.." && pwd); fi
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r entry; do
    # review-requiring? structured *Review:* field (with a value), or the legacy phrase
    grep -qiE 'Judged:L[12]|\*Review:\*?[[:space:]]*L[12]' <<<"$entry" || continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$entry" | head -1 | tr -d '*')
    [ -z "$rid" ] && continue
    local reqrev artifact verdict reviewed
    reqrev=$(grep -oiE '\*Revision:\*?[[:space:]]*[0-9]+' <<<"$entry" | grep -oE '[0-9]+' | tail -1 || true)
    is_l2=0; grep -qiE 'Judged:L2|\*Review:\*?[[:space:]]*L2' <<<"$entry" && is_l2=1
    found=0; cited=0; eng=0
    for trace in "$EVID"/review-"$rid"-*.md; do
      [ -e "$trace" ] || continue
      found=1; trace_cited=0; trace_eng=0
      # NB: L2 classification comes ONLY from the SPEC entry's *Review:* field (set
      # above) — never from this trace. The trace is the artifact under inspection;
      # letting it self-declare "level: L2" would escalate an honest L1 req and
      # false-RED it (A1-1). is_l2 is fixed for the whole requirement now.
      # cited iff it anchors to SPEC AND reckons Intent AND quotes a concrete passage
      declared=$(grep -oiE '^artifact:[[:space:]]*sha256:[a-f0-9]{64}' "$trace" | head -1 | sed 's/.*sha256://' || true)
      artifact_path=$(grep -oiE '^artifact-path:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//' || true)
      artifact_kind=$(grep -oiE '^artifact-kind:[[:space:]]*(file|manifest)' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//' || true)
      artifact_root=$(grep -oiE '^artifact-root:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//' || true)
      [ -n "$artifact_kind" ] || artifact_kind=file
      actual=""; safe=1
      case "$artifact_path" in /*|*..*) safe=0;; esac
      if [ "$safe" -eq 1 ] && [ -n "$root" ] && [ -n "$artifact_path" ] && [ -f "$root/$artifact_path" ]; then
        if command -v shasum >/dev/null; then actual=$(shasum -a 256 "$root/$artifact_path" | awk '{print $1}')
        elif command -v sha256sum >/dev/null; then actual=$(sha256sum "$root/$artifact_path" | awk '{print $1}'); fi
      fi
      manifest_ok=1; artifact_count=0
      if [ "$artifact_kind" = manifest ]; then
        case "$artifact_root" in ''|/*|*..*) manifest_ok=0;; esac
        [ -d "$root/$artifact_root" ] || manifest_ok=0
        while read -r expected rel; do
          artifact_count=$((artifact_count + 1))
          case "$rel" in /*|*..*) manifest_ok=0; continue;; "$artifact_root"/*) :;; *) manifest_ok=0; continue;; esac
          [ -n "$expected" ] && [ -n "$rel" ] && [ -f "$root/$rel" ] || { manifest_ok=0; continue; }
          if command -v shasum >/dev/null; then [ "$(shasum -a 256 "$root/$rel" | awk '{print $1}')" = "$expected" ] || manifest_ok=0
          else [ "$(sha256sum "$root/$rel" | awk '{print $1}')" = "$expected" ] || manifest_ok=0; fi
        done < "$root/$artifact_path"
        [ "$artifact_count" -gt 0 ] || manifest_ok=0
        actual_set=$(cd "$root" && find "$artifact_root" -type f -print | LC_ALL=C sort)
        declared_set=$(awk '{print $2}' "$root/$artifact_path" | LC_ALL=C sort)
        [ "$actual_set" = "$declared_set" ] || manifest_ok=0
      fi
      if grep -qi 'SPEC\.md' "$trace" && grep -qiE "^requirement:[[:space:]]*$rid@$reqrev" "$trace" \
         && [ -n "$declared" ] && [ "$declared" = "$actual" ] \
         && grep -qiE '^verdict:[[:space:]]*pass' "$trace" \
         && grep -qiE '^reviewed-at:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$trace" \
         && [ "$manifest_ok" -eq 1 ] && grep -qiE 'intent:|意图:' "$trace" \
         && grep -qE '^[[:space:]]*> |quote:|引用:|anchor:|line[[:space:]]*:|§|ch[0-9]+|章节|manuscript/|src/|[a-z0-9_-]+/[a-z0-9_.-]+\.(md|txt)' "$trace"; then
        trace_cited=1
      fi
      # L2 (judgment-independent) must name a DISTINCT reviewer engine vs producer — the
      # machine-checkable proxy for "a different judgment basis." Relabeling an L1 (same
      # model, clean context) as L2 is the forgery this catches. (A2; floor, not certainty
      # — the engine strings can still be lied about; see probes.md Honest limit.)
      if [ "$is_l2" -eq 1 ]; then
        prod=$(grep -oiE '^producer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        revw=$(grep -oiE '^reviewer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        { [ -n "$prod" ] && [ -n "$revw" ] && [ "$prod" != "$revw" ]; } && trace_eng=1
      fi
      if [ "$trace_cited" -eq 1 ]; then
        cited=1
        { [ "$is_l2" -eq 0 ] || [ "$trace_eng" -eq 1 ]; } && eng=1
      fi
    done
    if   [ "$found" -eq 0 ]; then echo "  RED  $rid needs an independent review but has NO review-$rid-*.md trace"; fail=1
    elif [ "$cited" -eq 0 ]; then echo "  RED  $rid trace is stale/hollow — must bind $rid@$reqrev + recomputable artifact-path/sha256 + pass verdict + reviewed-at + Intent + quote"; fail=1
    elif [ "$is_l2" -eq 1 ] && [ "$eng" -eq 0 ]; then echo "  RED  $rid is *Review:* L2 (judgment-independent) but no trace declares distinct producer-engine: and reviewer-engine: — relabeling an L1 (same model) as L2 is the forgery this catches"; fail=1
    else echo "  OK   $rid -> review trace reckons Intent + cites SPEC + quotes artifact$([ "$is_l2" -eq 1 ] && echo " + distinct L2 engines")"; fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

# ---- selftest: every check must be able to go red ----------------------------
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/probes" "$tmp/evid" "$tmp/pb"
  printf 'artifact fixture\n' > "$tmp/artifact.txt"
  digest=$(shasum -a 256 "$tmp/artifact.txt" | awk '{print $1}')
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
  # prose-mention of [locked] (not a real tag) + only provisional reqs stays GREEN — the
  # tightened oracle (R<n>…[locked], not bare [locked]) must not false-RED on format-doc
  # prose. SPEC.template itself generates "Requirements carry the [locked] tag …".
  printf '%s\n' 'Requirements carry the [locked] tag once evidence-backed, else [provisional].' '- **R1.** [provisional] first. *Intent:* [auto] x. *Acceptance:* y. *Method:* OPEN.' > "$tmp/prose.md"
  if check_requirement_coherence "$tmp/prose.md" >/dev/null 2>&1; then echo "  pos-control ok: prose [locked] mention + zero real locked reqs -> GREEN"
  else echo "  POS FAIL: prose-mention of [locked] false-RED'd"; rc=1; fi

  # requirement coherence: a [locked] req with only Acceptance -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Acceptance:* it works. *(D1)*' > "$tmp/S.md"
  if check_requirement_coherence "$tmp/S.md" >/dev/null 2>&1; then echo "  NEG FAIL: Acceptance-only locked req not caught"; rc=1
  else echo "  neg-control ok: Acceptance-only -> RED"; fi
  printf '%s\n' '- **R1** [locked] a thing. *Revision:* 1. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* it works. *Methods:* CitedFact. *(D1)*' > "$tmp/S.md"
  if check_requirement_coherence "$tmp/S.md" >/dev/null 2>&1; then echo "  pos-control ok: Intent+Method -> GREEN"
  else echo "  POS FAIL: complete req flagged"; rc=1; fi

  # spec<->probe: a locked req referencing a missing probe -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Revision:* 1. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* works. *Methods:* Probed(.spec/probes/G-missing.sh).' > "$tmp/S.md"
  if check_spec_probe_coherence "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1; then echo "  NEG FAIL: ungated locked req not caught"; rc=1
  else echo "  neg-control ok: missing referenced probe -> RED"; fi
  printf '#!/usr/bin/env bash\n# requirement: R1@1\n' > "$tmp/probes/G-real.sh"
  printf '%s\n' '- **R1** [locked] a thing. *Revision:* 1. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* works. *Methods:* Probed(.spec/probes/G-real.sh).' > "$tmp/S.md"
  if check_spec_probe_coherence "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1; then echo "  pos-control ok: referenced probe exists -> GREEN"
  else echo "  POS FAIL: coherent set flagged"; rc=1; fi

  # review-trace: a *Review:* req with no trace -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Revision:* 1. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* quality. *Methods:* Judged:L1.' > "$tmp/S.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: missing review trace not caught"; rc=1
  else echo "  neg-control ok: review-requiring req with no trace -> RED"; fi
  # FORGERY (the new negative control): a hollow trace that only names SPEC + artifact -> RED
  printf 'ref: SPEC.md R1\nartifact: manuscript/ch1.md\nlooks fine\n' > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: hollow/forget trace not caught"; rc=1
  else echo "  neg-control ok: hollow trace (no Intent reckoning, no quote) -> RED"; fi
  # honest trace: reckons Intent + quotes a passage -> GREEN
  printf 'ref: SPEC.md R1\nrequirement: R1@1\nartifact-path: artifact.txt\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nintent: the purpose is met\n> "the concrete quoted passage"\n' "$digest" > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: trace reckons Intent + quotes artifact -> GREEN"
  else echo "  POS FAIL: cited trace flagged"; rc=1; fi
  printf 'artifact mutated after review\n' > "$tmp/artifact.txt"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: artifact mutation reused stale review"; rc=1
  else echo "  neg-control ok: artifact changed after review -> RED"; fi
  printf 'artifact fixture\n' > "$tmp/artifact.txt"
  mkdir "$tmp/artifact-set"; printf 'first file\n' > "$tmp/artifact-set/first.txt"; printf 'second file\n' > "$tmp/artifact-set/second.txt"
  printf '%s  artifact-set/first.txt\n%s  artifact-set/second.txt\n' "$(shasum -a 256 "$tmp/artifact-set/first.txt" | awk '{print $1}')" "$(shasum -a 256 "$tmp/artifact-set/second.txt" | awk '{print $1}')" > "$tmp/artifacts.sha256"
  manifest_digest=$(shasum -a 256 "$tmp/artifacts.sha256" | awk '{print $1}')
  printf 'ref: SPEC.md R1\nrequirement: R1@1\nartifact-kind: manifest\nartifact-root: artifact-set\nartifact-path: artifacts.sha256\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nintent: met\n> "multi-file artifact"\n' "$manifest_digest" > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: multi-file artifact manifest -> GREEN"
  else echo "  POS FAIL: valid multi-file manifest flagged"; rc=1; fi
  printf 'mutated second file\n' > "$tmp/artifact-set/second.txt"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: changed file inside artifact manifest passed"; rc=1
  else echo "  neg-control ok: changed file inside artifact manifest -> RED"; fi
  printf 'second file\n' > "$tmp/artifact-set/second.txt"
  grep -v 'second.txt' "$tmp/artifacts.sha256" > "$tmp/subset.sha256"; mv "$tmp/subset.sha256" "$tmp/artifacts.sha256"
  subset_digest=$(shasum -a 256 "$tmp/artifacts.sha256" | awk '{print $1}')
  sed "s/^artifact: sha256:.*/artifact: sha256:$subset_digest/" "$tmp/evid/review-R1-x.md" > "$tmp/evid/subset"; mv "$tmp/evid/subset" "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: subset artifact manifest passed"; rc=1
  else echo "  neg-control ok: artifact manifest omits in-scope file -> RED"; fi
  # L2 (judgment-independent) forgery (A2): an L2 review whose trace reuses the SAME
  # engine as the producer (relabeling an L1 as L2) -> RED; distinct engines -> GREEN.
  printf '%s\n' '- **R2** [locked] generated quality. *Revision:* 2. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* quality. *Methods:* Judged:L2.' > "$tmp/S2.md"
  printf 'ref: SPEC.md R2\nrequirement: R2@2\nartifact-path: artifact.txt\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-sonnet-5\nintent: met\n> "passage"\n' "$digest" > "$tmp/evid/review-R2-x.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: L2 trace with SAME producer/reviewer engine not caught"; rc=1
  else echo "  neg-control ok: L2 same-engine (relabeled L1) -> RED"; fi
  printf 'ref: SPEC.md R2\nrequirement: R2@2\nartifact-path: artifact.txt\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nintent: met\n> "passage"\n' "$digest" > "$tmp/evid/review-R2-x.md"
  printf 'producer-engine: old-engine\nreviewer-engine: other-engine\n' > "$tmp/evid/review-R2-old.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: L2 trace with no engine fields not caught"; rc=1
  else echo "  neg-control ok: L2 cannot splice valid evidence + engines across traces -> RED"; fi
  rm "$tmp/evid/review-R2-old.md"
  printf 'ref: SPEC.md R2\nrequirement: R2@2\nartifact-path: artifact.txt\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-opus-4-8\nintent: met\n> "passage"\n' "$digest" > "$tmp/evid/review-R2-x.md"
  if check_review_coherence "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: L2 distinct engines -> GREEN"
  else echo "  POS FAIL: L2 distinct-engine trace flagged"; rc=1; fi
  # A1-1 regression guard: an HONEST L1 req whose trace carries a stray 'level: L2'
  # line must stay GREEN — the trace must not escalate the requirement's classification;
  # only the SPEC's *Review:* field decides L1 vs L2.
  printf '%s\n' '- **R3** [locked] thing. *Revision:* 1. *Changed:* 2026-01-01T00:00:00Z. *Intent:* [auto] x. *Acceptance:* quality. *Methods:* Judged:L1.' > "$tmp/S3.md"
  printf 'ref: SPEC.md R3\nrequirement: R3@1\nartifact-path: artifact.txt\nartifact: sha256:%s\nverdict: pass\nreviewed-at: 2026-01-01T00:00:00Z\nintent: met\n> "passage"\n' "$digest" > "$tmp/evid/review-R3-x.md"
  if check_review_coherence "$tmp/S3.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: L1 req + stray L2-trace level -> GREEN (trace can't escalate)"
  else echo "  POS FAIL: L1 req false-RED'd by trace's level: L2"; rc=1; fi

  [ "$rc" -eq 0 ] && echo "RESULT: coherence.template self-test passed (all three checks non-vacuous)" || echo "RESULT: self-test FAILED"
  exit "$rc"
fi

echo "coherence.template.sh is a TEMPLATE — copy a check_*() into .spec/probes/G<n>-*.sh and call it."
echo "run with --selftest to verify the checks can go red."
exit 0
