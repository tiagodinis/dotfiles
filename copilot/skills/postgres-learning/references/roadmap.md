# PostgreSQL Roadmap (Layer by Layer)

Teach one layer at a time. A layer is "done" when the learner passes its **Prove it** gate. Red flags are common misconceptions to watch for.

---

## Layer 0 — Mental model
- **Goal:** understand what a relational database and Postgres are before touching SQL.
- **Core concepts:** database vs DBMS vs tables vs rows/columns; why we persist data; Postgres as a server process with its own storage and query engine; the relational model = tabular data + relationships.
- **Prove it:** explain (in their own words) what a table, a row, and a column are, and one reason a DB beats a CSV/JSON file.
- **Exercise:** sketch (no SQL) a table layout for a personal library: books, authors, loans.
- **Red flags:** "a database is Excel", confusing Postgres (server) with a GUI tool (pgAdmin/DBeaver).

## Layer 1 — Setup & SELECT basics
- **Goal:** get a working Postgres and read data.
- **Core concepts:** `psql` connection basics; `SELECT ... FROM ... WHERE ... ORDER BY ... LIMIT`; filtering with `=`, `<>`, `>`, `<`, `LIKE`, `IN`, `BETWEEN`; `NULL` is not `= NULL`; `CREATE DATABASE` + `CREATE ROLE`/`GRANT` basics; a few string/date helpers (`lower`, `length`, `now`, `date_trunc`); `COPY` for bulk load.
- **Prove it:** run and explain 3 queries on a small sample table, incl. one with `WHERE` + ordering.
- **Exercise:** create a scratch DB, load a tiny CSV or `INSERT` a few rows, then filter/sort them.
- **Red flags:** `WHERE name = NULL` returning nothing; forgetting `LIMIT` on exploratory queries; case-sensitivity of quoted identifiers.

## Layer 2 — Tables, types, constraints, DML
- **Goal:** model and mutate data safely.
- **Core concepts:** `CREATE TABLE`; common types (`INTEGER`, `BIGSERIAL`/identity, `TEXT`/`VARCHAR`, `NUMERIC`, `TIMESTAMPTZ`, `BOOLEAN`, `UUID`); constraints — `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`; `INSERT`/`UPDATE`/`DELETE`; `RETURNING`; upserts via `INSERT ... ON CONFLICT`; `ALTER TABLE`; `TRUNCATE` vs `DELETE`.
- **Prove it:** write a small schema + valid/invalid inserts that a constraint correctly rejects.
- **Exercise:** build the library `books` table with sensible types/constraints and do CRUD.
- **Red flags:** using `VARCHAR(n)` everywhere "just in case"; storing money as `FLOAT`/`DOUBLE`; no primary key; timestamps without timezone.

