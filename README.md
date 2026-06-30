# /spec

A single, repeatable Claude Code command in which the AI plays an **expert
requirements-elicitation analyst** — it takes your vague idea and turns it into one
authoritative, *feasible* specification.

Think of it like `/init`, but for the living spec. You run `/spec`; it
**clarifies the vague into the clear** through investigation (reads what you point
at, mines your project's data, searches its knowledge and the web, reasons it
through — *investigation is research*), **reflects your idea back organized**,
**offers better views**, and **reports what's closed-loop (ready to build) vs what
you haven't thought through yet**. It then standardizes the result — key content,
boundaries, and anti-patterns — into **`SPEC.md`**. Run it again any time — it
**resumes** from where it left off.

It is **Gate 1** of an AI-assisted development process. (Gate 2 — extracting a
reusable skill from the finished project — is Claude Code's built-in
skill-builder, and is out of scope here.)

**The deal:** you weigh in only on the calls that are genuinely yours. The AI does
the heavy lifting — investigating, reasoning, probing, deciding everything that's
decidable, drafting, persisting. `/spec` is collaboration, not paperwork: no forms,
no burden.

## How it works

```
/spec ─▶ rehydrate (.spec/STATE.md)         # know exactly where it left off
      ─▶ INVESTIGATE (= research): cache → your material → project data → knowledge → web → skills/MCP → reason → probe
      ─▶ resolve what you can; register the reasoning (Decision Log)
      ─▶ report findings + closure status (ready vs not-yet-thought-through)
      ─▶ ask only the genuine forks (or a better option found) — low-burden, calibrated
      ─▶ back load-bearing gates with evidence (probes must be able to go red)
      ─▶ persist everything + update CLAUDE.md ─▶ closure seals a phase
```

### Principles

- **Investigation is research (探真 = 研究).** Finding the truth = finding the
  knowledge — by any means (knowledge, web, project data, skills/MCP, reasoning). A
  runnable probe is one instrument, not the definition.
- **Decide what's decidable; ask rarely.** It resolves what it can and registers
  the reasoning, asking you only about a genuine fork evidence can't settle, or a
  better option it found. It never makes you adjudicate commonsense.
- **Honest, including "no".** It refuses the research-proven-infeasible with the
  real reason and names problems in your decisions — it won't spec a known-wrong
  wish to be agreeable. Standing in for market/requirements/feasibility/
  architecture/design-review at once, it pulls top-tier authoritative sources when
  a role needs knowledge it lacks.
- **Gates are load-bearing only.** A gate is a truth a real decision *hinges* on.
  Commonsense facts (a free port, a writable dir, a tool on PATH) are never gates
  and never a coding focus — *we don't build around whether a port is free.*
- **Evidence, never fabrication.** A load-bearing gate is backed by a probe that
  can go red, or a cited source (marked WEAK) when it can't be scripted.
- **The filesystem is memory.** State lives on disk, not in the context window —
  so it runs reliably in a small window and **resumes** across resets/compaction.
  Reconnaissance persists (`.spec/knowledge/`) so it isn't re-explored.
- **The spec line.** The spec governs the *contract surface* (behavior, contracts,
  load-bearing gates, NFRs, declared constraints, boundaries, anti-patterns) —
  never implementation detail. Code stays free below the line.
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

A complete `/spec` run is captured under
[`examples/web-claude-code/`](examples/web-claude-code/) as the official example,
on a deliberately **knowledge-heavy** brief: *"develop a Web version of Claude
Code."* It also captures a real **mistake-and-correction** that shows the discipline
working: a first draft jumped to "build an agent backend" — designing the *how*
before establishing *what Claude Code is* (**define the noun before the verb**). The
corrected spec **establishes the subject first** from official docs (Claude Code is
an agentic **CLI** with a takeover-able I/O surface), and so finds the real core
problem: *"to web" = take over the existing CLI's I/O (PTY or `stream-json`) and
relay it to the browser over WebSocket — not rebuild the agent.* Two gates are
settled by cited research (the subject; the credential boundary), the one behavioral
truth (a CLI's stdio can be taken over and relayed) by a runnable probe with a
negative control, and the old framing is honestly **superseded**. Run `./verify.sh`
there for the probe + 24 assertions (`ALL PASS`, exit 0). Its README carries an
objective value assessment.

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
docs/DESIGN-NOTES.md                   # full design rationale: discussion rounds + decision log

# generated at runtime by /spec:
SPEC.md                                # the spec
.spec/STATE.md                         # progress ledger (resumability)
.spec/knowledge/<topic>.md             # persisted reconnaissance (pinned deps/facts)
.spec/probes/<gate>.sh                 # executable probes
.spec/evidence/<gate>-<ts>.log         # captured probe output
```

## Design rationale

`docs/DESIGN-NOTES.md` records the whole design conversation — from "port OpenSpec"
to this expert-analyst, resumable, single-command Gate 1 — plus a consolidated
decision log.
