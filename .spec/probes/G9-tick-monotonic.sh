#!/usr/bin/env bash
# Probe G9 — /yolo tick ceiling, audited from the append-only trail (D-73, revised D-74).
# The loop's tick count IS the line count of .spec/evidence/ticks.log: each firing's
# FIRST action appends one line and takes n = wc -l as its tick number (the append is
# the increment — a fresh context cannot "forget to increment" and loop forever, the
# stalled-counter hole a mutable field left open). The `ticks:` field in ## build is a
# MIRROR of that count, not the counter. This probe is the after-the-fact audit:
#   RED if  (a) the log exceeds the ceiling (loop failed to stop),
#           (b) ## build claims an active loop (`ticks:` field) but no log exists
#               (the counter has no producer — dead wiring), or
#           (c) the mirror disagrees with the log (a firing wrote a stale/false count).
# Honesty: the in-loop STOP is executor-honored (yolo/SKILL.md makes it the firing's
# first action); what this probe guarantees is that a violation leaves visible red,
# not that it cannot happen. GREEN when no loop is active and no log residue conflicts.
set -euo pipefail

CEILING="${CEILING:-20}"

# Robust to `## build` being the LAST section in the file (no trailing header to bound
# it) — a sed-range + "delete last line" trick silently drops real content in that case
# (caught by this probe's own selftest fixture); awk with an explicit in-section flag
# has no such edge case.
build_section() {
  awk '
    /^## build/ { insec=1; print; next }
    insec && /^(# |## )/ { exit }
    insec { print }
  ' "$1"
}

check() {
  local STATE="$1" LOG="$2" fail=0 field n
  field=$(build_section "$STATE" | grep -oiE '^[[:space:]]*-?[[:space:]]*ticks:[[:space:]]*[0-9]+' | grep -oE '[0-9]+' | tail -1 || true)
  if [ -f "$LOG" ]; then n=$(wc -l < "$LOG" | tr -d ' '); else n=""; fi

  if [ -z "$field" ] && [ -z "$n" ]; then
    echo "  OK   no active loop (no ticks field, no ticks.log) — nothing to enforce"; return 0
  fi
  if [ -n "$field" ] && [ -z "$n" ]; then
    echo "  RED  ## build claims an active loop (ticks: $field) but $LOG does not exist — counter has no producer (dead wiring)"; return 1
  fi
  # log exists
  if [ "$n" -gt "$CEILING" ]; then
    echo "  RED  ticks.log has $n lines > ceiling=$CEILING — the loop failed to stop at the cap"; fail=1
  else
    echo "  OK   ticks.log lines=$n <= ceiling=$CEILING"
  fi
  if [ -n "$field" ]; then
    if [ "$field" -ne "$n" ]; then
      echo "  RED  ## build ticks: $field disagrees with ticks.log line count $n — stale/false mirror"; fail=1
    else
      echo "  OK   ## build ticks: field mirrors the log ($field)"
    fi
  else
    echo "  OK   log present, no ticks: field — finished loop's residue (mirror removed on delete)"
  fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # neg (a): log over ceiling -> RED
  printf '## build\n- ticks: 21\n' > "$tmp/STATE.md"
  for i in $(seq 21); do echo "[t] tick"; done > "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && { echo "NEG FAIL: over-ceiling log not caught"; exit 1; } \
    || echo "  neg-control ok: 21-line log > ceiling=20 -> RED"
  # neg (b): field claims a loop, no log producer -> RED
  printf '## build\n- ticks: 5\n' > "$tmp/STATE.md"; rm -f "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && { echo "NEG FAIL: no-producer not caught"; exit 1; } \
    || echo "  neg-control ok: ticks field with no ticks.log -> RED (dead wiring)"
  # neg (c): mirror disagrees with log -> RED
  printf '[t] tick\n[t] tick\n[t] tick\n' > "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && { echo "NEG FAIL: stale mirror not caught"; exit 1; } \
    || echo "  neg-control ok: field=5 vs log=3 -> RED (stale mirror)"
  # pos: consistent, under ceiling -> GREEN
  printf '## build\n- ticks: 3\n' > "$tmp/STATE.md"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && echo "  pos-control ok: field=3 == log=3 <= 20 -> GREEN" \
    || { echo "POS FAIL: consistent state flagged"; exit 1; }
  # control: no loop at all -> GREEN
  printf '## build\n- built: none\n' > "$tmp/STATE.md"; rm -f "$tmp/ticks.log"
  CEILING=20 check "$tmp/STATE.md" "$tmp/ticks.log" >/dev/null 2>&1 && echo "  control ok: no loop -> GREEN" \
    || { echo "CTRL FAIL"; exit 1; }
  echo "RESULT: G9 self-test passed (non-vacuous)"; exit 0
fi

STATE="${1:-$(dirname "$0")/../STATE.md}"
LOG="${2:-$(dirname "$0")/../evidence/ticks.log}"
echo "== probe G9: /yolo tick ceiling audited from append-only ticks.log =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "  ceiling=$CEILING"; echo "----"
rc=0; check "$STATE" "$LOG" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — ceiling breached, counter unproduced, or mirror stale"; exit 1; }
echo "RESULT: GREEN — tick trail consistent and within ceiling (or no active loop)"
