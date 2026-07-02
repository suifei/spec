---
description: Brainstorm to a feasible spec, with the AI as your scout. Creates/updates SPEC.md (Gate 1). Resumable.
argument-hint: "[an idea, a PRD, a repo/path to read, or nothing to resume]"
---

Invoke the `spec` skill.

First **rehydrate** from `.spec/STATE.md` (+ `SPEC.md`, `.spec/knowledge/`) and tell
me where things stand. Then **investigate first** — investigation is research: read
what I point at, check the knowledge cache, mine the project's own data, search your
knowledge and the web, use skills/MCP, reason it through, and probe reality where a
**load-bearing** truth can be exercised (delegate heavy reads to a sub-agent and
keep only the summary). **Resolve everything you can yourself and register the
reasoning + conclusion in the Decision Log.** Present your findings, then ask me
**only** about a genuine fork evidence can't settle, or a better option than I
proposed. Back load-bearing gates with real evidence (no probes for commonsense
facts), and persist everything (SPEC.md + .spec/) — one safe-to-stop chunk,
updating `.spec/STATE.md`.

Don't make me adjudicate what you can decide; bring me the calls that are truly
mine.

Write your reports and `SPEC.md` in **my language** (the language I'm writing in);
if an existing spec is in another language, translate it to match (chunk it if
large). Keep code/paths/URLs/timestamps verbatim; a declared project language wins.

Input (optional): $ARGUMENTS
