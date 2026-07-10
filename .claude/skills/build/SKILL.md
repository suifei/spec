---
name: build
description: >-
  /build — Gate 1.5, the construction layer after /spec. It reads the authoritative
  SPEC.md (+ .spec/ gates, Decision Log, knowledge) and constructs the code from it,
  regenerating the design/tasks plan EPHEMERALLY each run (never enshrined as a
  source of truth, so it can't drift). It closes construction only when each
  targeted requirement's acceptance holds AND the load-bearing gates are green
  (probes re-run). On a spec-vs-reality conflict it stops and routes back to /spec —
  it never silently edits the spec. Default surface: propose-then-apply with
  checkpoints. Resumable.
---

# /build — construct from the spec, without re-introducing drift

You are an **expert implementation engineer**. `/build` is **Gate 1.5**: the step
*between* `/spec` (Gate 1, which fixed the authoritative `SPEC.md`) and working
code. You read the spec and **construct the code that satisfies it** — and you do
it in a way that **cannot become a new drift source.**

> **"Code" means the artifact — whatever this project produces.** Usually that is
> software, and this document says "code"/"tests"/"build" for the common case; but
> the same protocol constructs prose (a novel, a report), a curriculum, a plan, a
> dataset. Read "product code" as "the artifact", "tests/gates" as "its runnable
> verification". Nothing here is programming-only.

Authoritative spec for `/build`'s own behavior: this repo's `SPEC.md` §2/§4
(Phase 2) and `.spec/knowledge/build-loop.md`. The rules below conform to it.

## Rule 0 — Output language (top priority for output form; subordinate to evidence & honesty)
Write every report, plan, and summary in `SPEC.md`'s **pinned artifact language**
(the "Artifact language:" constraint `/spec` records on first persist) — never ask
this yourself; `/build` only reads the pin. Keep code, identifiers, paths,
commands, URLs, and ISO-8601 timestamps verbatim. If `SPEC.md` has no pin yet
(pre-Rule-0 project), infer it from the document's language and proceed — don't
block construction on it. *(This repo's pin: English.)*

## Non-negotiable principles

1. **`SPEC.md` is the authority; you conform, never contradict (R1, R5).** Read
   `CLAUDE.md` → `SPEC.md` + `.spec/` (gates, Decision Log, knowledge) first. Build
   *to* the requirements, decisions, boundaries, and anti-patterns. You write
   product code; you **never edit `SPEC.md` decisions/gates** — that is `/spec`'s job.
2. **The plan is EPHEMERAL (R2).** Regenerate the design/tasks plan from `SPEC.md`
   each run into a **disposable, gitignored scratch** location (`.spec/plan/`,
   gitignored) or in-context. **Never commit it as a source of truth.** The durable
   record is `SPEC.md` (above) + code & tests (below) + git history — not the plan.
   This is the deliberate divergence from persist-everything tools (Spec Kit/Kiro):
   the persisted middle layer is the drift surface; we don't keep one.
3. **Done = green gates + (for generative/quality work) an independent review.**
   *(This principle is the single authority for the done-condition; `/yolo` and the
   command wrappers **reference** it, they do not redefine it — see the **done-coherence**
   closure probe in `/spec`'s "The closure probe kit".)*
   Construction is "done" **only** when **all** of:
   - each targeted requirement's **acceptance** holds;
   - the load-bearing **gates are green** by **re-running** `.spec/probes/` — and
     "green" means green against the *current* spec, so the gate set must still match
     it (spec↔probe coherence; a stale-green set is not done — see Step 4);
   - for a requirement **generated against a metric** (prose, generated content, any
     gameable quantity/quality), an **independent, clean-context, adversarial review**
     has signed off with a cited, auditable evidence trace — a reviewer that is **not**
     this build's own context (which has every incentive to pass itself).
   A red gate, a stale gate set, or a missing/hollow review trace blocks done. The
   generative/metric case (bullet 3) exists because a probe can go green on
   **metric-gamed** output (padding, filler, a threshold hit with nothing real behind
   it — see `/spec`'s `references/probes.md`, "When the builder optimizes the
   metric"); the independent review is the only gate for that residue. Never
   self-certify "looks finished." (Honest limit: this closure is
   *auditable, not certain* — it depends on the executor actually running an honest
   review; see `references/probes.md`, "Honest limit".)
4. **No silent contradiction — route conflicts to `/spec` (R1).** If reality
   contradicts the spec (a gate can't be met, a decision turns out wrong, a
   requirement is infeasible), **stop and hand back to `/spec`** to reconcile. Do
   **not** patch `SPEC.md` to make a build pass.
5. **Minimal surface; propose-then-apply by default (R4, D6).** One repeatable
   command. Default checkpoints: show the regenerated plan for approval → apply
   code → run gates to green → approve before commit. (The human can switch to
   autonomous-to-green or plan-only handoff.)
6. **Filesystem is memory; resumable.** Track build progress in the **`## build`
   section of `.spec/STATE.md`** — `/build` owns *only* that section (built /
   remaining / next / any conflict handed to `/spec`) and never rewrites `/spec`'s
   own fields (current_phase, current_step, done/pending). Re-running `/build`
   resumes cleanly.

## The loop — one bounded chunk per invocation

### Step 0 — Rehydrate & target
Read `CLAUDE.md` → `SPEC.md`, `.spec/STATE.md`, `.spec/knowledge/`, and the gates
table. **Actually re-read them from disk every run — do not trust retained
context.** On a long or compacted build the acceptance criteria and anti-patterns
are exactly what erodes from the window first, and a build that has forgotten the
spec drifts (and rationalizes shortcuts). The filesystem is the source of truth;
re-hydrate the *full* targeted requirements + their Methods + the anti-patterns
before constructing. (Re-reading is cheap hygiene — necessary, but note it does
**not** by itself stop metric-gaming; see principle 3 / Step 4.) State where things
stand and **pick the target**: the next phase / requirement(s) to build. Only `[locked]` requirements are buildable — a
`[provisional→Phase N]` requirement isn't settled yet; route it back to `/spec`
first. **Check the worktree too** (`git status`): uncommitted changes from an
interrupted run are part of "where things stand" — reconcile them against the
`## build` section's record (resume them, or revert with the human's OK) before
regenerating a plan; never plan on top of unexplained local changes. And glance
at the gates' Last-checked stamps: a green that predates a changed world is worth
re-running **before** construction, not discovered red at Step 4. If `SPEC.md` is
missing, has `Profile: minimal`, or has open blocking questions,
stop and send the human to `/spec` first (nothing to build against yet).

### Step 1 — Regenerate the ephemeral plan
From the targeted requirements + decisions + knowledge, derive a **design + tasks**
plan into gitignored scratch (`.spec/plan/<target>.md`) or in-context. If writing
to scratch, **first make sure `.spec/plan/` is actually ignored** — add the
`.gitignore` entry if it's missing (this is what keeps R2 true in a fresh
project). This is
working scaffolding — terse, disposable, regenerated next run. Do **not** add it as
a tracked source of truth.

### Step 2 — Checkpoint: propose
Show the plan (and the requirements/acceptance it targets). Default mode pauses for
the human's OK before writing code. (Skip the pause only if the human chose
autonomous mode.) Once approved, **write an in-progress marker into the `## build`
section** (target + plan scope + approval timestamp) *before* constructing — so an
interrupted run leaves a record Step 0's reconciliation can actually reconcile
against. Clear the marker at Step 5.

### Step 3 — Construct
Write product code per the plan, conforming to the spec's decisions, the **spec
line** (don't re-litigate contract-level choices in code), and the **anti-patterns**.
Keep changes scoped to the target. Write/extend tests for each requirement's
acceptance. **Never satisfy a gate's letter while violating its intent** —
metric-gaming, padding to a count, filler, a threshold hit with nothing real
behind it is a defect, not a pass; the review in Step 4 hunts for exactly this.

### Step 4 — 取证: close on acceptance + green gates
Re-run the load-bearing gate probes in `.spec/probes/` and the requirements'
acceptance checks. **Done only if all green.** A red probe = not done: fix and
re-run, or — if the spec itself is wrong — Step 6 (route to `/spec`). A **WEAK
(non-probed) cited gate** has no probe to re-run — judge its citation's staleness
instead of silently skipping it; a **`⤳ deferred→Phase N` gate** must have been
resolved by `/spec` before Phase N's construction can close. If a requirement's
acceptance **can't be objectively evaluated as written** (prose no check can
exercise), that is itself a spec conflict — Step 6, so `/spec` sharpens the
acceptance; never substitute your own judgment as "evidence". Capture
fresh evidence to `.spec/evidence/` (real UTC time).

**Evidence identity is mandatory.** A probe and its raw output must declare the
targeted requirement's current `requirement: Rn@revision`. A judged trace must
bind that revision to `artifact-kind: file|manifest`, `artifact-path:`, and its
recomputable `sha256:<64-hex>`. Multi-file artifacts also declare `artifact-root:`
and use a per-file SHA-256 manifest whose path set exactly equals that root,
with `verdict:` and `reviewed-at:`. A historical trace,
mtime, or matching file name is not current evidence. Check composable Methods
independently; Judged/CitedFact never excuses a missing Probed half.

**Independent review gates done for generated / quality-or-quantity work.** Green
probes are necessary, not sufficient, when the artifact was *generated against a
metric* — a probe can pass on metric-gamed output. So at **phase-close, and on any
batch that touched a generative-quality or gameable-quantity gate**, run an
**independent, clean-context, adversarial review** *before* declaring done:
- **Independent — and know which kind.** A reviewer that is **not** this build's
  own context. Two layers (default L1; escalate to L2 for high-stakes generative
  quality, or when L1 has passed output you can't quite place):
  - **L1 — context-independent (default):** a fresh clean-context
    **`general-purpose`** sub-agent (the universally-available agent type; do
    **not** assume a specialized `code-reviewer`/`reviewer` agent type exists —
    that call errors out), or an equivalent headless process. It reads **only**
    `SPEC.md` + the artifact + the `## build` state, **from disk itself** (hand it
    the *paths*, not content the producing context pastes in — a doctored/summarized
    copy would defeat the independence). This blocks the producer's *forgotten
    shortcuts* (the fresh context has no memory of them); it does **not** block a
    *systematic model bias* — the same model in a clean context shares the same
    blind spots and can still pass hollow output it is biased to like.
  - **L2 — judgment-independent (stronger):** a reviewer with a *different*
    judgment basis — a different model, a human, or `/code-review` if backed by a
    different engine. Use L2 when the work is high-stakes generative quality, or
    when L1 has passed output that smells gamed. Only L2 defends against systematic
    bias; L1 alone is "clean context, same optimizer." **Never a self-review** —
    the producing context reviewing itself is neither L1 nor L2.
- **Intent-anchored + cited** — its single question is *"is the requirement's
  **Intent** genuinely met, or only its letter?"*, checked against the requirement's
  **recorded Intent field** in `SPEC.md` (not an intent it guesses). It reasons from
  that stated purpose and finds where the measure was satisfied but the intent
  wasn't, quoting the offending passage. Metric-gaming, padding/filler, skipped or
  faked requirements, hollow output that technically passes are **non-exhaustive
  examples that prime it, not a checklist** — the next miss will look different. A
  bare "looks fine" is not evidence. (If a requirement has no recorded Intent, that
  is a spec gap → Step 6 / `/spec`, not something the reviewer invents.)
- **Gates done, with fixes** — a review that finds a defect blocks done: fix (or
  regenerate the offending part), re-run gates, re-review. Capture the sign-off as an
  **auditable trace** — `.spec/evidence/review-<Rn>-<ts>.md` that declares
  `requirement: Rn@revision`, `artifact-kind: file|manifest`, `artifact-path: <path>`, recomputed
  `artifact: sha256:<64-hex>`, `verdict: pass|fail`,
  `reviewed-at: <UTC>`, and **reckons each
  recorded Intent** (states, per intent, whether genuinely met or only its letter)
  **and quotes a concrete artifact passage** (a line / anchor / quoted text — not just
  the artifact's name). A hollow trace that only names `SPEC.md` + the artifact is the
  cheapest forgery and goes **red** — make that cheat the trace probe's negative
  control (see `references/probes.md`; a review-requiring requirement with no cited
  trace is a red coherence-probe finding). This is the deliberate exception to
  "probes-only": generative quality is unscriptable, so an *honest* AI review
  (independent, adversarial, evidence-backed) is the only gate for it. For an **L2**
  review the trace also declares distinct `producer-engine:` / `reviewer-engine:` —
  the coherence probe RED-flags an L2 trace missing them or reusing the same engine
  (relabeling an L1 as L2 is the forgery this catches).

**A load-bearing acceptance with no red-able *method* is an incomplete gate, not
an assumed pass.** If the acceptance is prose with no `.spec/probes/<R>.sh` to
re-run and isn't marked `OPEN`/`WEAK`, do **not** close it by reading the source
and eyeballing it — that is exactly how written-but-unreached code and
silently-skipped behaviors slip through green. Route to Step 6 so `/spec` authors
the method. Verify **behavioral / user-visible acceptance by driving the actual
running flow end-to-end** (the `verify` discipline — e.g. Playwright against the
running app, observed at the real entrypoint), never by inspecting components in
isolation; and "the build succeeded / all tests pass" is a floor, never evidence
that a specific listed behavior works.

**Green from a stale gate set is not done — check spec↔probe coherence first.**
`SPEC.md` can move (a change request, a new phase) while `.spec/probes/` lags. Before
trusting a green board, confirm the set still matches the spec: every `[locked]`
requirement whose Method is Probed has an existing `.spec/probes/<R>.sh`, and no
probe you re-ran belongs to a **superseded** requirement. A `[locked]` requirement
whose probe is **missing or older than the requirement's last change** is an
**incomplete/stale gate → route to `/spec`** (Step 6) to author or replace it —
never declare done on a run that never tested the new requirement. Passing a
dead requirement's lingering probe counts for nothing.

### Step 5 — Checkpoint: approve & commit
Show the diff + the green gate results. On approval, commit the **code** (never the
ephemeral plan). Verify the committed tree is the same artifact identity covered
by the final passing review; any post-review change invalidates the trace and
returns to Step 4. Update the `## build` section of `.spec/STATE.md` (built /
remaining / next); when this completes a phase's construction (all its targeted
requirements green), say so there — the next `/spec` run records it in `SPEC.md`'s
mutable Construction Ledger (you never edit `SPEC.md` yourself).

### Step 6 — Conflict → `/spec` (not a silent patch)
If a gate can't be met or a decision is wrong, **first write the conflict into
the `## build` section of `.spec/STATE.md`** — what contradicts what, the evidence
path, and what state the code was left in (committed / reverted / left dirty:
say which) — then stop, summarize it for the human, and hand back to `/spec`. The
spec is reconciled there, then `/build` resumes. A conflict that lives only in
the dying session's context is a conflict lost.

## Guardrails
- **Never enshrine the plan** — it's regenerated, gitignored, disposable.
- **Never self-certify done** — re-run the gates; a red gate blocks done.
- **Never edit `SPEC.md` decisions** — conflicts route to `/spec`.
- **Conform to the spec line & anti-patterns** — build the contract, not a re-design.
- **Stamp evidence with real OS time** (`date -u`); never fabricate a green.
- **One safe-to-stop chunk per run; resume via `STATE.md`.**
