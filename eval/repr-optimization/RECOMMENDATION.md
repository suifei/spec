# Applying the finding — the decision rule + a worked before/after on a real skill block

The experiment (see `RESULT.md`) converged on a rule, not a blanket rewrite. This file makes it
actionable: the rule, then a real before/after on an actual skill block, showing the hybrid.

## The decision rule (what to convert, what to leave)

For any block of skill text, classify its payload:

```
payload = STRUCTURAL   (routing / field schema / pipeline / state machine / mapping / invariant)
              → render as text+arrows/table, SHARED symbols only ( → ∧ ∨ ¬ ≻ ∀ ∃ ), NO per-file legend
              → ~-50% tokens, full fidelity (proven: round 1 & 2)

payload = MOTIVATING-WHY   (the reason a rule exists, the failure it prevents)
              → keep as prose. It's what makes the agent internalise vs mechanically follow.

payload = EXEMPLAR   (a concrete sample phrase / snippet that calibrates tone or shows the trap)
              → keep verbatim. Defense-in-depth vs drift & weaker readers (round 3: a strong reader
                 doesn't strictly need it, but it's cheap insurance the fidelity test can't price).
```

Most real skill blocks are **mixed** → the right output is a **hybrid**: arrow-ify the structural
skeleton, keep the one or two load-bearing exemplar/why sentences in prose beside it.

**Do NOT** convert a whole judgment/doctrine section (e.g. build Step 4's independent-review rationale)
to notation — that's the over-optimization the experiment warns against. And **do NOT** adopt a dense
bespoke DSL-with-legend (arm D) as house style, despite it winning raw fidelity-per-byte.

## Worked before/after — `references/probes.md`, "Match the method … at the real entrypoint"

This block's *core* is a pure `acceptance.kind → method` mapping (structural) wrapped in one load-bearing
exemplar (the `<X/>`-mounted trap) and one invariant (negative-control-breaks-wiring). Hybrid conversion:

### BEFORE (current — 4-bullet prose list, the mapping ~600 chars)

> - **User-visible / interaction behavior** (a UI element, a status, a click flow) ⇒ **drive the
>   actually-running product end-to-end** (e.g. Playwright against the running app) and assert what the
>   *user* observes — **not** a component rendered in isolation or the source read by eye. Rendering
>   `<X/>` in a unit test proves nothing about whether `<X/>` is mounted on the screen you actually use.
> - **A pure function / module contract** ⇒ a unit probe asserting input→output.
> - **A service / API / cross-process contract** ⇒ an integration probe hitting the real endpoint or seam.
> - **A quality/subjective bar** ("is the payoff satisfying") ⇒ WEAK (above).

### AFTER (hybrid — arrow-table skeleton + the one load-bearing exemplar kept in prose)

> The modality is **derivable from the acceptance's nature** (decide silently, register `[auto]`):
>
> ```
> acceptance's nature ─▶ method
>   user-visible / interaction (UI element · status · click flow)
>        ─▶ drive the RUNNING product end-to-end (e.g. Playwright), assert what the USER observes
>           ¬ component-in-isolation · ¬ source-by-eye
>   pure function / module contract      ─▶ unit probe (input→output)
>   service / API / cross-process        ─▶ integration probe (real endpoint/seam)
>   quality / subjective bar             ─▶ WEAK
> ```
>
> The `<X/>` trap makes the top row load-bearing: rendering `<X/>` in a unit test proves nothing about
> whether `<X/>` is mounted on the screen you actually use.

The routing became a scannable table (faster to consult, fewer tokens); the one sentence that carries
the *why* stayed prose. Net on this block: tighter, no fidelity loss, no bespoke legend.

## How to ship it (per this repo's change-discipline)

A representation rewrite of load-bearing skill text is a real change, not a free edit:
1. Branch → convert the identified structural blocks (probes.md mapping, the `done =` / `ask-gate`
   definitions, the requirement-format schema) with the hybrid rule.
2. Add a dated round + `D-NN` to `docs/DESIGN-NOTES.md` (rule: structural→shared-symbol arrows,
   why/exemplars→prose; reject bespoke-DSL house style).
3. Keep `SPEC.md` / `.spec/` in sync; **regression = re-run every eval probe + `--selftest`** to prove
   the skills still behave identically after the rewrite (representation change must be behavior-neutral).
4. PR → merge.

Because it touches load-bearing references, it should be greenlit before mutating the files — the
experiment's own conclusion is that the win is targeted and modest, so it's worth doing deliberately,
not as an incidental churn.
