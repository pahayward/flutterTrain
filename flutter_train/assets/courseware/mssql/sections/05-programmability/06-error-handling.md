---
id: 06-error-handling
title: "Error handling: TRY/CATCH, THROW"
order: 6
section: 05-programmability
language: sql
summary: "Structured exceptions, raising errors, and @@ERROR"
tags: [error-handling, try-catch, throw, exceptions]
---

# Error handling

Real T-SQL fails sometimes. Handle it deliberately.

## TRY / CATCH

```sql
BEGIN TRY
    BEGIN TRANSACTION
        INSERT INTO Accounts (AccountID, Balance) VALUES (1, 100);
        INSERT INTO Accounts (AccountID, Balance) VALUES (1, -50); -- bad!
    COMMIT
END TRY
BEGIN CATCH
    ROLLBACK
    THROW;                 -- re-raise for the caller
END CATCH;
```

The CATCH has context:

```sql
BEGIN CATCH
    SELECT
        ERROR_NUMBER()     AS Number,
        ERROR_SEVERITY()   AS Severity,
        ERROR_STATE()      AS State,
        ERROR_PROCEDURE()  AS Proc,
        ERROR_LINE()       AS Line,
        ERROR_MESSAGE()    AS Message;
END CATCH;
```

> [!key] CATCH rolls back nothing by itself
> You still COMMIT/ROLLBACK the transaction yourself — typically
> `IF @@TRANCOUNT > 0 ROLLBACK`.

## THROW — raise your own error

Modern syntax (must come after a semicolon):

```sql
IF @Qty <= 0
    THROW 50001, 'Quantity must be positive', 1;
```

Older sibling `RAISERROR('...', 16, 1)` with severity numbers still appears
in legacy code. Prefer THROW for new work — it does not stop with a
truncated message and works with try/catch.

## What TRY/CATCH does NOT catch

- Compile errors before the batch runs.
- Most `DEADLOCK SELECT` errors (can be caught after 2012).
- Errors outside the current batch (from `GO`).

> [!trap] Errors that bypass CATCH
> Early-binding compile failures occur before the batch enters CATCH. When a
> proc itself fails to parse, no catch runs — the caller sees the error.

## Common pattern: safe update wrapper

```sql
CREATE PROCEDURE dbo.SafeAddItem
    @OrderID INT, @ProductID INT, @Qty INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN
            IF @Qty <= 0 THROW 50002, 'Qty must be > 0', 1;
            INSERT INTO OrderItems (OrderID, ProductID, Quantity)
            VALUES (@OrderID, @ProductID, @Qty);
        COMMIT
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
```

## @@ERROR legacy

```sql
INSERT INTO t VALUES (1);
IF @@ERROR <> 0
    PRINT 'Something failed';     -- fragile; use TRY/CATCH instead
```

`@@ERROR` holds only the last statement's error — one sysvariable, hard to
keep track of. `TRY/CATCH` is the modern approach.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which block catches errors in T-SQL?"
    type: single
    choices: ["CATCH", "EXCEPT", "ON ERROR", "HANDLER"]
    answer: [0]
    explanation: "BEGIN TRY ... BEGIN CATCH ... END CATCH handles runtime errors."
    difficulty: 1
  - id: q2
    prompt: "What happens if you do not roll back in CATCH?"
    type: single
    choices:
      - "The transaction auto-rolls back"
      - "The transaction stays open with locks held"
      - "Data is re-committed"
      - "Nothing; it is handled"
    answer: [1]
    explanation: "A failed transaction still holds locks until you ROLLBACK (or COMMIT)."
    difficulty: 2
  - id: q3
    prompt: "Which is the modern way to raise your own error?"
    type: single
    choices: ["RAISERROR(1)", "THROW 50001, 'msg', 1", "ERROR('msg')", "RAISE('msg')"]
    answer: [1]
    explanation: "THROW with a user number and message is the current best practice."
    difficulty: 2
  - id: q4
    prompt: "Why is @@ERROR considered fragile?"
    type: single
    choices:
      - "It only stores large numbers"
      - "It resets after each statement, losing earlier context"
      - "It can only catch SELECT errors"
      - "It is deprecated and removed"
    answer: [1]
    explanation: "@@ERROR reflects only the most recent statement's result."
    difficulty: 2
```