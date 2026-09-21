---
id: 03-etl-staging
title: "ETL patterns in T-SQL"
order: 3
section: 07-real-world
language: sql
summary: "Extract-transform-load with staging tables, MERGE, and bulk loads"
tags: [etl, staging, merge, bulk]
---

# ETL patterns in T-SQL

ETL moves data between systems. In T-SQL it is staging + set-based
transform + a final load.

## The classic pipeline

```
Source ──bulk/SSIS/openrowset──▶ Staging   ──clean/transform──▶ Presentation
                                      (raw copy)     │  (MERGE/INSERT-UPDATE)
```

Staging tables are mirrors of the source, kept raw. They let you inspect and
transform before anything touches production.

```sql
-- 1. land the file
BULK INSERT dbo.StgSales
FROM '/data/sales_2025_03.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
```

> [!key] Validate in staging, not in production
> Fix bad rows in a REFUSED/ERROR pool, audit counts in staging, and only
> push clean rows into the final tables.

## Transformation in set-based SQL

```sql
-- clean, validate, audit
SELECT
    SalesID,
    REPLACE(TRIM(CustomerCode), N'-', N'')            AS CustKey,
    TRY_CAST(Amount AS DECIMAL(12,2))                 AS Amount,   -- NULL on bad
    DateBucket
FROM dbo.StgSales
WHERE TRY_CAST(Amount AS DECIMAL(12,2)) IS NOT NULL;  -- drop offenders
```

`TRY_CAST` returns NULL instead of failing the whole batch — exactly what a
staging step wants.

## MERGE: insert + update in one statement

```sql
MERGE dbo.DimCustomer AS target
USING (
    SELECT DISTINCT CustKey, CompanyName FROM dbo.StgSales WHERE CustKey IS NOT NULL
) AS source ON target.CustKey = source.CustKey
WHEN MATCHED THEN
    UPDATE SET target.CompanyName = source.CompanyName,
               target.UpdatedOn  = SYSDATETIME()
WHEN NOT MATCHED THEN
    INSERT (CustKey, CompanyName, CreatedOn)
    VALUES (source.CustKey, source.CompanyName, SYSDATETIME())
OUTPUT $action, INSERTED.CustKey;   -- audit trail
```

> [!trap] MERGE needs a guarded source
> If the source has duplicate keys, the OUTPUT and `WHEN MATCHED` behave
> unpredictably. Dedupe the source first — `SELECT DISTINCT` or a ROW_NUMBER
> filter. Note: dup source raises error 8672 in some shapes; prefer a
> validated, deduped source.

## The two-pass alternative

```sql
-- update existing
UPDATE t
SET t.Amount = s.Amount, t.UpdatedOn = SYSDATETIME()
FROM dbo.FactSales t
JOIN dbo.StgSales s ON s.SalesID = t.SalesID;

-- insert missing
INSERT INTO dbo.FactSales (SalesID, Amount, LoadedOn)
SELECT SalesID, Amount, SYSDATETIME()
FROM dbo.StgSales s
WHERE NOT EXISTS (SELECT 1 FROM dbo.FactSales f WHERE f.SalesID = s.SalesID);
```

Simple to read, easy to debug, and each statement is maintainable.

## Idempotency and the reload question

- **Full refresh** — truncate target, insert everything (simple, repeatable).
- **Incremental** — process only rows newer than a watermark.

```sql
-- incremental watermark
DECLARE @last DATE = (SELECT MAX(LoadDate) FROM dbo.FactSales);
INSERT INTO dbo.FactSales (...)
SELECT ...
FROM dbo.StgSales
WHERE LoadDate > @last;
```

> [!tip] Make loads rerunnable
> Wrap in a transaction, log row counts, allow a clean retry. ETL that
> crashes midway must not corrupt the target.

## Wrapping a load in a transaction

```sql
BEGIN TRY
    BEGIN TRAN;
        TRUNCATE TABLE dbo.TargetStaging;
        INSERT INTO dbo.TargetStaging (...) SELECT ... FROM dbo.Cleaned;
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why use staging tables in ETL?"
    type: single
    choices:
      - "They are optional and usually skipped"
      - "They isolate raw data for validation before load"
      - "They make queries slower"
      - "They are the final destination"
    answer: [1]
    explanation: "Staging mirrors source data so you can inspect and validate first."
    difficulty: 2
  - id: q2
    prompt: "Why use TRY_CAST in a staging transform?"
    type: single
    choices:
      - "It always succeeds"
      - "Bad values become NULL instead of crashing the batch"
      - "It is faster than CAST"
      - "It adds a column"
    answer: [1]
    explanation: "TRY_CAST returns NULL on failure, so one bad row does not kill the load."
    difficulty: 2
  - id: q3
    prompt: "What is a key risk of MERGE with duplicate source keys?"
    type: single
    choices:
      - "Slower performance only"
      - "Unpredictable matches/output behavior or error 8672"
      - "It cannot update"
      - "It loses the target"
    answer: [1]
    explanation: "Dedupe or validate the source; MERGE is strict about key uniqueness."
    difficulty: 3
  - id: q4
    prompt: "How does incremental ETL know what to pick up?"
    type: single
    choices:
      - "It re-reads everything"
      - "It compares a watermark to the newest data"
      - "It deletes old rows first"
      - "It uses a cursor"
    answer: [1]
    explanation: "A watermark (MAX timestamp) captures only newer records."
    difficulty: 2
```