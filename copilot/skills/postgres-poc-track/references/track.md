# Track — Postgres basics → telemetry PoC

Scope and sequencing only. Concept depth, examples and the quiz bank live in the parent skill
(`postgres-learning`). This file says *what is in scope, in what order, and when to stop.*

**Exit criterion: all five gates passed → start Session 01 of the PoC.**

---

## Environment (learner runs these — the tutor has no terminal)

One container, kept for the whole PoC. Two databases inside it.

```bash
docker run -d --name ts-poc -p 5432:5432 \
  -e POSTGRES_PASSWORD=poc \
  -v ts-poc-data:/var/lib/postgresql/data \
  timescale/timescaledb:latest-pg17

docker exec -it ts-poc psql -U postgres
```

Then `CREATE DATABASE learn;`, reconnect with `\c learn`, and `CREATE EXTENSION timescaledb;`.

**`poc` is not created here.** It gets created in Session 01, on purpose. Do not create it.

### Seed for Layer 1

Small on purpose — Layer 1 is about reading, not generating.

```sql
CREATE TABLE readings (
  device    text        NOT NULL,
  taken_at  timestamptz NOT NULL,
  value     numeric(12,3)
);

INSERT INTO readings (device, taken_at, value) VALUES
  ('unit-01', now() - interval '9 minutes', 12.400),
  ('unit-01', now() - interval '8 minutes', 12.900),
  ('unit-01', now() - interval '7 minutes', NULL),
  ('unit-02', now() - interval '9 minutes',  0.000),
  ('unit-02', now() - interval '8 minutes',  4.100),
  ('unit-03', now() - interval '3 minutes', 88.000);
```

---

## In scope, in order

### 1 — Mental model (Layer 0)
- **PoC anchor:** before any SQL, sketch what one irrigation unit's readings look like over a day,
  and one reason they can't stay in a CSV.
- **Gate:** explain table / row / column in their own words; name one thing a database does that a
  spreadsheet does not.

### 2 — `psql` + `SELECT` (Layer 1)
- **PoC anchor:** query `readings` — the newest value per device, everything for one device, and
  something that returns nothing because of `NULL`.
- **Gate:** run and explain three queries, one of them filtered *and* sorted.

### 3 — Tables, types, constraints, DML (Layer 2)
- **PoC anchor:** build a simplified `variables` and `readings`/`telemetry` by hand — real types,
  a primary key, `NOT NULL`, `NUMERIC` not `FLOAT`, `TIMESTAMPTZ` not `TIMESTAMP`. Then attempt an
  insert that a constraint rejects, and one upsert with `ON CONFLICT`.
- **Gate:** a constraint correctly rejects an invalid insert, and they can say which one and why.

### 4 — Aggregation (Layer 4)
- **PoC anchor:** readings per device per hour; min/max/avg per device. These are literally the
  read-API queries.
- **Gate:** answer a per-group question, and explain why `WHERE` can't filter an aggregate and
  `HAVING` can.

### 5 — Indexes + `EXPLAIN ANALYZE` (Layer 7) — **pulled forward on purpose**
- **Why here:** Session 01 step 5 reads an `EXPLAIN ANALYZE` output. Without this layer that step
  is noise.
- **PoC anchor:** seed a few hundred thousand rows, run a slow filter, read the plan, add an index
  on `(device, taken_at)`, read the plan again, compare.
- **Gate:** read an `EXPLAIN (ANALYZE, BUFFERS)` output aloud and say whether an index was used,
  with before/after timings.

---

## Out of scope before the PoC

Layers 3 (joins), 5 (subqueries & CTEs), 6 (normalization theory), 8 (transactions & isolation),
9 (migrations & tooling). If asked, answer in a line and park it: *"that lands in the PoC when the
read API needs it."*

Also out of scope: **every TimescaleDB concept.** Hypertables, chunks, compression and continuous
aggregates are not Postgres and appear in no Postgres tutorial. They belong to Session 01, learned
by doing. Do not teach them from the wrong source, and say why.

---

## Timing

Roughly **4–5 sittings.** If the basics pass runs past a week it has stopped being a basics pass —
that is a signal to hand off, not to add more layers.

## Hand-off

When all five gates pass:
1. Say it out loud — "basics are done" — and stop teaching.
2. Point the learner at **Session 01 — Database only**.
3. Tell them the next thing they'll meet, hypertables, is not covered by anything they just
   learned, and that this is expected rather than a gap in their understanding.

## After the hand-off

Return to the parent roadmap on demand, driven by the PoC — not by the syllabus:

| PoC moment | Layer to resume |
| --- | --- |
| Read API joins readings to the variable catalogue | 3 |
| Read API needs tier routing or shaped results | 5 |
| Schema changes after data exists | 9 |
| Ingest concurrency and the newer-`device_ts` rule | 8 |
