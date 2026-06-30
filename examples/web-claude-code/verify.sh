#!/usr/bin/env bash
# verify.sh — assertion harness for the Web Claude Code /spec example.
#
# Beyond "does the probe pass", these assertions check the corrected philosophy:
# the SUBJECT is established before any solution (define the noun before the verb),
# investigation = research (most gates research-backed, one behavioral probe),
# gates are load-bearing only, decisions are auto-resolved-and-registered with only
# genuine forks escalated, and the spec fixes boundaries + anti-patterns.
set -uo pipefail
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok(){ printf '  PASS  %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }
assert(){ if eval "$2"; then ok "$1"; else no "$1"; fi; }

echo "== Web Claude Code — /spec example verification =="
date -u +"run: %Y-%m-%dT%H:%M:%SZ"; echo

echo "-- 1. subject established BEFORE the solution (define the noun before the verb) --"
assert "SPEC establishes what Claude Code IS first"     'grep -qi "what Claude Code" SPEC.md && grep -qi "agentic coding CLI" SPEC.md'
assert "essence captured: web-ify = relay the CLI I/O"  'grep -qi "take over" SPEC.md && grep -qi "relay i" SPEC.md'
assert "a 'what-is' research file exists with sources"  'test -f .spec/knowledge/what-is-claude-code.md && grep -qi "https\?://" .spec/knowledge/what-is-claude-code.md'
assert "anti-pattern names the noun-before-verb trap"   'grep -qi "before establishing what Claude Code is\|define the noun" SPEC.md'

echo
echo "-- 2. the one behavioral gate (the mechanism) is probe-verified --"
if timeout 30 ./.spec/probes/G2-stdio-takeover.sh >/dev/null 2>&1; then ok "G2 stdio-takeover probe is green (exit 0)"; else no "G2 probe should be green"; fi
assert "G2 probe carries a negative control"           'grep -qi "neg.control\|NEG CONTROL" .spec/probes/G2-stdio-takeover.sh'
assert "exactly ONE runnable probe exists"             'test "$(ls .spec/probes/*.sh 2>/dev/null | wc -l)" -eq 1'

echo
echo "-- 3. investigation = research; gates load-bearing only --"
assert "G1 (subject) backed by research, not a script"  'grep -q "G1" SPEC.md && grep -qi "verified (research)" SPEC.md'
assert "research gates cite real sources (URLs)"        'grep -rqi "https\?://" .spec/knowledge/'
assert "SPEC states commonsense facts are NOT gated"    'grep -qi "commonsense facts are deliberately" SPEC.md'
assert "no 'port is free / writable dir' gate row"      '! grep -Ei "^\| G[0-9].*(port is free|writable dir|on PATH)" SPEC.md'

echo
echo "-- 4. decide-and-register; only genuine forks escalated --"
assert "Decision Log present"                            'grep -qi "Decision Log" SPEC.md'
assert "auto-resolved decisions registered [auto]"       'grep -q "\[auto\]" SPEC.md'
assert "genuine forks escalated to the human [human]"    'grep -q "\[human\]" SPEC.md'
assert "v1 misframing recorded as superseded"            'grep -qi "supersed" SPEC.md && grep -qi "v1" SPEC.md'

echo
echo "-- 5. spec fixes boundaries + anti-patterns --"
assert "Anti-patterns section present"                   'grep -qi "Anti-patterns" SPEC.md'
assert "anti-pattern: don't rebuild the agent"           'grep -qi "Rebuilding the agent" SPEC.md'
assert "scope boundaries present"                        'grep -qi "Out of scope" SPEC.md'

echo
echo "-- 6. evidence carries real UTC time; artifacts present --"
assert "evidence logs exist"                             'ls .spec/evidence/*.log >/dev/null 2>&1'
assert "every evidence log has a UTC 'when:' stamp"      '! grep -L "when: 20.*Z" .spec/evidence/*.log | grep -q .'
assert "no placeholder/zero timestamps in evidence"      '! grep -rq "0000-00-00\|TODO\|FIXME\|XXXX" .spec/evidence/'
assert "STATE.md tracks current phase"                   'grep -q "current_phase:" .spec/STATE.md'
assert "CLAUDE.md carries the SPEC-AUTHORITY block"      'grep -q "BEGIN SPEC-AUTHORITY" CLAUDE.md'
assert "README carries the value assessment"             'grep -qi "value assessment" README.md'

echo
echo "== summary: $PASS passed, $FAIL failed =="
test "$FAIL" -eq 0 && { echo "ALL PASS"; exit 0; } || { echo "FAILURES PRESENT"; exit 1; }
