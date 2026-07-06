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

## Rule 0 — Output language (highest priority)
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
3. **Done = acceptance + green gates (R3).** Construction is "done" **only** when
   each targeted requirement's acceptance holds **and** the load-bearing gates are
   green — by **re-running** `.spec/probes/`. Never self-certify "looks finished."
   A red gate blocks done. (This is the load-bearing invariant — repo gate G2.)
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
table. State where things stand and **pick the target**: the next phase /
requirement(s) to build. Only `[locked]` requirements are buildable — a
`[provisional→Phase N]` requirement isn't settled yet; route it back to `/spec`
first. **Check the worktree too** (`git status`): uncommitted changes from an
interrupted run are part of "where things stand" — reconcile them against the
`## build` section's record (resume them, or revert with the human's OK) before
regenerating a plan; never plan on top of unexplained local changes. And glance
at the gates' Last-checked stamps: a green that predates a changed world is worth
re-running **before** construction, not discovered red at Step 4. If `SPEC.md` is
missing or has open blocking questions,
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
acceptance.

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
ephemeral plan). Update the `## build` section of `.spec/STATE.md` (built /
remaining / next); when this completes a phase's construction (all its targeted
requirements green), say so there — the next `/spec` run records it in `SPEC.md`'s
phases ledger (you never edit `SPEC.md` yourself).

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
