# eval/ — a real, non-programming test of `/spec` · `/build` · `/yolo`

This directory is an **evaluation harness**: it runs the three skills' protocols end-to-end
on a deliberately **non-programming** project, to test whether the pipeline's claims
("investigation → feasible spec", "gate-judged done", "autonomous-to-green loop") actually
hold outside software — and to surface where they break.

## Why a novella

The subject is a **mystery novella** (`novella/`). Fiction was chosen on purpose: it is the
hardest stress test of the machinery the last design rounds added —

- **Open-loop / payoff closure** (D-53/54 territory): a mystery planted in chapter 1 that must
  be resolved by chapter *N* is exactly the "declared obligation, closed only by end-to-end
  evidence" pattern — the fiction analog of "code written but never wired to the entrypoint."
- **Acceptance needs a *method*, not a description** (D-54): can `/spec` actually produce a
  **red-able** gate for prose? Where must it honestly fall back to WEAK/OPEN?
- **Done ≠ "looks finished"**: can `/build` close a chapter batch on a *running probe* rather
  than on vibes?

## Methodology (stated honestly)

The three skills are **prompt-protocols for an AI executor** — they are not compiled programs.
"Running the skill" therefore means: an AI executor follows the `SKILL.md` protocol faithfully,
step by step, on this isolated project (its own `SPEC.md` + `.spec/`, separate from the repo's).
That is exactly how these skills run in production. Every observation about where the protocol
strained is logged in [`EVALUATION.md`](EVALUATION.md) as it happened — including the defects.

## Layout

```
eval/
├── README.md            # this file
├── EVALUATION.md        # the running evaluation report: per-skill execution + defects found
└── novella/             # the isolated test project (has its OWN SPEC.md + .spec/)
    ├── CLAUDE.md         # the managed authority block /spec writes
    ├── SPEC.md           # the spec /spec produced for the novella
    ├── manuscript/       # the artifact /build constructs (chapters)
    └── .spec/            # gates (real red-able probes), knowledge, STATE, evidence
```

Read `EVALUATION.md` for the findings; browse `novella/` for the preserved sample artifacts.
