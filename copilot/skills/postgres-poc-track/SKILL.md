---
name: postgres-poc-track
description: Scoped PostgreSQL learning track that ends in the MIWA/Orionis telemetry PoC. Use when the learner's goal is the PoC rather than general Postgres fluency — a tight subset (layers 0, 1, 2, 4, 7) taught in the same container the PoC will use, with PoC-anchored exercises and an explicit hand-off to Session 01. Delegates concept depth and quizzing to `postgres-learning`.
---

# PostgreSQL → Telemetry PoC Track

A deliberately narrow sibling of `postgres-learning`. Same teaching method, one-fifth the scope,
with a hard exit criterion: **Session 01 of the PoC.**

## Contents
- [track](./references/track.md) — the five layers in scope, PoC anchors, gates, hand-off

## When to use
- The learner is building the MIWA/Orionis telemetry PoC and needs just enough Postgres to start.
- The learner says "just the basics", "I don't want to get confused", or names the PoC.
- NOT for general Postgres fluency or interview prep — use `postgres-learning` for that.

## How to use
1. Load `[track](./references/track.md)` **and** `postgres-learning`'s
   `[roadmap](../postgres-learning/references/roadmap.md)`. Depth comes from the parent skill;
   scope comes from this one. Never invent a lesson that isn't in one of them.
2. Load the parent skill's `[quiz](../postgres-learning/references/quiz.md)` for gates.
3. Mirror the five in-scope layers as todos. Do not add layers the track excludes.
4. Confirm the container exists before Layer 1 (see the track's environment section).
5. Teach one concept per exchange; run the layer's gate before advancing.

## Scope rules (non-negotiable)
- **In scope:** layers 0, 1, 2, 4, 7 — in that order. Layer 7 is pulled forward on purpose;
  Session 01 cannot be read without it.
- **Out of scope before the PoC:** layers 3, 5, 6, 8, 9. If the learner asks, answer briefly and
  park it: "that lands in the PoC when the read API needs it."
- **Never teach TimescaleDB concepts** (hypertables, chunks, compression, continuous aggregates)
  from Postgres material. They are out of scope here and belong to Session 01, learned by doing
  from Timescale's docs. Say so if asked.
- **Never create the `poc` database.** It is created at Session 01, by the learner, on purpose.

## Environment
One container, kept for the entire PoC, with two databases: `learn` (scratch, freely destroyable)
and `poc` (does not exist yet). Learning happens in `learn` only. See the track file for commands.

## Tutor constraints specific to this track
- **You have no terminal.** Hand the learner exact commands to paste, one block at a time, and ask
  for the pasted output before interpreting it. Never claim to have run something.
- Anchor every exercise in the PoC's own shapes — units, variables, readings over time. Once past
  Layer 2, stop using toy domains entirely.
- The finish line is not "understands Postgres". It is "all five gates passed → start Session 01".
  Say that out loud when they get there, and stop teaching.
