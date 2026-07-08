#!/usr/bin/env bash
# Meta-probe — the gate SET stays reconciled to the CURRENT spec.
# After any /spec change, this goes RED if the probe set has drifted from SPEC.md:
#  (1) a [locked] requirement's Method names a .spec/probes/<X>.sh that does NOT exist and is
#      NOT marked deferred/Phase — i.e. a new/changed requirement left UNGATED (false green risk);
#  (2) a probe file that NO current [locked] requirement references — an orphan gate, likely a
#      superseded requirement's stale probe still being run by /build.
set -euo pipefail

# The check, parameterized by (SPEC, PROBES) so --selftest can exercise it on fixtures.
check() {
  local SPEC="$1" PROBES="$2" fail=0 line refs deferred r base f
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
    [ -e "$f" ] || continue
    base=$(basename "$f"); case "$base" in _*) continue;; esac
    if ! grep -qF "$base" "$SPEC"; then echo "  RED  orphan probe $base — referenced by no requirement (stale gate?)"; fail=1; fi
  done
  return "$fail"
}

# --selftest: the meta-probe must itself be able to go RED. Build fixtures that break each rule,
# require RED, then a coherent fixture and require GREEN. (A probe that can't go red is vacuous.)
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/probes"
  # neg-control (1): a locked requirement references a probe that does not exist, not deferred -> RED
  printf '%s\n' '- **R1** [locked] — a thing. Method: Probed(.spec/probes/G-missing.sh).' > "$tmp/SPEC.md"
  check "$tmp/SPEC.md" "$tmp/probes" >/dev/null 2>&1 && { echo "NEG FAIL: ungated locked req not caught"; exit 1; } \
    || echo "  neg-control ok: locked req with missing probe -> RED"
  # neg-control (2): an orphan probe that no requirement references -> RED
  printf '%s\n' '- **R1** [locked] — a thing. Method: Probed(.spec/probes/G-real.sh).' > "$tmp/SPEC.md"
  printf '#!/usr/bin/env bash\n' > "$tmp/probes/G-real.sh"
  printf '#!/usr/bin/env bash\n' > "$tmp/probes/G-orphan.sh"
  check "$tmp/SPEC.md" "$tmp/probes" >/dev/null 2>&1 && { echo "NEG FAIL: orphan probe not caught"; exit 1; } \
    || echo "  neg-control ok: orphan probe -> RED"
  # pos-control: a coherent spec+probe set -> GREEN
  rm -f "$tmp/probes/G-orphan.sh"
  if check "$tmp/SPEC.md" "$tmp/probes" >/dev/null 2>&1; then echo "  pos-control ok: coherent set -> GREEN"
  else echo "POS FAIL: coherent set flagged as out-of-sync"; exit 1; fi
  echo "RESULT: _coherence self-test passed"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
PROBES="${2:-$(dirname "$0")}"
echo "== meta-probe: spec <-> probe coherence =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$PROBES" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — gate set OUT OF SYNC with the spec"; exit 1; fi
echo "RESULT: GREEN — every locked requirement is gated (or deferred); no orphan gates"; exit 0
