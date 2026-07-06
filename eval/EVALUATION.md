# EVALUATION — `/spec` · `/build` · `/yolo` on a non-programming project

**Subject:** a fair-play mystery novella (`novella/`). **Run:** 2026-07-06 (vm, UTC).
**Method:** the three skills are prompt-protocols for an AI executor; each was executed faithfully,
step by step, on the isolated `novella/` project. Every artifact under `novella/` is a preserved
sample; every probe run is a real captured log in `novella/.spec/evidence/`.

**Headline result:** the pipeline **generalizes to non-programming work.** The core machinery —
investigation→feasible spec, red-able gates, gate-judged "done", self-terminating loop — all fired
on a novella. Most importantly, the failure mode the recent design rounds target (**"reads finished
but is structurally incomplete"**) was reproduced *and caught* in prose: chapter 3 read like a fine
chapter, but the gate found a planted mystery left dangling and went **RED** (evidence below); an
eyeball pass would have shipped it. The defects found are about **naming the non-code moves the
protocol silently assumes**, not about broken machinery.

---

## What each skill did

### `/spec` — produced a real, feasible spec for a novel
- Defined the noun before the verb (D-39): fixed the subject as *fair-play mystery* (core contract =
  setup→payoff closure + a moving investigation), not "atmospheric lighthouse chapters".
- Applied the 3-part gate test: **G1** (every planted mystery paid off by deadline) and **G2** (main
  thread advances ≥ every 2 chapters) are load-bearing/uncertain/consequential → gated with **real
  probes**; prose *quality* is consequential but unscriptable → **not** gated.
- **D-54 (acceptance needs a *method*) generalized cleanly**: the four requirements naturally landed
  in all three legal states — R1/R2 **Probed**, R3 **WEAK** (reviewer sign-off), R4 **OPEN**
  (reader-surprise, deferred to Phase 2). The "no prose-only acceptance" rule did its job in a domain
  with no code at all.

### `/build` — constructed chapters and closed on a running gate
- Wrote ch01–ch05, planting M1/M2/M3 and advancing the thread each chapter.
- **Closed on the probe, not on vibes.** When M2 came due at ch3, the first draft (a perfectly
  readable chapter) had no payoff. Running `G1` returned **RED / exit 1**
  (`.spec/evidence/G1-*-dangling.log`). After adding the payoff, `G1` returned **GREEN / exit 0**
  (`.spec/evidence/G1-*-resolved.log`). Final closure: G1 + G2 both green over the full manuscript
  (`.spec/evidence/*-final.log`).
- The "drive the real flow" discipline mapped to "run the probe over the whole manuscript" — and it
  is what caught the defect a read-through rationalized away.

### `/yolo` — the launcher is domain-agnostic
- The fixed `/loop 1m` prompt, retargeted at the novella's `/build`, registered as a real cron
  (`CronCreate`), listed, and was deleted (`CronList`→`CronDelete`) — identical mechanics to the code
  case. The thin-launcher (D-53) doesn't care that the artifact is prose.

---

## Defects & insights found (the point of the exercise)

**D-EVAL-1 — "instrument the artifact" is a required, unnamed step for non-code gates.**
To make G1/G2 *red-able*, the executor had to **invent a machine-checkable instrumentation** of the
prose (the `ANCHOR/PAYOFF/THREAD` HTML-comment tags). Nothing in `SKILL.md`/`probes.md` names this
move. A less-careful executor meeting prose would shrug and mark everything **WEAK**, silently losing
the red-able gate — the non-code analog of "never wired to a real entrypoint." *Recommendation:*
`probes.md` should name **"instrument the artifact so its gate can go red"** as an explicit step for
non-code domains, with prose tagging as the worked example.

**D-EVAL-2 — long-range / position-phased obligations are unaddressed.**
M1 was due at ch5 while only ch1–3 existed. A correct probe must report it **"pending, not red"**
until its deadline *and still not forget it* — logic the executor had to build unaided. This is
exactly the user's "resolve a suspense 1000 chapters later" case, and the skills give no guidance on
**phased gates + an open-loop ledger** that tracks a far-future obligation so it neither false-reds
early nor silently lapses. *Recommendation:* add a note on phased long-range gates to `probes.md`.

**D-EVAL-3 — `/yolo` termination needs a bounded, gate-closable spec (a precondition, not a bug).**
"No buildable `[locked]` work remains" is crisp for code but fuzzy for open-ended creative work (a
novella can always have "more chapters"). Termination worked here **only because `/spec` drew a
bounded arc** (all planted anchors paid, thread green ⇒ Phase-1 done). An unbounded creative spec
("write a great novel") would leave `/yolo` unable to self-terminate → it would hit the no-progress /
human stop instead of "done". *Insight to state in the skill:* `/yolo` in any domain requires a spec
whose "done" is finite and gate-judged.

**D-EVAL-4 — vocabulary leak.** `SKILL.md`/`build`/template are code-flavored ("product code",
"Write/extend tests", "typecheck"). The protocol is sound and translated fine, but a non-technical
user driving a novel/curriculum/plan could read this as "not for me." *Recommendation:* a one-line
"the artifact is whatever the project produces — code, prose, a plan" note, or neutral wording.

---

## Verdict

| Skill | Generalizes to non-code? | Evidence |
|-------|--------------------------|----------|
| `/spec` | **Yes** — produced a feasible spec with real gates; D-54's three-state acceptance held | `novella/SPEC.md`, `.spec/` |
| `/build` | **Yes** — closed on a running gate; caught a "reads-done but incomplete" chapter | `.spec/evidence/G1-*-dangling.log` → `-resolved.log` |
| `/yolo` | **Yes (mechanics)** — domain-agnostic launcher; termination needs a bounded spec (D-EVAL-3) | cron create/list/delete demo |

The pipeline is **not** a programming-only tool. The four gaps above are refinements — naming the
moves a careful executor already had to make — and are proposed as the next iteration, not shipped
blindly. Preserved sample: the whole `novella/` project, including the red→green evidence trail.
