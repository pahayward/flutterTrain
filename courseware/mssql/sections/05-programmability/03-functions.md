---
id: 03-functions
title: "User-defined functions"
order: 3
section: 05-programmability
language: sql
summary: "Scalar, inline table-valued, and multi-statement functions"
tags: [functions, scalar, tvf, ddl]
---

# User-defined functions

UDFs return values you can call inside queries. Two shapes matter most.

## Scalar functions

Return one value:

```sql
CREATE FUNCTION dbo.Discounted
    (@price DECIMAL(12,2), @pct DECIMAL(4,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @price * (100 - @pct) / 100.0;
END;
```

```sql
SELECT dbo.Discounted(UnitPrice, 10) AS SalePrice
FROM Products;
```

> [!warning] Scalar UDFs can be slow in the SELECT list
> Older T-SQL scalar functions execute per row with interpreter overhead.
> They are fine for small uses; on big scans prefer a computed/join or
> inline expression. SQL Server 2019+ *scalar UDF inlining* helps some cases.
> Watch execution plans (Part 6).

## Inline table-valued functions (ITVF)

Return a table, written as a single SELECT:

```sql
CREATE FUNCTION dbo.OrdersFor
    (@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT OrderID, OrderDate, TotalAmount
    FROM Orders
    WHERE CustomerID = @CustomerID
);
```

```sql
SELECT * FROM dbo.OrdersFor(5)
WHERE TotalAmount > 100;
```

An ITVF is essentially a parameterizable view. The engine can inline it,
making it fast and indexable.

> [!key] Prefer ITVFs
> For "give me a set for this argument", an inline table function is the
> modern, optimal shape.

## Multi-statement TVF

Returns a populated table variable (slower — often avoidable):

```sql
CREATE FUNCTION dbo.SpanDates
    (@from DATE, @to DATE)
RETURNS @Days TABLE (d DATE)
AS
BEGIN
    DECLARE @d DATE = @from;
    WHILE @d <= @to
    BEGIN
        INSERT INTO @Days VALUES (@d);
        SET @d = DATEADD(day, 1, @d);
    END
    RETURN;
END;
```

> [!trap] Multi-statement TVFs discourage the optimizer
> Table variables have no statistics; the optimizer guesses row counts, and
> cardinality misguesses wreck plans. Use sparingly.

## Restrictions worth knowing

- **No side effects** — functions cannot write to tables (no DML).
- Determinism matters for indexed views/computed columns.
- Referencing a function this way usually can't use an index on it.

## Replacing with computed columns

A computed column persists the derivation:

```sql
ALTER TABLE Products ADD SalePrice AS (UnitPrice * (100-10) / 100.0);
```

Store the rule once, read it like real data.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which function type returns a table for a SELECT each call?"
    type: single
    choices:
      - "Scalar"
      - "Inline table-valued (ITVF)"
      - "A view is not a function"
      - "Aggregate"
    answer: [1]
    explanation: "ITVFs return a table from a single SELECT and inline well."
    difficulty: 1
  - id: q2
    prompt: "Why do scalar UDFs trip up large scans?"
    type: single
    choices:
      - "They cannot use indexes"
      - "They run per row with overhead"
      - "They are restricted to one argument"
      - "They return NULLs"
    answer: [1]
    explanation: "Per-row scalar interpretation is slow on big result sets."
    difficulty: 2
  - id: q3
    prompt: "Which is NOT allowed inside a function?"
    type: single
    choices:
      - "SELECT"
      - "A table INSERT"
      - "DECLARE"
      - "RETURN a value"
    answer: [1]
    explanation: "Functions are side-effect free; they cannot modify tables."
    difficulty: 2
  - id: q4
    prompt: "What is a risk of multi-statement table-valued functions?"
    type: single
    choices:
      - "They are corporation-only"
      - "Poor cardinality estimates hurt plans"
      - "They cannot return rows"
      - "They add constraints automatically"
    answer: [1]
    explanation: "Table variables lack statistics, so the optimizer may misestimate rows."
    difficulty: 3
```