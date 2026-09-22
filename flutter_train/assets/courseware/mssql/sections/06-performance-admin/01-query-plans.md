---
id: 01-query-plans
title: "Reading execution plans"
order: 1
section: 06-performance-admin
language: sql
summary: "Actual vs estimated plans, operators, costs, and warnings"
tags: [execution-plan, performance, operators, query-analysis]
---

# Reading execution plans

When a query is slow, the **execution plan** tells you exactly why. Every good
SQL tuner learns to read one.

## Where to look

- SSMS / Azure Data Studio: **Actual Execution Plan** (trace the query),
  or **Estimated Plan** on query alone.
- You can also capture the plan's text with `SET STATISTICS PROFILE ON` or
  query it from `sys.dm_exec_query_plans`.

## The plan is a tree of operators

Operators are nodes; data flows from bottom to top.

```
SELECT (<--- result)
  └─ Nested Loops (Join)
      ├─ Index Seek (Orders.CustomerID)     ← cheap, uses an index
      └─ Key Lookup (dbo.Orders)            ← goes for remaining columns
```

Common operators:

| Operator | Meaning |
|---|---|
| Index Seek | uses an index to jump to rows — good |
| Index Scan | reads the full index — expensive on big tables |
| Table Scan | reads every row of the table — the worst case |
| Key/RID Lookup | fetch the rest of the row after a nonclustered hit |
| Nested Loops | for each outer row, probe inner — good for small sets |
| Hash Match | build a hash of one side — good for large joins |
| Sort | reorder — costs a pass |
| Spool | materialize intermediate results |

> [!key] The percentage is a share of total cost
> The % next to each operator is relative to the whole statement. The
> fattest percentage you can avoid is your first tune.

## What to look for

1. **Scans on big tables** — needs a helpful index.
2. **Key lookups** — consider a covering index with INCLUDE.
3. **Sorts** — see if an index already offers the order.
4. **High estimated rows vs actual** — cardinality guesses are off.
5. **Table spools / nested loops doing many probes** — join order or
   statistics problems.

## STATISTICS I/O and TIME

Measure numbers, not vibes:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT o.OrderID, o.OrderDate
FROM Orders o
WHERE o.CustomerID = 5;
```

- `logical reads` — pages touched (lower = better).
- `CPU time` / `elapsed time` — compute and wall time.
- `parse and compile time` — plan build.

Watch for dramatic `logical reads` differences between near-identical
queries — that asymmetry usually locates the fix.

> [!tip] Compare plans, not absolutes
> A plan that scans a 5-row table is fine. "Seek everywhere" is a myth. Judge
> plans against the actual data size and the query's job.

## The classic slow query, annotated

```sql
SELECT p.ProductName,
       SUM(oi.Quantity) AS Sold
FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
WHERE p.CategoryID = 2
GROUP BY p.ProductName
ORDER BY Sold DESC;
```

Run with Actual Plan and look:
- Is OrderItems reached by a seek on `ProductID`? (No index? → scan.)
- Does a SORT appear for the GROUP BY? (An index ordering the group column
  would help.)
- Does the join hash (bigger sets) or loop?

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which operator is the worst for a large table?"
    type: single
    choices: ["Index Seek", "Table Scan", "Nested Loops", "Key Lookup"]
    answer: [1]
    explanation: "A table scan reads every row — the most expensive default."
    difficulty: 1
  - id: q2
    prompt: "What does an Index Seek mean in a plan?"
    type: single
    choices:
      - "The engine jumped straight to matching rows"
      - "The engine read the whole index"
      - "The query errored"
      - "The query is uncachable"
    answer: [0]
    explanation: "A seek uses index structure to locate matching entries efficiently."
    difficulty: 1
  - id: q3
    prompt: "Which statement turns on page-read metrics?"
    type: single
    choices: ["SET STATISTICS IO ON", "SHOW PAGES", "TRACEIC", "EXPLAIN IO"]
    answer: [0]
    explanation: "SET STATISTICS IO ON reports logical reads per table."
    difficulty: 2
  - id: q4
    prompt: "What does a Key Lookup after a nonclustered seek usually suggest?"
    type: single
    choices:
      - "A covering index would help"
      - "The query is fine"
      - "A missing constraint"
      - "The table is fragmented"
    answer: [0]
    explanation: "Lookups fetch extra columns; INCLUDE them to avoid it."
    difficulty: 2
```