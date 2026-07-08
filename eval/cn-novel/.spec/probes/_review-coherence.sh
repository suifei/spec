#!/usr/bin/env bash
# Meta-probe — the independent-review closure leaves an AUDITABLE TRACE.
# For every [locked] requirement whose Method names an independent intent-review
# (独立…评审 / "independent review"), a .spec/evidence/review-<Rn>-*.md must exist AND
# cite BOTH a SPEC anchor (SPEC.md) and an artifact anchor (manuscript/…). This converts
# the review from honor-system ("just trust it ran") to auditable-trace: no file ⇒ RED
# (the review can't be shown to have happened); a bare "looks fine" with no citations ⇒ RED.
# (references/probes.md, independent-review sub-section; D-65.)
set -euo pipefail

check() {
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited
  while IFS= read -r entry; do
    case "$entry" in *"[locked]"*) ;; *) continue;; esac
    grep -qE '独立.{0,8}评审|independent[ -]?review' <<<"$entry" || continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$entry" | head -1 | tr -d '*')
    [ -z "$rid" ] && continue
    found=0; cited=0
    for trace in "$EVID"/review-"$rid"-*.md; do
      [ -e "$trace" ] || continue
      found=1
      grep -q 'SPEC\.md' "$trace" && grep -qE 'manuscript/' "$trace" && cited=1
    done
    if   [ "$found" -eq 0 ]; then echo "  RED  $rid needs an independent review but has NO .spec/evidence/review-$rid-*.md trace"; fail=1
    elif [ "$cited" -eq 0 ]; then echo "  RED  $rid trace exists but does not cite BOTH a SPEC anchor and an artifact anchor"; fail=1
    else echo "  OK   $rid -> review trace present, cites SPEC + artifact"; fi
  done < <(awk '
    /^- \*\*R/    { if(e!="") print e; e=$0; next }         # start of a requirement entry
    /^[[:space:]]+[^[:space:]]/ { if(e!="") e=e" "$0; next } # wrapped continuation -> join
    { if(e!=""){ print e; e="" } }
    END { if(e!="") print e }
  ' "$SPEC")
  return "$fail"
}

# --selftest: the probe must be able to go red — missing trace ⇒ RED, uncited trace ⇒ RED,
# cited trace ⇒ GREEN.
if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/evid"
  printf '%s\n' '- **R1** `[locked]` 角色不得泄漏其此刻无从得知的信息。' \
                '  *方法:* **WEAK**——独立意图评审对着本条意图核。' > "$tmp/SPEC.md"
  check "$tmp/SPEC.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: missing trace not caught"; exit 1; } \
    || echo "  neg-control ok: review-requiring req with no trace -> RED"
  printf 'verdict: MET\nspec-cite: SPEC.md R1\n' > "$tmp/evid/review-R1-x.md"   # uncited: no artifact anchor
  check "$tmp/SPEC.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: uncited trace not caught"; exit 1; } \
    || echo "  neg-control ok: trace missing artifact anchor -> RED"
  printf 'verdict: MET\nspec-cite: SPEC.md R1\nartifact-cite: manuscript/ch001.md — "…"\n' > "$tmp/evid/review-R1-x.md"
  check "$tmp/SPEC.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: cited trace -> GREEN" \
    || { echo "POS FAIL: cited trace flagged"; exit 1; }
  echo "RESULT: _review-coherence self-test passed"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
EVID="${2:-$(dirname "$0")/../evidence}"
echo "== meta-probe: independent-review trace coherence =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$EVID" || rc=$?
echo "----"
if [ "$rc" -ne 0 ]; then echo "RESULT: RED — a review-requiring requirement lacks a cited evidence trace"; exit 1; fi
echo "RESULT: GREEN — every independent-review requirement has a cited .spec/evidence/review-*.md trace"; exit 0
