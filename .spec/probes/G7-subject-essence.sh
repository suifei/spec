#!/usr/bin/env bash
# Probe G7 — subject essence (D-39 "define the noun before the verb", anchored
# D-72). The spec's first content section (§1 / Vision / Subject) must establish
# what the thing *is* from an official/primary source — not assert it from
# memory. RED if §1 carries no authoritative citation. This is a floor proxy for
# "subject established before solutioning" — the skill's self-declared worst
# failure mode finally has a mechanical anchor (P2-1). Honesty limit: a citation
# presence proves the subject was *looked up*, not that it was understood right.
set -euo pipefail

check() {
  local SPEC="$1" section
  # extract §1 (first numbered section); fall back to the document head if unnumbered
  section=$(sed -n '/^## 1\./,/^## 2\./p' "$SPEC")
  [ -z "$section" ] && section=$(sed -n '1,/^## [0-9]\./p' "$SPEC")
  if printf '%s' "$section" | grep -qiE 'https?://|\.spec/knowledge/|sources|来源|official|官方|文档|standards? bod|维护者|maintainer'; then
    echo "  OK   §1 establishes the subject from a cited source"; return 0
  else
    echo "  RED  §1 asserts the subject with no official/primary citation (noun-before-verb unanchored)"; return 1
  fi
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '## 1. Subject\nA construction layer is a bridge. (Sources in .spec/knowledge/x.md.)\n## 2. Scope\nx\n' > "$tmp/S.md"
  check "$tmp/S.md" >/dev/null 2>&1 && echo "  pos-control ok: §1 with source citation -> GREEN" \
    || { echo "POS FAIL: cited §1 flagged"; exit 1; }
  printf '## 1. Subject\nA construction layer is a bridge from spec to code.\n## 2. Scope\nx\n' > "$tmp/S.md"
  check "$tmp/S.md" >/dev/null 2>&1 && { echo "NEG FAIL: bare §1 not caught"; exit 1; } \
    || echo "  neg-control ok: §1 with no citation -> RED"
  echo "RESULT: G7 self-test passed (non-vacuous)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
echo "== probe G7: subject essence (§1 cites an authoritative source) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — §1 asserts the subject without an official/primary citation"; exit 1; }
echo "RESULT: GREEN — §1 establishes the subject from a cited source"
