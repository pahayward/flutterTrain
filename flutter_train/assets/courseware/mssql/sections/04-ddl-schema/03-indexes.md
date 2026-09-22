---
id: 03-indexes
title: "Indexes: clustered and nonclustered"
order: 3
section: 04-ddl-schema
language: sql
summary: "What indexes are, the two main types, and when the engine uses them"
tags: [indexes, clustered, nonclustered, seek, scan]
---

# Indexes

An index is an extra ordered structure the engine keeps to answer queries
quickly — think of the index at the back of a book.

## Why they matter

Without an index, a query must read every row (a **scan**). With the right
index, it can jump straight to matching rows (a **seek**).

```sql
-- needs an index on UnitPrice to seek here
SELECT ProductID FROM Products WHERE UnitPrice = 42;
```

## Two main types

**Clustered** index — the table's actual row order:
- One per table.
- The primary key is clustered by default.
- Fast for range scans and by-key lookups.
- Inserting in the middle may cause page splits.

**Nonclustered** index — a separate ordered list (+ bookmark to the row):
- Many per table.
- Ideal for equality lookups and covering queries.

```sql
CREATE NONCLUSTERED INDEX IX_Products_UnitPrice
ON Products (UnitPrice);
```

## What the engine can do

| Operation | Meaning |
|---|---|
| Index Seek | jump straight to matching entries — fast |
| Index Scan | read the whole index/table — slow on big data |
| Key Lookup | fetch the full row after finding the index entry |

A seek is what you want. A scan is a sign something is missing.

> [!key] Indexing isn't magic
> Costs are storage plus maintenance on every INSERT/UPDATE/DELETE. Index for
> the workload that matters; do not index everything.

## Covering indexes

When a query reads only indexed columns, the engine never visits the table:

```sql
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Status
ON Orders (CustomerID, Status)
INCLUDE (OrderDate);
```

Good for reports that repeatedly ask the same columns.

## Composite and order

A composite index on `(CustomerID, Status)` helps:
- equality on CustomerID (prefix) — seek to it,
- equality on both — even better,
- a scan on just Status (leading column missing) — not sought.

Index order follows column order in the index definition.

## Beware fan-out

If a column has few distinct values (like `Status` with 2 values), the index
may not be selective enough to help — the engine may still scan.

> [!tip] Start simple
> Query slow? Look at the Actual Execution Plan (Part 6). The eager-beaver
> fix is usually one composite index on the WHERE/ORDER columns actually
> used. Measure before and after.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How many clustered indexes can a table have?"
    type: single
    choices: ["Zero", "One", "Two", "Unlimited"]
    answer: [1]
    explanation: "A clustered index defines physical order, so a table has at most one."
    difficulty: 1
  - id: q2
    prompt: "Which is faster on lots of rows?"
    type: single
    choices: ["Index Scan", "Index Seek", "Key Lookup", "Table Spool"]
    answer: [1]
    explanation: "A seek jumps directly to matching entries instead of reading everything."
    difficulty: 1
  - id: q3
    prompt: "What does INCLUDE add to a covering index?"
    type: single
    choices:
      - "Extra key columns for ordering"
      - "Non-key columns stored at the leaf"
      - "A second clustered index"
      - "Automatic statistics"
    answer: [1]
    explanation: "INCLUDE stores leaf-level data so lookups need not visit the table."
    difficulty: 2
  - id: q4
    prompt: "When may an index be ignored?"
    type: single
    choices:
      - "When the column has very few distinct values"
      - "Always when a WHERE exists"
      - "When the table is large"
      - "When the query uses TOP"
    answer: [0]
    explanation: "Low selectivity (few distinct values) may make scanning cheaper."
    difficulty: 2
```