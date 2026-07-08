#!/usr/bin/env bash
# Calibration probe — the independent review must be ABLE TO GO RED on a known-bad.
# `references/probes.md` imposes "must be able to go red" on every probe, but the
# review keystone (build/SKILL.md principle 3) had no such check: `_review-coherence.sh`
# only verifies a trace EXISTS, not that the review can FIND a defect. This closes
# that gap (P0-2 / D-70): a review trace of a known-bad artifact MUST flag a defect
# (cite the SPEC + name it); a trace that returns MET on the known-bad is vacuous -> RED.
set -euo pipefail

check() {
  local TRACE="$1" fail=0
  if ! grep -q 'SPEC\.md' "$TRACE"; then echo "  RED  trace does not cite a SPEC anchor"; fail=1; fi
  if ! grep -qE 'known-bad|manuscript/|artifact' "$TRACE"; then echo "  RED  trace does not cite the artifact"; fail=1; fi
  if ! grep -qiE 'NOT MET|defect|violation|注水|padding|未达|不达标|hollow|gamed|未推进' "$TRACE"; then
    echo "  RED  trace returns MET on a known-bad artifact — the review is vacuous (cannot go red)"; fail=1
  fi
  [ "$fail" -eq 0 ] && echo "  OK   trace flags a defect on the known-bad (review can go red)"
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # neg-control: a trace that passes the known-bad clean (MET, no defect flagged) -> RED
  printf 'verdict: MET\nspec-cite: SPEC.md R8\nartifact: known-bad.md\n' > "$tmp/trace.md"
  check "$tmp/trace.md" >/dev/null 2>&1 && { echo "NEG FAIL: a MET-on-known-bad trace not caught"; exit 1; } \
    || echo "  neg-control ok: MET-on-known-bad trace -> RED (vacuous review)"
  # pos-control: a trace that flags the defect -> GREEN
  printf 'verdict: NOT MET\nspec-cite: SPEC.md R8\nartifact: known-bad.md\ndefect: 注水 padding, no story increment\n' > "$tmp/trace.md"
  check "$tmp/trace.md" >/dev/null 2>&1 && echo "  pos-control ok: defect-flagging trace -> GREEN" \
    || { echo "POS FAIL: defect-flagging trace flagged"; exit 1; }
  echo "RESULT: _neg-control self-test passed (non-vacuous)"; exit 0
fi

TRACE="${1:-$(dirname "$0")/review-of-known-bad.md}"
echo "== calibration probe: review can go red on a known-bad =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$TRACE" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — the review trace does not flag the known-bad (vacuous review)"; exit 1; }
echo "RESULT: GREEN — the review flags a defect on the known-bad (review capability calibrated)"
