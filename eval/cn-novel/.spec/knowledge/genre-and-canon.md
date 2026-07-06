# Knowledge — 重生+系统+高武+星系 web-serial: conventions, failure modes, canon design

- **Captured:** 2026-07-06T16:56:19Z (vm) · **Recency:** genre conventions age slowly; re-verify only on genre shift.
- **Originality note (declared constraint):** this is an **original** work emulating genre *conventions*.
  No text, plot, character, or setting is copied or closely paraphrased from any published novel. The
  human's "仿写" is honored as *convention emulation*, not imitation of a specific copyrighted book.

## What the four tropes each promise (and therefore must keep consistent)

- **重生 (rebirth):** the protagonist carries **foreknowledge** of a future. That future is now *canon*:
  every "I remember this happens" must stay consistent, and the plot must not contradict the remembered
  timeline without an in-story reason. → a **timeline/foreknowledge consistency** obligation.
- **系统 (system):** a game-like quantified overlay (levels, attributes, quests, rewards). Every number
  it states is a promise. → a **numeric consistency** obligation (the classic failure is 数值崩坏).
- **高武 (high martial world):** a defined **power ladder** (境界). Ranks are ordered; a character's rank
  is monotone (no silent downgrade) and never skips the ladder. → a **power-monotonicity** obligation.
- **星系 (interstellar):** a **worldbuilding scope** (systems, factions, tech). Established geography/
  faction facts must not later contradict. → a **setting-canon** obligation.

## The genre's characteristic failure modes (⇒ anti-patterns)

Long serialization is where these creep in — each is a **consistency collapse**, not a taste matter:
1. **人设崩塌** — a character acts against their established personality/goals.
2. **数值崩坏 / 金手指失衡** — attributes or power levels contradict earlier statements or inflate incoherently.
3. **姓名·称谓漂移** — a character's name/title/relationship drifts or is mis-stated across chapters.
4. **文风漂移** — POV person, tense, or register shifts between chapters.
5. **设定前后矛盾** — an established worldbuilding fact is contradicted later.
6. **坑不填** — foreshadowing planted and never paid off.
7. **主线拖沓/断裂** — the main quest stalls for chapters.

## Canon = the story bible (the instrumentation that makes the gates red-able)

A **canon ledger** (`.spec/canon/`) is the append-only source of truth the probes check the manuscript against:
- `characters.tsv` — name, immutable attrs (瞳色, 出身), personality tags, current 境界, key relationships.
- `power-ladder.txt` — the ordered 境界 list (ordinal), so "monotone / in-ladder" is checkable.
- `glossary.txt` — canonical names/places/terms; anything not here that looks like a name is drift.
Chapters carry lightweight tags in HTML comments the probe scans, e.g.:
`<!-- CANON:name=陆沉 attr=境界 val=淬体3 -->`, `<!-- CANON:name=陆沉 attr=瞳色 val=墨金 -->`,
`<!-- FORESHADOW:F1 deadline=40 -->` / `<!-- PAYOFF:F1 -->`, `<!-- THREAD:main -->`.

## Original power ladder (this project's canon)
淬体 → 通脉 → 凝罡 → 星辉 → 星河 → 星域 (each with 1–9 重). Ordinal = tier×100 + 重.
A character's 境界 ordinal is **non-decreasing** by chapter and never names a tier outside this list.

## What stays WEAK vs what becomes checkable
- **Checkable (probed):** canon contradictions, power monotonicity, name/glossary adherence, foreshadow
  payoff, main-thread advance, and the *mechanical* part of style consistency (POV person, tense,
  honorific/term usage against the glossary).
- **WEAK (human/LLM-judge):** is the prose *good*, is a character *compelling*, is a twist *earned*.
  Consistency is checkable; quality is not. SPEC is a lower bound on verified truth.
