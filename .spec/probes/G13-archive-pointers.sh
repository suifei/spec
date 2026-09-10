#!/usr/bin/env bash
# Probe G13 — sealed history compacted by reference must still RESOLVE (D-87).
# Step 7 moves a sealed phase's body to .spec/archive/phase-<N>.md and leaves a stub
# in SPEC.md; Decision Log rows nothing current cites move with it. That is only
# safe if every pointer still lands somewhere. RED on any of:
#   (a) a `.spec/archive/<file>.md` path cited in SPEC.md that does not exist;
#   (b) a `supersedes … Phase K` / `阶段K` reference naming a phase with no
#       `### Phase K` heading in SPEC.md (stub or full);
#   (c) a local decision ID (`D<n>`, no hyphen — SPEC.md's own Decision Log
#       namespace) cited anywhere in SPEC.md that exists as a `| D<n> |` row neither
#       in SPEC.md nor in any .spec/archive/*.md file.
# `D-NN` (hyphenated) IDs are docs/DESIGN-NOTES.md's journal namespace, checked only
# when that journal exists. Without this gate, archiving is an honor-system rule.
set -euo pipefail

check() {
  local SPEC="$1" ROOT="$2" fail=0 p k id notes
  # (a) archive pointers resolve
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    if [ -f "$ROOT/$p" ]; then echo "  OK   archive pointer resolves: $p"
    else echo "  RED  dangling archive pointer: $p (cited in SPEC.md, no such file)"; fail=1; fi
  done < <(grep -oE '\.spec/archive/[A-Za-z0-9_./-]+\.md' "$SPEC" | sort -u)

  # (b) supersedes references name an existing phase heading
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    if grep -qE "^### Phase $k([^0-9]|$)" "$SPEC"; then echo "  OK   supersedes → Phase $k exists"
    else echo "  RED  'supersedes' names Phase $k but SPEC.md has no '### Phase $k' heading (stub missing)"; fail=1; fi
  done < <(grep -oiE 'supersedes[^.|]*' "$SPEC" | grep -oE '(Phase[[:space:]]*|阶段)[0-9]+' | grep -oE '[0-9]+' | sort -u)

  # (c) cited local decision IDs exist in SPEC.md's log or the archive
  while IFS= read -r id; do
    [ -z "$id" ] && continue
    if grep -qE "^\| *$id *\|" "$SPEC" || { ls "$ROOT"/.spec/archive/*.md >/dev/null 2>&1 && cat "$ROOT"/.spec/archive/*.md | grep -qE "^\| *$id *\|"; }; then
      :
    else echo "  RED  decision $id is cited in SPEC.md but defined neither in its Decision Log nor in .spec/archive/"; fail=1; fi
  done < <(grep -oE '\bD[0-9]+\b' "$SPEC" | sort -u)
  [ "$fail" -eq 0 ] && echo "  OK   every cited local decision ID (D<n>) resolves (SPEC.md log or archive)"

  # journal namespace (optional): D-NN cited in SPEC.md must be a row in DESIGN-NOTES
  notes="$ROOT/docs/DESIGN-NOTES.md"
  if [ -f "$notes" ]; then
    while IFS= read -r id; do
      [ -z "$id" ] && continue
      grep -qE "^\| *$id *\|" "$notes" || { echo "  RED  $id cited in SPEC.md but not a row in docs/DESIGN-NOTES.md"; fail=1; }
    done < <(grep -oE '\bD-[0-9]+\b' "$SPEC" | sort -u)
  fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/.spec/archive"
  good() { printf '%s\n' \
    '| D1 | x | y | z | [auto] | 2026-01-01 |' \
    '- **R1.** [locked] thing *(D1; D2)*' \
    '### Phase 1 — a · status: sealed · full text: `.spec/archive/phase-1.md`' \
    '### Phase 2 — b · status: open' \
    '- **Supersedes:** 阶段1 的第2条' > "$tmp/SPEC.md"; }
  good; printf '### Phase 1\n## Decisions\n| D2 | archived | y | z | [auto] | 2026-01-01 |\n' > "$tmp/.spec/archive/phase-1.md"
  check "$tmp/SPEC.md" "$tmp" >/dev/null 2>&1 && echo "  pos-control ok: pointer + supersedes + archived D2 all resolve -> GREEN" \
    || { echo "POS FAIL: clean set flagged"; check "$tmp/SPEC.md" "$tmp"; exit 1; }
  rm "$tmp/.spec/archive/phase-1.md"
  check "$tmp/SPEC.md" "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: dangling archive pointer not caught"; exit 1; } \
    || echo "  neg-control ok: archive file deleted -> dangling pointer + orphan D2 -> RED"
  printf '### Phase 1\n## Decisions\n| D2 | archived | y | z | [auto] | 2026-01-01 |\n' > "$tmp/.spec/archive/phase-1.md"
  sed -i 's/阶段1 的第2条/阶段9 的第2条/' "$tmp/SPEC.md"
  check "$tmp/SPEC.md" "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: supersedes → missing phase not caught"; exit 1; } \
    || echo "  neg-control ok: supersedes names Phase 9 with no stub -> RED"
  good; printf '### Phase 1\n' > "$tmp/.spec/archive/phase-1.md"
  check "$tmp/SPEC.md" "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: cited D2 defined nowhere not caught"; exit 1; } \
    || echo "  neg-control ok: D2 cited, defined in neither log nor archive -> RED"
  echo "RESULT: G13 self-test passed (non-vacuous)"; exit 0
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SPEC="${1:-$ROOT/SPEC.md}"
echo "== probe G13: archive pointers / supersedes / cited decisions resolve (D-87) =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$ROOT" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — sealed history was compacted but a pointer no longer resolves"; exit 1; }
echo "RESULT: GREEN — every archive pointer, supersedes reference and cited decision ID resolves"
