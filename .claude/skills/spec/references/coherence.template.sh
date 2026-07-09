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
#   (D-57) spec <-> probe:  every [locked] requirement whose Method references a
#            .spec/probes/<X>.sh has that file; no probe file is orphaned by a
#            superseded requirement. (Reference impl: eval/cn-novel/_coherence.sh)
#   (D-65) review trace:    every [locked] requirement whose Method names an
#            independent intent-review has a cited .spec/evidence/review-<Rn>-*.md
#            (SPEC anchor + artifact anchor). (Reference impl: eval/cn-novel/_review-coherence.sh)
#   (NEW)  requirement:     every [locked] requirement carries Intent + Method
#            (Probed/OPEN/WEAK), never Acceptance alone — the defect class where
#            the spec's own format rule is silently unmet. (references/probes.md
#            "Every load-bearing acceptance needs a method".)
#
# All three are parameterized by (SPEC, PROBES, EVID) so --selftest can exercise
# them on fixtures. A coherence probe, like any probe, MUST be able to go red.

set -euo pipefail

# ---- requirement-entry parser (shared) ---------------------------------------
# Joins wrapped continuation lines of a "- **Rn.**" entry into one line, then
# filters to [locked]. Reused from eval/cn-novel/_coherence.sh.
locked_reqs() {
  awk '
    /^- \*\*R/    { if(e!="") print e; e=$0; next }
    /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
    { if(e!=""){ print e; e="" } }
    END { if(e!="") print e }
  ' "$1" | grep -F '[locked]'
}

# ---- (NEW) requirement coherence: Intent + Method present --------------------
# A [locked] requirement is complete iff it carries BOTH an Intent field and a
# Method field (Probed/OPEN/WEAK). Bilingual tokens (English pin | Chinese pin).
# RED if a [locked] req has Acceptance alone — the "incomplete requirement"
# defect (probes.md: "the same defect as a gate with no evidence").
check_requirement_coherence() {
  local SPEC="$1" fail=0 entry has_intent has_method
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
  while IFS= read -r line; do
    refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
    [ -z "$refs" ] && continue
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
# A [locked] req whose Method names an independent intent-review must have a
# cited .spec/evidence/review-<Rn>-*.md (SPEC anchor + artifact anchor). No file
# => the review can't be shown to have happened; a bare "looks fine" => not cited.
check_review_coherence() {
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited
  while IFS= read -r entry; do
    grep -qE '独立.{0,8}评审|independent[ -]?review' <<<"$entry" || continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$entry" | head -1 | tr -d '*')
    [ -z "$rid" ] && continue
    found=0; cited=0
    for trace in "$EVID"/review-"$rid"-*.md; do
      [ -e "$trace" ] || continue
      found=1
      grep -q 'SPEC\.md' "$trace" && grep -qE 'manuscript/|artifact' "$trace" && cited=1
    done
    if   [ "$found" -eq 0 ]; then echo "  RED  $rid needs an independent review but has NO review-$rid-*.md trace"; fail=1
    elif [ "$cited" -eq 0 ]; then echo "  RED  $rid trace exists but does not cite BOTH a SPEC anchor and an artifact anchor"; fail=1
    else echo "  OK   $rid -> review trace present, cites SPEC + artifact"; fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

# ---- selftest: every check must be able to go red ----------------------------
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/probes" "$tmp/evid"
  rc=0

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

  # review-trace: review-requiring req with no trace -> RED
  printf '%s\n' '- **R1** [locked] a thing. *Method:* WEAK 独立意图评审. *Intent:* [auto] x.' > "$tmp/S.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  NEG FAIL: missing review trace not caught"; rc=1
  else echo "  neg-control ok: review-requiring req with no trace -> RED"; fi
  printf 'spec-cite: SPEC.md R1\nartifact: manuscript/ch1.md\n' > "$tmp/evid/review-R1-x.md"
  if check_review_coherence "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1; then echo "  pos-control ok: cited trace -> GREEN"
  else echo "  POS FAIL: cited trace flagged"; rc=1; fi

  [ "$rc" -eq 0 ] && echo "RESULT: coherence.template self-test passed (all three checks non-vacuous)" || echo "RESULT: self-test FAILED"
  exit "$rc"
fi

echo "coherence.template.sh is a TEMPLATE — copy a check_*() into .spec/probes/G<n>-*.sh and call it."
echo "run with --selftest to verify the checks can go red."
exit 0
