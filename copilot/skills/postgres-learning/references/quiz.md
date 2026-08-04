# PostgreSQL Quiz Bank

Use for layer gates and spaced-repetition warm-ups. Ask a few questions at a time; reveal the answer after the learner tries.

## Layer 0 — Mental model
1. **Q:** In your own words: what's the difference between "a database" and "a DBMS"?  
   <details><summary>Answer</summary>A *database* is the collection of data (the logical store); a *DBMS* is the software that manages it (Postgres is a DBMS/server — it reads/writes the data files, enforces rules, answers queries).</details>
2. **Q:** Why would you pick Postgres over a big JSON/CSV file for an app's data?  
   <details><summary>Answer</summary>Concurrent access, querying/filtering at scale, consistency/constraints, transactions, and durability — files get messy when many writers and complex queries exist.</details>

## Layer 1 — SELECT basics
1. **Q:** Why does `WHERE name = NULL` never match rows?  
   <details><summary>Answer</summary>`NULL` means "unknown", and `= NULL` is unknown, not true. You must use `IS NULL` / `IS NOT NULL`.</details>
2. **Q:** Write a query returning the 10 newest books from a `books` table with a `published_at` timestamp.  
   <details><summary>Answer</summary>`SELECT * FROM books ORDER BY published_at DESC LIMIT 10;`</details>
3. **Q:** What's the difference between `<>` and `NOT LIKE`?  
   <details><summary>Answer</summary>`<>` compares exact values; `NOT LIKE` negates a pattern match. They test different things (equality vs pattern).</details>

## Layer 2 — Tables & constraints
1. **Q:** Why store a timestamp with timezone (`TIMESTAMPTZ`) rather than a naive local time?  
   <details><summary>Answer</summary>It stores an absolute instant (UTC internally) so the same value renders correctly for users in any timezone; naive times are ambiguous.</details>
2. **Q:** What does `CHECK (price >= 0)` do, and when does it fire?  
   <details><summary>Answer</summary>It's a row-level constraint rejecting inserts/updates where the condition is false, keeping invalid data out at the DB layer.</details>
3. **Q:** Money should be stored as `NUMERIC`, not `FLOAT`. Why?  
   <details><summary>Answer</summary>Floating point is binary and can't represent most decimals exactly (0.1 + 0.2 problems); `NUMERIC` stores exact decimal digits.</details>
4. **Q:** You want "insert this book, but if the ISBN already exists leave it alone". Which statement shape?
   <details><summary>Answer</summary>`INSERT ... ON CONFLICT (isbn) DO NOTHING` — or `DO UPDATE` to upsert. It needs a `UNIQUE`/`PRIMARY KEY` constraint on the conflict target.</details>

## Layer 3 — Joins
1. **Q:** Where does the foreign key live in a 1:N relationship — on the "one" side or the "many" side?  
   <details><summary>Answer</summary>On the "many" side (each child row references one parent).</details>
2. **Q:** When does `LEFT JOIN` return rows the `INNER JOIN` wouldn't?  
   <details><summary>Answer</summary>When the left table has rows with no matching right-side rows — `LEFT JOIN` keeps them, with `NULL` for the right columns.</details>
3. **Q:** Why is a 3-table query sometimes returning more rows than expected?  
   <details><summary>Answer</summary>Likely a fan-out: a row matches multiple rows in a join (e.g. N:M), multiplying rows. Check cardinality — you may need `DISTINCT`, a subquery, or your join conditions are too loose.</details>
4. **Q:** What does `ON DELETE CASCADE` on a foreign key do, and what's the risk?
   <details><summary>Answer</summary>Deleting a parent row automatically deletes its children, preserving referential integrity. The risk is that one delete silently wipes many rows — `RESTRICT` or `SET NULL` is often the safer default for important data.</details>

## Layer 4 — Aggregation
1. **Q:** `COUNT(*)` vs `COUNT(col)` — difference?  
   <details><summary>Answer</summary>`COUNT(*)` counts rows in the group; `COUNT(col)` counts non-`NULL` values of that column.</details>
2. **Q:** Why can't you write `WHERE COUNT(*) > 5`, and what do you use instead?  
   <details><summary>Answer</summary>`WHERE` filters rows before grouping, so aggregates aren't available yet. Filter groups after grouping with `HAVING COUNT(*) > 5`.</details>
