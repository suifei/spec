# Decision cases — the /spec questioning doctrine (judgment-heavy)

You are the `/spec` analyst. For each case, decide what the doctrine says to do.
Answer with the LETTER of the single best option. Use ONLY the representation you were given.

## C1
During investigation you hit a choice between two caching libraries. Both are viable; benchmarks
you ran show library A is ~15% faster with no other tradeoff. The human never mentioned caching.
Do you:
- (a) Ask the human which caching library they prefer.
- (b) Pick A, record the benchmark + reasoning in SPEC.md, don't ask.
- (c) Pick A but ask the human to confirm before recording.
- (d) Leave it as an open question for the human.

## C2
You've researched hard and the decision comes down to whether the product should prioritize
low latency or low cost — they genuinely trade off, and which matters depends on the business
model, which you don't know and can't derive. Do you:
- (a) Pick the one most projects pick (low latency) and record it.
- (b) Ask the human — this is a true fork only they own.
- (c) Keep researching until evidence settles it.
- (d) Ask, but phrase it as "you should choose low latency, right?"

## C3
The human said "build it with MongoDB." Your research found that their access pattern is
strongly relational and Postgres would be materially simpler and faster for their case. Do you:
- (a) Silently switch to Postgres — you know better.
- (b) Build MongoDB as asked; the human decided.
- (c) Surface the finding — "one option that looks materially better for your access pattern is
  Postgres, because…" — and let them choose.
- (d) Ask "are you sure about MongoDB?" without saying why.

## C4
You want to ask the human a question. You have not yet written down anywhere which sources you
checked or what you concluded. Is asking now legitimate?
- (a) Yes — the question is what matters, not the paperwork.
- (b) No — the investigation trail (sources + conclusions) must already be logged before a
  question reaches the human; an untrailed question isn't earned.
- (c) Yes, but only if the human is an expert.
- (d) No, you must never ask the human anything.

## C5
The human is a domain expert with deep context on the subject. You need to pressure-test one
assumption in their design. Which questioning mode fits?
- (a) Give a recommendation + a worked example and ask them to confirm.
- (b) Run them through a full Socratic loop from first principles.
- (c) A counterfactual probe — "if constraint Z changed, does the conclusion still hold?"
- (d) Don't ask experts anything; just record their design.

## C6
The human has NO background in the unfamiliar area your question touches. How do you engage?
- (a) Socratic questions — asking triggers better thinking than telling.
- (b) A counterfactual probe.
- (c) Don't run them through Socratic loops; give a clear recommendation + a short worked
  example, then ask them to confirm.
- (d) Send them a list of six clarifying questions to answer.

## C7
The request is "a web version of Anki." You're eager to start choosing the UI framework. What
does the doctrine say to establish first?
- (a) The UI framework — decide fast so you can move.
- (b) What Anki fundamentally is and how spaced repetition works, from authoritative sources,
  before sketching any solution.
- (c) The human's favorite color scheme.
- (d) A full feature list, enumerated exhaustively.

## C8
The human is terse and clearly rushed ("just get me something, quick"). You have a decision that
you'd normally raise as a question. What does the doctrine say?
- (a) Ask anyway — the process requires it.
- (b) Switch to direct mode: give the answer/recommendation and let them veto, instead of asking.
- (c) Send the full question batch but mark it urgent.
- (d) Stop work until they have time to answer.

## C9
Your investigation shows the human's core wish is infeasible — the thing they want is proven not
to work. The truth is unwelcome. What does the doctrine say?
- (a) Spec a close-enough version that works, without mentioning the infeasibility.
- (b) Ask a leading question that steers them away, without stating the problem.
- (c) Say so and refuse it with the real reason; name the flaw honestly.
- (d) Build the infeasible thing and let it fail as evidence.

## C10
You're about to ask a question. It's well-researched and a genuine fork. But answering it wouldn't
resolve any open question, confirm any decision, or pin any gate in SPEC.md. What do you do?
- (a) Ask it anyway — good questions are always worth asking.
- (b) Don't ask it; a question that doesn't move the spec toward closure shouldn't be asked.
- (c) Ask it and file the answer for later.
- (d) Convert it into five smaller questions.
