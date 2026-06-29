---
name: spec
description: >-
  Create or update the project's single authoritative specification, SPEC.md, by
  brainstorming with the user to closure AND proving every gate with a real,
  executable probe (not AI judgement). Like /init, but for a construction-grade
  living spec: it pins every source of truth, writes a probe script that actually
  verifies each one against reality, refuses to mark anything ready without green
  evidence, plans phased work when truth can't be probed yet, records decisions,
  and rewrites the complete spec. Use for /spec, or whenever the user wants to
  define, refine, reconcile, or lock down what the project should be.
---

# /spec — the project's living, probe-verified specification

`/spec` is a single, repeatable command. It is a **thinking partner that converges
on truth, proves it with real scripts, and writes it down.** Its outputs are one
authoritative document `SPEC.md`, the probe scripts under `.spec/probes/`, their
evidence under `.spec/evidence/`, and an authority pointer in `CLAUDE.md`.

**Scope boundary:** `/spec` does **not** implement the product and is **not**
coupled to any execution skill. It only specifies and *verifies readiness*.
Downstream work reads `CLAUDE.md` → `SPEC.md`.

**Fixed locations** (always read, always rewrite whole — never fragment):
- `SPEC.md` — the spec, at the repo root
- `.spec/probes/<gate-id>_<slug>.sh` — the executable probe for each gate
- `.spec/evidence/<gate-id>-<timestamp>.log` — captured probe output

## The non-negotiable principle: 摸排探真 (probe for truth)

A goal or a source-of-truth/gate **may never be marked verified/ready from words** —
not the user's, not yours. It becomes verified **only** when a real probe script
ran against reality and passed, with raw evidence captured. **No green probe ⇒ the
gate is not closed ⇒ that phase may not be constructed.** ("没有准备好就不能施工.")

A user's answer is a **lead to verify**, never the verification. If the user says
"the database is there," the correct response is "let me prove it" → write a probe
→ run it → trust the evidence.

## Sources of truth & gates (真实源/门)

For each important concern, exactly **one** place is authoritative; everything else
defers to it, and a probe proves it is real. Each gate carries:

- **concern**, **authoritative source**, **invariant** (never violate)
- **probe**: the script at `.spec/probes/…` that proves it
- **evidence**: raw output + where/when it ran
- **status**: `unverified` · `verified` · `failed` · `deferred→Phase N`

## Probes must be trustworthy (because you author them)

"Non-AI judgement" only holds if the probe itself is dumb, explicit, and auditable.
Every probe MUST (see `references/probes.md` for the full guide + examples):

- be a standalone script with `set -euo pipefail`; **exit 0 = pass, non-zero = fail**.
- **print raw evidence** to stdout — the *actual* resolved path, version string,
  `SELECT 1` result, `df` output — not just "PASS".
- be **non-destructive, isolated, idempotent, and self-cleaning** (use a `trap` to
  remove temp artifacts). Default to read-only or writes into a temp/scoped path.
- include a **negative control** where feasible (prove the probe *can* go red).
- **never contain or echo secrets**; read credentials from env vars; redact them.
- record the environment (`uname -a`, hostname, date) at the top of its evidence.

**Safety gate:** any action that is destructive, irreversible, touches production,
deletes data, or writes to an external system MUST be confirmed with the user
(AskUserQuestion) before running. When in doubt, probe a safe proxy or defer.

**Honesty about scope:** a probe proves truth *on the machine it ran, at that
time*. Record where it ran; do not claim a devbox result holds for production. If
the real target is unreachable, say so and either probe a proxy or defer the gate.

## Phased construction — when truth can't be probed yet

The hard gate ("no green probe ⇒ no build") would deadlock any project whose later
truths depend on work that doesn't exist yet (Phase 2 calls an API Phase 1 will
build). Phasing resolves this **without lowering the bar** — cut the work so each
phase only needs truths that are probe-able *now*. Treat this as a first-class part
of the spec, not an afterthought.

Principles:

1. **Cut phases along the probe line.** Phase 1 = everything you can prove today.
   Push anything not-yet-probe-able into a later phase. The boundary between two
   phases is literally "what becomes probe-able after the earlier one ships."
2. **Planning resolution decreases with distance.** The near phase is fully probed
   and detailed; far phases stay deliberately coarse — goal + open questions + the
   trigger that will make them plannable. **Detailing or "verifying" a far phase now
   is fabrication and is forbidden.** An honest "TBD, unlocked by Phase 2" beats a
   made-up requirement.
3. **Phases chain by probes.** State each phase's **exit criterion as the probe(s)
   that will go green** — and those are exactly the probes that unlock the next
   phase's deferred gates. A phase is *done* only when its exit probes pass.
4. **Every deferred gate carries a trigger + owner**, e.g.
   `deferred→Phase 2 (trigger: Phase 1 ships the ingest API; re-probe
   .spec/probes/G4.sh; owner: <who>)`. On each `/spec` run, re-attempt any deferred
   gate whose trigger is now satisfied.
5. **Tag decisions/requirements `[locked]` vs `[provisional→Phase N]`.** Locked =
   backed by a green probe. Provisional = a best guess a future phase will confirm or
   overturn. A later **red** probe may re-open an earlier provisional decision — this
   is the feedback path; phasing is *not* "decide everything now."
