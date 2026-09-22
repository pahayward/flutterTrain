---
id: 03-delete-truncate
title: "DELETE and TRUNCATE"
order: 3
section: 03-data-modification
language: sql
summary: "Removing rows, and the fast empty-table shortcut"
tags: [delete, truncate, dml, remove]
---

# DELETE and TRUNCATE

Two different ways to remove data — do not use them interchangeably.

## DELETE

Removes rows one at a time, honoring WHERE:

```sql
DELETE FROM OrderItems WHERE OrderID = 10;
DELETE FROM Customers WHERE City = N'Gone' AND CreditLimit = 0;
```

- Slow on large tables (row-by-row, logged, indexed updates).
- Fires triggers, respects FKs, can be rolled back.
- `OUTPUT deleted.*` can capture removed rows.

> [!trap] DELETE without WHERE
> Removes **all** rows. The FKs may reject some deletes too.

## TRUNCATE

Deletes **every row** instantly:

```sql
TRUNCATE TABLE StagingBatch;
```

- Deallocates whole pages — very fast, minimal log.
- Cannot have a WHERE clause.
- Cannot run on a table referenced by a FK (unless the referencing side is
  also truncated/removed first).
- Resets identity seed by default (usually a good thing for staging).

> [!warning] TRUNCATE and rollback
> TRUNCATE can still be rolled back inside a transaction, but because it logs
> deallocations it is much harder to undo in practice. Confirm the target
> before running.

## Choosing

| | DELETE | TRUNCATE |
|---|---|---|
| WHERE | yes | no |
| Speed | row-based | page-dealloc, fast |
| FKs | checked | must be absent |
| Triggers | fire | do not fire |
| Identity | keeps seed | resets seed |
| Rollback | easy | possible but heavy |

```sql
-- clear yesterday's staging table
TRUNCATE TABLE dbo.StagingOrders;

-- tidy up individual bad rows
DELETE FROM dbo.StagingOrders
WHERE RowStatus = 'Invalid';
```

> [!tip] Reseed after truncate if needed
> `DBCC CHECKIDENT (table, RESEED, 0)` resets the identity counter manually
> when you need values to restart.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which can filter with WHERE?"
    type: single
    choices: ["TRUNCATE", "DELETE", "Both", "Neither"]
    answer: [1]
    explanation: "DELETE accepts a WHERE; TRUNCATE removes every row."
    difficulty: 1
  - id: q2
    prompt: "Which resets the identity seed by default?"
    type: single
    choices: ["DELETE", "TRUNCATE", "Both", "Neither"]
    answer: [1]
    explanation: "TRUNCATE resets the identity; DELETE keeps counting from where it was."
    difficulty: 2
  - id: q3
    prompt: "Why is TRUNCATE faster on large tables?"
    type: single
    choices:
      - "It skips logging entirely"
      - "It deallocates pages instead of removing rows"
      - "It runs in parallel automatically"
      - "It only touches the first page"
    answer: [1]
    explanation: "TRUNCATE deallocates whole pages, avoiding per-row work."
    difficulty: 2
  - id: q4
    prompt: "When can you NOT TRUNCATE?"
    type: single
    choices:
      - "On a table with a clustered index"
      - "On a table referenced by a foreign key"
      - "On an empty table"
      - "On a partitioned table"
    answer: [1]
    explanation: "A FK referencing the table blocks TRUNCATE until the reference is removed."
    difficulty: 2
```