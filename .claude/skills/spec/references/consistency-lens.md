# Consistency lens — eliciting a project's load-bearing consistency dimensions

Long-running work is the incremental construction of a **state model** under **consistency laws**:
almost every way it rots — a contradiction buried 50 chapters (or 50 commits) later, an unpaid setup, a
faked "done", a leaked secret, an orphaned reference — is a *law* being violated. Domains name these
differently (a novel's canon/bible, code's contracts + dependency graph, a study's assumptions + error
budget), but they project onto a small **universal basis**.

**Use this basis as a lens to think with, not a checklist to enshrine — and above all as an ELICITATION
scaffold.** You are the analyst; the basis is your internal differential. Derive which dimensions bear
load where you can, and **draw the rest — and the *intent* behind each — out of the human
interactively.** The human owns what "consistent" *means* for their project; you own spotting the gaps
and asking well. (This is also what closes the anti-cheat loop: the "verify intent, not letter" principle needs
an intent, and intent can't be derived — it is the human's to state. Eliciting it here is where it comes
from.)

## The basis (each: what it guards · cross-domain · the question you'd elicit)

| # | Law | Cross-domain form | Elicitation question (ask only if you can't derive it) |
|---|-----|-------------------|--------------------------------------------------------|
| 1 | **Non-contradiction** — an established fact stays true unless explicitly revised | novel: character/world canon · code: contracts/schemas/invariants · research: settled definitions/results | "Once you've stated X, what must never quietly change later? What's the canon here?" |
| 2 | **Lawful change** — a mutable attribute may change only by its rule (immutable / monotone / continuous / allowed transitions) | novel: 境界 monotone, emotion arc · code: version/state-machine/migration · research: an estimate that should only converge | "What's allowed to change over time — and by what rule? What change would be *illegal* (a jump, a regression)?" |
| 3 | **Conservation** — an accounted quantity must balance; nothing from nothing (decay is lawful change of a quantity) | novel: money/items/星力 · code: memory/budget/transactions · research: error/sample budget | "What is being *spent or accounted*, and must it balance? What can't appear from nowhere?" |
| 4 | **Closure** — every opened obligation is discharged, on time; none dangles | novel: 伏笔/unresolved conflict · code: TODOs/deprecations/tickets · research: hypotheses to test, promised proofs | "What are you opening here that you're *promising* to resolve — and by when?" |
| 5 | **Referential integrity + reachability** — every reference resolves; no orphan/dangling; reachable from the real entrypoint | novel: relationship/interaction graph · code: dependency/call graph, wiring · research: citation/evidence graph | "What refers to / depends on what — and is the thing actually *reached* from where it matters?" |
| 6 | **Boundary & visibility** — information and access respect their declared scopes; no leak, no acting on what you shouldn't know | novel: who-knows-what (fair-play mystery) · code: encapsulation/access-control/security · research: train↔test leakage, embargo | "Who is allowed to know or touch what, at each point? What would be a leak or an out-of-bounds move?" |
| 7 | **Genuine progress** — each active thread advances toward closure, no stall, and the advance is *real* (judged by intent, not faked) | novel: main/subplot advance, no 注水 · code: milestones truly close, no busywork · research: each pass reduces uncertainty | "For each thread: what counts as *real* progress here vs. going through the motions?" |
| 8 | **Provenance** — every change is recorded, timestamped, attributable (the substrate that makes 1–7 checkable) | novel: chapter summaries · code: commits/changelog · research: lab notebook/decision log | (rarely elicited — you provide this via `STATE.md` / evidence / Decision Log) |

Laws 1–6 govern the *state*; law 7 is the *goal* — genuine progress, and the "verify
intent, not letter" principle lives here; law 8 is the *substrate* that
makes the rest verifiable.

## How to run it (derive first, ask sparingly, human owns intent)

1. **Derive what you can (investigation, Step 1).** From the domain, mark which laws obviously bear
   load. *Don't ask what you can tell* — a serial novel obviously has canon (1), closure (4), progress
   (7); a payments system obviously has conservation (3) and boundary (6). Register `[auto]`.
2. **Ask only the genuine residue — and ask by *expanding options*, not interrogating.** The lens is a
   **derivation engine first, an elicitation aid only for the residue.** A dimension (and its intent)
   that the basis + your investigation settle with **high confidence is decided and registered `[auto]`
   — you do NOT ask it.** The human's attention is spent only on what is *genuinely* undecidable: which
   dimensions truly bear load here, and what a *violation* of each means (the intent the independent review needs — theirs
   to state). And when you do ask, **lead with a curated option-set you generated from the basis +
   research — candidate dimensions, candidate intents, framings they may not have considered — with a
   recommendation**, not a blank prompt. The human's strength is judgment, imagination, and receptivity,
   **not** recall of consistency theory or breadth of prior art; do the breadth *for* them and let them
   choose / react / extend. (This is Step 3(b) — "a better option you found" — applied to the lens, and
   `questioning.md`'s "beginner → recommendation + example" generalized: even an expert has bounded
   breadth versus your sweep, so offering well-formed options serves them better than an open question.)
   **Never dump the eight laws as a questionnaire.**
3. **Turn each surfaced dimension into a gate family** — a red-able probe where the truth is mechanical
   (canon/conservation/closure/reachability/boundary can often be instrumented, see `probes.md`), an
   **independent intent-level review** where it isn't (genuine progress/quality). Write the dimension's
   purpose into the requirement's first-class **Intent field** (tagged `[auto]` if you derived it,
   `[human]` if elicited) — that recorded intent is exactly what the independent review verifies against
   (see `references/probes.md`); do not leave it as implicit prose. Then it's an ordinary gate, held to the three-part test in
   `SKILL.md`.
4. **Stay open — the basis is well-grounded, not complete.** The human may name a load-bearing dimension
   it doesn't cover (an aesthetic bar, an ethical/legal constraint, a domain invariant). Add it as a
   first-class dimension; the lens is a starting scaffold, not a ceiling.

The point of the lens is that discovering *which consistency truths a project rests on* stops being a
matter of the analyst happening to know the domain (the failure mode of relying on executor knowledge)
and becomes a systematic sweep — while the calls that are genuinely the human's (which dimensions matter,
and what each one *means*) are elicited from them, not guessed.
