#!/usr/bin/env bash
# Probe G2 — ILLUSTRATIVE logic-check of /build's done-RULE. NOT a behavioral gate.
#
# Honest scope: /build is a prompt skill — there is no importable done() function to
# exercise here. This probe models the done-rule (done = acceptance AND the re-run gate is
# green) and shows the rule DISCRIMINATES a broken impl from a fixed one. It proves the RULE
# is sound; it does NOT prove that a real /build run re-runs the gates (its "negative control"
# is an inline alternate function, not a broken wiring — by references/probes.md's own bar it
# tests logic, not reachability). The BEHAVIORAL truth — that the pipeline actually gates
# "done" on real artifacts — is proven in eval/ (real red-able probes with --selftest,
# red->green evidence logs, _coherence.sh catching stale probe sets). See SPEC.md §3 / R3.
set -euo pipefail

# The modelled done-rule discriminates broken (gate red) from fixed (gate green). Exit 0 if so.
run_illustration() {
  node <<'JS'
const gate        = (impl) => impl.passesGate;                  // the spec's gate, re-run
const doneGated   = (impl) => impl.acceptanceMet && gate(impl); // CORRECT: acceptance AND gate green
const doneUngated = (impl) => impl.fileExists;                  // contrast: a check that IGNORES the gate
const broken = { fileExists: true, acceptanceMet: true, passesGate: false }; // looks built, gate RED
const fixed  = { fileExists: true, acceptanceMet: true, passesGate: true  }; // gate GREEN
const bad = (m) => { console.log('FAIL: ' + m); process.exit(1); };
if (doneGated(broken)  !== false) bad('gated done-rule accepted a broken impl (red gate)');
if (doneGated(fixed)   !== true ) bad('gated done-rule rejected a passing impl');
if (doneUngated(broken)!== true ) bad('contrast check did not even pass the broken impl');
process.exit(0);
JS
}

# --selftest: prove the illustration is non-vacuous — a done-rule that IGNORES the gate must
# misbehave (wrongly pass a red-gate impl), i.e. the check can distinguish gated from ungated.
if [ "${1:-}" = "--selftest" ]; then
  run_illustration >/dev/null 2>&1 \
    && echo "  self-test: correct gated done-rule discriminates broken vs fixed -> GREEN" \
    || { echo "SELFTEST FAIL: correct rule flagged a good case"; exit 1; }
  if node <<'JS' >/dev/null 2>&1
const doneBroken = (impl) => impl.acceptanceMet;                // BROKEN: ignores the gate (ships drift)
const broken = { acceptanceMet: true, passesGate: false };
process.exit(doneBroken(broken) === true ? 0 : 1);             // must WRONGLY return done
JS
  then echo "  self-test: a gate-ignoring done-rule wrongly passes a red-gate impl -> the check has teeth"
  else echo "SELFTEST FAIL: the broken rule did not misbehave"; exit 1; fi
  echo "RESULT: G2 self-test passed (illustrative logic-check is non-vacuous)"; exit 0
fi

echo "== probe G2 (ILLUSTRATIVE): /build 'done' = acceptance AND re-run gate green =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"
echo "scope: illustrative logic-check of the done-RULE; behavioral proof lives in eval/ (SPEC.md §3/R3)"
echo "----"
run_illustration && {
  echo "gated done-rule: broken impl (gate red)  -> NOT done  ✓"
  echo "gated done-rule: fixed impl  (gate green) -> done      ✓"
  echo "contrast: a done-rule that ignores the gate would pass the broken impl -> ship drift"
  echo "RESULT: the done-RULE discriminates (illustrative). Behavioral truth: eval/."
  exit 0
} || exit 1
