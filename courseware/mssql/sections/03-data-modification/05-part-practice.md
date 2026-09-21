---
id: 05-part-practice
title: "Part 3 Practice"
order: 5
section: 03-data-modification
language: sql
summary: "Review and exam questions for the Data Modification part"
tags: [practice, exam, review]
---

# Part 3 Practice

## Section review

You've learned to change data safely:

- **INSERT** — single rows, multiple rows, INSERT-SELECT, `OUTPUT
  INSERTED` for generated keys.
- **UPDATE** — set-based, precise WHERE, updates joined to other tables.
- **DELETE / TRUNCATE** — row-level vs whole-table; FK and log differences.
- **Transactions** — BEGIN/COMMIT/ROLLBACK, ACID, savepoints, isolation
  levels, short transactions.

```sql
BEGIN TRANSACTION;

UPDATE Inventory
SET QuantityOnHand = QuantityOnHand - oi.Quantity
FROM OrderItems oi
WHERE oi.ProductID = Inventory.ProductID
  AND oi.OrderID = 42;

INSERT INTO OrderLog (OrderID, Action, At)
VALUES (42, N'Ship', SYSDATETIME());

COMMIT;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which statement moves a large row set efficiently?"
    type: single
    choices:
      - "A cursor-based INSERT loop"
      - "INSERT ... SELECT ... FROM ..."
      - "INSERT one row per trigger"
      - "SELECT INTO only"
    answer: [1]
    explanation: "Set-based INSERT-SELECT copies rows atomically and fast."
    difficulty: 2
  - id: q2
    prompt: "What does OUTPUT expose on an INSERT?"
    type: single
    choices:
      - "Only the affected count"
      - "The inserted rows"
      - "The plan"
      - "The query text"
    answer: [1]
    explanation: "OUTPUT INSERTED.* returns the rows you inserted, including keys."
    difficulty: 2
  - id: q3
    prompt: "Why is TRUNCATE fast?"
    type: single
    choices:
      - "It writes zero logs"
      - "It deallocates pages in bulk"
      - "It skips the lock manager"
      - "It runs on a separate thread"
    answer: [1]
    explanation: "TRUNCATE trades per-row logging for bulk page deallocation."
    difficulty: 2
  - id: q4
    prompt: "When should a transaction be short?"
    type: single
    choices:
      - "Never; long is safer"
      - "When it holds locks that block others"
      - "Only when reading data"
      - "When the query is read-only"
    answer: [1]
    explanation: "Long open transactions keep locks, blocking concurrent users."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which best describes a transaction?"
    type: single
    choices: ["A stored query", "An all-or-nothing unit of work", "An index", "A backup"]
    answer: [1]
    explanation: "A transaction groups statements so they commit or roll back together."
    weight: 3
    section: 03-data-modification
  - prompt: "Which resets an identity column's seed?"
    type: single
    choices: ["DELETE", "UPDATE", "TRUNCATE", "ALTER"]
    answer: [2]
    explanation: "TRUNCATE resets identity by default; DELETE does not."
    weight: 2
    section: 03-data-modification
  - prompt: "What is the default isolation level?"
    type: single
    choices: ["SERIALIZABLE", "SNAPSHOT", "READ COMMITTED", "READ UNCOMMITTED"]
    answer: [2]
    explanation: "READ COMMITTED is the SQL Server default."
    weight: 2
    section: 03-data-modification
  - prompt: "Which keyword makes an UPDATE auditable within the statement?"
    type: single
    choices: ["RETURNING", "OUTPUT", "LOGGING", "AUDIT"]
    answer: [1]
    explanation: "OUTPUT exposes deleted/inserted rows of a DML statement."
    weight: 2
    section: 03-data-modification
```
