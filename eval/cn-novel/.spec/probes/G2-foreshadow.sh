#!/usr/bin/env bash
# Probe G2 (R2) — every planted foreshadow is paid off by its deadline chapter (坑不填).
# FORESHADOW:<id> deadline=<n> ... must have PAYOFF:<id> in a chapter <= n. RED if a DUE one dangles.
set -euo pipefail
scan() {
  local ms="$1"; local chapters; chapters=$(ls "$ms"/ch*.md 2>/dev/null | sort || true)
  [ -z "$chapters" ] && { echo "  (no chapters)"; return 1; }
  local max=0 f n; for f in $chapters; do n=$(basename "$f" .md|sed 's/^ch0*//'); [ "$n" -gt "$max" ] && max=$n; done
  local fail=0
  while IFS= read -r rec; do
    [ -z "$rec" ] && continue
    local file="${rec%%:*}" rest="${rec#*:}"; local id="${rest%%:*}" dl="${rest##*:}"
    if [ "$max" -ge "$dl" ]; then
      local paid=0 cf cn
      for cf in $chapters; do cn=$(basename "$cf" .md|sed 's/^ch0*//'); [ "$cn" -le "$dl" ] || continue
        grep -q "PAYOFF:$id\b" "$cf" && { paid=1; break; }; done
      [ "$paid" = 1 ] && echo "  OK   $id due ch$dl — paid" || { echo "  RED  $id due ch$dl — DANGLING"; fail=1; }
    else echo "  wait $id due ch$dl — not due (max ch$max)"; fi
  done < <(grep -oHn 'FORESHADOW:[A-Za-z0-9_]* deadline=[0-9]*' $chapters \
            | sed -E 's/^([^:]+):[0-9]+:FORESHADOW:([A-Za-z0-9_]+) deadline=([0-9]+)/\1:\2:\3/')
  return $fail
}
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '%s\n' '<!-- FORESHADOW:F1 deadline=2 -->' > "$tmp/ch001.md"; printf 'x\n' > "$tmp/ch002.md"
  scan "$tmp" >/dev/null && { echo "NEG FAIL"; exit 1; } || echo "  neg-control ok: dangling RED"
  printf '<!-- PAYOFF:F1 -->\n' > "$tmp/ch002.md"
  scan "$tmp" >/dev/null && echo "  pos-control ok: paid GREEN" || { echo "POS FAIL"; exit 1; }
  echo "RESULT: G2 self-test passed"; exit 0
fi
echo "== probe G2: foreshadow payoff =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
MS="${1:-$(dirname "$0")/../../manuscript}"
scan "$MS" && { echo "RESULT: GREEN"; exit 0; } || { echo "RESULT: RED — 坑不填"; exit 1; }
