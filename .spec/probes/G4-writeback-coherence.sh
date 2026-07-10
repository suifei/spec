#!/usr/bin/env bash
# Meta-probe G4 — construction write-back coherence, scoped PER PHASE.
# The S1-3 gap: /build finished Phase 2 on 2026-06-30 but the SPEC.md phases ledger was
# not updated for 6 days — caught by an external review, not the pipeline. This probe
# catches that class internally: if STATE.md's `## build` reports a phase built, THAT
# phase's block in the SPEC.md phases ledger must record the construction write-back.
#
# D-74 fix (clean-context audit): the original version whole-file-grepped SPEC.md for
# ANY "construction ... built" string, so once Phase 2's header carried that marker the
# probe went permanently green — a LATER phase reported built-but-unrecorded would never
# be caught. Convention: a `- built:` line names its phase, e.g. `- built: Phase 3 — ...`;
# this probe extracts that phase number and checks ONLY that phase's `### Phase N` block.
# A `built:` line naming no phase falls back to a whole-file check (legacy compatibility)
# — logged as such, not silently precise. (D-66, rescoped D-74.)
set -euo pipefail

build_section() {
  awk '
    /^## build/ { insec=1; print; next }
    insec && /^(# |## )/ { exit }
    insec { print }
  ' "$1"
}

# extract the ### Phase N ... block up to the next ### Phase or the next ## heading
phase_block() {
  local SPEC="$1" N="$2"
  awk -v n="$N" '
    $0 ~ "^### Phase " n "([^0-9]|$)" { insec=1; print; next }
    insec && /^(### Phase |^## )/ { exit }
    insec { print }
  ' "$SPEC"
}

check() {
  local STATE="$1" SPEC="$2" fail=0 built_lines line phase blk

  built_lines=$(build_section "$STATE" | grep -iE '^- *built:' || true)
  if [ -z "$built_lines" ] || grep -qiE 'built: *(none|—|-) *$|built:.*\bnone\b' <<<"$built_lines"; then
    echo "  OK   ## build reports nothing built yet — no write-back owed"; return 0
  fi

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    phase=$(grep -oE 'Phase[[:space:]]+[0-9]+' <<<"$line" | grep -oE '[0-9]+' | head -1 || true)
    if [ -n "$phase" ]; then
      blk=$(phase_block "$SPEC" "$phase")
      if [ -z "$blk" ]; then
        echo "  RED  built line names Phase $phase but SPEC.md has no '### Phase $phase' block at all"; fail=1
      elif grep -qiE 'construction[:*]?.*built|✅ *built|built [0-9]{4}-[0-9]{2}-[0-9]{2}' <<<"$blk"; then
        echo "  OK   Phase $phase reported built AND its own SPEC.md block records the construction write-back"
      else
        echo "  RED  Phase $phase reported built, but ITS SPEC.md phase block has no 'construction … built' write-back (the S1-3 gap, phase-scoped)"; fail=1
      fi
    else
      # legacy: no phase named in the built line -> fall back to whole-file (imprecise)
      if grep -qiE 'construction[:*]?.*built|✅ *built|built [0-9]{4}-[0-9]{2}-[0-9]{2}' "$SPEC"; then
        echo "  OK   (unscoped — built line names no phase) SPEC.md has SOME construction write-back somewhere"
      else
        echo "  RED  (unscoped) built line names no phase and SPEC.md has no write-back anywhere"; fail=1
      fi
    fi
  done <<< "$built_lines"
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # neg-control: STATE says Phase 2 built, SPEC's Phase 2 block has no write-back -> RED
  printf '## build\n- built: Phase 2 — 2026-06-30 — the skill per R1-R5\n' > "$tmp/STATE.md"
  printf '## 7. Phases\n### Phase 2 — status: sealed\n- Goal: the skill\n' > "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: built-but-unrecorded not caught"; exit 1; } \
    || echo "  neg-control ok: Phase 2 built but its block has no write-back -> RED"
  # pos-control: Phase 2's own block records the construction -> GREEN
  printf '## 7. Phases\n### Phase 2 — status: sealed · construction: ✅ built 2026-06-30\n' > "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  pos-control ok: Phase 2's own block records construction -> GREEN" \
    || { echo "POS FAIL: recorded write-back flagged"; exit 1; }
  # THE key regression this rewrite fixes: STATE now reports Phase 3 built, Phase 2's
  # write-back exists but Phase 3's does NOT -> must still go RED (old version went green
  # forever once ANY phase had the marker; this proves the new one doesn't).
  printf '## build\n- built: Phase 3 — 2026-07-09 — a later phase\n' > "$tmp/STATE.md"
  printf '## 7. Phases\n### Phase 2 — status: sealed · construction: ✅ built 2026-06-30\n### Phase 3 — status: sealed\n- Goal: later work\n' > "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: LATER unrecorded phase not caught (the whole-file-grep bug)"; exit 1; } \
    || echo "  neg-control ok: Phase 3 built-but-unrecorded NOT masked by Phase 2's existing write-back -> RED"
  # and Phase 3 recorded too -> GREEN
  printf '## 7. Phases\n### Phase 2 — status: sealed · construction: ✅ built 2026-06-30\n### Phase 3 — status: sealed · construction: ✅ built 2026-07-09\n' > "$tmp/SPEC.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  pos-control ok: Phase 3 also recorded in its own block -> GREEN" \
    || { echo "POS FAIL: Phase 3 recorded but flagged"; exit 1; }
  # nothing-built control: no write-back owed -> GREEN
  printf '## build\n- built: none\n' > "$tmp/STATE.md"
  check "$tmp/STATE.md" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  control ok: nothing built -> no write-back owed -> GREEN" \
    || { echo "CTRL FAIL"; exit 1; }
  echo "RESULT: G4-writeback-coherence self-test passed"; exit 0
fi

STATE="${1:-$(dirname "$0")/../STATE.md}"
SPEC="${2:-$(dirname "$0")/../../SPEC.md}"
echo "== meta-probe G4: construction write-back coherence, PER PHASE (STATE ## build <-> SPEC phase block) =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$STATE" "$SPEC" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — a built phase is not written back to its own SPEC.md phase block"; exit 1; fi
echo "RESULT: GREEN — every reported-built phase is reflected in its own SPEC.md phase block"; exit 0
