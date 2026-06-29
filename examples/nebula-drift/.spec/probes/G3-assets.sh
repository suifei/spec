#!/usr/bin/env bash
# Probe G3 — asset directory is real and writable (+ negative control)
set -euo pipefail
DIR="${1:-./public/assets}"; mkdir -p "$DIR"; ABS=$(cd "$DIR" && pwd)
echo "== probe G3: assets =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"; echo "----"
echo "resolved: $ABS"; df -h "$ABS" | awk 'NR==2{print "free: "$4}'
T="$ABS/.probe_$$"; trap 'rm -f "$T"' EXIT
echo ok > "$T" && test "$(cat "$T")" = ok || { echo "write FAILED"; exit 1; }
if ( : > /proc/definitely/not/writable ) 2>/dev/null; then echo "NEG CONTROL FAILED"; exit 1; fi
echo "RESULT: assets writable"