6. **Even pure research has a probe-able Phase 1.** Scope it to what's verifiable
   today — can we access the data? run the experiment? reach the cluster? — and make
   its deliverable a probe-able artifact/finding that unlocks the next phase. If you
   genuinely can't probe anything, the first deliverable is "make one thing
   probe-able."

**Phase status lifecycle (ownership matters):** `/spec` sets **blocked → ready**
purely from probe state; the *executor* (not `/spec`) sets **in-progress → done**;
`/spec` confirms **done** by re-running the phase's exit probes on its next run.

Not everything reduces to a script (e.g. "legal approved"). Record those as an
**attestation** gate with a named source, and **mark them explicitly as weak
(non-probed) evidence** — never fabricate a script for them.

## Procedure (run this every time)

### 1. Load state
Read `SPEC.md`, `CLAUDE.md`, existing `.spec/probes/*`. Scan the project (README,
manifests, structure, tests, config) to model "what this project currently is."
Reflect it back briefly so the user can correct you early.

### 2. Reconcile drift — and re-run probes
Compare code/project reality vs `SPEC.md`. **Re-run existing probes** (cheap ones
at least): a previously-green gate whose probe now fails, or whose evidence is stale
(old timestamp / different machine), drops back to `unverified`/`failed`. List every
discrepancy as an item for step 4.

### 3. Ingest the user's input
Fold any argument/free-form content (new requirement, correction, pasted doc, change
of direction) into the open items.

### 4. Brainstorm + probe to closure (the core loop)
For each concern/gate/open item:
1. **Discuss** the real constraints (scale, load, durability, ops). Don't accept a
   vague answer — dig until the choice is concrete and probe-able.
2. **Recommend options** via AskUserQuestion (concrete choices, recommended first),
   e.g. "SQLite vs Postgres vs Docker-Postgres" with the trade-offs.
3. On a concrete answer, **author a probe**, save it to `.spec/probes/…`, **run
   it**, and capture evidence to `.spec/evidence/…`.
   - *Example (storage = SQLite at `./data`):* probe creates a temp DB at the
     resolved path, makes a table, inserts+reads a row, reports the absolute path,
     writability and free space, then deletes the temp DB.
   - *Example (Docker):* `docker info` exits 0 → then check the specific DB
     image/service is actually present.
   - *Example (remote Postgres):* connect with env creds and run `SELECT 1`.
4. **Green** → record raw evidence + set `verified`.
   **Red** → do NOT accept the answer. Show the raw failure and loop: pick another
   option / fix the environment / defer the gate to a later phase. Never set
   `verified` from words.
5. **Not probe-able now** (depends on unbuilt work) → `deferred→Phase N`; make sure
   the *current* phase doesn't depend on it.
- **Closure gate (闭环):** keep looping until, **per phase**, every gate is
  `verified` (or explicitly `deferred` to a later phase) and no blocking open
  question remains. Be honest about what's still open.

### 5. Record explicit decisions
For each resolved item, append to the Decision Log: the decision, the rationale
(why this over alternatives — cite the probe evidence), and the date. Append; note
reversals explicitly.

### 6. Write the complete `SPEC.md`
Overwrite `SPEC.md` in full using `references/SPEC.template.md`. Each gate row shows
its probe path, last-run (when/where), evidence summary, and status. Fill the Phases
section with per-phase gates and readiness. Bump version + timestamp.

### 7. Wire up `CLAUDE.md`
Ensure `CLAUDE.md` has the managed authority block (create if missing); replace only
between the markers:

```markdown
<!-- BEGIN SPEC-AUTHORITY (managed by /spec) -->
## Specification authority
`SPEC.md` is the authoritative specification for this project and the
**highest-priority** reference. Before planning or implementing anything, read
`SPEC.md` and conform to it — especially its "Sources of Truth & Gates" section. A
phase may not be built until its gates are probe-verified (green) in `SPEC.md`. If
reality and `SPEC.md` disagree, treat `SPEC.md` as intent and run `/spec` to
reconcile. Do not silently contradict it.
<!-- END SPEC-AUTHORITY -->
```

### 8. Report
Summarize what changed, decisions recorded, **probe results (green/red) with the key
evidence**, and what was deferred and why. End with per-phase closure status, e.g.
"Phase 1: ✅ construction-ready (3/3 gates green) · Phase 2: ⏳ 2 gates deferred."

## Guardrails

- **Words are never evidence.** Verified status requires a passing probe, full stop.
- **Red or unverified ⇒ no construction** for that phase. Change the plan, fix the
  environment, or defer — don't lower the bar.
- **One document, always whole.** `SPEC.md` is the single source.
- **One authority per concern.** No two places may claim the same truth.
- **Probes are safe by default.** Non-destructive, self-cleaning; confirm anything
  risky; never persist secrets.
- **Don't implement the product.** `/spec` only specifies and verifies readiness.
- **Idempotent.** No new input + no drift + probes still green ⇒ only the timestamp
  changes.
- **Honesty over completeness theater.** Unknowns go to Open Questions or a phased
  deferral, never invented into a "verified" gate.
