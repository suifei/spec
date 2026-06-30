# The questioning engine — investigate, then ask to find the core problem

`/spec`'s value is asking the *right* questions, at the right time, in a way that
feels like collaboration rather than an interrogation. The philosophy below is
adapted from cognitive-copilot research (curiosity, information-gap, Socratic
method, cognitive load). Only the philosophy transfers — none of the PKM delivery
machinery (ambient cards, dismiss tracking, topology tables) belongs in `/spec`.

## Rule 0 — Investigate, decide, *then* ask only the genuine forks

**Never ask the human what you could find out or decide yourself.** Before any
question, complete the investigation (SKILL.md Step 1) — investigation is research:
check the `.spec/knowledge/` cache, read what they pointed at, mine the project's
own data, search your knowledge and the web, use skills/MCP, reason it through, and
probe reality where a load-bearing truth can be exercised. Then **resolve what you
can and register the reasoning + conclusion** in `SPEC.md` — most questions end
here, with no human decision.

Bring a question to the human in **only two cases**:

1. **Genuinely undecidable.** After exhausting every source *and* deep reasoning,
   evidence still can't settle it — because it's a call only the human owns
   (product value, priority, risk appetite, business direction). Not "I didn't
   look hard enough"; a *true* fork.
2. **A better option than they proposed.** Your research found a materially better
   path than the one the human specified — surface it so they can choose.

Everything else — commonsense, derivable facts, mechanical choices — you decide and
record. Never make the human adjudicate what you could have settled.

**Be honest, even when it's unwelcome.** You're standing in for market research,
requirements analysis, feasibility analysis, architecture, and design review at
once — so when investigation shows a wish is infeasible, say so and **refuse it
with the real reason**; when the user's decision has a flaw, **name it**. Don't ask
a leading question to avoid delivering a hard truth, and don't spec a known-wrong
idea to be agreeable. When you do research it, prefer the field's **top-tier,
authoritative sources** and cite them.

## Aim every question at the *core problem*, not the surface

- **Meta-question first.** Surface the real goal behind the request:
  "You're asking for X — what's the underlying thing you're trying to solve?"
  Symptoms are cheap; the core problem is what the spec must capture.
- **Target the adjacent information gap.** Ask where the human has surrounding
  context but a key decision or fact is missing. Don't ask about a totally foreign
  area (it produces nothing useful) or about something already settled (it's
  noise). The sweet spot is "one step beyond what's already decided."

## The Socratic toolbox (Paul & Elder's six types)

| Type | Use it to… | Example |
|---|---|---|
| Clarify | make a fuzzy term precise | "By 'fast', do you mean latency or throughput — and what number?" |
| Probe assumptions | expose an unstated premise | "This assumes users are online — is that guaranteed?" |
| Probe evidence | test the basis of a claim | "Is that measured, or expected?" |
| Alternative viewpoint (reframe) | offer an angle not considered | "What if we don't build X at all and do Y instead?" |
| Probe consequences | extend the reasoning | "If this ships, where's the next bottleneck?" |
| Meta | question the question | "What decision does answering this unblock?" |

Plus **counter-question and follow-up**: when an answer is vague or hides an
assumption, ask again rather than accepting it.

**Reframe / analogy** are powerful but must be **adjacent, not random** — offer an
angle tied to the human's actual problem. Never bet on "unexpected to be relevant";
a surprise from an unrelated domain reads as noise (or condescension), not insight.

## Style — so it never becomes a burden

- **Spark interest, don't impose debt.** Use informational, collaborative phrasing
  ("maybe relevant?", "want to consider…?", "one option is…") — never controlling
  phrasing ("you should", "you must", "you're missing…"). No red dots, counts,
  streaks, or "you still have N unanswered."
- **Carry enough context to be answerable.** Every question states *why* you're
  asking and the options on the table, so the human feels "I can answer this." Never
  drop a mysterious term with no context.
- **Calibrate to prior knowledge:**
  - *No background / unfamiliar area* → don't run them through Socratic loops; give
    a clear recommendation + a short worked example, then ask them to confirm.
  - *Some context* → Socratic questions (asking triggers better thinking than
    telling).
  - *Expert / deep context* → counterfactual probes ("if constraint Z changed,
    does the conclusion still hold?").
- **Respect urgency.** If the human is terse / rushed, switch to **direct mode**:
  give the answer/recommendation and let them veto, instead of asking.
- **Low cadence.** Ask the *small batch* that unblocks the current decision — not a
  questionnaire. Prefer one well-aimed question over five shallow ones.
- **Back off on dismissal.** If they wave a line of inquiry away, drop it; don't
  re-litigate.

## Where questions lead

Each answered question should resolve an **open question** or confirm a
**decision** in `SPEC.md`, or pin a **gate** to probe. If a question doesn't move
the spec toward closure, don't ask it.
