#!/usr/bin/env bash
# verify.sh — the assertion harness for the Nebula Drift /spec example.
#
# It does two things, in order:
#   1. RUNS every gate probe and checks its exit code matches its expected
#      verdict (greens must pass; the refuted gate G0 MUST go red — that is how
#      we prove a probe can actually fail rather than rubber-stamp).
#   2. ASSERTS the spec artifacts are internally consistent and evidence-backed
#      (gates present, supersede recorded, negative controls present, every piece
#      of evidence carries a real UTC timestamp).
#
# Exit 0 only if all assertions pass. Re-runnable, non-destructive.
set -uo pipefail
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok(){ printf '  PASS  %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }
assert(){ if eval "$2"; then ok "$1"; else no "$1"; fi; }

echo "== Nebula Drift — /spec example verification =="
date -u +"run: %Y-%m-%dT%H:%M:%SZ"
echo

echo "-- 1. probes run with the expected verdict --"
# greens: must exit 0
for g in G1-node-toolchain G2-devport G3-assets G6-ws-transport; do
  if timeout 30 ./.spec/probes/$g.sh >/dev/null 2>&1; then ok "$g probe is green (exit 0)"; else no "$g probe should be green"; fi
done
# refuted: G0 MUST go red (proves probes can fail)
if timeout 30 ./.spec/probes/G0-godot.sh >/dev/null 2>&1; then no "G0 should be RED (godot refuted)"; else ok "G0 probe goes red (refuted, as expected)"; fi

echo
echo "-- 2. negative controls exist (a green means something) --"
assert "G2 probe has a negative control"        'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G2-devport.sh'
assert "G3 probe has a negative control"         'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G3-assets.sh'
assert "G6 probe has a negative control"         'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G6-ws-transport.sh'

echo
echo "-- 3. evidence carries real UTC timestamps (never fabricated) --"
assert "evidence logs exist"                     'ls .spec/evidence/*.log >/dev/null 2>&1'
assert "every evidence log has a UTC 'when:' stamp" '! grep -L "when: 20.*Z" .spec/evidence/*.log | grep -q .'
assert "no placeholder/zero timestamps in evidence" '! grep -rq "0000-00-00\|TODO\|FIXME\|XXXX" .spec/evidence/'

echo
echo "-- 4. spec artifacts present & authoritative --"
assert "SPEC.md exists"                           'test -f SPEC.md'
assert "STATE.md tracks current phase"            'grep -q "current_phase:" .spec/STATE.md'
assert "CLAUDE.md carries the SPEC-AUTHORITY block" 'grep -q "BEGIN SPEC-AUTHORITY" CLAUDE.md'
assert "knowledge entries exist"                  'ls .spec/knowledge/*.md >/dev/null 2>&1'

echo
echo "-- 5. Phase 1 truth is recorded honestly --"
assert "G0 recorded as refuted/dropped in SPEC"   'grep -qi "refuted" SPEC.md'
assert "G4 perf gate kept honestly OPEN"          'grep -q "G4" SPEC.md && grep -qi "open" SPEC.md'
assert "gates G1/G2/G3 verified in SPEC"          'grep -q "G1" SPEC.md && grep -q "G2" SPEC.md && grep -q "G3" SPEC.md'

echo
echo "-- 6. Phase 2 decision is closed & superseding is explicit --"
assert "G6 transport gate verified in SPEC"       'grep -q "G6" SPEC.md && grep -qi "verified" SPEC.md'
assert "Q2 netcode decided (server-authoritative)" 'grep -qi "server-authoritative" SPEC.md'
assert "R5 marked superseded"                      'grep -qi "R5" SPEC.md && grep -qi "supersed" SPEC.md'
assert "R7 (server-authority) locked"              'grep -q "R7" SPEC.md && grep -qi "locked" SPEC.md'
assert "transport knowledge status = decided"      'grep -q "status: decided" .spec/knowledge/realtime-transport.md'

echo
echo "== summary: $PASS passed, $FAIL failed =="
test "$FAIL" -eq 0 && { echo "ALL PASS"; exit 0; } || { echo "FAILURES PRESENT"; exit 1; }
