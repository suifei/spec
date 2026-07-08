#!/usr/bin/env bash
# Meta-probe G4 — construction write-back coherence.
# The S1-3 gap: /build finished Phase 2 on 2026-06-30 but the SPEC.md phases ledger was
# not updated for 6 days — caught by an external review, not the pipeline. This probe
# catches that class internally: if STATE.md's `## build` reports something built, the
# SPEC.md phases ledger MUST record a construction write-back. RED if built-but-unrecorded.
# (D-66.)
set -euo pipefail

check() {
  local STATE="$1" SPEC="$2" fail=0 built
  # the `- built:` line inside STATE's `## build` section
  built=$(sed -n '/^## build/,/^# /p' "$STATE" | grep -iE '^- *built:' | head -1 || true)
  if [ -z "$built" ] || grep -qiE 'built: *(none|—|-) *$|built:.*\bnone\b' <<<"$built"; then
    echo "  OK   ## build reports nothing built yet — no write-back owed"; return 0
  fi
  # STATE claims construction happened -> the SPEC phases ledger must record it
  if grep -qiE 'construction[:*]?.*built|✅ *built|built [0-9]{4}-[0-9]{2}-[0-9]{2}' "$SPEC"; then
    echo "  OK   ## build reports built AND SPEC.md phases ledger records the construction write-back"
  else
    echo "  RED  ## build reports construction built, but SPEC.md phases ledger has no 'construction … built' write-back (the S1-3 gap)"; fail=1
  fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # neg-control: STATE says built, SPEC ledger has no write-back -> RED
  printf '## build\n- built: 2026-06-30 — the skill per R1-R5\n' > "$tmp/STATE.md"
  printf '## 7. Phases\n### Phase 2 — status: sealed\n- Goal: the skill\n' > "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: built-but-unrecorded not caught"; exit 1; } \
    || echo "  neg-control ok: built but no ledger write-back -> RED"
  # pos-control: SPEC ledger records the construction -> GREEN
  printf '### Phase 2 — status: sealed · construction: ✅ built 2026-06-30\n' >> "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  pos-control ok: ledger records construction -> GREEN" \
    || { echo "POS FAIL: recorded write-back flagged"; exit 1; }
  # nothing-built control: no write-back owed -> GREEN
  printf '## build\n- built: none\n' > "$tmp/STATE.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  control ok: nothing built -> no write-back owed -> GREEN" \
    || { echo "CTRL FAIL"; exit 1; }
  echo "RESULT: G4-writeback-coherence self-test passed"; exit 0
fi

STATE="${1:-$(dirname "$0")/../STATE.md}"
SPEC="${2:-$(dirname "$0")/../../SPEC.md}"
echo "== meta-probe G4: construction write-back coherence (STATE ## build <-> SPEC phases ledger) =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$STATE" "$SPEC" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — construction built but not written back to the SPEC phases ledger"; exit 1; fi
echo "RESULT: GREEN — build progress is reflected in the SPEC phases ledger"; exit 0
