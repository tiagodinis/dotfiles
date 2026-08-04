---
name: postgres-learning
description: Step-by-step PostgreSQL learning path with a layered roadmap, concept checks, quizzes, and small exercises. Use when teaching or studying Postgres, SQL, or relational databases — with the `tutor` agent or standalone.
---

# PostgreSQL Learning Skill

Curriculum + question bank for learning PostgreSQL layer by layer. This is the domain brain for the `tutor` agent and can also be used standalone.

## Contents
- [roadmap](./references/roadmap.md) — ordered layers, goals, prove-it gates, exercises
- [quiz](./references/quiz.md) — quiz bank by layer (with answers)

## When to use
- Learner asks to learn Postgres, SQL, or relational databases from any level.
- `tutor` is teaching a database topic.
- Standalone self-study via `/postgres-learning`.

## How to use (tutor protocol)
1. Load [roadmap](./references/roadmap.md). Confirm the learner's level first — don't start at Layer 0 blindly.
2. Mirror the layer list as milestones in the todo list (one todo per layer).
3. Teach one concept per exchange; after each layer run its **prove it** gate (explain-in-own-words or quiz).
4. Pull questions from [quiz](./references/quiz.md) for checks and spaced repetition.
5. In Layer 1 confirm tooling: local Postgres (e.g. Docker or system package) + `psql`, and which project/stack they'll build against.

## Layer overview
| Layer | Focus | Gate |
|---|---|---|
| 0 | Mental model: relational DBs & Postgres | Explain what a database/table/row is |
| 1 | Setup + SELECT basics | Run your first queries |
| 2 | Tables, types, constraints, keys, DML | Model a small table; insert/update rows |
| 3 | Relationships & joins (1:1, 1:N, N:M) | Join 3 tables correctly |
| 4 | Aggregation: GROUP BY, HAVING | Answer "per group" questions |
| 5 | Subqueries, CTEs & shaping results | Rewrite a subquery as a CTE; use EXISTS |
| 6 | Design: normalization vs denormalization | Justify a schema decision |
| 7 | Indexes + EXPLAIN ANALYZE | Read an EXPLAIN output |
| 8 | Transactions, ACID, isolation, locking | Explain isolation anomalies |
| 9 | Migrations, ORM vs raw, next steps | Plan a small migration |

Full detail, prove-it checks, exercises, and red flags live in [roadmap](./references/roadmap.md).

## Notes for the tutor
- Keep each session scoped to part of one layer; stop at a natural checkpoint.
- Prefer the learner's real project over toy examples once past Layer 3.
- Track what layer they're on across sessions; open with a 2-question spaced-repetition warm-up from [quiz](./references/quiz.md).
