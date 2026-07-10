#!/usr/bin/env bash
# Probe G11 — protocol lifecycle/source invariants introduced by Phase 3.
set -euo pipefail

check_text() {
  local SPEC_SKILL="$1" BUILD="$2" YOLO="$3" SPEC_TEMPLATE="$4" STATE_TEMPLATE="$5" fail=0
  grep -q 'Profile: minimal|governed' "$SPEC_SKILL" || { echo 'RED: explicit profiles missing'; fail=1; }
  grep -q 'requirement: R7@3' "$SPEC_SKILL" || { echo 'RED: requirement revision binding missing'; fail=1; }
  grep -q 'Construction Ledger' "$SPEC_TEMPLATE" || { echo 'RED: mutable construction projection missing'; fail=1; }
  grep -q 'Revision:' "$SPEC_TEMPLATE" || { echo 'RED: requirement revision field missing'; fail=1; }
  grep -q 'artifact-path:' "$BUILD" && grep -q 'artifact: sha256:<64-hex>' "$BUILD" || { echo 'RED: build review artifact binding missing'; fail=1; }
  grep -q 'run_id:' "$STATE_TEMPLATE" || { echo 'RED: yolo run identity missing from STATE'; fail=1; }
  grep -q 'n >= ceiling' "$YOLO" || { echo 'RED: ceiling is not checked before append'; fail=1; }
  grep -q 'never commit before review' "$YOLO" || { echo 'RED: review-before-commit ordering missing'; fail=1; }
  grep -q 'tick-order: admit-run > construct > probes > review > fix > re-probe > final-review > commit > checkpoint' "$YOLO" || { echo 'RED: authoritative tick order missing'; fail=1; }
  if grep -q '\.spec/evidence/ticks\.log' "$YOLO"; then echo 'RED: global cross-run tick log remains'; fail=1; fi
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf 'Profile: minimal|governed\nrequirement: R7@3\n' > "$tmp/spec"
  printf 'artifact-path:\nartifact: sha256:<64-hex>\n' > "$tmp/build"
  printf 'n >= ceiling\nnever commit before review\ntick-order: admit-run > construct > probes > review > fix > re-probe > final-review > commit > checkpoint\n' > "$tmp/yolo"
  printf 'Construction Ledger\nRevision:\n' > "$tmp/template"
  printf 'run_id:\n' > "$tmp/state"
  check_text "$tmp/spec" "$tmp/build" "$tmp/yolo" "$tmp/template" "$tmp/state"
  printf '%s\n' '.spec/evidence/ticks.log' >> "$tmp/yolo"
  if check_text "$tmp/spec" "$tmp/build" "$tmp/yolo" "$tmp/template" "$tmp/state" >/dev/null 2>&1; then
    echo 'NEG FAIL: global cross-run tick log passed'; exit 1
  fi
  echo 'neg-control ok: global tick log -> RED'
  ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
  bash "$ROOT/.spec/probes/G9-tick-monotonic.sh" --selftest >/dev/null
  bash "$ROOT/.claude/skills/spec/references/coherence.template.sh" --selftest >/dev/null
  echo 'semantic controls ok: run lifecycle + artifact mutation/revision checks go RED'
  echo 'RESULT: G11 self-test passed'; exit 0
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo '== probe G11: protocol lifecycle coherence =='; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo '----'
check_text "$ROOT/.claude/skills/spec/SKILL.md" "$ROOT/.claude/skills/build/SKILL.md" "$ROOT/.claude/skills/yolo/SKILL.md" "$ROOT/.claude/skills/spec/references/SPEC.template.md" "$ROOT/.claude/skills/spec/references/STATE.template.md"
bash "$ROOT/.spec/probes/G9-tick-monotonic.sh" --selftest >/dev/null
bash "$ROOT/.spec/probes/G9-tick-monotonic.sh" >/dev/null
bash "$ROOT/.claude/skills/spec/references/coherence.template.sh" --selftest >/dev/null
echo 'RESULT: GREEN — profiles, evidence identity, immutable history, and isolated yolo lifecycle are wired'
