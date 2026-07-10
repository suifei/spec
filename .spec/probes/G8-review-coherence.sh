#!/usr/bin/env bash
# Probe G8 — review-trace coherence (D-65, hardened D-74). Every review-requiring
# [locked] requirement (carries a *Review:* field, or names an independent intent-
# review) must have a cited .spec/evidence/review-<Rn>-*.md that reckons the recorded
# Intent AND quotes a concrete artifact passage — not merely names SPEC + artifact
# (that hollow trace is the cheapest forgery: a fake review; it goes RED, and is the
# selftest's negative control). No file => the review can't be shown to have happened.
# (Template: references/coherence.template.sh; reference impl: eval/cn-novel/.spec/probes/_review-coherence.sh. D-69/D-74.)
# Note: this dogfood's R1–R5 are contract requirements (Method WEAK), not
# generative/quality work, so none name an independent review — the probe is
# GREEN trivially here and exists to catch a future review-requiring requirement.
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
  local SPEC="$1" EVID="$2" fail=0 entry rid trace found cited is_l2 eng prod revw
  assert_parser_sane "$SPEC" || return 1
  while IFS= read -r entry; do
    # review-requiring? structured *Review:* field (with a value), or the legacy phrase
    grep -qiE '\*Review:\*?[[:space:]]*\S|独立.{0,8}评审|independent[ -]?review' <<<"$entry" || continue
    rid=$(grep -oE '\*\*R[0-9]+' <<<"$entry" | head -1 | tr -d '*')
    [ -z "$rid" ] && continue
    is_l2=0
    grep -qiE '\*Review:\*?[[:space:]]*L2' <<<"$entry" && is_l2=1
    found=0; cited=0; eng=0
    for trace in "$EVID"/review-"$rid"-*.md; do
      [ -e "$trace" ] || continue
      found=1
      # NB: L2 classification comes ONLY from the SPEC entry's *Review:* field (set
      # above) — never from this trace. The trace is the artifact under inspection;
      # letting it self-declare "level: L2" would escalate an honest L1 req and
      # false-RED it (A1-1). is_l2 is fixed for the whole requirement now.
      # cited iff it anchors to SPEC AND reckons Intent AND quotes a concrete passage
      if grep -qi 'SPEC\.md' "$trace" && grep -qiE 'intent:|意图:' "$trace" \
         && grep -qE '^[[:space:]]*> |quote:|引用:|anchor:|line[[:space:]]*:|§|ch[0-9]+|章节|manuscript/|src/|[a-z0-9_-]+/[a-z0-9_.-]+\.(md|txt)' "$trace"; then
        cited=1
      fi
      # L2 (judgment-independent) must name a DISTINCT reviewer engine vs producer — the
      # machine-checkable proxy for "a different judgment basis." Relabeling an L1 (same
      # model, clean context) as L2 is the forgery this catches. (A2; floor, not certainty
      # — the engine strings can still be lied about; see probes.md Honest limit.)
      if [ "$is_l2" -eq 1 ]; then
        prod=$(grep -oiE '^producer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        revw=$(grep -oiE '^reviewer-engine:[[:space:]]*[^[:space:]]+' "$trace" | head -1 | sed 's/^[^:]*:[[:space:]]*//')
        { [ -n "$prod" ] && [ -n "$revw" ] && [ "$prod" != "$revw" ]; } && eng=1
      fi
    done
    if   [ "$found" -eq 0 ]; then echo "  RED  $rid needs an independent review but has NO review-$rid-*.md trace"; fail=1
    elif [ "$cited" -eq 0 ]; then echo "  RED  $rid trace exists but is hollow — must cite SPEC + reckon Intent + quote a concrete artifact passage"; fail=1
    elif [ "$is_l2" -eq 1 ] && [ "$eng" -eq 0 ]; then echo "  RED  $rid is *Review:* L2 (judgment-independent) but no trace declares distinct producer-engine: and reviewer-engine: — relabeling an L1 (same model) as L2 is the forgery this catches"; fail=1
    else echo "  OK   $rid -> review trace reckons Intent + cites SPEC + quotes artifact$([ "$is_l2" -eq 1 ] && echo " + distinct L2 engines")"; fi
  done < <(locked_reqs "$SPEC")
  return "$fail"
}

