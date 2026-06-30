#!/usr/bin/env bash
# verify.sh — assertion harness for the Self-Evolving Agent System /spec example.
#
# This example was produced by an ACTUAL /spec skill run (real research, real probe,
# real human decisions on the forks). The assertions check the discipline held:
# subject established first, the one behavioral truth probe-verified, gates
# load-bearing only, decisions registered with the human forks recorded, and the
# auto-promote choice honestly hardened rather than waved through.
set -uo pipefail
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok(){ printf '  PASS  %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }
assert(){ if eval "$2"; then ok "$1"; else no "$1"; fi; }

echo "== Self-Evolving Agent System — /spec example verification =="
date -u +"run: %Y-%m-%dT%H:%M:%SZ"; echo

echo "-- 1. subject established BEFORE the solution (define the noun before the verb) --"
assert "SPEC defines what self-evolving IS first"        'grep -qi "what a .self-evolving agent system. .is\|Subject & Core Problem" SPEC.md'
assert "essence: propose->evaluate->select->archive loop" 'grep -qi "propose" SPEC.md && grep -qi "archive" SPEC.md'
assert "a 'what-is' research file exists with sources"    'test -f .spec/knowledge/what-is-a-self-evolving-agent.md && grep -qi "arxiv.org" .spec/knowledge/what-is-a-self-evolving-agent.md'
assert "anti-pattern names the noun-before-verb trap"     'grep -qi "before establishing the loop\|define-the-noun" SPEC.md'

echo
echo "-- 2. the one behavioral gate is probe-verified --"
if timeout 30 ./.spec/probes/G2-evolution-gate.sh >/dev/null 2>&1; then ok "G2 evolution-gate probe is green (exit 0)"; else no "G2 probe should be green"; fi
assert "G2 probe carries a negative control"             'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G2-evolution-gate.sh'
assert "exactly ONE runnable probe exists"               'test "$(ls .spec/probes/*.sh 2>/dev/null | wc -l)" -eq 1'
assert "core invariant captured: gate rejects regression" 'grep -qi "reject" SPEC.md && grep -qi "regression" SPEC.md'

echo
echo "-- 3. investigation = research; gates load-bearing only --"
assert "G1 (subject) backed by research, not a script"   'grep -q "G1" SPEC.md && grep -qi "verified (research)" SPEC.md'
assert "research gates cite real sources (URLs)"         'grep -rqi "https\?://" .spec/knowledge/'
assert "SPEC states commonsense facts are NOT gated"     'grep -qi "commonsense facts are deliberately" SPEC.md'
assert "no 'port is free / writable dir' gate row"       '! grep -Ei "^\| G[0-9].*(port is free|writable dir|on PATH)" SPEC.md'

echo
echo "-- 4. decide-and-register; human forks recorded; honest hardening --"
assert "Decision Log present"                             'grep -qi "Decision Log" SPEC.md'
assert "auto-resolved decisions registered [auto]"        'grep -q "\[auto\]" SPEC.md'
assert "human forks recorded [human]"                     'grep -q "\[human\]" SPEC.md'
assert "auto-promote choice honestly hardened (not waved)" 'grep -qi "did .not. silently accept\|Honest note on D6" SPEC.md'
assert "hardening is a locked requirement (held-out+rollback+kill-switch)" 'grep -qi "held-out" SPEC.md && grep -qi "kill-switch" SPEC.md'

echo
echo "-- 5. spec fixes boundaries + anti-patterns --"
assert "Anti-patterns section present"                    'grep -qi "Anti-patterns" SPEC.md'
assert "anti-pattern: self-grading without objective signal" 'grep -qi "Self-grading" SPEC.md'
assert "scope boundary: no core code/weights this phase"  'grep -qi "core code" SPEC.md && grep -qi "weights" SPEC.md'

echo
echo "-- 6. evidence carries real UTC time; artifacts present --"
assert "evidence logs exist"                              'ls .spec/evidence/*.log >/dev/null 2>&1'
assert "every evidence log has a UTC 'when:' stamp"       '! grep -L "when: 20.*Z" .spec/evidence/*.log | grep -q .'
assert "no placeholder/zero timestamps in evidence"       '! grep -rq "0000-00-00\|TODO\|FIXME\|XXXX" .spec/evidence/'
assert "STATE.md tracks current phase"                    'grep -q "current_phase:" .spec/STATE.md'
assert "CLAUDE.md carries the SPEC-AUTHORITY block"       'grep -q "BEGIN SPEC-AUTHORITY" CLAUDE.md'
assert "README carries the value assessment"              'grep -qi "value assessment" README.md'

echo
echo "== summary: $PASS passed, $FAIL failed =="
test "$FAIL" -eq 0 && { echo "ALL PASS"; exit 0; } || { echo "FAILURES PRESENT"; exit 1; }
