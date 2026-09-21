---
id: 01-variables-flow
title: "Variables and control flow"
order: 1
section: 05-programmability
language: sql
summary: "Local variables, IF/ELSE, WHILE, and CURSOR warning"
tags: [variables, control-flow, t-sql, batch]
---

# Variables and control flow

T-SQL is not just queries — it is a structured language for building
procedures, triggers, and scripts.

## DECLARE and SET

```sql
DECLARE @City NVARCHAR(50) = N'Lisbon';
DECLARE @MinTotal DECIMAL(10,2);

SET @MinTotal = 100;
SELECT * FROM Orders
WHERE City = @City AND TotalAmount > @MinTotal;
```

Variables hold a single value (or a table). Default is NULL.

> [!key] Two ways to assign
> `SET @v = expression` — one value. `SELECT @v = expr FROM ...` — can take a
> value from a row. `SET` is clearer for plain assignments.

## IF / ELSE

```sql
DECLARE @Cnt INT = (SELECT COUNT(*) FROM Orders WHERE Status = N'Backorder');

IF @Cnt = 0
    PRINT N'All orders up to date';
ELSE
    PRINT CONCAT(@Cnt, N' order(s) waiting');
```

Conditional blocks via `BEGIN ... END`:

```sql
IF @Cnt > 100
BEGIN
    PRINT N'Queued';
    RETURN;             -- leave the batch/proc early
END
```

## WHILE

```sql
DECLARE @n INT = 1;
WHILE @n <= 5
BEGIN
    PRINT @n;
    SET @n = @n + 1;
END;
```

`BREAK` exits; `CONTINUE` skips to the next test.

> [!trap] WHILE is for orchestration, not data
> Row-by-row loops run slowly and update one row at a time. Prefer a
> single set-based statement (`UPDATE ... WHERE ...`). Use loops for things
> like "process batches until none remain".

## CURSOR — usually not your friend

```sql
DECLARE c CURSOR FOR SELECT ProductID FROM Products;
OPEN c;
FETCH NEXT FROM c INTO @pid;
WHILE @@FETCH_STATUS = 0
BEGIN
    FETCH NEXT FROM c INTO @pid;
END
CLOSE c;
DEALLOCATE c;
```

Cursors give row access — but every fetch is overhead, and most cursor uses
collapse into one set-based statement.

> [!tip] When a cursor is genuinely OK
> Rarely needed: sequential number assignment, per-row error isolation, and
> some ETL oddities. Always measure; always prefer sets. More than 90% of
> cursor code can be rewritten with a single statement.

## Batch control

- `GO` — batch separator in SSMS/sqlcmd, not T-SQL.
- `RETURN` — exit batch/proc immediately.
- `RAISERROR` / `PRINT` — messages (error handling in its own lesson).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which keyword declares a local variable?"
    type: single
    choices: ["VAR", "DECLARE", "LOCAL", "SET"]
    answer: [1]
    explanation: "DECLARE introduces a local variable; SET assigns it."
    difficulty: 1
  - id: q2
    prompt: "What is a common problem with WHILE-based data updates?"
    type: single
    choices:
      - "They cannot read data"
      - "They run row-by-row and are slow"
      - "They violate isolation"
      - "They always fail"
    answer: [1]
    explanation: "Loop-based DML processes one row at a time; sets are far faster."
    difficulty: 2
  - id: q3
    prompt: "What does RETURN do in a procedure?"
    type: single
    choices:
      - "Returns a result set"
      - "Exits the batch/procedure immediately"
      - "Rolls back the transaction"
      - "Prints a message"
    answer: [1]
    explanation: "RETURN exits the current batch or proc right away."
    difficulty: 2
  - id: q4
    prompt: "What are cursors best avoided for?"
    type: single
    choices:
      - "Sequential numbering"
      - "Bulk row processing"
      - "Per-row error isolation"
      - "Simulating a queue"
    answer: [1]
    explanation: "For bulk operations, a single set-based statement is far better."
    difficulty: 2
```