#!/usr/bin/env bash
# Probe G-infoboundary (R9, law 6) — no character acts on information it has no in-story way to know.
# The MECHANICAL FLOOR for the information-boundary gate (the subtle cases stay WEAK/intent-review).
# Tags: <!-- KNOWS:char=X fact=F -->  X legitimately learns F this chapter
#       <!-- FOREKNOW:char=陆沉 fact=F -->  licensed rebirth foreknowledge (bounded — WEAK judges the bound)
#       <!-- COMMON:fact=F -->  common knowledge, everyone may use it
#       <!-- USES:char=Y fact=F -->  Y acts on / reveals F
# RED when a USES(Y,F) has no prior (or same-chapter) KNOWS(Y,F)/FOREKNOW(Y,F)/COMMON(F) — a knowledge leak.
set -euo pipefail

scan() {  # scan <dir>; 0 = no leak, 1 = leak
  local ms="$1"; local chapters; chapters=$(ls "$ms"/ch*.md 2>/dev/null | sort || true)
  [ -z "$chapters" ] && { echo "  (no chapters)"; return 1; }
  declare -A KNOWN   # "char|fact" -> 1 ; and "*|fact" for COMMON
  local fail=0 cf cn
  for cf in $chapters; do
    cn=$(basename "$cf" .md | sed 's/^ch0*//')
    # first, this chapter's acquisitions become known (same-chapter learning counts)
    while IFS= read -r r; do [ -n "$r" ] && KNOWN["$r"]=1; done < <(grep -oE 'KNOWS:char=[^ ]+ fact=[^ ]+' "$cf" | sed -E 's/KNOWS:char=([^ ]+) fact=([^ ]+)/\1|\2/')
    while IFS= read -r r; do [ -n "$r" ] && KNOWN["$r"]=1; done < <(grep -oE 'FOREKNOW:char=[^ ]+ fact=[^ ]+' "$cf" | sed -E 's/FOREKNOW:char=([^ ]+) fact=([^ ]+)/\1|\2/')
    while IFS= read -r f; do [ -n "$f" ] && KNOWN["*|$f"]=1; done < <(grep -oE 'COMMON:fact=[^ ]+' "$cf" | sed -E 's/COMMON:fact=([^ ]+)/\1/')
    # then check uses
    while IFS= read -r rec; do
      [ -z "$rec" ] && continue
      local ch="${rec%%|*}" fact="${rec##*|}"
      if [ -n "${KNOWN["$ch|$fact"]:-}" ] || [ -n "${KNOWN["*|$fact"]:-}" ]; then
        echo "  OK   ch$cn: $ch uses '$fact' — known"
      else
        echo "  RED  ch$cn: $ch uses '$fact' — NEVER learned it (信息泄漏)"; fail=1
      fi
    done < <(grep -oE 'USES:char=[^ ]+ fact=[^ ]+' "$cf" | sed -E 's/USES:char=([^ ]+) fact=([^ ]+)/\1|\2/')
  done
  return $fail
}

if [ "${1:-}" = "--selftest" ]; then
  echo "== G-infoboundary negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '%s\n' '<!-- KNOWS:char=甲 fact=密约 --> <!-- USES:char=甲 fact=密约 -->' > "$tmp/ch001.md"
  scan "$tmp" >/dev/null || { echo "POS CONTROL FAILED: legit use RED"; exit 1; }
  echo "  pos-control ok: learned-then-used GREEN"
  printf '%s\n' '<!-- USES:char=乙 fact=密约 -->' > "$tmp/ch002.md"   # 乙 never learned 密约
  if scan "$tmp" >/dev/null; then echo "NEG CONTROL FAILED: leak GREEN"; exit 1; fi
  echo "  neg-control ok: use-without-learning RED"
  echo "RESULT: G-infoboundary self-test passed"; exit 0
fi

echo "== probe G-infoboundary (R9): no knowledge leak =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"
if scan "$MS_DIR"; then echo "----"; echo "RESULT: GREEN — no knowledge leak (among tagged facts)"; exit 0
else echo "----"; echo "RESULT: RED — a character used info it never learned"; exit 1; fi
