#!/usr/bin/env bash
# Probe G8 — review-trace coherence (D-65). Every [locked] requirement whose
# *Method* IS an independent intent-review must have a cited
# .spec/evidence/review-<Rn>-*.md (SPEC anchor + artifact anchor). No file =>
# the review can't be shown to have happened; a bare "looks fine" => not cited.
# (Template: references/coherence.template.sh; reference impl: eval/cn-novel/_review-coherence.sh. D-69.)
#
# D-74 fix: detection is scoped to the *Method:* clause specifically, not the whole
# requirement entry. Whole-entry grepping false-positived on R3 after the clean-context
# audit reconciled R3's Intent/Acceptance to MENTION "independent review" as a general
# rule (generative/quality work needs one) — R3's own Method stays WEAK(cited), it is
# not itself review-requiring, so matching outside Method wrongly demanded a trace for a
# requirement about /build's process, not a generative artifact.
set -euo pipefail

locked_reqs() {
  awk '/^- \*\*R/ { if(e!="") print e; e=$0; next }
       /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
       { if(e!=""){ print e; e="" } } END { if(e!="") print e }' "$1" | grep -F '[locked]'
}

# extract just the *Method:* ... clause (up to the next " *(" citation marker or end)
method_clause() {
  grep -oE '\*Method:\*.*' <<<"$1" | sed -E 's/ \*\([^)]*\)\*?\s*$//'
}

check() {
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited method
  while IFS= read -r entry; do
    method=$(method_clause "$entry")
    grep -qE '独立.{0,8}评审|independent[ -]?review' <<<"$method" || continue
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

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/evid"
  printf '%s\n' '- **R1** [locked] a thing. *Method:* WEAK 独立意图评审. *Intent:* [auto] x.' > "$tmp/S.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: missing review trace not caught"; exit 1; } \
    || echo "  neg-control ok: review-requiring req with no trace -> RED"
  printf 'spec-cite: SPEC.md R1\nartifact: manuscript/ch1.md\n' > "$tmp/evid/review-R1-x.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: cited trace -> GREEN" \
    || { echo "POS FAIL: cited trace flagged"; exit 1; }
  # the R3 false-positive this fix closes: "independent review" mentioned in Intent/
  # Acceptance (describing a general rule) but the Method itself is WEAK(cited), not an
  # independent review -> must NOT be flagged as review-requiring (no trace needed)
  printf '%s\n' '- **R2** [locked] a process rule. *Intent:* [auto] for generative work an independent review must sign off. *Acceptance:* the rule holds. *Method:* WEAK(cited) — a coherence probe checks this. *(D-x)*' > "$tmp/S2.md"
  check "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: 'independent review' mentioned OUTSIDE Method (Intent only) -> not flagged, GREEN" \
    || { echo "POS FAIL: R3-class false positive reintroduced (Method-scoping regressed)"; exit 1; }
  echo "RESULT: G8 self-test passed (non-vacuous)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
EVID="${2:-$(dirname "$0")/../evidence}"
echo "== probe G8: review-trace coherence (D-65) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$EVID" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — a review-requiring requirement lacks a cited evidence trace"; exit 1; }
echo "RESULT: GREEN — every review-requiring requirement has a cited .spec/evidence/review-*.md trace"
