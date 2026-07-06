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

## Every load-bearing acceptance needs a *method*, not just a description

Recording **what** to accept ("the status shows a warning color above 70%")
without recording **how** it is verified leaves a hole: a downstream builder
faced with prose and no runnable check falls back to *reading the source and
eyeballing it* — which passes code that is written-but-never-reached, or a listed
behavior that was silently skipped. So a load-bearing requirement's **acceptance
is itself a gate**: `/spec` must resolve it into exactly one of three states —
never leave it as prose alone:

1. **Probed** — a red-able check in `.spec/probes/<R>.sh` with a negative control.
2. **OPEN** — no red-able check is constructible yet ⇒ the requirement stays
   unclosed (an open question / a later phase), *visibly*. Never a silent pass.
3. **WEAK** — genuinely un-scriptable (a quality/subjective judgment) ⇒ a cited
   finding or a named human/LLM-judge sign-off, marked WEAK — honest, not a fake
   probe.

**Prose acceptance with no method is an incomplete requirement**, the same defect
as a gate with no evidence. Prove it by construction: if you cannot describe the
red for this acceptance, it is state 2 or 3, not a quiet green.

## Match the method to what the acceptance observes — at the *real* entrypoint

The modality is **derivable from the acceptance's nature** (decide it silently,
register `[auto]`; you already investigate the project, so you know its harness):

- **User-visible / interaction behavior** (a UI element, a status, a click flow)
  ⇒ **drive the actually-running product end-to-end** (e.g. Playwright against the
  running app) and assert what the *user* observes — **not** a component rendered
  in isolation or the source read by eye. Rendering `<X/>` in a unit test proves
  nothing about whether `<X/>` is mounted on the screen you actually use.
- **A pure function / module contract** ⇒ a unit probe asserting input→output.
- **A service / API / cross-process contract** ⇒ an integration probe hitting the
  real endpoint or seam.
- **A quality/subjective bar** ("is the payoff satisfying") ⇒ WEAK (above).

**The negative control must break the *wiring/reachability*, not only the logic.**
The failure that hides is "present but never reached": delete the mount / the
route / the call site and the probe must go **red**. If only corrupting the
internal logic turns it red, the probe is blind to orphaned features — rewrite it
to observe from the real entrypoint.

**"Build succeeds" and "all tests pass" are not acceptances.** They stay green
while a listed behavior is unimplemented (that is exactly how a missing behavior
slips through). Each behavior in the acceptance list earns its own red-able check;
a green build is a floor, never evidence that behavior *B* works.

## Non-code artifacts: instrument first, then the gate can go red

The artifact is not always code. It may be prose (a novel, a report), a
curriculum, a plan, a dataset. These have load-bearing gates too — "every planted
mystery is paid off before its deadline chapter", "every learning objective is
assessed", "every claim is sourced" — but they are **not machine-checkable by
default**, so the naive move is to shrug and mark them all WEAK, quietly losing a
gate that *could* have gone red.

**So for a non-code gate, the first step is to instrument the artifact** — design
a small, machine-checkable convention the probe can scan. In prose that means
lightweight tags in invisible comments (e.g. `<!-- ANCHOR:M2 deadline=6 -->` where
the setup is planted, `<!-- PAYOFF:M2 -->` where it lands); the probe greps them
and goes red on a dangling anchor. The convention is the price of a red-able prose
gate. A project unwilling to instrument keeps that gate **WEAK** (a named
human/LLM-judge read) — an honest degrade, chosen with eyes open, not a silent
collapse. Instrumenting the artifact is the non-code analog of wiring code to a
real entrypoint: without it, the gate cannot observe the thing it claims to prove.

## Phased gates: a long-range obligation is "pending", not red — but never forgotten

Some obligations come due far from where they are declared — a mystery planted in
chapter 1 resolved by chapter 40, a migration promised for a later release. Its
probe must be **position/time-phased**: **not red before its deadline** (an unmet
obligation that isn't due yet is not a failure), yet **tracked so it can't lapse**
— record every open obligation as a ledger entry (`id`, declared-at, due-at,
status open/closed) that the probe reads, so a due-and-unmet one goes red on the
dot and a not-yet-due one reports "pending". Losing the ledger is how a
1000-chapter payoff silently evaporates: the check must carry the obligation
across the whole span, not just the chapter it was planted in.

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
