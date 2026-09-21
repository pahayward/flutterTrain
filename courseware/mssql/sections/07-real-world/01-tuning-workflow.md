---
id: 01-tuning-workflow
title: "A query tuning workflow"
order: 1
section: 07-real-world
language: sql
summary: "A repeatable process for making slow queries fast"
tags: [performance, tuning, workflow, practice]
---

# A query tuning workflow

Tuning follows a repeatable loop. Do it in order; do not guess.

## Step 1: measure first

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- ... the slow query ...
```

Record **logical reads** and **elapsed time** before touching anything.
Baselines let you prove improvement.

> [!key] One change at a time
> Change the index, retest. Change the query, retest. "I changed everything
> and it got faster" cannot be reproduced — or trusted.

## Step 2: read the plan

Enable **Actual Execution Plan** and look for:

- Table/Index Scans on big tables.
- Key/RID lookups (consider a covering index).
- Sorts (is an index already ordered for me?).
- Big cost % operators.
- Large spills (a temp table spilled to disk).

> [!trap] Misleading estimates
> A plan that *looks* fine but misestimates rows suffers from stale
> statistics. `UPDATE STATISTICS table;` and rerun.

## Step 3: find the missing index

The engine will often suggest `/* missing index */` in the plan. It is a
hint, not a command — but a strong signal.

```sql
-- candidate from a plan
CREATE NONCLUSTERED INDEX IX_Orders_Cust_Date
ON Orders (CustomerID, OrderDate)
INCLUDE (TotalAmount);
```

## Step 4: rewrite sargably

Fix nonsargable predicates (YEAR()/UPPER()/percent LIKE), implicit
conversions, and `OR`-across-columns by plan reasoning — see the sargability
lesson.

## Step 5: simplify the shape

- Avoid double-aggregation joins (two one-to-many joins in one GROUP BY).
- Turn `WHERE col IN (SELECT ...)` into a join when it helps the plan.
- Prefer **NOT EXISTS** over **NOT IN** when NULLs exist.
- Replace big scalar-UDF calls with inline forms or computed columns.

## Step 6: validate with a regression check

```sql
-- verify both queries return identical rows
SELECT COUNT(*) FROM (... old query ...) x;
SELECT COUNT(*) FROM (... new query ...) y;
```

Then compare reads. Faster + same answer = done.

## Checklist (shorthand)

1. Capture baseline (time + logical reads).
2. Actual plan → spot the expensive node.
3. Add/adjust one index; retest.
4. Make predicates sargable.
5. Re-measure. Repeat with the next bottleneck.
6. Prove row-equality before shipping the change.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which metric is a stable before/after gauge?"
    type: single
    choices:
      - "logical reads"
      - "wall clock time alone"
      - "rows in the result"
      - "rows returned per second"
    answer: [0]
    explanation: "Logical reads are machine-stable; wall time varies with load."
    difficulty: 2
  - id: q2
    prompt: "What is the role of STATISTICS?"
    type: single
    choices:
      - "They decide access paths via row estimates"
      - "They store backup sizes"
      - "They record every query"
      - "They are logs of deadlocks"
    answer: [0]
    explanation: "The optimizer estimates row counts from statistics to choose operators."
    difficulty: 2
  - id: q3
    prompt: "What is the value of changing one thing at a time?"
    type: single
    choices:
      - "It is faster"
      - "You can attribute the improvement"
      - "Less disk usage"
      - "It avoids permissions errors"
    answer: [1]
    explanation: "Isolate the variable to know what actually helped."
    difficulty: 1
  - id: q4
    prompt: "When is a 'missing index' suggestion most trustworthy?"
    type: single
    choices:
      - "When it matches the query's actual hot spot"
      - "Always, blindly"
      - "Only on small tables"
      - "Never"
    answer: [0]
    explanation: "Validate the suggestion against the measured bottleneck."
    difficulty: 2
```