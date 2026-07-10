#!/usr/bin/env bash
# Probe G5 — spec <-> probe coherence (D-57). The gate SET must match the CURRENT
# spec: every [locked] requirement whose Method references a .spec/probes/<X>.sh
# has that file; no probe file is orphaned (referenced by nothing in SPEC). RED
# on either — a stale set is a false green (the drift-detector drifting).
# (Template: references/coherence.template.sh; reference impl: eval/cn-novel/.spec/probes/_coherence.sh. D-69.)
set -euo pipefail

locked_reqs() {
  awk '/^- \*\*R/ { if(e!="") print e; e=$0; next }
       /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
       { if(e!=""){ print e; e="" } } END { if(e!="") print e }' "$1" | grep -F '[locked]'
}

# ---- parser-health guard (anti-vacuous-green) --------------------------------
# locked_reqs() is a brittle awk heuristic bound to a PARSER CONTRACT (a
# requirement = a list item whose first line matches `^- **R<n>.**` carrying
# `[locked]`). If SPEC.md drifts from that shape (headings instead of list items,
# a different bullet, fields wrapped across a blank line), locked_reqs() silently
# matches ZERO entries and the check() loop never runs -> GREEN over a spec the
# probe never parsed (the drift-detector's own vacuous-green). So make it the
# negative control: if the raw SPEC contains `[locked]` but locked_reqs()
# recognized none, the parser is blind -> RED. (probes.md "A gate is a proxy for
# an intent"; consistency-lens law 5.) Legitimately-zero-[locked] stays GREEN.
assert_parser_sane() {
  local SPEC="$1" n
  n=$(locked_reqs "$SPEC" | grep -c . || true)
  if [ "$n" -eq 0 ] && grep -qE 'R[0-9]+.*\[locked\]|\[locked\].*R[0-9]+' "$SPEC"; then
    echo "  RED  parser recognized ZERO locked reqs yet SPEC has a requirement tagged '[locked]' — requirement shape unrecognized (probe is blind, not green); align SPEC.md's requirement markdown with the PARSER CONTRACT or extend locked_reqs()"
    return 1
  fi
  return 0
}

check() {
  local SPEC="$1" PROBES="$2" fail=0 line refs deferred r base f
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r line; do
    refs=$(grep -oE '\.spec/probes/[A-Za-z0-9_-]+\.sh' <<<"$line" || true)
    [ -z "$refs" ] && continue
    # "not-yet-instantiated" markers: Phase/deferred/OPEN/WEAK, plus `实例化`
    # ("instantiate [at construction]", the cn-novel eval's convention). Waited, not RED.
    deferred=0; grep -qE 'Phase|实例化|OPEN|WEAK|deferred|⤳' <<<"$line" && deferred=1
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
  # parser-blindness: a SPEC whose [locked] req is in an UNRECOGNIZED shape (heading)
  # must RED — not silent GREEN because locked_reqs() matched zero. (assert_parser_sane)
  printf '%s\n' '### R1 [locked] heading form. *Method:* Probed(.spec/probes/G-real.sh). *Intent:* [auto] x.' > "$tmp/blind.md"
  check "$tmp/blind.md" "$tmp/probes" >/dev/null 2>&1 && { echo "NEG FAIL: parser-blind SPEC was silent GREEN"; exit 1; } \
    || echo "  neg-control ok: parser-blind SPEC -> RED"
  # prose-mention of [locked] (not a real tag) + only provisional reqs stays GREEN.
  printf '%s\n' 'Requirements carry the [locked] tag once evidence-backed.' '- **R1.** [provisional] first.' > "$tmp/prose.md"
  check "$tmp/prose.md" "$tmp/probes" >/dev/null 2>&1 && echo "  pos-control ok: prose [locked] mention -> GREEN" \
    || { echo "POS FAIL: prose-mention of [locked] false-RED'd"; exit 1; }
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
