#!/usr/bin/env bash
# Calibration probe — checks that a review TRACE, if it exists, discriminates a known-bad
# from a pass (D-70, reframed D-74 per clean-context audit).
#
# Honest scope: this script mechanically greps a trace FILE for citations + a
# defect-flagging verdict. It does NOT itself spawn a reviewer or prove a live review
# will produce such a trace — it guards the TRACE FORMAT's discriminability (a
# defect-flagging trace passes, a MET-on-known-bad trace fails), using whatever trace is
# on disk. The evidence that a LIVE reviewer actually produces a correct trace on this
# fixture is `review-of-known-bad.md` — as of D-74 that file holds a REAL live
# `general-purpose` run (not hand-authored), so this probe's default real-run argument is
# no longer "does our canned answer key parse", but "did the last live calibration run
# flag the defect". Re-running the live reviewer (see README "How to use") and re-checking
# is the only way to freshen that evidence — this script alone cannot.
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
echo "== calibration probe: does the on-disk trace flag the known-bad? (format check, not a live run) =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$TRACE" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — the trace on disk does not flag the known-bad (vacuous or stale)"; exit 1; }
echo "RESULT: GREEN — the trace on disk flags the known-bad (last live calibration run caught it; not a standing guarantee)"
