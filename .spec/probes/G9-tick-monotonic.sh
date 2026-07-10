#!/usr/bin/env bash
# Probe G9 — /yolo run-isolated tick lifecycle (Phase 3 / D8).
set -euo pipefail

build_section() {
  awk '/^## build/{insec=1;print;next} insec&&/^(# |## )/{exit} insec{print}' "$1"
}

field() { build_section "$1" | sed -nE "s/^[[:space:]]*-[[:space:]]*$2:[[:space:]]*(.*)/\1/p" | tail -1; }

check() {
  local STATE="$1" ROOT="$2" run job status ceiling rel ticks n fail=0
  run=$(field "$STATE" run_id); status=$(field "$STATE" run_status)
  job=$(field "$STATE" job_id)
  ceiling=$(field "$STATE" ceiling); rel=$(field "$STATE" tick_log); ticks=$(field "$STATE" ticks)
  if [ -z "$run$job$status$ceiling$rel$ticks" ]; then echo '  OK   no yolo run'; return 0; fi
  [ -n "$run" ] && [ -n "$job" ] && [ -n "$status" ] && [ -n "$ceiling" ] && [ -n "$rel" ] && [ -n "$ticks" ] || { echo '  RED  partial yolo run state'; return 1; }
  case "$status" in active|done|blocked|stuck|ceiling|stopped) :;; *) echo "  RED  invalid run_status=$status"; return 1;; esac
  case "$ceiling$ticks" in *[!0-9]*) echo '  RED  ceiling/ticks must be integers'; return 1;; esac
  [ "$ceiling" -gt 0 ] || { echo '  RED  ceiling must be positive'; return 1; }
  [ "$rel" = ".spec/evidence/yolo/$run/ticks.log" ] || { echo "  RED  tick_log is not isolated to run_id=$run"; return 1; }
  [ -f "$ROOT/$rel" ] || { echo "  RED  tick_log missing: $rel"; return 1; }
  n=$(wc -l < "$ROOT/$rel" | tr -d ' ')
  [ "$n" -eq "$ticks" ] || { echo "  RED  ticks=$ticks but log=$n"; fail=1; }
  [ "$n" -le "$ceiling" ] || { echo "  RED  log=$n exceeds ceiling=$ceiling"; fail=1; }
  [ "$status" != active ] || [ "$n" -lt "$ceiling" ] || { echo '  RED  active run is already at ceiling and should have terminated'; fail=1; }
  [ "$status" != ceiling ] || [ "$n" -eq "$ceiling" ] || { echo '  RED  ceiling status does not match count'; fail=1; }
  [ "$fail" -eq 0 ] && echo "  OK   run=$run status=$status ticks=$n/$ceiling"
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/.spec/evidence/yolo/run-a"
  printf 'x\nx\n' > "$tmp/.spec/evidence/yolo/run-a/ticks.log"
  printf '## build\n- run_id: run-a\n- job_id: job-1\n- run_status: active\n- ceiling: 3\n- tick_log: .spec/evidence/yolo/run-a/ticks.log\n- ticks: 2\n' > "$tmp/STATE"
  check "$tmp/STATE" "$tmp" >/dev/null || { echo 'POS FAIL: valid isolated run flagged'; exit 1; }
  printf 'x\nx\n' >> "$tmp/.spec/evidence/yolo/run-a/ticks.log"
  if check "$tmp/STATE" "$tmp" >/dev/null 2>&1; then echo 'NEG FAIL: over-ceiling run passed'; exit 1; fi
  echo 'neg-control ok: over-ceiling run -> RED'
  printf 'x\nx\n' > "$tmp/.spec/evidence/yolo/run-a/ticks.log"
  sed '/job_id:/d' "$tmp/STATE" > "$tmp/nojob"
  if check "$tmp/nojob" "$tmp" >/dev/null 2>&1; then echo 'NEG FAIL: missing job_id passed'; exit 1; fi
  echo 'neg-control ok: missing job_id -> RED'
  sed 's/run_status: active/run_status: nonsense/' "$tmp/STATE" > "$tmp/badstatus"
  if check "$tmp/badstatus" "$tmp" >/dev/null 2>&1; then echo 'NEG FAIL: invalid status passed'; exit 1; fi
  echo 'neg-control ok: invalid run_status -> RED'
  sed 's#yolo/run-a#yolo/run-b#' "$tmp/STATE" > "$tmp/cross"
  if check "$tmp/cross" "$tmp" >/dev/null 2>&1; then echo 'NEG FAIL: cross-run log passed'; exit 1; fi
  echo 'neg-control ok: cross-run log reuse -> RED'
  echo 'RESULT: G9 self-test passed'; exit 0
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo '== probe G9: isolated /yolo tick lifecycle =='; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo '----'
check "$ROOT/.spec/STATE.md" "$ROOT"
echo 'RESULT: GREEN — yolo run state is absent or isolated and within ceiling'
