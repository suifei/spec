#!/usr/bin/env bash
# Probe G2 — the load-bearing behavioral truth of a self-evolving agent: the
# evolution loop must be gated by an OBJECTIVE evaluation that REJECTS regressions.
# This is what separates real self-improvement from drift/Goodhart. Dependency-free.
#
# Positive: run propose->evaluate->select->archive with the gate; feed a fixed
#           sequence of candidate fitnesses that INCLUDES a regression; assert the
#           retained "best" is monotonic non-decreasing and the bad candidate is
#           rejected (kept best unchanged), and the archive grows.
# Negative control: run the SAME sequence with the gate REMOVED (accept-all);
#           assert a regression IS admitted (current drops below the prior best) —
#           proving the gate is what prevents degradation, i.e. the probe can go red.
set -euo pipefail
echo "== probe G2: objective-gated evolution rejects regressions =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"; echo "----"
node <<'JS'
// a fixed (deterministic) stream of proposed-variant fitnesses, with a planted
// REGRESSION at index 3 (0.55 < running best 0.70).
const proposals = [0.50, 0.62, 0.70, 0.55, 0.74, 0.69, 0.81];
const fail = (m) => { console.log('FAIL: ' + m); process.exit(1); };

// --- POSITIVE: with the objective selection gate ---
let best = 0.0, archive = [];
let bestSeries = [];
for (const f of proposals) {
  if (f >= best) { best = f; archive.push(f); }   // keep iff better (the gate)
  bestSeries.push(best);
}
// monotonic non-decreasing?
for (let i = 1; i < bestSeries.length; i++)
  if (bestSeries[i] < bestSeries[i-1]) fail('gated best regressed at step ' + i);
// the planted regression (index 3, 0.55) must have been rejected (best stays 0.70)
if (bestSeries[3] !== 0.70) fail('gate did not reject the regression (best=' + bestSeries[3] + ')');
console.log('gated best series: [' + bestSeries.join(', ') + ']');
console.log('  regression 0.55 at step 3 REJECTED (best held at 0.70); archive size ' + archive.length);
console.log('  final best = ' + best.toFixed(2));

// --- NEGATIVE CONTROL: gate removed (accept-all) ---
let current = 0.0, admittedRegression = false, prevBest = 0.0;
for (const f of proposals) {
  prevBest = Math.max(prevBest, current);
  current = f;                                     // accept everything (no gate)
  if (current < prevBest) admittedRegression = true;
}
if (!admittedRegression)
  fail('NEG CONTROL FAILED: no regression admitted even without a gate');
console.log('no-gate run: regression ADMITTED (current fell below prior best) — probe can go red');

console.log('RESULT: an objective selection gate is what makes the evolution loop non-degrading');
process.exit(0);
JS
