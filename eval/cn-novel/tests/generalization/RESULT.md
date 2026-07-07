# Generalization test — does "intent-level review" catch cheats it has no probe for?

**Date:** 2026-07-07 (vm, UTC). **Purpose:** the user's challenge — `——` padding was one mask;
does the *principle* (D-59: a gate is a proxy for intent; verify intent, not letter; known tricks
are non-exhaustive) actually catch a **different, un-probed** cheat, or is it just words?

## Setup (fair test)

Three anonymised draft chapters, the reviewer **not** told which (if any) is a cheat:
- **chA** — near-verbatim **repetition padding**: one sentence rewritten 6× with cosmetic edits.
- **chB** — **fluent-but-hollow filler**: grammatical, varied scenery/mood prose that advances nothing.
- **chC** — a **genuine** chapter (real discovery + capability + stakes) as the control.

Neither chA nor chB has a probe written for it. Both are *new* masks, distinct from `——`.

## Result

**Step 1 — the mechanical probe is blind to these cheats.** `G-antidegeneracy.sh` (the `——` patch)
passed **all three** (dash≈0, no single-char domination, no long runs):
```
OK chA  OK chB  OK chC   RESULT: GREEN
```
So the specific patch does nothing here — any catch is the intent-level review's doing.

**Step 2 — the independent intent-level review caught both, from intent alone, with cited evidence,
and passed the real one:**

| Chapter | Cheat (hidden from reviewer) | Verdict | Reviewer's cited reason |
|---------|------------------------------|---------|--------------------------|
| chA | repetition padding | **FAIL** | quoted the byte-identical paragraphs; "the character 'plans his next steps' without a single next step ever being named" |
| chB | hollow filler | **FAIL** | "no character acts, speaks, decides, or is even named; no plot event occurs"; quoted the empty 仿佛…也仿佛… hedging |
| chC | none (genuine) | **PASS** | cited the 封→引 discovery, the tested lock-rune result, and the fresh stakes — real progress |

The reviewer was a fresh clean-context sub-agent given only the requirement's **intent** and the three
chapters; it reasoned from purpose (the tricks were named only as *non-exhaustive priming*), and it
produced **no false positive** on the genuine chapter.

## Honest reading

- **What this shows:** the D-59 abstraction generalizes — an independent, adversarial, intent-anchored
  review catches un-probed cheats (repetition, hollow filler) that the specific mechanical probe misses,
  without flagging a real chapter. The defense transferred to masks it was never patched for.
- **What it does NOT show:** this is one trial with in-house fixtures — not a proof. A subtler cheat, or
  a lazy/gameable reviewer, could still slip. The guarantee is **structural**, not mathematical:
  independence (never self-review) + adversarial intent-anchoring + cited evidence + a mechanical floor
  underneath (defense in depth). That is the strongest form available when quality is unscriptable — it
  converts an un-winnable exploit-enumeration game into one independent, motivated, auditable judgment.

---

## Round 2 — the ADVERSARIAL reviewer test (a determined cheat)

A cheat written *specifically to beat the reviewer*: fluent, on-canon, correctly styled, with every
surface feature of a real chapter (setting, dialogue, an action beat, a system message, a resolute
closing) — but **subtly hollow**: it advances nothing. Placed among two genuine chapters, anonymised
(`adversarial/ch1..ch3`), reviewer not told which was the decoy.

- Mechanical probe: **GREEN on all three** (no `——`, normal distribution) — fully blind.
- Independent intent-review verdict:
  - **ch2 = FAIL** (the decoy) — caught it and named the sharpest tell: the system line **"运转如常"**
    (capability unchanged), every "fact" a restatement of known lore, the rune "又缓缓散去" (no residue),
    the close an *intention not an event* → "start state = end state".
  - **ch1 = PASS**, **ch3 = PASS** — each with a cited concrete delta (enemy can command residuals
    across deep space; a second mole using a dead man's identity). **No false positive.**

**Reading:** the structural guarantee held against a *determined* fluent-hollow cheat that the mechanical
layer passed completely. Still one trial with in-house fixtures — a structural guarantee, not a proof; a
subtler adversary could still slip, which is why the design keeps a mechanical floor + independence +
cited evidence rather than trusting any single reviewer's mood.

---

## Round 3 — information boundary (law 6), the least scriptable law — verified against a RECORDED Intent (D-61)

The hardest case: a *foreknowledge overreach*. R9's mechanical floor treats 陆沉's rebirth-memory as
licensed, so it cannot judge whether a given "memory" exceeds his author-set bound — that is purely the
WEAK intent-review's job, and it must verify against R9's **recorded** Intent (limited & drifting; only
big lived/heard events; no fine detail he couldn't have witnessed). Three chapters, blind, one a subtle
overreach dressed as natural foreknowledge.

- Mechanical floor `G-infoboundary.sh`: **GREEN** (blind — no tagged uses, and by design it can't judge
  the foreknowledge bound).
- Independent intent-review, given R9's recorded Intent:
  - **ch2 = FAIL** — quoted the over-reach: exact words of a *triple-sealed private meeting* he could not
    have witnessed, an exact date, impossible micro-detail (candle direction, a half jade-seal), and
    "分毫不差 / 不必再查 / 错不了" — the opposite of the fuzzy, drift-aware memory the bound requires.
  - **ch1 = PASS** (coarse, "只知会来", drift-aware) · **ch3 = PASS** (lived it but distant/uncertain,
    gives a direction not an answer). **No false positive.**

**Reading:** the WEAK intent-review carried the least-scriptable law by **reasoning from the recorded
Intent field** — validating D-61 (the reviewer checks against a recorded intent, not a guessed one) and
D-59 (verify intent, not letter) on the hardest terrain. Same honest caveat stands: one trial, in-house
fixtures — a structural guarantee (independent + against a recorded human-set intent + cited + a
mechanical floor for the crude cases), not a proof.
