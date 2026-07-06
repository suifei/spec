#!/usr/bin/env bash
# Meta-probe — the gate SET stays reconciled to the CURRENT spec.
# After any /spec change, this goes RED if the probe set has drifted from SPEC.md:
#  (1) a [locked] requirement's Method names a .spec/probes/<X>.sh that does NOT exist and is
#      NOT marked deferred/Phase — i.e. a new/changed requirement left UNGATED (false green risk);
#  (2) a probe file that NO current [locked] requirement references — an orphan gate, likely a
#      superseded requirement's stale probe still being run by /build.
set -euo pipefail
SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
PROBES="${2:-$(dirname "$0")}"
echo "== meta-probe: spec <-> probe coherence =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
fail=0

# (1) every locked requirement's referenced probe must exist (unless the line marks it deferred)
while IFS= read -r line; do
  refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
  [ -z "$refs" ] && continue
  deferred=0; grep -qE 'Phase|实例化|OPEN|WEAK|deferred' <<<"$line" && deferred=1
  for r in $refs; do
    base=$(basename "$r")
    if [ -f "$PROBES/$base" ]; then echo "  OK   locked req -> $base exists"
    elif [ "$deferred" -eq 1 ]; then echo "  wait locked req -> $base missing but marked deferred/Phase"
    else echo "  RED  locked req -> $base MISSING, not deferred — requirement is UNGATED"; fail=1; fi
  done
done < <(awk '
  /^- \*\*R/    { if(e!="") print e; e=$0; next }        # start of a requirement entry
  /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next } # wrapped continuation line -> join
  { if(e!=""){ print e; e="" } }
  END { if(e!="") print e }
' "$SPEC" | grep -F '[locked]')

# (2) orphan probes: a probe file no locked requirement references (a superseded req's stale gate)
for f in "$PROBES"/*.sh; do
  base=$(basename "$f"); case "$base" in _*) continue;; esac
  if ! grep -qF "$base" "$SPEC"; then echo "  RED  orphan probe $base — referenced by no requirement (stale gate?)"; fail=1; fi
done

echo "----"
if [ "$fail" -ne 0 ]; then echo "RESULT: RED — gate set OUT OF SYNC with the spec"; exit 1; fi
echo "RESULT: GREEN — every locked requirement is gated (or deferred); no orphan gates"; exit 0
