#!/usr/bin/env bash
# Probe G9 — /yolo tick ceiling + monotonicity (D-73). The autonomous loop's hard
# cap is enforced structurally, not by honor-system: if STATE.md ## build reports
# an active loop (a `ticks:` field), it must be <= CEILING (default 20, overridable
# via env); and if a ticks log is kept (.spec/evidence/ticks.log), its sequence
# must be non-decreasing — a decrease means a fresh-context tick overwrote the
# counter with a stale value (the ceiling-silently-inflates risk, P2-3). GREEN
# when no loop is active. This is the mechanical backstop for /yolo's fail-safe.
set -euo pipefail

CEILING="${CEILING:-20}"

# extract the ## build section (to the next h1 or EOF)
build_section() { sed -n '/^## build/,/^\(# \|^## \)/p' "$1" | sed '$d'; }

check() {
  local STATE="$1" LOG="${2:-}" fail=0 ticks
  ticks=$(build_section "$STATE" | grep -oiE '^[[:space:]]*-?[[:space:]]*ticks:[[:space:]]*[0-9]+' | grep -oE '[0-9]+' | tail -1 || true)
  if [ -z "$ticks" ]; then
    echo "  OK   no active loop (no ticks field in ## build) — nothing to enforce"; return 0
  fi
  if [ "$ticks" -gt "$CEILING" ]; then
    echo "  RED  ticks=$ticks exceeds ceiling=$CEILING"; fail=1
  else
    echo "  OK   ticks=$ticks <= ceiling=$CEILING"
  fi
  if [ -n "$LOG" ] && [ -f "$LOG" ]; then
    local prev=0 n
    while IFS= read -r line; do
      n=$(printf '%s' "$line" | grep -oE 'ticks:[[:space:]]*[0-9]+' | grep -oE '[0-9]+' || true)
      [ -z "$n" ] && continue
      if [ "$n" -lt "$prev" ]; then echo "  RED  tick log went backwards ($prev -> $n) — stale overwrite"; fail=1; fi
      prev="$n"
    done < "$LOG"
  fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '## build\n- ticks: 25\n- built: x\n## 2.\n' > "$tmp/STATE.md"
  CEILING=20 check "$tmp/STATE.md" "" >/dev/null 2>&1 && { echo "NEG FAIL: over-ceiling not caught"; exit 1; } \
    || echo "  neg-control ok: ticks=25 > ceiling=20 -> RED"
  printf '## build\n- ticks: 5\n- built: x\n' > "$tmp/STATE.md"
  printf 'ticks: 4\nticks: 5\n' > "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && echo "  pos-control ok: ticks=5, non-decreasing log -> GREEN" \
    || { echo "POS FAIL: in-ceiling flagged"; exit 1; }
  printf 'ticks: 5\nticks: 3\n' > "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && { echo "NEG FAIL: backwards log not caught"; exit 1; } \
    || echo "  neg-control ok: log went 5->3 -> RED"
  printf '## build\n- built: none\n' > "$tmp/STATE.md"
  CEILING=20 check "$tmp/STATE.md" "" >/dev/null 2>&1 && echo "  control ok: no active loop -> GREEN" \
    || { echo "CTRL FAIL: no-loop flagged"; exit 1; }
  echo "RESULT: G9 self-test passed (non-vacuous)"; exit 0
fi

STATE="${1:-$(dirname "$0")/../STATE.md}"
LOG="${2:-$(dirname "$0")/../evidence/ticks.log}"
echo "== probe G9: /yolo tick ceiling + monotonicity (D-73) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "  ceiling=$CEILING"; echo "----"
rc=0; check "$STATE" "$LOG" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — tick ceiling breached or counter went backwards"; exit 1; }
echo "RESULT: GREEN — tick ceiling respected (or no active loop)"
