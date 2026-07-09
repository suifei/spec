#!/usr/bin/env bash
# Probe G8 — review-trace coherence (D-65). Every [locked] requirement whose
# Method names an independent intent-review must have a cited
# .spec/evidence/review-<Rn>-*.md (SPEC anchor + artifact anchor). No file =>
# the review can't be shown to have happened; a bare "looks fine" => not cited.
# (Template: references/coherence.template.sh; reference impl: eval/cn-novel/_review-coherence.sh. D-69.)
# Note: this dogfood's R1–R5 are contract requirements (Method WEAK), not
# generative/quality work, so none name an independent review — the probe is
# GREEN trivially here and exists to catch a future review-requiring requirement.
set -euo pipefail

locked_reqs() {
  awk '/^- \*\*R/ { if(e!="") print e; e=$0; next }
       /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
       { if(e!=""){ print e; e="" } } END { if(e!="") print e }' "$1" | grep -F '[locked]'
}

check() {
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

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/evid"
  printf '%s\n' '- **R1** [locked] a thing. *Method:* WEAK 独立意图评审. *Intent:* [auto] x.' > "$tmp/S.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: missing review trace not caught"; exit 1; } \
    || echo "  neg-control ok: review-requiring req with no trace -> RED"
  printf 'spec-cite: SPEC.md R1\nartifact: manuscript/ch1.md\n' > "$tmp/evid/review-R1-x.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: cited trace -> GREEN" \
    || { echo "POS FAIL: cited trace flagged"; exit 1; }
  echo "RESULT: G8 self-test passed (non-vacuous)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
EVID="${2:-$(dirname "$0")/../evidence}"
echo "== probe G8: review-trace coherence (D-65) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$EVID" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — a review-requiring requirement lacks a cited evidence trace"; exit 1; }
echo "RESULT: GREEN — every review-requiring requirement has a cited .spec/evidence/review-*.md trace"
