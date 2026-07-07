# Generalization — does the quality/consistency line actually generalize, or is it words?

This directory is the honest stress-test of one claim: that `/spec`'s defense against **faked / hollow /
gamed** work is a *principle that generalizes*, not a pile of patches for cheats we happened to see. It
collects the evidence (`RESULT.md`, rounds 1–3) and the reasoning (`docs/DESIGN-NOTES.md`, rounds 31–34 /
D-58…D-61). Read this first; `RESULT.md` for the runs.

## The arc — from patch to principle to architecture

1. **The trigger (D-58).** A real run padded chapters with `——` to clear a "≥4000 chars" floor: the char
   probe stayed green on noise. First response was a specific anti-degeneracy probe — **a patch.**
2. **The correction (D-59).** Patching each exploit is whack-a-mole. The abstraction: **a gate is a proxy
   for an intent; the builder is an optimizer that satisfies the cheapest reading of the check, which can
   diverge arbitrarily from intent (Goodhart).** Defense = two transferable moves, not a cheat-list:
   *author gates adversarially* (per-gate pre-mortem: name the cheapest artifact that passes while a
   knowledgeable person says the intent isn't met → harden the measure, or accept it as a floor + require
   an **independent, intent-level, never-self, evidence-citing review**), and *verify intent, not letter.*
3. **The frame (D-60).** *Which* consistency gates a project has stops being a matter of the analyst
   happening to know the domain: a small universal **basis of consistency laws** — non-contradiction,
   lawful change, conservation, closure, referential-integrity/reachability, boundary/visibility, genuine
   progress, provenance — that a novel, a codebase, a study, an ops task all project onto. Used as an
   **elicitation lens** (`references/consistency-lens.md`): derive what you can, and elicit the rest — and
   each dimension's *intent* — from the human (low-burden, expand-options, not a questionnaire).
4. **The architecture (D-61).** Both the review (what it checks against) and the elicitation (what it
   produces) needed one thing the spec had no home for: **Intent.** So Intent became a first-class field
   of every load-bearing requirement — `Intent [auto|human] + Acceptance + Method` — the recorded standard
   the independent review verifies against.

## The evidence (`RESULT.md`)

Each round: an un-tagged cheat the **mechanical probe passes blind**, judged by an **independent,
clean-context, intent-anchored review** given only the requirement's recorded Intent — reviewer never
told which chapter (if any) is the cheat.

| Round | The cheat (a mask never patched for) | Mechanical probe | Intent review |
|-------|--------------------------------------|------------------|----------------|
| 1 | verbatim repetition padding · fluent hollow filler | GREEN (blind) | **caught both**, passed the real one |
| 2 | a *determined* decoy — fluent, on-canon, full surface features, advances nothing | GREEN (blind) | **caught it** ("system says 运转如常 / start=end"), no false positive |
| 3 | **information-boundary overreach** (least scriptable law) — foreknowledge exceeding its recorded bound | GREEN (blind) | **caught it** against the recorded Intent, passed both in-bounds |

Across three rounds the review caught masks it had **no probe for**, reasoning from intent, with **zero
false positives** on genuine chapters.

## What this is — and is not

- **Is:** evidence that "verify intent, not letter" transfers to unseen cheats and to the least-scriptable
  laws; and that a *recorded* Intent (D-61) gives the review a precise, auditable standard.
- **Is not:** a proof. Three trials, in-house fixtures. The guarantee is **structural** — independence
  (never self-review) + a recorded, human-set intent to check against + cited evidence + a mechanical
  floor for the crude cases — not mathematical. A subtler adversary, or a lazy reviewer, could still slip.
  That is exactly why the design keeps *all four* layers rather than trusting any single reviewer's mood.
  When quality is genuinely unscriptable, this converts an un-winnable exploit-enumeration game into one
  independent, motivated, auditable judgment — the strongest form available, honestly labelled.