if [ "${1:-}" = "--selftest" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT; mkdir -p "$tmp/evid"
  # parser-blindness: a SPEC whose [locked] req is in an UNRECOGNIZED shape (heading)
  # must RED — not silent GREEN because locked_reqs() matched zero. (assert_parser_sane)
  printf '%s\n' '### R1 [locked] heading form. *Method:* WEAK(cited). *Review:* L1. *Intent:* [auto] x.' > "$tmp/blind.md"
  check "$tmp/blind.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: parser-blind SPEC was silent GREEN"; exit 1; } \
    || echo "  neg-control ok: parser-blind SPEC -> RED"
  # prose-mention of [locked] (not a real tag) + only provisional reqs stays GREEN.
  printf '%s\n' 'Requirements carry the [locked] tag once evidence-backed.' '- **R1.** [provisional] first.' > "$tmp/prose.md"
  check "$tmp/prose.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: prose [locked] mention -> GREEN" \
    || { echo "POS FAIL: prose-mention of [locked] false-RED'd"; exit 1; }
  printf '%s\n' '- **R1** [locked] a thing. *Method:* WEAK(cited). *Review:* L1. *Intent:* [auto] x.' > "$tmp/S.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: missing review trace not caught"; exit 1; } \
    || echo "  neg-control ok: review-requiring req with no trace -> RED"
  # FORGERY (negative control): a hollow trace that only names SPEC + artifact -> RED
  printf 'ref: SPEC.md R1\nartifact: manuscript/ch1.md\nlooks fine\n' > "$tmp/evid/review-R1-x.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: hollow/forget trace not caught"; exit 1; } \
    || echo "  neg-control ok: hollow trace (no Intent reckoning, no quote) -> RED"
  # honest trace: reckons Intent + quotes a passage -> GREEN
  printf 'ref: SPEC.md R1\nintent: the purpose is met, not metric-gamed\n> "the concrete quoted passage from ch1"\n' > "$tmp/evid/review-R1-x.md"
  check "$tmp/S.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: trace reckons Intent + quotes artifact -> GREEN" \
    || { echo "POS FAIL: cited trace flagged"; exit 1; }
  # L2 (judgment-independent) forgery (A2): same producer/reviewer engine (relabeled L1) -> RED;
  # distinct engines -> GREEN.
  printf '%s\n' '- **R2** [locked] generated quality. *Method:* WEAK(cited). *Review:* L2. *Intent:* [auto] x.' > "$tmp/S2.md"
  printf 'ref: SPEC.md R2\nlevel: L2\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-sonnet-5\nintent: met\n> "passage"\n' > "$tmp/evid/review-R2-x.md"
  check "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1 && { echo "NEG FAIL: L2 same-engine not caught"; exit 1; } \
    || echo "  neg-control ok: L2 same-engine (relabeled L1) -> RED"
  printf 'ref: SPEC.md R2\nlevel: L2\nproducer-engine: claude-sonnet-5\nreviewer-engine: claude-opus-4-8\nintent: met\n> "passage"\n' > "$tmp/evid/review-R2-x.md"
  check "$tmp/S2.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: L2 distinct engines -> GREEN" \
    || { echo "POS FAIL: L2 distinct-engine trace flagged"; exit 1; }
  # A1-1 regression guard: an HONEST L1 req whose trace carries a stray 'level: L2'
  # line must stay GREEN — only the SPEC's *Review:* field decides L1 vs L2.
  printf '%s\n' '- **R3** [locked] thing. *Method:* WEAK(cited). *Review:* L1. *Intent:* [auto] x.' > "$tmp/S3.md"
  printf 'ref: SPEC.md R3\nlevel: L2\nintent: met\n> "passage"\n' > "$tmp/evid/review-R3-x.md"
  check "$tmp/S3.md" "$tmp/evid" >/dev/null 2>&1 && echo "  pos-control ok: L1 req + stray L2-trace level -> GREEN (trace can't escalate)" \
    || { echo "POS FAIL: L1 req false-RED'd by trace's level: L2"; exit 1; }
  echo "RESULT: G8 self-test passed (non-vacuous, forgery caught)"; exit 0
fi

SPEC="${1:-$(dirname "$0")/../../SPEC.md}"
EVID="${2:-$(dirname "$0")/../evidence}"
echo "== probe G8: review-trace coherence (D-65, hardened D-74) =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "----"
rc=0; check "$SPEC" "$EVID" || rc=$?
echo "----"
[ "$rc" -ne 0 ] && { echo "RESULT: RED — a review-requiring requirement lacks a cited, non-hollow evidence trace"; exit 1; }
echo "RESULT: GREEN — every review-requiring requirement has a cited trace that reckons Intent + quotes the artifact"
