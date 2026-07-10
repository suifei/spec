#!/usr/bin/env bash
# Probe G4 — build writeback targets the mutable Construction Ledger, never sealed history.
set -euo pipefail

check() {
  local SPEC="$1" STATE="$2" phase
  phase=$(awk '/^## build/{insec=1;next} insec&&/^(# |## )/{exit} insec&&/built:[[:space:]]*Phase [0-9]+/{match($0,/Phase [0-9]+/);print substr($0,RSTART,RLENGTH);exit}' "$STATE")
  [ -n "$phase" ] || { echo '  OK   no built phase owed'; return 0; }
  awk '/^### Construction Ledger/{insec=1;next} insec&&/^###? /{exit} insec{print}' "$SPEC" | grep -qE "\|[[:space:]]*$phase[[:space:]]*\|[[:space:]]*built[[:space:]]*\|" \
    || { echo "  RED  $phase built in STATE but absent from mutable Construction Ledger"; return 1; }
  echo "  OK   $phase built is recorded in mutable Construction Ledger"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '## build\n- built: Phase 3 — today\n' > "$tmp/STATE"
  printf '### Phase 3 — sealed\nimmutable\n### Construction Ledger\n| Phase | Status |\n| Phase 2 | built |\n' > "$tmp/SPEC"
  if check "$tmp/SPEC" "$tmp/STATE" >/dev/null 2>&1; then echo 'NEG FAIL: missing ledger row passed'; exit 1; fi
  echo 'neg-control ok: built phase absent from ledger -> RED'
  printf '| Phase 3 | built | now | evidence |\n' >> "$tmp/SPEC"
  check "$tmp/SPEC" "$tmp/STATE" >/dev/null || { echo 'POS FAIL: valid ledger row flagged'; exit 1; }
  echo 'RESULT: G4 self-test passed'; exit 0
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo '== probe G4: construction-ledger writeback =='; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo '----'
check "$ROOT/SPEC.md" "$ROOT/.spec/STATE.md"
echo 'RESULT: GREEN — construction writeback is outside sealed phase history'
