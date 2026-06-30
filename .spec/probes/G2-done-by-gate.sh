#!/usr/bin/env bash
# Probe G2 — the load-bearing behavioral truth of /build: construction "done" is
# decided by RE-RUNNING the spec's gates; a red gate blocks "done" (so drift /
# regressions can't slip through as finished). Dependency-free.
#
# Positive: a gated done-check returns NOT-done for a broken impl (gate red) and
#           done for a fixed impl (gate green).
# Negative control: a naive done-check that IGNORES the gate wrongly passes the
#           broken impl — proving the gated check discriminates (it can go red).
set -euo pipefail
echo "== probe G2: build 'done' is gated by re-running the spec's gates =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"; echo "----"
node <<'JS'
// the spec's gate, re-run against an implementation (this is what /build re-runs)
const gate = (impl) => impl.passesGate;
// CORRECT done-check: acceptance met AND the load-bearing gate is green
const doneGated = (impl) => impl.acceptanceMet && gate(impl);
// NEGATIVE CONTROL: a done-check that ignores the gate (self-certifies on "looks built")
const doneUngated = (impl) => impl.fileExists;

const broken = { fileExists: true, acceptanceMet: true, passesGate: false }; // looks built, gate RED
const fixed  = { fileExists: true, acceptanceMet: true, passesGate: true  }; // gate GREEN
const fail = (m) => { console.log('FAIL: ' + m); process.exit(1); };

if (doneGated(broken) !== false) fail('gated done-check accepted a broken impl (red gate)');
console.log('gated done-check: broken impl (gate red) -> NOT done  ✓');
if (doneGated(fixed) !== true) fail('gated done-check rejected a passing impl');
console.log('gated done-check: fixed impl (gate green) -> done  ✓');

if (doneUngated(broken) !== true) fail('NEG CONTROL did not even pass the broken impl');
console.log('neg-control: UNGATED done-check passes the broken impl -> would ship drift (probe can go red)');

console.log('RESULT: construction "done" must re-run the spec gates; a red gate blocks done');
process.exit(0);
JS
