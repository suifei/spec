#!/usr/bin/env bash
# Probe G-antidegeneracy — a chapter must be real prose, not metric-gamed filler.
# The cheap way to hit a "≥N chars/chapter" floor is to pad with separators (e.g. '——') or
# repeat one character. This is Goodhart: the count goes green on noise. RED when a chapter is
# degenerate: em-dash '—' density too high, or one character dominates, or a long separator run.
# NOTE: this is the FLOOR (mechanical, cheap). Generative QUALITY still needs an independent
# adversarial review — see /spec references/probes.md ("When the builder optimizes the metric").
set -euo pipefail

analyze() {  # analyze <file> ; exit 0 = ok, 1 = degenerate. prints one line.
python3 - "$1" <<'PY'
import sys, re, collections
t = open(sys.argv[1], encoding='utf-8').read()
t = re.sub(r'<!--.*?-->', '', t, flags=re.S)   # drop instrumentation tags
t = re.sub(r'^\s*#.*$', '', t, flags=re.M)      # drop markdown headers
chars = [c for c in t if not c.isspace()]
n = len(chars)
if n < 60:
    print(f"  skip {sys.argv[1]} (n={n} too small)"); sys.exit(0)
dash = sum(1 for c in chars if c == '—')
top_c, top_n = collections.Counter(chars).most_common(1)[0]
longest = max((len(m.group(0)) for m in re.finditer(r'—+', t)), default=0)
dash_r, top_r = dash/n, top_n/n
bad = dash_r > 0.10 or top_r > 0.25 or longest > 8
tag = "RED " if bad else "OK  "
print(f"  {tag}{sys.argv[1]}: n={n} dash={dash_r:.2f} top={top_c!r}:{top_r:.2f} run={longest}")
sys.exit(1 if bad else 0)
PY
}

if [ "${1:-}" = "--selftest" ]; then
  echo "== G-antidegeneracy negative control =="
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  # real prose -> GREEN
  printf '%s\n' '林辰站在偏院的院中,凝元境的太虚剑意在他掌心缓缓凝聚,与通脉境那空洞的一式截然不同,他闭目感受着元气如江河奔涌,心中已有了破关的定计,只待今夜。' > "$tmp/ch001.md"
  analyze "$tmp/ch001.md" >/dev/null || { echo "POS CONTROL FAILED: real prose RED"; exit 1; }
  echo "  pos-control ok: real prose GREEN"
  # '——' padded filler (the actual cheat) -> RED
  printf '%s\n' '林——辰——站——在——观——测——窗——前——看——着——逐——渐——远——去——的——暗——渊——星——域——已——经——变——得——和——其——他——星——域——一——样——' > "$tmp/ch002.md"
  if analyze "$tmp/ch002.md" >/dev/null; then echo "NEG CONTROL FAILED: '——' padding GREEN"; exit 1; fi
  echo "  neg-control ok: '——' padding RED"
  echo "RESULT: G-antidegeneracy self-test passed (real prose GREEN, filler RED)"; exit 0
fi

echo "== probe G-antidegeneracy: chapters are real prose, not filler =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
MS_DIR="${1:-$(dirname "$0")/../../manuscript}"; fail=0
for f in "$MS_DIR"/ch*.md; do analyze "$f" || fail=1; done
echo "----"
[ "$fail" -eq 0 ] && { echo "RESULT: GREEN — no degenerate/filler chapter"; exit 0; } || { echo "RESULT: RED — metric-gamed/filler chapter present"; exit 1; }
