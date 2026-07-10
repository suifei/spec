#!/usr/bin/env bash
# Probe G12 — release/install distribution completeness.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ "${1:-}" = "--selftest" ]; then
  bash "$ROOT/scripts/verify-distribution.sh" --selftest
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  SPEC_INSTALL_SOURCE="$ROOT" bash "$ROOT/scripts/install.sh" "$tmp/target" >/dev/null
  before=$(shasum -a 256 "$tmp/target/.claude/skills/spec/SKILL.md" "$tmp/target/.claude/spec-install.manifest")
  if SPEC_INSTALL_SOURCE="$ROOT" SPEC_INSTALL_FAIL_AFTER_BACKUP=1 bash "$ROOT/scripts/install.sh" "$tmp/target" >/dev/null 2>&1; then
    echo 'NEG FAIL: injected mid-install failure returned success'; exit 1
  fi
  after=$(shasum -a 256 "$tmp/target/.claude/skills/spec/SKILL.md" "$tmp/target/.claude/spec-install.manifest")
  [ "$before" = "$after" ] || { echo 'NEG FAIL: rollback did not restore payload + install record'; exit 1; }
  echo 'neg-control ok: injected post-backup failure restores prior payload + revision record'
  echo 'RESULT: G12 self-test passed'; exit 0
fi

echo '== probe G12: distribution integrity =='; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo '----'
bash "$ROOT/scripts/verify-distribution.sh" "$ROOT"
grep -q 'scripts/distributable-files.txt' "$ROOT/.github/workflows/release.yml"
grep -q 'verify-distribution.sh' "$ROOT/.github/workflows/release.yml"
grep -q 'distributable-files.txt' "$ROOT/scripts/install.sh"
grep -q 'distributable-files.txt' "$ROOT/scripts/install.ps1"
echo 'RESULT: GREEN — one validated manifest drives release and both installers'
