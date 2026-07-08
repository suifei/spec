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

```
acceptance's nature ─▶ method
  user-visible / interaction (UI element · status · click flow)
       ─▶ Probed(E2E): drive the actually-RUNNING product end-to-end (e.g. Playwright),
          assert what the USER observes — not a component in isolation, not source read by eye
  pure function / module contract   ─▶ Probed(unit): assert input→output
  service / API / cross-process     ─▶ Probed(integration): hit the real endpoint or seam
  quality / subjective bar ("is the payoff satisfying")  ─▶ WEAK (above)
```

Rendering `<X/>` in a unit test proves nothing about whether `<X/>` is mounted on
the screen you actually use — which is why the top row must observe from the real
entrypoint, not an isolated component.

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

## Canon: consistency over a *growing* corpus (a gate family in its own right)

Most gates ask "is this truth true?" at design time. A different, load-bearing
class asks **"does each new addition contradict what was already established?"** —
and it is the defining gate of anything that grows over time: a serial novel (a
character's name, eye colour, power rank, relationships), a wiki or knowledge base,
a multi-release system's public contracts, even a long spec. The characteristic
failure is a **quiet contradiction** buried 50 chapters (or 50 commits) after the
fact it breaks — invisible to any local read, exactly like an orphaned feature is
invisible to a unit test.

Gate it the same way you gate reachability: **instrument, then check against a
ledger.**
- Keep a **canon ledger** (a "story bible" / a facts-of-record file): each
  established fact = an entry (`subject`, `attribute`, `value`, `established-at`),
  plus which attributes are **immutable** (eye colour) vs **monotone** (a power
  rank only rises) vs **free**.
- Tag each addition (`<!-- CANON:name=… attr=… val=… -->`) and run a
  **contradiction probe**: an immutable attribute that changed, a monotone one that
  went backwards, or an identifier absent from the glossary → **red**. Its negative
  control is a synthetic contradiction (flip an eye colour, drop a rank) that must
  go red.
This catches the whole family — 人设崩塌 / 数值崩坏 / 姓名漂移 / 设定前后矛盾 — that no
"reads fine" pass will. Without the ledger the gate collapses to "trust the author's
memory across 100 chapters", which is how long works rot.

**Consistency is checkable even when *quality* is not.** Don't fold everything
subjective into one WEAK bucket. "Is the prose good / the character compelling / the
twist earned" is genuinely WEAK. But *consistency* of the same material — a single
POV person, one tense, terminology drawn from the glossary, a rank that never
regresses — is a **red-able sub-gate**. Split them: probe the consistency half, mark
only the taste half WEAK.

## A gate is a proxy for an intent — assume the builder optimizes the proxy

This is the general principle behind every "vacuous green" in this document; the
specific cases (an unmounted component that unit-passes, a prose-only acceptance, a
stale probe, a `——`-padded word count) are all **one failure wearing different
masks**, and the *next* one will look different again — so do not defend by
enumerating exploits. Defend by the principle.

**Every check is a proxy.** A probe, a metric, an acceptance is a *stand-in* for a
real intent it cannot fully capture. And the executor turning gates green is,
structurally, an **optimizer**: it will find the *cheapest* way to satisfy the
check, which can diverge arbitrarily from the intent (Goodhart's law — the moment a
measure becomes the target, it stops being a good measure). You cannot list the
ways it will diverge. Apply two moves that generalize to any gate, any domain:

1. **Author the gate adversarially — a pre-mortem.** For the gate in front of you:
   state the **intent** in one line, then ask *"what is the cheapest artifact that
   makes this gate green but a knowledgeable person would reject as not meeting the
   intent?"* If such a path exists, the check is only a **proxy**: either **harden
   the measure** to close that specific path (and make the cheat itself the probe's
   negative control — build the red by *doing the cheat*), or accept the check as a
   **floor** and require an intent-level review below. Run this reasoning per gate;
   the *procedure* transfers even though no fixed cheat-list does. (*Illustration,
   not a rule:* a "≥N chars" floor is trivially gamed by padding, so its probe also
   caps single-token frequency / separator runs / low lexical diversity — but a
   different metric will need a different hardening you derive the same way.)
2. **Verify the intent, not the letter.** Where the measure cannot fully capture the
   intent — quality, authenticity, "does it actually work / read / solve the
   problem" — that residue is **WEAK** (unscriptable), and an autonomous loop will
   *silently skip* it unless it is made part of "done." So make it one: an
   **independent, intent-level review**, whose single question is always *"does this
   achieve the requirement's purpose, or merely its measure?"* — open-ended, never a
   checklist. To keep that AI review trustworthy (the reason the pipeline distrusted
   AI review to begin with):
   - **Independent, clean context** — the reviewer is **not** the context that
     produced the artifact (that context has an incentive to pass itself and
     remembers its own shortcuts). A fresh reviewer reading **only** `SPEC.md` + the
     artifact + the build state, **from disk itself** (given the *paths*, not content
     the producing context relays — a sanitized copy defeats the independence).
     Mechanism: a fresh **`general-purpose`** sub-agent
     by default (the universally-available agent type — do **not** assume a
     specialized `code-reviewer`/`reviewer` agent type exists, that call errors
     out), or an equivalent headless process. **Never a self-review.**
   - **Adversarial and intent-anchored** — its job is to decide whether the *purpose*
     is genuinely met and to *find* where only the letter was satisfied. Known
     tricks (padding, filler, faked/skipped requirements, hollow output that
     technically passes) are **priming examples, explicitly non-exhaustive** — it
     reasons from intent, it does not tick a list.
   - **Cited evidence, not a verdict — leave an auditable trace** — it quotes the
     offending (or, on a pass, the corroborating) passage/line; a bare "looks fine" is not
     evidence (words never are). Write the sign-off to `.spec/evidence/review-<Rn>-<ts>.md`
     citing **both** (1) the requirement + its recorded **Intent** in `SPEC.md`, and (2) the
     artifact location (section/line/quote). This makes the review *auditable*: no trace ⇒ the
     review can't be shown to have happened — a coherence probe over `.spec/evidence/review-*.md`
     goes **red** on a done review-requiring requirement with a missing/uncited trace (reference
     implementation: `eval/cn-novel/.spec/probes/_review-coherence.sh`).

**Defense in depth.** The hardened measure is cheap, deterministic, catches the
crude gaming; the intent review catches the subtle miss a probe can't (output that
clears every mechanical bar and is still hollow, off-purpose, or faked). Both gate
"done"; a green measure with no intent review is exactly how a gamed artifact ships.

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

**And the same limit applies to this pipeline's own anti-cheat closure — say so.**
The independent-review + done-gating that guards generated/quality work is
**probabilistic, dependent on the executor model actually following these
instructions — not a mechanical guarantee.** A determined or budget-starved
optimizer can still satisfy the cheapest reading (run the review for show, or
skip it). The review-trace probe (above) makes the closure **auditable, not
certain** — no trace ⇒ red, but a present trace proves a review happened, not
that it was honest. Hold this pipeline to the same standard it holds user
projects: a lower bound on verified truth, not a correctness proof.
