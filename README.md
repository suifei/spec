# /spec

A single, repeatable Claude Code command that turns conversation into one
authoritative, *feasible* specification — with the AI working as your
**reconnaissance scout**.

Think of it like `/init`, but for the living spec. You run `/spec`; it
**investigates first** (reads what you point at, checks its own knowledge cache,
searches the web when the answer depends on external facts, and probes reality for
evidence), then **brainstorms with you** to find the *core problem* and drive every
decision to closure, and writes the result to a fixed file: **`SPEC.md`**. Run it
again any time — it **resumes** from where it left off.

It is **Gate 1** of an AI-assisted development process. (Gate 2 — extracting a
reusable skill from the finished project — is Claude Code's built-in
skill-builder, and is out of scope here.)

**The deal:** you only **brainstorm and decide**. The AI does the heavy lifting —
scouting, probing, drafting, persisting. `/spec` is collaboration, not paperwork:
no forms, no burden.

## How it works

```
/spec ─▶ rehydrate (.spec/STATE.md)         # know exactly where it left off
      ─▶ SCOUT FIRST: cache → your material → own knowledge → web (if needed) → probe
      ─▶ present findings (core problem, constraints, candidate gates, risks)
      ─▶ ask only what needs you (aim at the core problem; low-burden, calibrated)
      ─▶ you decide (options + recommendation + evidence)
      ─▶ verify gates with real probes (must be able to go red)
      ─▶ persist everything + update CLAUDE.md ─▶ closure seals a phase
```

### Principles

- **Scout before asking.** It never asks you what it could find out itself.
- **Evidence, not bureaucracy.** Truth-finding (probing, never fabricating) is the
  AI's discipline; the GO/no-go is yours.
- **The filesystem is memory.** State lives on disk, not in the context window —
  so it runs reliably in a small window and **resumes** across resets/compaction.
- **Reconnaissance is persisted** (`.spec/knowledge/`) so it isn't re-explored;
  e.g. for a dependency it captures stable + latest + alternatives, you pick, and
  it pins the version and saves the docs.
- **The spec line.** The spec governs the *contract surface* (behavior, contracts,
  sources of truth & gates, NFRs, declared constraints) — never implementation
  detail. Code stays free below the line.
- **Phases emerge from closure**, they aren't pre-planned; sealed phases are
  read-only (corrections open a new, superseding phase).
- **Honest limit.** `SPEC.md` is a *lower bound on verified truth*, not a
  correctness proof.

## Usage

```
/spec                                  # create, or resume where it left off
/spec add multi-tenant support         # fold in an idea, then converge
/spec read ./legacy-service and spec the rewrite   # point it at material to scout
```

`SPEC.md` and `.spec/` are generated on first run.

## Example

A complete, **probe-verified** `/spec` run is captured under
[`examples/nebula-drift/`](examples/nebula-drift/) as the official example. It
takes a real brief ("build a 2D space shooter") through two phases to closure:
the scout **refutes** a human assumption (a native Godot build — gate G0 goes
red), pivots to a browser build, then in Phase 2 makes a real netcode decision
(server-authoritative over `ws`) backed by a dependency-free transport probe
(G6). Run `./verify.sh` in that directory to re-run every probe plus 23
assertions (`ALL PASS`, exit 0). The example's README also carries an objective
value assessment of the artifacts as a project-initial-phase deliverable.

## Files

```
.claude/
├── skills/spec/
│   ├── SKILL.md                       # the /spec procedure (scout → ask → decide → probe → persist → resume)
│   └── references/
│       ├── questioning.md              # how to ask (Socratic, info-gap, low-burden, calibrated)
│       ├── probes.md                   # how to probe (evidence + mandatory negative control)
│       ├── SPEC.template.md            # structure of SPEC.md
│       ├── STATE.template.md           # the .spec/STATE.md progress ledger
│       └── knowledge.template.md       # a .spec/knowledge/ reconnaissance entry
├── commands/spec.md                   # /spec slash-command wrapper
CLAUDE.md                              # declares SPEC.md the supreme, read-first reference
docs/DESIGN-NOTES.md                   # full design rationale: 9 discussion rounds + decision log

# generated at runtime by /spec:
SPEC.md                                # the spec
.spec/STATE.md                         # progress ledger (resumability)
.spec/knowledge/<topic>.md             # persisted reconnaissance (pinned deps/facts)
.spec/probes/<gate>.sh                 # executable probes
.spec/evidence/<gate>-<ts>.log         # captured probe output
```

## Design rationale

`docs/DESIGN-NOTES.md` records the whole design conversation — nine rounds from
"port OpenSpec" to this scout-based, resumable, single-command Gate 1 — plus a
consolidated decision log.
