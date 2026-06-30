---
topic: WHAT a "self-evolving agent system" is (the subject — established before any solution)
decision: it is a closed evolution loop {propose a change to a chosen agent component → evaluate against an OBJECTIVE signal → keep iff better → archive}, gated by evidence not self-judgment
status: decided
captured: 2026-06-30
sources:
  - https://arxiv.org/abs/2507.21046     # Survey of Self-Evolving Agents — what/when/how/where to evolve
  - https://arxiv.org/pdf/2508.07407      # Survey: System Inputs / Agent System / Environment / Optimisers loop
  - https://arxiv.org/abs/2505.22954      # Darwin Gödel Machine — empirical self-code-modification + archive
  - https://sakana.ai/dgm/                 # DGM overview (sandboxed, benchmark-validated)
  - https://arxiv.org/abs/2408.08435      # ADAS / Meta Agent Search — evolve agent designs in code
---

## Why this file exists (define the noun before the verb)
Before sketching any architecture, establish what the thing *is* from the
authoritative literature — not from a guessed design.

## What it is (from the surveys)
A self-evolving agent is organized around **what / when / how / where to evolve**
(arXiv 2507.21046). The component that evolves is on a **spectrum**:
**prompts → memory/context → tools → workflow/architecture (topology) → the agent's
own code → model weights** (2507.21046; 2508.07407). The unified framing is a loop
over four parts: **System Inputs · Agent System · Environment · Optimisers**
(2508.07407).

## The essence (the invariant that defines it)
Across the leading concrete systems it is the **same loop**:
> **propose** a modification to a chosen component → **evaluate** the variant
> against an **objective signal** (a benchmark / the environment) → **keep it only
> if it measurably improves** → **archive** the variant for open-ended search.

- **Darwin Gödel Machine** (Sakana/UBC/Vector, 2025): an agent that **rewrites its
  own code** and **empirically validates each change on real benchmarks**
  (SWE-bench 20%→50%), keeping an **archive**; runs in a **sandbox**. Explicitly
  *empirical*, **not** the theoretical Gödel machine's "provable" self-rewrite —
  because provable beneficial self-modification is impractical.
- **ADAS / Meta Agent Search** (ICLR 2025): a meta-agent **programs new agents in
  code**, tests them, and uses results to inform the next round. Three named parts:
  **search space · search algorithm · evaluation function**.

## The load-bearing consequence
The defining invariant is **evolution gated by an objective evaluation, not by the
agent's self-assessment.** Drop that gate and "self-evolution" degrades into drift
/ Goodhart / reward-hacking. So the core problem of *building* one is not "let an
LLM edit itself" — it is **building a trustworthy propose→evaluate→select→archive
loop with an objective fitness signal and a safe rollback**, then choosing *which
layer* evolves. Mechanism details: `evolution-loop.md`.

## Pinned knowledge (for execution)
- Don't conflate the **theoretical Gödel machine** (provable self-rewrite —
  impractical) with **practical self-evolution** (empirical validation + archive).
- The **layer that evolves** is a deliberate choice with very different risk:
  prompt/memory/skills (safe) vs workflow (ADAS) vs self-code/weights (DGM,
  needs sandbox+rollback). This is the human's safety/scope fork.
- Captured 2026-06-30; this is an active 2024–2025 research area — re-verify
  state-of-the-art at build time.
