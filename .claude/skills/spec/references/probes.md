# Probes — the executable instrument of investigation

Investigation **is** research (探真 = 研究): you find the truth by every means —
your knowledge, the web, the project's own data, skills/MCP, reasoning. A
**probe** is *one* of those means: the **executable** one — a small, runnable
check that confirms a truth by exercising it against the actual environment.
Reach for a probe when the truth is **environment- or behavior-specific** and
**load-bearing**; it is the strongest evidence there is, but it is **not** the
definition of investigation, and most truths are settled by research and
reasoning without one. Never reduce "探真" to "run a check."

**Probe only what earns a gate.** A probe is worth writing only for a gate that is
load-bearing, uncertain, and consequential-if-wrong (see SKILL.md "What earns a
gate"). Do **not** write probes for commonsense facts — a free port, a writable
dir, a tool on PATH, a stock library doing its documented thing. You may verify
such a thing in passing, but it stays a footnote: never a gate, never a focus of
downstream coding. *We do not build the project around whether a port is free.*

The scout gathers evidence; the human makes the GO call on a genuine fork. A probe
informs that decision — it is not a bureaucratic machine that blocks the human —
and it never fabricates: it reports the truth, red or green.

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
5. **Record where/when it ran** with **real OS time in UTC** — never a guessed
   timestamp. Use the platform's date command: `date -u` on Unix/macOS/Linux/WSL/
   git-bash; `(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")` in
   Windows PowerShell. Also record `hostname`/`uname`. A probe proves truth *on
   that machine at that time* — don't claim a devbox result holds for production;
   if the target is unreachable, probe a proxy or defer. The evidence timestamp is
   what later lets `/spec` judge whether this green is fresh or stale.
6. Carry a **negative control** (above).

## Standard preamble

```bash
#!/usr/bin/env bash
# Probe: <gate-id> — <what truth this proves>
set -euo pipefail
echo "== probe <gate-id> =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
```

## Example: a load-bearing gate (refutes an assumption, with negative control)

A good probe targets an assumption the **design rests on** — one that, if false,
makes you build something different. The archetype is refuting a stated premise
(like "this ships as a native app" turning out untrue). Here: the design assumes
on-device GPU compute; if absent, the whole inference approach changes.

```bash
#!/usr/bin/env bash
# Probe G1 — does reality support the assumption the design rests on?
# Assumption under test: "the target host has usable GPU compute."
# If false, the on-device inference design is wrong — THIS is gate-worthy.
# (A "port is free" / "dir is writable" check is NOT — never gate those.)
set -euo pipefail
echo "== probe G1: GPU compute available =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"; echo "----"
command -v nvidia-smi >/dev/null || { echo "nvidia-smi NOT found — assumption refuted"; exit 1; }
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || { echo "no usable GPU"; exit 1; }
# negative control: a GPU index that cannot exist must NOT report present
if nvidia-smi -i 999 >/dev/null 2>&1; then echo "NEG CONTROL FAILED: bogus GPU index reported OK"; exit 1; fi
echo "neg-control: bogus GPU index rejected"
echo "RESULT: GPU compute present — assumption holds"
```

## Recording

```bash
mkdir -p .spec/probes .spec/evidence
bash .spec/probes/G1.sh 2>&1 | tee ".spec/evidence/G1-$(date -u +%Y%m%dT%H%M%SZ).log"
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
