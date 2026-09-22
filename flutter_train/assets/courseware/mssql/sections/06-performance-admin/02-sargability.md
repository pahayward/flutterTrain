---
id: 02-sargability
title: "Writing sargable queries"
order: 2
section: 06-performance-admin
language: sql
summary: "Predicates that can use indexes and mistakes that block them"
tags: [sargable, performance, predicates, indexes]
---

# Writing sargable queries

A predicate is **sargable** (Search ARGument-ABLE) when SQL Server can use an
index to evaluate it. Nonsargable predicates force a scan.

## The classic mistakes

| Nonsargable | Sargable alternative |
|---|---|
| `WHERE YEAR(OrderDate) = 2025` | `WHERE OrderDate >= '2025-01-01' AND OrderDate < '2026-01-01'` |
| `WHERE UPPER(City) = 'PARIS'` | `WHERE City = 'Paris'` (index-friendly; compare in one case) |
| `WHERE UnitPrice * 1.2 > 100` | `WHERE UnitPrice > 100 / 1.2` |
| `WHERE Volume % 2 = 0` | range/set rewrite if possible |
| `WHERE LastName LIKE '%sen'` | `LIKE 'sen%'` (or a full-text index) |

> [!key] Keep the column bare
> Wrap *literals/parameters*, not columns. The instant a function wraps the
> indexed column, the estimate and the seek both fall apart.

## Trailing wildcards are your friend

```sql
-- seek-able: uses an index prefix
WHERE LastName LIKE 'Smi%'

-- not useful: wildcard first
WHERE LastName LIKE '%mith'
```

A leading `%` defeats ordering-based index use.

## Converting your own

```sql
-- before (scan on OrderDate)
SELECT OrderID FROM Orders
WHERE DATEPART(year, OrderDate) = 2024;

-- after (seek on OrderDate)
SELECT OrderID FROM Orders
WHERE OrderDate >= '2024-01-01'
  AND OrderDate <  '2025-01-01';
```

## NULL, OR, and IN nuances

- `IS NULL`/`IS NOT NULL` are generally sargable.
- `col IN (a, b)` can seek (rewritten as ORs under some plans).
- `col1 = @x OR col2 = @y` on two columns needs an index per column — a
  single-column index usually ends life as a join/UNION rewrite.

## Implicit conversion traps

```sql
-- @id is NVARCHAR comparing to INT column
WHERE OrderID = @id;      -- conversion applied to OrderID -> scan
```

The engine coerces the **column** to the parameter type when they differ,
wrapping the column and killing the seek. Keep types aligned; use
`TRY_CONVERT` / `CAST` on the *variable* side.

## Verification

```sql
SET STATISTICS IO ON;
-- compare the two forms below; the seek version shows far fewer reads
SELECT OrderID FROM Orders WHERE YEAR(OrderDate) = 2024;
SELECT OrderID FROM Orders WHERE OrderDate >= '2024-01-01' AND OrderDate < '2025-01-01';
```

> [!tip] Sargability is a habit, not a law
> Tiny tables: scans are fine. Data in the millions: every nonsargable
> predicate costs seconds. Measure with STATISTICS IO and the plan.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which predicate can use an index?"
    type: single
    choices:
      - "WHERE YEAR(OrderDate) = 2025"
      - "WHERE OrderDate >= '2025-01-01'"
      - "WHERE UPPER(City) = 'PARIS'"
      - "WHERE UnitPrice * 2 > 100"
    answer: [1]
    explanation: "A bare column compared to literals is sargable and can seek."
    difficulty: 1
  - id: q2
    prompt: "Why does WHERE Function(col) = x cause a scan?"
    type: single
    choices:
      - "Functions are always slow"
      - "The engine must evaluate the function on every row"
      - "It can only use table scans"
      - "It bypasses statistics"
    answer: [1]
    explanation: "Wrapping the column forces per-row evaluation, defeating index seeks."
    difficulty: 2
  - id: q3
    prompt: "Which LIKE pattern is index-friendly?"
    type: single
    choices: ["'%smith'", "'smi%'", "'%mith'", "'_mith'"]
    answer: [1]
    explanation: "A prefix 'smi%' can match against the index's ordering."
    difficulty: 2
  - id: q4
    prompt: "What does implicit conversion of the column cause?"
    type: single
    choices:
      - "A faster plan"
      - "A scan because the column is wrapped in conversion"
      - "A syntax error"
      - "Index maintenance"
    answer: [1]
    explanation: "Engine-side coercion wraps the column and blocks index use."
    difficulty: 2
```