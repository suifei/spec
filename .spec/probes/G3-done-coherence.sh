#!/usr/bin/env bash
# Meta-probe G3 — the done-condition stays COHERENT across SPEC.md R3, the skill files,
# AND the command wrappers. Authority: build/SKILL.md principle 3 — done = acceptance AND
# green gates AND (for generative/quality) an independent review. SPEC.md R3, /yolo, and
# the command wrappers must each either fully STATE those three elements or (wrappers
# only) REFERENCE the SKILL.md authority — never a drifted abbreviation. This goes RED if
# SPEC.md's own authoritative requirement (R3) drops the review clause (the clean-context-
# audit finding: R3 said "acceptance + green gates" with no independent-review mention,
# while every skill treated the review as a necessary third condition — the contract
# the pipeline calls supreme had silently diverged from its own skills), if an
# authoritative skill file drops one of the three, or if a command wrapper restates done
# incompletely without deferring to the SKILL.md authority (the S1-4 class). Illustrative
# meta-check over the prompt files; see references/probes.md. (D-66; extended to command
# wrappers D-69; extended to SPEC.md R3 D-74.)
set -euo pipefail

# a file/text states the done-condition coherently iff all three elements are present
states_done_coherently() {
  local f="$1"
  grep -qiE 'acceptance' "$f" \
    && grep -qiE 'gates? (are )?green|green gates?' "$f" \
    && grep -qi 'independent' "$f" && grep -qi 'review' "$f"
}
# a wrapper may defer to the authority instead of restating done (D-66: reference,
# not restate) — that is also coherent, provided it actually points at SKILL.md
references_authority() { grep -qi 'SKILL\.md' "$1"; }

# extract SPEC.md's R3 requirement line (the wrapped bullet, joined) for its own check
extract_r3() {
  awk '
    /^- \*\*R3\.?\*\*/ { if(e!="") print e; e=$0; next }
    /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
    { if(e!=""){ print e; e="" } }
    END { if(e!="") print e }
  ' "$1"
}

check() {
  local SKILLS="$1" CMDS="$2" SPEC="$3" fail=0 f name r3

  # SPEC.md R3 is the authoritative contract's own statement of done — must be coherent
  if [ -f "$SPEC" ]; then
    r3=$(extract_r3 "$SPEC")
    local r3file; r3file=$(mktemp); printf '%s\n' "$r3" > "$r3file"
    if [ -z "$r3" ]; then
      echo "  RED  SPEC.md has no R3 requirement to check (done-condition contract missing)"; fail=1
    elif states_done_coherently "$r3file"; then
      echo "  OK   SPEC.md R3 states done = acceptance + green gates + independent review"
    else
      echo "  RED  SPEC.md R3 done-condition drifted from the skills (missing acceptance / green gates / independent review) — the authoritative contract disagrees with build/yolo"; fail=1
    fi
    rm -f "$r3file"
  else
    echo "  RED  missing SPEC.md: $SPEC"; fail=1
  fi

  # authoritative skill files: MUST state done coherently (all three elements)
  for f in "$SKILLS/build/SKILL.md" "$SKILLS/yolo/SKILL.md"; do
    name="$(basename "$(dirname "$f")")/SKILL.md"
    [ -f "$f" ] || { echo "  RED  missing skill file: $f"; fail=1; continue; }
    if states_done_coherently "$f"; then
      echo "  OK   $name states done = acceptance + green gates + independent review"
    else
      echo "  RED  $name done-condition drifted (missing acceptance / green gates / independent review)"; fail=1
    fi
  done
  # command wrappers that restate the build done-condition / loop prompt: must
  # EITHER fully state all three elements OR defer to the SKILL.md authority.
  # (commands/spec.md is /spec's closure surface, not a build-done restatement —
  #  not checked here.)
  for f in "$CMDS/build.md" "$CMDS/yolo.md"; do
    name="commands/$(basename "$f")"
    [ -f "$f" ] || { echo "  RED  missing wrapper: $f"; fail=1; continue; }
    if states_done_coherently "$f" || references_authority "$f"; then
      echo "  OK   $name defers to (or fully restates) the done-condition"
    else
      echo "  RED  $name restates done incompletely and references no SKILL.md authority (drift)"; fail=1
    fi
  done
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/skills/build" "$tmp/skills/yolo" "$tmp/cmds"
  printf 'done = acceptance and gates are green and an independent review signs off\n' > "$tmp/skills/build/SKILL.md"
  printf 'done inherits: acceptance, gates green, independent review\n' > "$tmp/skills/yolo/SKILL.md"
  printf 'close when acceptance holds, green gates, and an independent review\n' > "$tmp/cmds/build.md"
  printf 'see yolo/SKILL.md Fire the loop for the authoritative tick prompt\n' > "$tmp/cmds/yolo.md"
  printf -- '- **R3.** done when acceptance holds and gates are green and an independent review signs off. *(D3)*\n' > "$tmp/SPEC.md"
  check "$tmp/skills" "$tmp/cmds" "$tmp/SPEC.md" >/dev/null 2>&1 && echo "  pos-control ok: R3 + authoritative + (full OR referencing) wrappers -> GREEN" \
    || { echo "POS FAIL: coherent set flagged"; exit 1; }
  # SPEC.md R3 dropping the review clause -> RED (the actual clean-context-audit finding)
  printf -- '- **R3.** done when each targeted requirement acceptance holds and the load-bearing gates are green (probes re-run). *(D3)*\n' > "$tmp/SPEC.md"
  check "$tmp/skills" "$tmp/cmds" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: SPEC R3 review-clause drift not caught"; exit 1; } \
    || echo "  neg-control ok: SPEC.md R3 missing the independent-review clause -> RED"
  printf -- '- **R3.** done when acceptance holds and gates are green and an independent review signs off. *(D3)*\n' > "$tmp/SPEC.md"
  # a wrapper restating done incompletely with no SKILL.md ref -> RED
  printf 'close when gates are green\n' > "$tmp/cmds/build.md"
  check "$tmp/skills" "$tmp/cmds" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: drifted wrapper not caught"; exit 1; } \
    || echo "  neg-control ok: a wrapper restating done incompletely with no SKILL.md ref -> RED"
  printf 'close when acceptance holds, green gates, and an independent review\n' > "$tmp/cmds/build.md"
  # a skill file dropping a done element -> RED
  printf 'done = acceptance and gates are green\n' > "$tmp/skills/yolo/SKILL.md"
  check "$tmp/skills" "$tmp/cmds" "$tmp/SPEC.md" >/dev/null 2>&1 && { echo "NEG FAIL: skill drift not caught"; exit 1; } \
    || echo "  neg-control ok: a skill file dropping independent review -> RED"
  echo "RESULT: G3-done-coherence self-test passed"; exit 0
fi

PROBE_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS="${1:-"$PROBE_DIR/../../.claude/skills"}"
CMDS="${2:-"$PROBE_DIR/../../.claude/commands"}"
SPEC="${3:-"$PROBE_DIR/../../SPEC.md"}"
echo "== meta-probe G3: done-condition coherence across SPEC.md R3 + skills + wrappers =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SKILLS" "$CMDS" "$SPEC" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — R3/a skill's/wrapper's done-condition drifted from build principle 3"; exit 1; fi
echo "RESULT: GREEN — done-condition coherent across SPEC.md R3, build/yolo SKILL.md, and command wrappers"
