#!/usr/bin/env bash
# Meta-probe G3 — the done-condition stays COHERENT across the skill files.
# Authority: build/SKILL.md principle 3 — done = acceptance AND green gates AND (for
# generative/quality) an independent review. /yolo and the command wrappers must
# REFERENCE, not DRIFT from, those three elements. This goes RED if a skill file that
# states "done" drops one of the three — the S1-4 drift GLM-5.2 flagged (the done-rule is
# restated in several places with no coherence check). Illustrative meta-check over the
# prompt files; see references/probes.md. (D-66.)
set -euo pipefail

# a file states the done-condition coherently iff all three elements are present
states_done_coherently() {
  local f="$1"
  grep -qiE 'acceptance' "$f" \
    && grep -qiE 'gates? (are )?green|green gates?' "$f" \
    && grep -qi 'independent' "$f" && grep -qi 'review' "$f"
}

check() {
  local root="$1" fail=0 f name
  for f in "$root/build/SKILL.md" "$root/yolo/SKILL.md"; do
    name="$(basename "$(dirname "$f")")/SKILL.md"
    [ -f "$f" ] || { echo "  RED  missing skill file: $f"; fail=1; continue; }
    if states_done_coherently "$f"; then
      echo "  OK   $name states done = acceptance + green gates + independent review"
    else
      echo "  RED  $name done-condition drifted (missing one of: acceptance / green gates / independent review)"; fail=1
    fi
  done
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/build" "$tmp/yolo"
  printf 'done = acceptance and gates are green and an independent review signs off\n' > "$tmp/build/SKILL.md"
  printf 'done inherits: acceptance, gates green, independent review\n' > "$tmp/yolo/SKILL.md"
  check "$tmp" >/dev/null 2>&1 && echo "  pos-control ok: coherent done across files -> GREEN" || { echo "POS FAIL"; exit 1; }
  printf 'done = acceptance and gates are green\n' > "$tmp/yolo/SKILL.md"   # drops the review element
  check "$tmp" >/dev/null 2>&1 && { echo "NEG FAIL: drift not caught"; exit 1; } \
    || echo "  neg-control ok: a file dropping the independent review -> RED"
  echo "RESULT: G3-done-coherence self-test passed"; exit 0
fi

ROOT="${1:-$(dirname "$0")/../../.claude/skills}"
echo "== meta-probe G3: done-condition coherence across skill files =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$ROOT" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — a skill's done-condition drifted from build principle 3"; exit 1; fi
echo "RESULT: GREEN — done-condition coherent across build/SKILL.md and yolo/SKILL.md"; exit 0
