#!/usr/bin/env bash
# Probe G5 — spec <-> probe coherence (D-57). The gate SET must match the CURRENT
# spec: every [locked] requirement whose Method references a .spec/probes/<X>.sh
# has that file; no probe file is orphaned (referenced by nothing in SPEC). RED
# on either — a stale set is a false green (the drift-detector drifting).
# (Template: references/coherence.template.sh; reference impl: eval/cn-novel/_coherence.sh. D-69.)
set -euo pipefail

locked_reqs() {
  awk '/^- \*\*R/ { if(e!="") print e; e=$0; next }
       /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
       { if(e!=""){ print e; e="" } } END { if(e!="") print e }' "$1" | grep -F '[locked]'
}

check() {
  local SPEC="$1" PROBES="$2" fail=0 line refs deferred r base f
  while IFS= read -r line; do
    refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
    [ -z "$refs" ] && continue
    deferred=0; grep -qE 'Phase|实例化|OPEN|WEAK|deferred' <<<"$line" && deferred=1
    for r in $refs; do
      base=$(basename "$r")
      if [ -f "$PROBES/$base" ]; then echo "  OK   locked req -> $base exists"
      elif [ "$deferred" -eq 1 ]; then echo "  wait locked req -> $base missing but marked deferred/Phase"
      else echo "  RED  locked req -> $base MISSING, not deferred — UNGATED"; fail=1; fi
    done
  done < <(locked_reqs "$SPEC")
  for f in "$PROBES"/*.sh; do
    [ -e "$f" ] || continue
    base=$(basename "$f"); case "$base" in _*) continue;; esac
    if ! grep -qF "$base" "$SPEC"; then echo "  RED  orphan probe $base — referenced by no requirement/gate (stale?)"; fail=1; fi
  done
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/probes"
  printf '%s\n' '- **R1** [locked] a thing. *Method:* Probed(.spec/probes/G-missing.sh). *Intent:* [auto] x.' > "$tmp/S.md"
  check "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1 && { echo "NEG FAIL: ungated locked req not caught"; exit 1; } \
    || echo "  neg-control ok: missing referenced probe -> RED"
  printf '#!/usr/bin/env bash\n' > "$tmp/probes/G-real.sh"
  printf '%s\n' '- **R1** [locked] a thing. *Method:* Probed(.spec/probes/G-real.sh). *Intent:* [auto] x.' > "$tmp/S.md"
  check "$tmp/S.md" "$tmp/probes" >/dev/null 2>&1 && echo "  pos-control ok: referenced probe exists -> GREEN" \
    || { echo "POS FAIL: coherent set flagged"; exit 1; }
  echo "RESULT: G5 self-test passed (non-vacuous)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
PROBES="${2:-$(dirname "$0")}"
echo "== probe G5: spec <-> probe coherence (D-57) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$PROBES" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — gate set OUT OF SYNC with the spec"; exit 1; }
echo "RESULT: GREEN — every locked requirement is gated (or deferred); no orphan gates"