3. **Q:** Write a query counting books per author.  
   <details><summary>Answer</summary>`SELECT author_id, COUNT(*) FROM books GROUP BY author_id;` (join to authors if you want names).</details>

## Layer 5 — Subqueries, CTEs & shaping results
1. **Q:** `WHERE id NOT IN (SELECT parent_id FROM books)` returns zero rows, though you know some books have no parent. Why?
   <details><summary>Answer</summary>If the subquery yields even one `NULL`, `NOT IN` evaluates to unknown for every row, so nothing matches. Use `NOT EXISTS`, or exclude NULLs inside the subquery.</details>
2. **Q:** When is `EXISTS` a better fit than `IN`?
   <details><summary>Answer</summary>When you only care *whether* a matching row exists: it short-circuits, is NULL-safe, and is often faster for a correlated check against a large table.</details>
3. **Q:** What does `COALESCE(a, b, c)` return?
   <details><summary>Answer</summary>The first argument that isn't `NULL` — the usual way to supply a fallback for a nullable column.</details>
4. **Q:** Why put part of a query in a `WITH` CTE?
   <details><summary>Answer</summary>Readability and structure: it names a step, lets you reuse it, and replaces deep nesting with a readable chain. It is not automatically faster — the planner may inline or materialize it.</details>
5. **Q:** `UNION` vs `UNION ALL`?
   <details><summary>Answer</summary>`UNION` removes duplicate rows and pays for a sort/hash to do it; `UNION ALL` keeps every row and is cheaper — use it when you know the rows are distinct.</details>
6. **Q:** What is a `VIEW`, in one sentence?
   <details><summary>Answer</summary>A saved query you can select from like a table. It stores no rows (a *materialized* view does, and must be refreshed).</details>

## Layer 6 — Schema design
1. **Q:** Name the smell that 2NF/3NF mainly attack.  
   <details><summary>Answer</summary>Storing the same fact in multiple places / a column depending on part of the key or on a non-key column → update anomalies and inconsistency.</details>
2. **Q:** When is denormalization reasonable?  
   <details><summary>Answer</summary>As a deliberate, documented tradeoff for read performance or simpler queries (e.g. a precomputed count or cached display field) — with the write-path complexity acknowledged.</details>

## Layer 7 — Indexes
1. **Q:** Give one cost of adding an index.  
   <details><summary>Answer</summary>Every write (INSERT/UPDATE/DELETE) must also maintain the index, and indexes take disk space. Too many indexes slow writes.</details>
2. **Q:** For `WHERE a = ? AND b = ?`, why might `INDEX(a,b)` beat `INDEX(b,a)`?  
   <details><summary>Answer</summary>Equality on both means order matters less; but the index can only use a leftmost prefix for range/order. `(a,b)` also serves queries filtering only on `a`, which `(b,a)` can't. Choose based on real query mix.</details>
3. **Q:** Will an index on `name` speed up `WHERE lower(name) = 'x'`?  
   <details><summary>Answer</summary>Not with a plain B-tree — the column is wrapped in a function, so the index isn't usable. You'd need an expression index on `lower(name)`.</details>

## Layer 8 — Transactions & isolation
1. **Q:** What's a lost update?  
   <details><summary>Answer</summary>Two transactions read the same value, both modify it, and the later commit overwrites the earlier one — one update silently disappears.</details>
2. **Q:** Under which isolation level does it still happen by default, and how do you prevent it?  
   <details><summary>Answer</summary>Read Committed (Postgres default). Prevent with `SELECT ... FOR UPDATE` (row lock) or `SERIALIZABLE` + retry on serialization failure.</details>
3. **Q:** True or false: transactions make queries faster.  
   <details><summary>Answer</summary>False — they're about correctness (atomicity/consistency under concurrency), not speed.</details>

## Layer 9 — Migrations & tooling
1. **Q:** Why versioned migrations instead of running DDL by hand?  
   <details><summary>Answer</summary>Migrations are ordered, repeatable, reviewable, and track what's applied where — so dev/staging/prod stay in sync and changes are auditable.</details>
2. **Q:** Why is "rename this column in one migration" risky in production?  
   <details><summary>Answer</summary>Old code still running against the DB will break the moment the column changes. Safe path: add new column → backfill → dual-write → switch code → drop old.</details>

---

## Warm-up suggestion
At the start of a session, pick 2 questions from the most recently completed layer and 1 from an earlier one.
