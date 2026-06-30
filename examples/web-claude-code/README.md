# Example — Web Claude Code (a real `/spec` run, captured)

The official worked example of `/spec`, on a deliberately **knowledge-heavy**
target: *"develop a Web version of Claude Code."* Unlike a game (where feasibility
is mostly local), this brief can only be answered by **research** — what a browser
can and can't do, how an agent's tools must be hosted, where secrets may live. It
therefore exercises the heart of `/spec`: investigation *is* research, gates are
load-bearing only, and the AI decides what's decidable while staying **honest**
about what isn't possible.

## What `/spec` did here (the analyst at work)
Acting as a requirements-elicitation analyst, it **clarified a vague idea into a
buildable architecture**:

- **Found the core problem** behind the surface ask: a browser tab has no
  filesystem, shell, or processes — so the real question is *where the agent's
  hands live.*
- **Investigated by research** (not by guessing): WebContainers run Node-in-WASM
  but **can't run native git/compilers/addons**; Claude Code on the web runs each
  session in an **isolated ephemeral container** with a **credential proxy outside
  the sandbox**. (Sources cited in `.spec/knowledge/`.)
- **Was honest and refused the tempting-but-impossible.** "Just run it all in the
  browser" is the shortcut every newcomer wants; research shows it breaks on real
  repos, so the spec **refutes it** (gate G1) and records *why* — rather than
  nodding along. The anti-patterns section names the other traps.
- **Decided what was decidable and registered the reasoning** (Decision Log D1–D4,
  `[auto]`), and **escalated the one genuine fork** — multi-tenant isolation depth
  and who pays for idle compute — to the human (`[human]`, Q1), because it's a
  risk/business call no amount of research settles.
- **Reserved its one probe for the one behavioral truth.** Most gates are
  research-backed; only "a session survives disconnect" is exercised by a runnable
  probe (G3) with a negative control. *We did not gate commonsense* (a free port, a
  writable dir) — those change no decision.

## What's in here
```
SPEC.md                         the architecture spec (core problem, gates, decision log, anti-patterns)
CLAUDE.md                       SPEC-AUTHORITY block — read SPEC.md first
verify.sh                       runs the probe + 20 assertions; exit 0 == ALL PASS
.spec/
  STATE.md                      resumable progress ledger
  knowledge/                    the research, with cited sources
    execution-model.md            browser vs remote + transport
    credential-boundary.md        where secrets live
  probes/
    G3-session-persistence.sh     the ONE behavioral gate (with negative control)
  evidence/                     raw probe output, real UTC-stamped
```

## Reproduce
```bash
cd examples/web-claude-code
./verify.sh            # runs the probe + 20 assertions; prints ALL PASS / exit 0
```
Requires `bash` and `node`. The probe is dependency-free and self-cleaning.

---

# Objective value assessment

Can these artifacts be a project-initial-phase deliverable and a spec standard?
Assessed honestly, including the limits — for a research-driven brief specifically.

### Where it clears the bar
1. **It answers a question you can't answer from the armchair.** The whole value of
   this brief is external knowledge, and the spec is built on cited research, not
   vibes. The load-bearing claims ("execution must be remote", "keys stay
   server-side") trace to named sources.
2. **It is honest, including saying no.** The spec refutes the most tempting
   approach (all-in-browser) with a reason, and labels the traps as anti-patterns.
   A standard that can *reject* a stakeholder's idea with evidence is worth more
   than one that only records wishes.
3. **It puts probes in their place.** Exactly one runnable probe — for the one
   behavioral truth — while platform facts are settled by research. This is the
   corrected discipline: 探真 = 研究; a probe is an instrument, not the definition,
   and commonsense is never gated.
4. **It separates what the AI can decide from what only the human can.** Four
   decisions auto-resolved with registered reasoning; one genuine fork (isolation
   depth + cost) escalated. The human's surface stays tiny and is aimed only at a
   real value/risk call.
5. **It governs altitude and change.** Architecture and boundaries, not code; an
   append-only Decision Log and a sealed Phase 1 with an open, superseding Phase 2.

### Where it is bounded (and says so)
- **Research is "as of" a date.** Platform capabilities move; the entries are
  stamped 2026-06-30 and say to re-verify exact runtime/isolation versions at build
  time. A green here is a *lower bound*, not a permanent guarantee.
- **Research-backed gates are only as good as their sources.** G1/G2 are marked
  *verified (research)* with named sources — not a runnable green. That's honest,
  but a reader must weigh the sources, not treat the checkmark as a probe.
- **It's a starting contract, not a build plan.** No estimates, no task breakdown,
  no UI. Strong as a spec standard; deliberately not a project plan.

### Verdict
As a **project-initial deliverable** for a research-driven product: yes — it turns
"build a web Claude Code" into a defended architecture with a cited rationale, named
anti-patterns, a clear human decision, and an honest map of what's settled vs open.
As a **spec standard**: yes, and it demonstrates the discipline that gives the
format its worth — *research is the default evidence, probes are reserved for
behavior, commonsense is never gated, the AI decides what it can and is honest about
the rest (including refusing the impossible).*
