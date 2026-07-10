---
description: Brainstorm to a feasible spec, with the AI as your scout. Creates/updates SPEC.md (Gate 1). Resumable.
argument-hint: "[an idea, a PRD, a repo/path to read, or nothing to resume]"
---

Invoke the `spec` skill.

First read `SPEC.md` and its profile; for a governed project **rehydrate** from
`.spec/STATE.md` + `.spec/knowledge/`, then tell me where things stand. Then
**investigate first** — investigation is research: read
what I point at, check the knowledge cache, mine the project's own data, search your
knowledge and the web, use skills/MCP (including the optional `/deep-research`
fallback for a contested, load-bearing question, when available), reason it
through, and probe reality where a **load-bearing** truth can be exercised
(delegate heavy reads to a sub-agent and keep only the summary). **Resolve
everything you can yourself and register the
reasoning + conclusion in the Decision Log.** Present your findings, then ask me
**only** about a genuine fork evidence can't settle, or a better option than I
proposed. Back load-bearing gates with real evidence (no probes for commonsense
facts), and persist everything (SPEC.md + .spec/) — one safe-to-stop chunk,
updating `.spec/STATE.md`.

Use the profile recorded in `SPEC.md`: `minimal` creates only a short SPEC and is
not `/build`/`/yolo` ready; `governed` uses `.spec/` plus the closure kit. Upgrade
minimal→governed atomically before construction or when load-bearing uncertainty
appears; never leave a half-created `.spec/`.

Don't make me adjudicate what you can decide; bring me the calls that are truly
mine.

Artifact language: if `SPEC.md` already has a pinned "Artifact language," just use
it — don't ask. If this is the **first time persisting** for this project, ask me
**once** which language to write reports and `SPEC.md` in (default: the language
I'm writing in now; offer English/中文/日本語/… or other), then **pin it in `SPEC.md`
and never ask again**. If the spec's existing language doesn't match the pin,
translate it to match (chunk it if large). Code/paths/URLs/timestamps stay verbatim.

Input (optional): $ARGUMENTS
