# Probes — gathering real evidence for the human's decision (摸排探真)

A **probe** is a small, runnable check that confirms a source-of-truth/gate is
*real* by exercising it against the actual environment. Probes are how `/spec`
replaces "the user said so" with evidence. **The scout gathers the evidence; the
human makes the GO decision.** Probes inform decisions — they are not a
bureaucratic machine that blocks the human. But the scout never fabricates: a
probe reports the truth, red or green.

Probes live at `.spec/probes/<gate>.sh`; their captured output goes to
`.spec/evidence/<gate>-<timestamp>.log`. Both are committed.

## The one rule that makes a probe meaningful: it must be able to go red

A probe that cannot fail proves nothing. `npm test` against an always-green test
suite is **vacuous** — it stays green even when the behavior is wrong. So:

- **Every probe carries a negative control** — demonstrate it goes red when the
  thing is broken/absent (e.g. bind a port, then bind it again and require the
  second bind to fail; write to the real path, then to an impossible path and
  require an error). If you can't construct a red, the probe is vacuous — rewrite
  it or mark the gate unverified.
- **Adversarial self-review:** before trusting a probe, try to make it pass with a
  wrong implementation. If you can fool it, it's vacuous.
- **A gate probe targets a specific truth/scenario**, not "run the whole suite."

## Two kinds of truth

- **Existence / environment** (self-validating): does X exist / is it reachable /
  writable / the right version? The raw output *is* the fact (e.g. `SELECT 1`
  returned `1`; `df` shows 12G free). Hard to fake.
- **Behavioral correctness** (only as good as its assertion): does the code do the
  right thing? Here the probe must assert a concrete, spec-derived input→output
  and carry a negative control. If you can't yet write a meaningful behavioral
  assertion, the behavior isn't specified yet — leave the gate **open** (an open
  question / a later phase). "Can't write a real test" ⇒ "not closed", never
  "close it with a fake test."

## Every probe must

1. Be a standalone script: `set -euo pipefail`; **exit 0 = pass, non-zero = fail**.
2. **Print raw evidence** (resolved paths, versions, query results) — not just
   "PASS". A human/CI must be able to audit the facts.
3. Be **non-destructive, isolated, self-cleaning** (use `trap` to remove temp
   artifacts); confirm with the human before anything destructive, irreversible,
   production-touching, or secret-using.
4. **Never contain or echo secrets** — read credentials from env vars; redact.
5. **Record where/when it ran** (`date -u`, `hostname`, `uname`). A probe proves
   truth *on that machine at that time* — don't claim a devbox result holds for
   production; if the target is unreachable, probe a proxy or defer.
6. Carry a **negative control** (above).

## Standard preamble

```bash
#!/usr/bin/env bash
# Probe: <gate-id> — <what truth this proves>
set -euo pipefail
echo "== probe <gate-id> =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
```

## Example: a dependency/storage gate (with negative control)

```bash
#!/usr/bin/env bash
# Probe G1 — storage path is real and writable (chosen: SQLite @ ./data)
set -euo pipefail
DIR="${1:-./data}"; mkdir -p "$DIR"; ABS=$(cd "$DIR" && pwd)
echo "resolved: $ABS"; df -h "$ABS" | awk 'NR==2{print "free: "$4}'
TMP="$ABS/.probe_$$"; trap 'rm -f "$TMP"' EXIT
echo ok > "$TMP" && test "$(cat "$TMP")" = ok || { echo "write FAILED"; exit 1; }
# negative control: writing an impossible path must fail
if ( : > /proc/definitely/not/writable ) 2>/dev/null; then echo "NEG CONTROL FAILED"; exit 1; fi
echo "RESULT: storage writable"
```

## Recording

```bash
mkdir -p .spec/probes .spec/evidence
bash .spec/probes/G1.sh ./data 2>&1 | tee ".spec/evidence/G1-$(date -u +%Y%m%dT%H%M%SZ).log"
echo "exit: ${PIPESTATUS[0]}"
```

Copy the key evidence lines into the gate's entry in `SPEC.md`, set the status,
and note when/where it ran. Green ⇒ verified. Red ⇒ surface it as a finding for
the human's decision (redesign / defer to a phase / proceed with eyes open).

## Honest limit

A negative control fixes *per-probe* vacuity. It does **not** prove you probed
*everything* — coverage completeness is unprovable. `SPEC.md` is a **lower bound
on verified truth**, not a correctness proof. State this; don't let a green board
be over-trusted.
