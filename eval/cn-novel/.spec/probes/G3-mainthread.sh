#!/usr/bin/env bash
# Probe G3 (R3) — the main thread advances at least every 2 chapters (主线拖沓).
# RED when any gap of >1 consecutive chapter lacks a THREAD:main tag.
set -euo pipefail
scan() {
  local ms="$1" maxgap="${2:-1}"; local chapters; chapters=$(ls "$ms"/ch*.md 2>/dev/null | sort || true)
  [ -z "$chapters" ] && { echo "  (no chapters)"; return 1; }
  local gap=0 fail=0 cf cn
  for cf in $chapters; do cn=$(basename "$cf" .md|sed 's/^ch0*//')
    if grep -q 'THREAD:main' "$cf"; then echo "  ch$cn: advances"; gap=0
    else gap=$((gap+1)); echo "  ch$cn: (stall) gap=$gap"; [ "$gap" -gt "$maxgap" ] && { echo "  RED gap=$gap"; fail=1; }; fi
  done; return $fail
}
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf 'x <!-- THREAD:main -->\n' > "$tmp/ch001.md"; printf 'n\n' > "$tmp/ch002.md"; printf 'n\n' > "$tmp/ch003.md"
  scan "$tmp" 1 >/dev/null && { echo "NEG FAIL"; exit 1; } || echo "  neg-control ok: 2-stall RED"
  printf 'y <!-- THREAD:main -->\n' > "$tmp/ch002.md"
  scan "$tmp" 1 >/dev/null && echo "  pos-control ok: GREEN" || { echo "POS FAIL"; exit 1; }
  echo "RESULT: G3 self-test passed"; exit 0
fi
echo "== probe G3: main thread advance =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
MS="${1:-$(dirname "$0")/../../manuscript}"
scan "$MS" 1 && { echo "RESULT: GREEN"; exit 0; } || { echo "RESULT: RED — 主线拖沓"; exit 1; }
