#!/usr/bin/env bash
# verify.sh — assertion harness for the Web Claude Code /spec example.
#
# Beyond "does the probe pass", these assertions check that the spec embodies the
# corrected philosophy: investigation = research (most gates are research-backed,
# probes are reserved for behavioral truths), gates are load-bearing only (no
# commonsense gates), decisions are auto-resolved-and-registered with only genuine
# forks escalated, and the spec fixes boundaries + anti-patterns.
set -uo pipefail
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok(){ printf '  PASS  %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }
assert(){ if eval "$2"; then ok "$1"; else no "$1"; fi; }

echo "== Web Claude Code — /spec example verification =="
date -u +"run: %Y-%m-%dT%H:%M:%SZ"; echo

echo "-- 1. the one behavioral gate is probe-verified --"
if timeout 30 ./.spec/probes/G3-session-persistence.sh >/dev/null 2>&1; then ok "G3 session-persistence probe is green (exit 0)"; else no "G3 probe should be green"; fi
assert "G3 probe carries a negative control"        'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G3-session-persistence.sh'

echo
echo "-- 2. probes are reserved; research does the rest (探真 = 研究) --"
assert "exactly ONE runnable probe exists"          'test "$(ls .spec/probes/*.sh 2>/dev/null | wc -l)" -eq 1'
assert "G1 is backed by research (not a script)"    'grep -q "G1" SPEC.md && grep -qi "verified (research)" SPEC.md'
assert "research gates cite real sources (URLs)"    'grep -rqi "https\?://" .spec/knowledge/'

echo
echo "-- 3. gates are load-bearing only; commonsense is excluded by design --"
assert "SPEC states commonsense facts are NOT gated" 'grep -qi "commonsense facts are deliberately" SPEC.md'
assert "all three load-bearing gates present"        'grep -q "G1" SPEC.md && grep -q "G2" SPEC.md && grep -q "G3" SPEC.md'
# no commonsense gate names leaked into the gate rows
assert "no 'port is free / writable dir' gate row"   '! grep -Ei "^\| G[0-9].*(port is free|writable dir|on PATH)" SPEC.md'

echo
echo "-- 4. decide-and-register; only genuine forks escalated --"
assert "Decision Log present"                         'grep -qi "Decision Log" SPEC.md'
assert "auto-resolved decisions registered [auto]"    'grep -q "\[auto\]" SPEC.md'
assert "a genuine fork escalated to the human [human]" 'grep -q "\[human\]" SPEC.md'
assert "Open Questions are human-owned forks only"     'grep -qi "genuine forks" SPEC.md'

echo
echo "-- 5. spec fixes boundaries + anti-patterns --"
assert "Anti-patterns section present"                'grep -qi "Anti-patterns" SPEC.md'
assert "scope boundaries present"                     'grep -qi "Out of scope" SPEC.md'

echo
echo "-- 6. evidence carries real UTC time; artifacts present --"
assert "evidence logs exist"                          'ls .spec/evidence/*.log >/dev/null 2>&1'
assert "every evidence log has a UTC 'when:' stamp"   '! grep -L "when: 20.*Z" .spec/evidence/*.log | grep -q .'
assert "no placeholder/zero timestamps in evidence"   '! grep -rq "0000-00-00\|TODO\|FIXME\|XXXX" .spec/evidence/'
assert "STATE.md tracks current phase"                'grep -q "current_phase:" .spec/STATE.md'
assert "CLAUDE.md carries the SPEC-AUTHORITY block"   'grep -q "BEGIN SPEC-AUTHORITY" CLAUDE.md'
assert "README carries the value assessment"          'grep -qi "value assessment" README.md'

echo
echo "== summary: $PASS passed, $FAIL failed =="
test "$FAIL" -eq 0 && { echo "ALL PASS"; exit 0; } || { echo "FAILURES PRESENT"; exit 1; }
