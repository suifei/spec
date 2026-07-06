# Knowledge — mystery-novella structure & how to make its gates red-able

- **Captured:** 2026-07-06T16:32:36Z (vm)
- **Recency:** craft conventions age slowly (decades-stable); re-verify only if the target genre changes.

## The genre's load-bearing promise (fair-play mystery)

A mystery makes a **contract with the reader**: every mystery it *deliberately plants* will be
**resolved on-page** before the story ends (Chekhov's gun — a rifle on the wall in act one must
fire by act three). A planted-but-unresolved mystery is a **structural defect**, not a matter of
taste. This is what makes "all mysteries paid off" a *gate*, not a preference.

Secondary promise: the **investigative main thread advances continuously** — a whodunit that
goes several chapters without moving the investigation forward has stalled.

## Making a prose gate red-able (the instrumentation convention — DECISION)

Prose is not machine-checkable by default. To give G1/G2 a **red-able method** (D-54) instead of
collapsing them to WEAK/human, the manuscript carries lightweight tags in HTML comments (invisible
in rendered output):

| Tag | Meaning | Example |
|-----|---------|---------|
| `<!-- ANCHOR:<id> deadline=<n> desc="…" -->` | a mystery is planted here; must be paid off by chapter *n* | `<!-- ANCHOR:M2 deadline=6 desc="the light that shouldn't be lit" -->` |
| `<!-- PAYOFF:<id> -->` | that mystery is resolved on-page here | `<!-- PAYOFF:M2 -->` |
| `<!-- THREAD:main -->` | the investigative main thread advanced in this chapter | `<!-- THREAD:main -->` |

The probes scan these tags. The convention is the price of a red-able prose gate; a project
unwilling to instrument its prose keeps G1/G2 as **WEAK** (a human/LLM-judge read) instead — an
honest degrade, not a fake green.

## Quality is deliberately NOT gated mechanically

"Is the payoff *earned*? Is the voice consistent?" — real, but unscriptable. Gated **WEAK**
(named human/LLM-judge sign-off), per the three-state rule. `SPEC.md` is a lower bound on verified
truth: the probes prove *closure*, not *quality*.
