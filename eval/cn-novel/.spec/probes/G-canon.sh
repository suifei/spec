#!/usr/bin/env bash
# Probe G-canon — the manuscript never contradicts established canon.
# Gate (load-bearing): a long serial fails by consistency collapse. This scans <!-- CANON:... -->
# tags across chapters and goes RED on: (a) a name not in the glossary (姓名漂移),
# (b) a 境界 that decreases or names a tier outside the ladder (数值/体系崩坏),
# (c) an immutable attribute (瞳色/出身…) whose value changes (人设/设定矛盾).
# Convention: manuscript/chNNN.md; canon in .spec/canon/. See .spec/knowledge/genre-and-canon.md.
set -euo pipefail

scan() {   # scan <manuscript_dir> <canon_dir> ; exit 0 = consistent, 1 = contradiction
  local ms="$1" canon="$2"
  local chapters; chapters=$(ls "$ms"/ch*.md 2>/dev/null | sort || true)
  if [ -z "$chapters" ]; then echo "  (no chapters in $ms)"; return 1; fi

  # load power ladder ordinals
  declare -A LADDER; local i=0 t
  while IFS= read -r t; do [ -z "$t" ] && continue; i=$((i+1)); LADDER["$t"]=$i; done < "$canon/power-ladder.txt"
  # load glossary names (non-comment, non-empty)
  local glossary; glossary=$(grep -v '^#' "$canon/glossary.txt" | grep -v '^[[:space:]]*$' || true)

  declare -A PREV_ORD    # name -> last 境界 ordinal
  declare -A IMMUT       # name|attr -> value
  local fail=0 cf cn
  for cf in $chapters; do
    cn=$(basename "$cf" .md | sed 's/^ch0*//')
    while IFS= read -r rec; do
      [ -z "$rec" ] && continue
      # rec: name<TAB>attr<TAB>val
      local name attr val; name="${rec%%$'\t'*}"; rec="${rec#*$'\t'}"; attr="${rec%%$'\t'*}"; val="${rec##*$'\t'}"
      # (a) name in glossary?
      if ! grep -qxF "$name" <<<"$glossary"; then echo "  RED ch$cn: name '$name' not in glossary (drift)"; fail=1; fi
      if [ "$attr" = "境界" ]; then
        local tier num ord; tier="${val%%[0-9]*}"; num="${val//[!0-9]/}"; num="${num:-0}"
        if [ -z "${LADDER[$tier]:-}" ]; then echo "  RED ch$cn: $name 境界 tier '$tier' not in ladder"; fail=1
        else ord=$(( LADDER[$tier]*100 + num ))
          if [ -n "${PREV_ORD[$name]:-}" ] && [ "$ord" -lt "${PREV_ORD[$name]}" ]; then
            echo "  RED ch$cn: $name 境界 went DOWN ($val < prev) — 数值崩坏"; fail=1
          fi
          PREV_ORD[$name]=$ord
        fi
      else   # immutable attribute
        local key="$name|$attr"
        if [ -n "${IMMUT[$key]:-}" ] && [ "${IMMUT[$key]}" != "$val" ]; then
          echo "  RED ch$cn: $name $attr changed '${IMMUT[$key]}' -> '$val' — 人设/设定矛盾"; fail=1
        else IMMUT[$key]="$val"; fi
      fi
    done < <(grep -oE 'CANON:name=[^ ]+ attr=[^ ]+ val=[^ ]+' "$cf" \
              | sed -E 's/CANON:name=([^ ]+) attr=([^ ]+) val=([^ ]+).*/\1\t\2\t\3/')
  done
  return $fail
}

if [ "${1:-}" = "--selftest" ]; then
  echo "== G-canon negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/ms" "$tmp/canon"
  printf '%s\n' 淬体 通脉 凝罡 > "$tmp/canon/power-ladder.txt"
  printf '%s\n' '# g' 陆沉 > "$tmp/canon/glossary.txt"
  # consistent baseline -> GREEN
  printf '%s\n' '<!-- CANON:name=陆沉 attr=境界 val=淬体1 --> <!-- CANON:name=陆沉 attr=瞳色 val=墨金 -->' > "$tmp/ms/ch001.md"
  printf '%s\n' '<!-- CANON:name=陆沉 attr=境界 val=通脉2 -->' > "$tmp/ms/ch002.md"
  scan "$tmp/ms" "$tmp/canon" >/dev/null || { echo "POS CONTROL FAILED: consistent manuscript RED"; exit 1; }
  echo "  pos-control ok: consistent manuscript GREEN"
  # inject a 境界 downgrade -> must be RED
  printf '%s\n' '<!-- CANON:name=陆沉 attr=境界 val=淬体1 -->' > "$tmp/ms/ch003.md"
  if scan "$tmp/ms" "$tmp/canon" >/dev/null; then echo "NEG CONTROL FAILED: downgrade GREEN"; exit 1; fi
  echo "  neg-control ok: 境界 downgrade RED"
  rm "$tmp/ms/ch003.md"
  # inject an immutable-attr contradiction -> must be RED
  printf '%s\n' '<!-- CANON:name=陆沉 attr=瞳色 val=赤金 -->' > "$tmp/ms/ch003.md"
  if scan "$tmp/ms" "$tmp/canon" >/dev/null; then echo "NEG CONTROL FAILED: 瞳色 change GREEN"; exit 1; fi
  echo "  neg-control ok: 瞳色 contradiction RED"
  # inject an off-glossary name -> must be RED
  printf '%s\n' '<!-- CANON:name=某路人 attr=境界 val=淬体1 -->' > "$tmp/ms/ch003.md"
  if scan "$tmp/ms" "$tmp/canon" >/dev/null; then echo "NEG CONTROL FAILED: off-glossary name GREEN"; exit 1; fi
  echo "  neg-control ok: off-glossary name RED"
  echo "RESULT: G-canon self-test passed (probe can go red AND green)"; exit 0
fi

echo "== probe G-canon: manuscript honors canon =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"; CANON_DIR="${2:-$(dirname "$0")/../canon}"
if scan "$MS_DIR" "$CANON_DIR"; then
  echo "----"; echo "RESULT: GREEN — no canon contradiction"; exit 0
else
  echo "----"; echo "RESULT: RED — canon contradicted"; exit 1
fi