## Layer 3 — Relationships & joins
- **Goal:** model relationships and query across tables.
- **Core concepts:** `FOREIGN KEY` + referential integrity; relationship cardinality (1:1, 1:N, N:M) and where the FK goes; `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`/`FULL` differences; join tables for N:M; referential actions (`ON DELETE CASCADE`/`RESTRICT`/`SET NULL`); self-joins.
- **Prove it:** draw the relationship diagram for books/authors/loans, then write a 3-table join.
- **Exercise:** add `authors` + `book_authors` (N:M) and `loans` (1:N) to the library; query "which books are currently loaned out".
- **Red flags:** forgetting the FK index on the referencing column; `LEFT JOIN` vs `INNER` confusion when filtering (filtering on the right table's column in `WHERE` can null-out the left-join effect); duplicate rows after joins.

## Layer 4 — Aggregation
- **Goal:** summarize data.
- **Core concepts:** aggregate functions `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`; `GROUP BY`; `HAVING` (filter groups, not rows); `COUNT(*)` vs `COUNT(col)`; `DISTINCT`.
- **Prove it:** explain why `WHERE` can't filter an aggregate and `HAVING` can.
- **Exercise:** "books per author with > 5 books", "loans per month", from the library data.
- **Red flags:** selecting a non-grouped column without aggregating it; using `HAVING` where `WHERE` belongs; off-by-one with `COUNT(*)`.

## Layer 5 — Subqueries, CTEs & shaping results
- **Goal:** break a question into steps instead of writing one giant query.
- **Core concepts:** scalar subqueries and `IN (SELECT …)`; `EXISTS`/`NOT EXISTS`; correlated vs uncorrelated subqueries; `WITH` CTEs for naming, reusing and chaining steps; `CASE` for derived/labelled columns; `COALESCE`/`NULLIF` for handling NULLs; `UNION`/`UNION ALL`; a `VIEW` as a saved query (and when a materialized view helps).
- **Prove it:** rewrite a nested subquery as a CTE (and back) and say which reads better; use `EXISTS` to find authors with no loans.
- **Exercise:** on the library data, answer "books never loaned", "authors with more than 5 books", and "loans per month" — one with a subquery, one with a CTE, one with a `CASE` label.
- **Red flags:** `NOT IN (subquery)` returning nothing because the subquery yields a `NULL` (use `NOT EXISTS`); correlated subqueries scanning a large table where a join is better; assuming CTEs are automatically faster (they may be inlined or materialized); using `UNION` where `UNION ALL` would do.

## Layer 6 — Design: normalization vs denormalization
- **Goal:** reason about schema quality, not just write DDL.
- **Core concepts:** normal forms intuition (1NF/2NF/3NF as "no repeating groups", "no partial dependencies", "no transitive dependencies"); denormalization as a deliberate, documented tradeoff; surrogate vs natural keys.
- **Prove it:** take a denormalized sheet and argue which tables you'd split and why.
- **Exercise:** refactor a messy "users_orders_items" single-table design into a normalized schema; note where you'd *keep* denormalized and why.
- **Red flags:** "normalize everything always" (perf/read models exist); storing the same fact twice with no single source of truth; JSON columns as a substitute for modeling.

## Layer 7 — Indexes + EXPLAIN ANALYZE
- **Goal:** make queries fast — and measure it.
- **Core concepts:** index = sorted lookup structure (B-tree); cost of writes vs reads; single vs composite (leftmost prefix) vs partial indexes; `UNIQUE` creates an index; `EXPLAIN (ANALYZE, BUFFERS)` output: seq scan vs index scan, rows estimates; when indexes are *not* used.
- **Prove it:** read an `EXPLAIN (ANALYZE)` output out loud and say whether the query used an index.
- **Exercise:** on a larger table, find a slow filter, add an index, show before/after EXPLAIN.
- **Red flags:** indexing every column; composite index with columns in the wrong order; expecting an index to help `LIKE '%x%'` or a function-wrapped column; not re-checking after data changes.

## Layer 8 — Transactions, ACID, isolation, locking
- **Goal:** understand correctness under concurrency.
- **Core concepts:** `BEGIN`/`COMMIT`/`ROLLBACK`; ACID; why "read committed" vs "repeatable read" vs "serializable" differ; lost updates, dirty/non-repeatable reads, phantoms; row locks and the `FOR UPDATE` pattern.
- **Prove it:** explain what an isolation anomaly is and which isolation prevents it; describe a case where two transactions clobber each other.
- **Exercise:** two `psql` sessions: demonstrate a lost update under read committed, then fix with `FOR UPDATE` (or serializable + retry).
- **Red flags:** thinking transactions = speed; autocommit habits; retries ignored on serialization failures; long transactions holding locks.

## Layer 9 — Migrations, ORM vs raw, next steps
- **Goal:** ship schema changes safely and choose the right tooling.
- **Core concepts:** why migrations (versioned, ordered, reviewable) beat ad-hoc DDL; expand/contract and backward-compatible changes; ORM vs query-builder vs raw SQL tradeoffs; connection pooling basics.
- **Prove it:** plan a backward-compatible "rename column" migration (add → backfill → dual-write → cutover) at a high level.
- **Exercise:** pick a migration tool for their stack and write/run a real migration adding a column + index.
- **Red flags:** editing a migration after it shipped; renaming a column in one step in production; treating the ORM as a schema-design-free zone.

---

## Beyond (optional horizons)
Window functions (rankings, running totals, `LAG`/`LEAD`), Postgres internals (MVCC, vacuum, WAL), partitioning, full-text search, JSONB modeling, replication/high availability, backup/restore (`pg_dump`/`pg_basebackup`), and observability.
