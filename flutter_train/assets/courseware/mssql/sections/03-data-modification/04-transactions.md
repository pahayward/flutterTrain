---
id: 04-transactions
title: "Transactions: COMMIT, ROLLBACK, ACID"
order: 4
section: 03-data-modification
language: sql
summary: "Atomicity, isolation, commits, savepoints, and locking basics"
tags: [transactions, acid, commit, rollback]
---

# Transactions

A **transaction** groups statements into one all-or-nothing unit. Either every
statement succeeds, or none of them leave a trace.

## ACID

| Letter | Meaning |
|---|---|
| Atomicity | All-or-nothing |
| Consistency | Data stays valid under constraints |
| Isolation | Concurrent work does not see half-finished changes |
| Durability | Committed changes survive crashes |

## The three statements

```sql
BEGIN TRANSACTION;            -- mark the start

UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;

COMMIT;                       -- make it permanent
-- or
ROLLBACK;                     -- undo everything since BEGIN
```

The money transfer is atomic only because both UPDATEs sit inside one
transaction. If the second fails, `ROLLBACK` restores the first.

> [!key] Autocommit is the default
> Every single statement outside a BEGIN/COMMIT is its own transaction: if
> anything stops it, that statement alone rolls back. Errors do not
> automatically unsend prior committed statements.

## @@TRANCOUNT and nested BEGIN

SQL Server counts nesting:

```sql
SELECT @@TRANCOUNT;   -- 0 outside a transaction
BEGIN TRANSACTION;
BEGIN TRANSACTION;
SELECT @@TRANCOUNT;   -- 2
COMMIT;               -- one level out
ROLLBACK;             -- rolls back ALL levels
```

Only the outermost COMMIT makes data permanent; a ROLLBACK anywhere undoes
everything.

> [!trap] ROLLBACK undoes all levels
> A stored procedure that rolls back inside a caller's transaction wipes the
> caller's work too. Use savepoints to roll back partially.

## Savepoints

```sql
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;

SAVE TRANSACTION afterDebit;      -- mark a point

UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;
ROLLBACK TRANSACTION afterDebit;  -- undo only this step
COMMIT;
```

The debit survives; the failed credit is rolled back to the savepoint.

## Isolation and concurrency

While one transaction is open, another session may see the result differently
depending on the **isolation level**. The default is READ COMMITTED:

- **READ UNCOMMITTED** — can read dirty (uncommitted) rows.
- **READ COMMITTED** — (default) reads only committed data.
- **REPEATABLE READ** — holds read locks; prevents non-repeatable reads.
- **SNAPSHOT** — row-versioned, builds on statement start.
- **SERIALIZABLE** — strongest; locks ranges, prevents phantom inserts.

```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
```

Locking and blocking are covered in depth in Part 6; for now remember:
transactions and isolation are where the engine guarantees your "all or
nothing" data.

> [!warning] Keep transactions short
> A long transaction holds locks and blocks other users. Move slow work
> outside; only the statements that must be atomic belong inside.

## Common pattern: TRY/CATCH

```sql
BEGIN TRANSACTION;
BEGIN TRY
    -- possibly several DML statements
    UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;
    UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;                      -- re-raise so the caller knows
END CATCH;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which word best describes atomicity?"
    type: single
    choices:
      - "Partial success is allowed"
      - "All-or-nothing"
      - "Always the fastest path"
      - "Automatic retries"
    answer: [1]
    explanation: "Atomicity means the whole unit commits or rolls back."
    difficulty: 1
  - id: q2
    prompt: "What does ROLLBACK do?"
    type: single
    choices:
      - "Commits the current statement only"
      - "Undoes all work since BEGIN TRANSACTION"
      - "Re-runs the failed statement"
      - "Closes the session"
    answer: [1]
    explanation: "ROLLBACK discards the transaction's changes (all nested levels)."
    difficulty: 1
  - id: q3
    prompt: "What is the default isolation level?"
    type: single
    choices:
      - "SERIALIZABLE"
      - "READ UNCOMMITTED"
      - "READ COMMITTED"
      - "SNAPSHOT"
    answer: [2]
    explanation: "READ COMMITTED is SQL Server's default; it reads only committed data."
    difficulty: 2
  - id: q4
    prompt: "Why keep transactions short?"
    type: single
    choices:
      - "SHORT is mandatory syntax"
      - "Long transactions hold locks and block others"
      - "It changes the isolation level"
      - "It improves backup speed only"
    answer: [1]
    explanation: "Open transactions keep locks until they end, which can block other sessions."
    difficulty: 2
```