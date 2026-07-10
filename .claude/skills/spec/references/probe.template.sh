#!/usr/bin/env bash
# probe.template.sh — a skeleton for a LOAD-BEARING GATE probe (a requirement's
# Method = Probed). Copy this to .spec/probes/<R>.sh and fill in the gate's truth.
#
# A probe is the *executable* instrument of investigation (references/probes.md).
# It is worth writing only for a gate that is load-bearing AND uncertain AND
# consequential-if-wrong — never for commonsense (free port / writable dir / tool
# on PATH). The one rule that makes a probe meaningful: IT MUST BE ABLE TO GO RED.
#
# Fill these per gate:
#   <gate-id>        the requirement / gate this proves (e.g. R1, G1)
#   <truth>          the environment-/behavior-specific truth it exercises
#   <neg-control>    the broken/absent case that MUST turn this red
#   <requirement>    the exact evidence identity, e.g. R7@3
#
# The negative control is the whole point: a probe that can't fail proves nothing.
# Make the cheat itself the negative control where you can (references/probes.md,
# "A gate is a proxy for an intent") — if the cheapest way to game the measure is X,
# the probe's --selftest does X and requires red.

set -euo pipefail

# ---- the check ---------------------------------------------------------------
# Exercise the real environment / behavior. Print raw evidence (resolved paths,
# versions, query results) — not just "PASS" — so a human/CI can audit the facts.
run_check() {
  # EXAMPLE (replace): does the target host have usable GPU compute?
  # command -v nvidia-smi >/dev/null || { echo "nvidia-smi NOT found — refuted"; return 1; }
  # nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || { echo "no usable GPU"; return 1; }
  echo "(probe body not filled in — see probe.template.sh)"
  return 1
}

# ---- negative control --------------------------------------------------------
# The broken case. This MUST return non-zero (red). If it ever returns 0, the
# probe is vacuous — rewrite it or mark the gate unverified (OPEN).
run_neg_control() {
  # EXAMPLE: a GPU index that cannot exist must NOT report present.
  # if nvidia-smi -i 999 >/dev/null 2>&1; then echo "NEG CONTROL FAILED: bogus index OK"; return 1; fi
  echo "(neg-control body not filled in)"
  return 1
}

# ---- selftest: the probe must be able to go red ------------------------------
# --selftest proves non-vacuity: the negative control MUST go red, and (if the
# good case is constructible inline) the check MUST go green. A probe whose
# selftest can't show a red is rejected (references/probes.md "Honest limit").
if [ "${1:-}" = "--selftest" ]; then
  rc=0
  if run_neg_control >/dev/null 2>&1; then
    echo "  NEG FAIL: negative control went GREEN — probe is vacuous"; rc=1
  else
    echo "  neg-control ok: broken case -> RED"
  fi
  # (positive control optional — only if the good case is inline-constructible)
  [ "$rc" -eq 0 ] && echo "RESULT: <gate-id> self-test passed (non-vacuous)" || echo "RESULT: self-test FAILED"
  exit "$rc"
fi

# ---- run ---------------------------------------------------------------------
echo "== probe <gate-id>: <truth> =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "requirement: <requirement-id>@<revision>"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
run_check && {
  echo "neg-control:"; run_neg_control >/dev/null 2>&1 \
    && { echo "NEG CONTROL FAILED (bogus case passed)"; exit 1; } \
    || echo "  rejected (ok)"
  echo "RESULT: GREEN — <truth> holds"
  exit 0
} || { echo "RESULT: RED — <truth> refuted"; exit 1; }
