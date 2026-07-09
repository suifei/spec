#!/usr/bin/env bash
# Probe G6 — requirement coherence (NEW, D-69). Every [locked] requirement
# carries BOTH an Intent field and a Method field (Probed/OPEN/WEAK) — never
# Acceptance alone. This catches the defect class where the spec's own format
# rule (SPEC.template.md §4 / probes.md "Every load-bearing acceptance needs a
# method") is silently unmet — the dogfood's R1–R5 historically lacked
# Intent/Method (P0-1: the independent-review keystone was unachievable on the
# dogfood's own requirements). RED if a [locked] req is Acceptance-only.
set -euo pipefail

locked_reqs() {
  awk '/^- \*\*R/ { if(e!="") print e; e=$0; next }
       /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next }
       { if(e!=""){ print e; e="" } } END { if(e!="") print e }' "$1" | grep -F '[locked]'
}

check() {
  local SPEC="$1" fail=0 entry has_intent has_method rid
  while IFS= read -r entry; do
    has_intent=0; has_method=0
    grep -qiE '\*Intent:|\*意图:' <<<"$entry" && has_intent=1
    grep -qiE '\*Method:|\*方法:'   <<<"$entry" && has_method=1
    rid=$(printf '%s' "$entry" | grep -oE '\*\*R[0-9]+' | head -1 | tr -d '*')
    [ -z "$rid" ] && rid="(unnamed)"
    if [ "$has_intent" -eq 0 ] || [ "$has_method" -eq 0 ]; then
      echo "  RED  $rid missing$( [ $has_intent -eq 0 ] && echo -n ' Intent' )$( [ $has_method -eq 0 ] && echo -n ' +Method' ) — Acceptance alone is an incomplete requirement"; fail=1
    else
      echo "  OK   $rid has Intent + Method"
    fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  printf '%s\n' '- **R1** [locked] a thing. *Acceptance:* it works. *(D1)*' > "$tmp/S.md"
  check "$tmp/S.md" >/dev/null 2>&1 && { echo "NEG FAIL: Acceptance-only locked req not caught"; exit 1; } \
    || echo "  neg-control ok: Acceptance-only -> RED"
  printf '%s\n' '- **R1** [locked] a thing. *Intent:* [auto] x. *Acceptance:* it works. *Method:* WEAK(cited). *(D1)*' > "$tmp/S.md"
  check "$tmp/S.md" >/dev/null 2>&1 && echo "  pos-control ok: Intent+Method -> GREEN" \
    || { echo "POS FAIL: complete req flagged"; exit 1; }
  echo "RESULT: G6 self-test passed (non-vacuous)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
echo "== probe G6: requirement coherence (Intent + Method present) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — a [locked] requirement lacks Intent or Method (prose-alone defect)"; exit 1; }
echo "RESULT: GREEN — every [locked] requirement carries Intent + Method"
