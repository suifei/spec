#!/usr/bin/env bash
# Probe G-conservation (R7) — 系统 star-force accounting is conserved.
# RED when: a positive LEDGER gain has source=凭空 (star force from nowhere),
# a SYS:upgrade has no matching LEDGER deduction of its cost in the same chapter,
# or a character's running 星力 balance goes negative. Tags: see .spec/knowledge.
set -euo pipefail

scan() {   # scan <manuscript_dir> ; 0 = conserved, 1 = violation
  local ms="$1"; local chapters; chapters=$(ls "$ms"/ch*.md 2>/dev/null | sort || true)
  [ -z "$chapters" ] && { echo "  (no chapters)"; return 1; }
  declare -A BAL; local fail=0 cf cn
  for cf in $chapters; do
    cn=$(basename "$cf" .md | sed 's/^ch0*//')
    # rule A: no 凭空 positive gain
    while IFS= read -r rec; do
      [ -z "$rec" ] && continue
      local name delta source; name="${rec%%|*}"; rec="${rec#*|}"; delta="${rec%%|*}"; source="${rec##*|}"
      if [ "${delta#-}" != "$delta" ]; then :; else # delta >= 0
        if [ "$source" = "凭空" ] || [ "$source" = "无" ]; then echo "  RED ch$cn: $name 星力 +${delta#+} 凭空而来 (不得凭空增加)"; fail=1; fi
      fi
      BAL[$name]=$(( ${BAL[$name]:-0} + ${delta//+/} ))
      if [ "${BAL[$name]}" -lt 0 ]; then echo "  RED ch$cn: $name 星力余额为负 (${BAL[$name]})"; fail=1; fi
    done < <(grep -oE 'LEDGER:name=[^ ]+ [^ ]+ delta=[-+0-9]+ source=[^ ]+' "$cf" \
              | sed -E 's/LEDGER:name=([^ ]+) [^ ]+ delta=([-+0-9]+) source=([^ ]+).*/\1|\2|\3/')
    # rule B: each upgrade has a matching deduction this chapter
    while IFS= read -r up; do
      [ -z "$up" ] && continue
      local uname cost; uname="${up%%|*}"; cost="${up##*|}"
      if ! grep -qE "LEDGER:name=$uname [^ ]+ delta=-$cost " "$cf"; then
        echo "  RED ch$cn: $uname 升级 cost=$cost 无等额扣减 (账目不平)"; fail=1; fi
    done < <(grep -oE 'SYS:upgrade name=[^ ]+ to=[^ ]+ cost=[0-9]+' "$cf" \
              | sed -E 's/SYS:upgrade name=([^ ]+) to=[^ ]+ cost=([0-9]+).*/\1|\2/')
  done
  return $fail
}

if [ "${1:-}" = "--selftest" ]; then
  echo "== G-conservation negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '%s\n' '<!-- LEDGER:name=甲 星力 delta=+80 source=悟道 -->' > "$tmp/ch001.md"
  printf '%s\n' '<!-- SYS:upgrade name=甲 to=淬体2 cost=50 --> <!-- LEDGER:name=甲 星力 delta=-50 source=突破 -->' > "$tmp/ch002.md"
  scan "$tmp" >/dev/null || { echo "POS CONTROL FAILED: conserved ledger RED"; exit 1; }
  echo "  pos-control ok: conserved ledger GREEN"
  printf '%s\n' '<!-- LEDGER:name=甲 星力 delta=+500 source=凭空 -->' > "$tmp/ch003.md"
  if scan "$tmp" >/dev/null; then echo "NEG CONTROL FAILED: 凭空 gain GREEN"; exit 1; fi
  echo "  neg-control ok: 凭空 gain RED"
  printf '%s\n' '<!-- SYS:upgrade name=甲 to=淬体3 cost=200 -->' > "$tmp/ch003.md"
  if scan "$tmp" >/dev/null; then echo "NEG CONTROL FAILED: upgrade w/o deduction GREEN"; exit 1; fi
  echo "  neg-control ok: upgrade without deduction RED"
  echo "RESULT: G-conservation self-test passed"; exit 0
fi

echo "== probe G-conservation (R7): star-force accounting conserved =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"
if scan "$MS_DIR"; then echo "----"; echo "RESULT: GREEN — 账目守恒"; exit 0
else echo "----"; echo "RESULT: RED — 数值崩坏 (R7 violated)"; exit 1; fi
