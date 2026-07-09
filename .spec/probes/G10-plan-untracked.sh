#!/usr/bin/env bash
# Probe G10 — the ephemeral-plan convention (R2) is mechanically real, not just prose.
# R2 says /build's design/tasks plan is regenerated each run and never committed as a
# source of truth; `.spec/plan/` is the gitignored scratch location. That gitignore
# convention IS checkable (git check-ignore + no tracked files under it) — the
# clean-context audit flagged R2 as WEAK(cited) with no mechanical gate even though this
# half is constructible. RED if `.spec/plan/` is NOT ignored, or if any file under it is
# tracked by git (the plan hardened into a committed source of truth — exactly what R2
# forbids). The semantic half ("never treated as authoritative") stays WEAK — this only
# gates the mechanical half. (D-74.)
set -euo pipefail

check() {
  local REPO="$1" fail=0 tracked
  ( cd "$REPO" && git rev-parse --is-inside-work-tree >/dev/null 2>&1 ) || { echo "  RED  not a git repo: $REPO"; return 1; }

  if ( cd "$REPO" && git check-ignore -q .spec/plan/ 2>/dev/null ); then
    echo "  OK   .spec/plan/ is gitignored"
  else
    echo "  RED  .spec/plan/ is NOT gitignored — the ephemeral plan could be committed as a source of truth"; fail=1
  fi

  tracked=$( cd "$REPO" && git ls-files -- .spec/plan/ 2>/dev/null || true )
  if [ -z "$tracked" ]; then
    echo "  OK   no tracked files under .spec/plan/"
  else
    echo "  RED  tracked file(s) under .spec/plan/ — the plan has hardened into a committed artifact:"; printf '%s\n' "$tracked" | sed 's/^/    /'; fail=1
  fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  ( cd "$tmp" && git init -q && git config user.email t@t && git config user.name t )
  # neg-control (a): no .gitignore entry at all -> RED
  mkdir -p "$tmp/.spec/plan"; echo x > "$tmp/.spec/plan/scratch.md"
  check "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: un-ignored .spec/plan/ not caught"; exit 1; } \
    || echo "  neg-control ok: .spec/plan/ not gitignored -> RED"
  # fix the gitignore, but COMMIT the plan file anyway (tracked-plan fixture) -> RED
  printf '.spec/plan/\n' > "$tmp/.gitignore"
  ( cd "$tmp" && git add -f .spec/plan/scratch.md .gitignore && git commit -q -m x )
  check "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: tracked plan file not caught"; exit 1; } \
    || echo "  neg-control ok: a committed (tracked) file under .spec/plan/ -> RED"
  # pos-control: gitignored, nothing tracked -> GREEN
  ( cd "$tmp" && git rm -q --cached -f .spec/plan/scratch.md && git commit -q -m y )
  check "$tmp" >/dev/null 2>&1 && echo "  pos-control ok: gitignored + no tracked files -> GREEN" \
    || { echo "POS FAIL: clean state flagged"; exit 1; }
  echo "RESULT: G10 self-test passed (non-vacuous)"; exit 0
fi

REPO="${1:-$(dirname "$0")/../..}"
echo "== probe G10: .spec/plan/ is gitignored and untracked (R2 mechanical half) =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$REPO" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — the ephemeral-plan gitignore convention is violated"; exit 1; }
echo "RESULT: GREEN — .spec/plan/ stays gitignored and untracked"
