#!/usr/bin/env bash
# Probe G1 — no planted mystery is left dangling past its deadline chapter.
# Gate (load-bearing): the fair-play mystery contract. Every ANCHOR:<id> planted in the
# manuscript must have a matching PAYOFF:<id> in a chapter <= its deadline. This can REFUTE
# the assumption "the draft honors its setups" and force a rewrite — so it earns a gate.
# Convention: chapters are manuscript/chNN.md; tags live in HTML comments (see .spec/knowledge).
set -euo pipefail

# --- core: scan a manuscript dir; exit 0 = every DUE anchor paid off, 1 = a dangling anchor ---
scan_dir() {
  local dir="$1"
  local chapters; chapters=$(ls "$dir"/ch*.md 2>/dev/null | sort || true)
  if [ -z "$chapters" ]; then echo "  (no chapters in $dir)"; return 1; fi

  local max_ch=0 f n
  for f in $chapters; do n=$(basename "$f" .md | sed 's/^ch0*//'); [ "$n" -gt "$max_ch" ] && max_ch=$n; done
  echo "  chapters present: up to ch$max_ch"

  local fail=0
  while IFS= read -r rec; do
    [ -z "$rec" ] && continue
    local file="${rec%%:*}" rest="${rec#*:}"; local id="${rest%%:*}" deadline="${rest##*:}"
    local planted; planted=$(basename "$file" .md | sed 's/^ch0*//')
    if [ "$max_ch" -ge "$deadline" ]; then                 # deadline has arrived
      local paid=0 cf cn
      for cf in $chapters; do
        cn=$(basename "$cf" .md | sed 's/^ch0*//'); [ "$cn" -le "$deadline" ] || continue
        if grep -q "PAYOFF:$id\b" "$cf"; then paid=1; break; fi
      done
      if [ "$paid" -eq 1 ]; then echo "  OK   $id (planted ch$planted, due ch$deadline) — paid off"
      else echo "  RED  $id (planted ch$planted, due ch$deadline) — DANGLING past deadline"; fail=1; fi
    else
      echo "  wait $id (planted ch$planted, due ch$deadline) — not due yet"
    fi
  done < <(grep -oHn 'ANCHOR:[A-Za-z0-9_]* deadline=[0-9]*' $chapters \
            | sed -E 's/^([^:]+):[0-9]+:ANCHOR:([A-Za-z0-9_]+) deadline=([0-9]+)/\1:\2:\3/')
  return $fail
}

# --- negative control (self-test): a dangling anchor MUST go red; a resolved one MUST go green ---
if [ "${1:-}" = "--selftest" ]; then
  echo "== G1 negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '%s\n' '<!-- ANCHOR:X deadline=2 desc="test" -->' 'body' > "$tmp/ch01.md"
  printf '%s\n' 'no payoff here' > "$tmp/ch02.md"     # X is due by ch2 but unpaid -> must be RED
  if scan_dir "$tmp"; then echo "NEG CONTROL FAILED: dangling anchor reported GREEN"; exit 1; fi
  echo "  neg-control ok: dangling anchor correctly RED"
  printf '%s\n' 'resolved <!-- PAYOFF:X -->' > "$tmp/ch02.md"   # now resolved -> must be GREEN
  if scan_dir "$tmp"; then echo "  pos-control ok: resolved anchor correctly GREEN";
  else echo "POS CONTROL FAILED: resolved anchor reported RED"; exit 1; fi
  echo "RESULT: G1 self-test passed (probe can go red AND green)"; exit 0
fi

echo "== probe G1: mystery anchors resolved by deadline =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"
if scan_dir "$MS_DIR"; then
  echo "----"; echo "RESULT: GREEN — every due mystery is paid off by its deadline"; exit 0
else
  echo "----"; echo "RESULT: RED — at least one mystery dangling past its deadline"; exit 1
fi
