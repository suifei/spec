#!/usr/bin/env bash
# Validate the exact distributable surface before release or installation.
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
MANIFEST="${2:-$ROOT/scripts/distributable-files.txt}"

check() {
  local root="$1" manifest="$2" fail=0 role path
  [ -f "$manifest" ] || { echo "RED: manifest missing: $manifest"; return 1; }
  while IFS='|' read -r role path; do
    [ -n "$path" ] || continue
    case "$role" in runtime|support) :;; *) echo "RED: invalid manifest role: $role"; fail=1; continue;; esac
    if [ "$role" = runtime ]; then
      case "$path" in
        .claude/skills/spec/*|.claude/skills/build/*|.claude/skills/yolo/*|.claude/commands/spec.md|.claude/commands/build.md|.claude/commands/yolo.md) :;;
        *) echo "RED: runtime path outside transactional install units: $path"; fail=1;;
      esac
    fi
    case "$path" in /*|*..*) echo "RED: unsafe manifest path: $path"; fail=1; continue;; esac
    if [ ! -f "$root/$path" ]; then echo "RED: missing distributable: $path"; fail=1; fi
  done < "$manifest"

  # Runtime completeness is set equality, not a hand-picked required subset.
  # Every file under .claude is product runtime, and every runtime entry must be there.
  local actual_runtime declared_runtime actual_support declared_support
  actual_runtime=$(cd "$root" && find .claude -type f -print | LC_ALL=C sort)
  declared_runtime=$(sed -n 's/^runtime|//p' "$manifest" | LC_ALL=C sort)
  if [ "$actual_runtime" != "$declared_runtime" ]; then
    echo "RED: runtime manifest != complete .claude file set"; fail=1
  fi
  actual_support=$(cd "$root" && { printf '%s\n' CLAUDE_template.md; find scripts -maxdepth 1 -type f -print; } | LC_ALL=C sort)
  declared_support=$(sed -n 's/^support|//p' "$manifest" | LC_ALL=C sort)
  if [ "$actual_support" != "$declared_support" ]; then
    echo "RED: support manifest != complete CLAUDE_template.md + scripts file set"; fail=1
  fi

  grep -q 'references/consistency-lens.md' "$root/.claude/skills/spec/SKILL.md" || { echo "RED: consistency-lens wiring missing"; fail=1; }
  grep -q 'references/coherence.template.sh' "$root/.claude/skills/spec/SKILL.md" || { echo "RED: coherence-template wiring missing"; fail=1; }
  grep -q 'references/probe.template.sh' "$root/.claude/skills/spec/SKILL.md" || { echo "RED: probe-template wiring missing"; fail=1; }
  [ "$fail" -eq 0 ] || return 1
  echo "GREEN: distributable manifest complete ($(grep -c . "$manifest") files; $(grep -c '^runtime|' "$manifest") runtime)"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/root/scripts" "$tmp/root/.claude/skills/spec/references"
  cp scripts/distributable-files.txt "$tmp/root/scripts/"
  cp scripts/install.sh scripts/install.ps1 "$tmp/root/scripts/"
  cp scripts/verify-distribution.sh "$tmp/root/scripts/"
  cp -R .claude "$tmp/root/"
  cp CLAUDE_template.md "$tmp/root/"
  check "$tmp/root" "$tmp/root/scripts/distributable-files.txt" >/dev/null
  rm "$tmp/root/.claude/skills/spec/references/consistency-lens.md"
  if check "$tmp/root" "$tmp/root/scripts/distributable-files.txt" >/dev/null 2>&1; then
    echo "NEG FAIL: missing referenced resource passed"; exit 1
  fi
  echo "neg-control ok: missing referenced resource -> RED"
  cp .claude/skills/spec/references/consistency-lens.md "$tmp/root/.claude/skills/spec/references/"
  cp scripts/distributable-files.txt "$tmp/root/scripts/distributable-files.txt"
  sed '/questioning\.md$/d' "$tmp/root/scripts/distributable-files.txt" > "$tmp/short.manifest"
  if check "$tmp/root" "$tmp/short.manifest" >/dev/null 2>&1; then
    echo "NEG FAIL: runtime manifest omitted a real .claude file"; exit 1
  fi
  echo "neg-control ok: omitted runtime entry -> RED (set inequality)"
  sed '/scripts\/install\.ps1$/d' scripts/distributable-files.txt > "$tmp/no-ps.manifest"
  if check "$tmp/root" "$tmp/no-ps.manifest" >/dev/null 2>&1; then
    echo "NEG FAIL: support manifest omitted PowerShell installer"; exit 1
  fi
  echo "neg-control ok: omitted support entry -> RED (set inequality)"
  cp scripts/distributable-files.txt "$tmp/root/scripts/distributable-files.txt"
  printf 'runtime|extra.txt\n' >> "$tmp/root/scripts/distributable-files.txt"; touch "$tmp/root/extra.txt"
  if check "$tmp/root" "$tmp/root/scripts/distributable-files.txt" >/dev/null 2>&1; then
    echo "NEG FAIL: runtime path outside transactional units passed"; exit 1
  fi
  echo "neg-control ok: unsupported runtime namespace -> RED"
  echo "RESULT: distribution self-test passed"; exit 0
fi

check "$ROOT" "$MANIFEST"
