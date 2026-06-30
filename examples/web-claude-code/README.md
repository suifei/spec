# Example — Web Claude Code (a real `/spec` run, captured)

The official worked example of `/spec`, on a deliberately **knowledge-heavy**
target: *"develop a Web version of Claude Code."* It can only be answered by
research, so it exercises the heart of `/spec` — and it also captures a real
mistake-and-correction that makes the lesson concrete.

## The lesson this example is built around: define the noun before the verb
The first draft (v1) jumped straight to "build an agent backend + a sandbox." That
was wrong — not in detail, but in **starting point**: it designed *how to build it*
before establishing *what Claude Code is*. (As the critique put it: you don't
debate baby names before you know whether the subject is a human or a monkey.)

v2 fixes the root cause. It **first establishes the subject** from the official
docs: Claude Code is an **agentic coding CLI** — terminal-based, Unix-composable,
with a headless `stream-json` mode and an Agent SDK; the agent loop, tools, and
permission model already live inside it. From that, the real problem falls out:

> **"To web" = take over the existing `claude` CLI's I/O (an interactive PTY, or
> headless `stream-json`) and relay it to the browser over a WebSocket.** The real
> Claude Code runs unchanged on the server; the browser is a terminal/view.

This is the established terminal-over-web pattern (ttyd / wetty / xterm.js), not a
new agent. Everything downstream — transport, sessions, the credential boundary —
follows from the subject.

## What `/spec` did here (the analyst at work)
- **Identified the subject first** (define the noun before the verb) from official
  Claude Code docs, instead of guessing an architecture.
- **Derived the core problem** from the essence: relay the CLI's I/O, don't rebuild
  the agent.
- **Was honest** — it recorded that v1's framing was wrong and **superseded** it,
  rather than quietly editing.
- **Reserved its one probe for the one behavioral truth:** a CLI process's stdio can
  be taken over and relayed both ways (G2), with a negative control. The other gates
  are research-backed (cited official docs); commonsense was never gated.
- **Decided what was decidable** (D1–D4 `[auto]`) and **escalated the genuine forks**
  (D5 terminal-mirror vs custom UI; D6 isolation/cost) to the human (`[human]`).

## What's in here
```
SPEC.md                         the spec — subject established first, then approach, gates, decision log
CLAUDE.md                       SPEC-AUTHORITY block — read SPEC.md first
verify.sh                       runs the probe + 24 assertions; exit 0 == ALL PASS
.spec/
  STATE.md                      resumable progress ledger
  knowledge/                    the research, with cited official sources
    what-is-claude-code.md        THE SUBJECT (established before any solution)
    io-bridge.md                  mechanism: PTY/stream-json + WS + xterm.js (ttyd/wetty)
    credential-boundary.md        CLI server-side; browser is a relayed view
  probes/
    G2-stdio-takeover.sh          the ONE behavioral gate (with negative control)
  evidence/                     raw probe output, real UTC-stamped
```

## Reproduce
```bash
cd examples/web-claude-code
./verify.sh            # runs the probe + 24 assertions; prints ALL PASS / exit 0
```
Requires `bash` and `node`. The probe is dependency-free and self-cleaning.

---

# Objective value assessment

Can these artifacts be a project-initial-phase deliverable and a spec standard?
Assessed honestly, including the limits.

### Where it clears the bar
1. **It starts from the right place.** The single most expensive error in a spec is
   designing for a misidentified subject; this example makes "establish what the
   thing is, from authoritative sources, before any solution" a visible, checked
   step (G1, and the `what-is-claude-code.md` research). The captured v1→v2
   correction is the proof that the discipline catches the error.
2. **It is honest, including about itself.** It records that its own first framing
   was wrong and supersedes it with a reason — not a silent edit. A standard that
   can self-correct on the record is more trustworthy than one that hides drift.
3. **It puts probes in their place.** Exactly one runnable probe, for the one
   behavioral truth (stdio takeover + relay); the subject and the trust boundary are
   settled by cited research. 探真 = 研究; commonsense is never gated.
4. **It separates AI-decidable from human-only.** Four decisions auto-resolved with
   registered reasoning; two genuine forks (UX direction; isolation/cost) escalated.
5. **It governs altitude and change.** Approach and boundaries, not code; an
   append-only Decision Log; a sealed Phase 1 that explicitly supersedes v1.

### Where it is bounded (and says so)
- **Research is "as of" a date.** CLI flags and SDK evolve; entries are stamped
  2026-06-30 and say to re-verify exact flags at build time.
- **One truth is honestly deferred, not faked.** Full interactive TUI fidelity needs
  a native PTY (`node-pty`); that's a build-time gate (G4), not probeable
  dependency-free here, so it's tracked open rather than rubber-stamped.
- **It's a starting contract, not a build plan.** No estimates, no task breakdown,
  no UI design. Strong as a spec standard; deliberately not a project plan.

### Verdict
As a **project-initial deliverable**: yes — it turns a vague "web version of Claude
Code" into a correctly-framed approach (relay the CLI's I/O), grounded in the
subject's real nature, with named anti-patterns, clear human forks, and an honest
map of settled vs open. As a **spec standard**: yes, and it demonstrates the
discipline that gives the format its worth — *define the noun before the verb,
research is the default evidence, probes are reserved for behavior, commonsense is
never gated, and the AI is honest enough to supersede its own mistake.*
