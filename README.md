# /spec

A single, repeatable Claude Code command that turns conversation into one
authoritative specification — and **proves every critical assumption with a real
script before it lets you build.**

Think of it like `/init`, but for a construction-grade living spec. You run
`/spec`, it brainstorms with you until **every open question is closed** and
**every source of truth is pinned**, then it **writes an executable probe for each
gate and actually runs it** to confirm the truth is real (not assumed). It records
the decisions and writes the complete spec to a fixed file — **`SPEC.md`** at the
repo root — and points `CLAUDE.md` at it as the highest-priority reference. Run it
again any time: it reconciles `SPEC.md` with reality, re-runs the probes, folds in
new input, and rewrites the latest spec.

Everything else is decoupled: downstream work just reads `CLAUDE.md` → `SPEC.md`.

## The core idea: 摸排探真 (probe for truth)

A goal or gate is **never** marked verified from words — not yours, not the AI's. It
is verified **only** when a probe script ran against the real environment and
passed, with raw evidence captured. **No green probe ⇒ the gate isn't closed ⇒ that
phase isn't built.** ("没有准备好就不能施工.")

> Example: the project needs a database. `/spec` discusses scale with you, recommends
> options, you pick SQLite at `./data` — then it writes a probe that *actually*
> creates a DB there, round-trips a row, and reports the resolved path and free
> space. If you'd picked Docker, it runs `docker info` and checks the real service.
> A vague or made-up answer can't pass, because the script has to.

When a truth genuinely can't be probed yet (it depends on work that doesn't exist),
`/spec` doesn't fake it — it **phases** the work: each gate belongs to a phase, and
a phase is construction-ready only when all its gates are green. Research/spike
phases exit by "producing something that can now be probed."

## What it does

```
/spec ──▶ load SPEC.md + scan project ──▶ reconcile drift, RE-RUN probes
      ──▶ fold in your input ──▶ brainstorm + PROBE each gate to green (闭环)
      ──▶ record decisions ──▶ rewrite SPEC.md ──▶ point CLAUDE.md at it
```

- **Closure gate:** won't finish while a blocking question is open or a gate is red.
- **Probe-verified gates:** every concern ends with one named authority + a passing
  probe script + raw evidence (where/when it ran).
- **Phased construction:** a phase can't be built until its gates are green.
- **Safe probes:** non-destructive, self-cleaning; anything risky needs your OK; no
  secrets are persisted.
- **Idempotent:** no new input + no drift + probes still green ⇒ only the timestamp
  changes.
- **Decoupled from execution:** `/spec` only specifies and verifies readiness — it
  never writes the product code.

## Usage

```
/spec                                  # create or reconcile the spec, run probes
/spec needs a postgres + redis         # fold a requirement in; /spec will probe both
/spec <paste a doc / a change / notes> # absorb arbitrary input, then converge
```

`SPEC.md` and `.spec/` are generated on first run, so they aren't in the repo yet.

## The SPEC.md structure (fixed)

```
SPEC.md
├─ 0. Meta             version · last updated · per-phase closure status
├─ 1. Vision & Problem
├─ 2. Scope            In / Out
├─ 3. Sources of Truth & Gates   ← each gate: authority + probe + evidence + status
├─ 4. Requirements     numbered, verifiable
├─ 5. Phases           gated by probes; a phase builds only when its gates are green
├─ 6. Architecture & Key Decisions   (+ append-only decision log)
├─ 7. Open Questions   ← the closure gate
└─ 8. Glossary
```

## Layout

```
.claude/
├── skills/spec/
│   ├── SKILL.md                       # the /spec procedure & guardrails
│   └── references/
│       ├── SPEC.template.md            # fixed structure of SPEC.md
│       └── probes.md                   # how to write trustworthy probes + library
└── commands/spec.md                   # /spec slash-command wrapper
CLAUDE.md                              # declares SPEC.md as the supreme reference

# generated at runtime by /spec:
SPEC.md                                # the spec
.spec/probes/<gate>_<slug>.sh          # executable probe per gate
.spec/evidence/<gate>-<timestamp>.log  # captured raw probe output
```
