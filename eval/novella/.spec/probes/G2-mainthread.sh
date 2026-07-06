#!/usr/bin/env bash
# Probe G2 — the investigative main thread advances at least every 2 chapters.
# Gate (load-bearing): a whodunit that stalls for a stretch has abandoned its spine. RED when
# any gap of > 1 consecutive chapter lacks a THREAD:main tag. Refutes "the investigation keeps
# moving" and would force a restructure — gate-worthy. (Quality of the advance is WEAK, not here.)
set -euo pipefail

scan_dir() {
  local dir="$1" maxgap="${2:-1}"
  local chapters; chapters=$(ls "$dir"/ch*.md 2>/dev/null | sort || true)
  if [ -z "$chapters" ]; then echo "  (no chapters in $dir)"; return 1; fi
  local gap=0 fail=0 cf cn
  for cf in $chapters; do
    cn=$(basename "$cf" .md | sed 's/^ch0*//')
    if grep -q 'THREAD:main' "$cf"; then echo "  ch$cn: thread advances"; gap=0
    else gap=$((gap+1)); echo "  ch$cn: (no advance) gap=$gap"
         if [ "$gap" -gt "$maxgap" ]; then echo "  RED  gap of $gap chapters with no main-thread advance"; fail=1; fi
    fi
  done
  return $fail
}

if [ "${1:-}" = "--selftest" ]; then
  echo "== G2 negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf 'x <!-- THREAD:main -->\n' > "$tmp/ch01.md"
  printf 'nothing\n' > "$tmp/ch02.md"; printf 'nothing\n' > "$tmp/ch03.md"  # gap of 2 -> RED
  if scan_dir "$tmp" 1; then echo "NEG CONTROL FAILED: 2-chapter stall reported GREEN"; exit 1; fi
  echo "  neg-control ok: main-thread stall correctly RED"
  printf 'y <!-- THREAD:main -->\n' > "$tmp/ch02.md"                          # now advances -> GREEN
  if scan_dir "$tmp" 1; then echo "  pos-control ok: advancing thread correctly GREEN";
  else echo "POS CONTROL FAILED"; exit 1; fi
  echo "RESULT: G2 self-test passed"; exit 0
fi

echo "== probe G2: main thread advances every <=2 chapters =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"
if scan_dir "$MS_DIR" 1; then
  echo "----"; echo "RESULT: GREEN — no main-thread stall"; exit 0
else
  echo "----"; echo "RESULT: RED — the investigation stalled"; exit 1
fi
