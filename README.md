# /spec

A single, repeatable Claude Code command that turns conversation into one
authoritative specification.

Think of it like `/init`, but for the living spec. You run `/spec`, it
brainstorms with you until **every open question is closed** and **every source of
truth is pinned down**, records the decisions, and writes the complete spec to a
fixed file: **`SPEC.md`** at the repo root. Run it again any time — it reconciles
`SPEC.md` with the project's actual progress, folds in whatever new requirement or
change you bring, keeps clarifying to closure, and rewrites the latest spec.

Everything else is decoupled: downstream work just reads `CLAUDE.md` → `SPEC.md`
and treats `SPEC.md` as the highest-priority reference.

## What it does

```
/spec ──▶ load SPEC.md + scan project ──▶ reconcile drift ──▶ fold in your input
      ──▶ brainstorm to closure (闭环) ──▶ pin sources of truth (真实源/门)
      ──▶ record decisions ──▶ rewrite SPEC.md ──▶ point CLAUDE.md at it
```

- **Closure gate (闭环):** it won't call the spec done while a blocking question is
  unresolved. Items leave the list only when *decided* or *explicitly deferred*.
- **Sources of truth & gates (真实源/门):** every key concern ends with a single
  named authority — no two places silently claim the same truth.
- **One document, always whole:** `SPEC.md` is the single source; it's rewritten in
  full each run, never fragmented.
- **Idempotent:** with no new input and no drift, a re-run changes nothing but the
  timestamp.
- **Decoupled from execution:** `/spec` only specifies. It doesn't write code.

## Usage

```
/spec                                  # create or reconcile the spec
/spec add multi-tenant support         # fold a new requirement in, then converge
/spec <paste a doc / a change / notes> # absorb arbitrary input, then converge
```

`SPEC.md` is generated on first run, so it isn't in the repo yet.

## The SPEC.md structure (fixed)

```
SPEC.md
├─ 0. Meta            version · last updated · status
├─ 1. Vision & Problem
├─ 2. Scope           In / Out (what it deliberately won't do)
├─ 3. Sources of Truth & Gates   ← the 真实源/门: one authority per concern
├─ 4. Requirements    numbered, verifiable
├─ 5. Architecture & Key Decisions   (+ append-only decision log)
├─ 6. Open Questions  ← the closure gate: empty/deferred ⇒ "Closed"
└─ 7. Glossary
```

See `.claude/skills/spec/references/SPEC.template.md` for the full template.

## Layout

```
.claude/
├── skills/spec/
│   ├── SKILL.md                       # the /spec procedure & guardrails
│   └── references/SPEC.template.md     # fixed structure of SPEC.md
└── commands/spec.md                   # /spec slash-command wrapper
CLAUDE.md                              # declares SPEC.md as the supreme reference
```
