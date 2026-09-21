---
id: 04-null-handling
title: "NULL, IS NULL, COALESCE, ISNULL"
order: 4
section: 01-query-basics
language: sql
summary: "Why NULL is tricky and how to handle it safely"
tags: [null, coalesce, isnull, nullif]
---

# NULL handling

NULL means **unknown** or **not supplied**. It is neither zero nor an empty
string, and it propagates through almost every expression.

> [!key] NULL poisons arithmetic
> `NULL + 5` is NULL, `NULL = NULL` is not TRUE (it is unknown), and
> `NULL = 0` is not FALSE — it is NULL. You cannot compare NULL with `=`.

## Why WHERE ignores NULLs

```sql
SELECT * FROM Customers WHERE Region = N'CA';
```

Rows with `Region IS NULL` are **not** returned — they are not equal to
'CA', they are unknown to it. To find them:

```sql
SELECT * FROM Customers WHERE Region IS NULL;        -- missing region
SELECT * FROM Customers WHERE Region IS NOT NULL;    -- has a region
```

## Three-valued logic

A WHERE condition evaluates to TRUE, FALSE, or **UNKNOWN**. Only TRUE rows are
returned. That changes how `NOT` and `OR` behave:

```sql
-- Does NOT return rows where Region is NULL:
WHERE NOT (Region = N'CA')

-- NULL Region does not survive OR either unless tested:
WHERE Region = N'CA' OR Region IS NULL
```

> [!trap] NOT IN and NULL
> `WHERE x NOT IN (1, 2)` quietly drops rows where x is NULL — the comparison
> `NULL NOT IN (...)` is unknown, not true. Prefer `NOT EXISTS` when NULLs
> are possible.

## COALESCE

Returns the **first non-NULL** argument:

```sql
SELECT
    CompanyName,
    COALESCE(Region, N'(no region)') AS Region
FROM Customers;
```

Works with any number of arguments. Use it for safe display defaults.

## ISNULL

A shorthand for two arguments:

```sql
SELECT ISNULL(Region, N'(no region)') FROM Customers;
```

`ISNULL` is really meant for two args and also changes the result's type to
the type of the first arg. `COALESCE` (standard SQL) handles many args and
picks the highest-precedence type.

> [!tip] Choose COALESCE
> For new code, `COALESCE` is the standard, more predictable choice.

## NULLIF

Returns NULL when two values are equal:

```sql
-- treat discount 0 as 'no discount' NULL
SELECT NULLIF(DiscountPct, 0) AS Discount FROM OrderItems;
```

## Aggregates skip NULLs

`SUM`, `AVG`, `COUNT(col)` skip NULL rows; `COUNT(*)` counts every row.

```sql
-- average of non-null prices; missing rows ignored
SELECT AVG(UnitPrice) FROM Products;

-- how many rows have a price at all
SELECT COUNT(UnitPrice) FROM Products;

-- how many rows exist (NULL or not)
SELECT COUNT(*) FROM Products;
```

> [!trap] Count-the-rows surprises
> `COUNT(col)` only counts non-NULL col values. If you need the number of
> product rows, use `COUNT(*)`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the result of NULL = NULL?"
    type: single
    choices:
      - "TRUE"
      - "FALSE"
      - "UNKNOWN (NULL)"
      - "An error"
    answer: [2]
    explanation: "Comparing a NULL value to anything yields unknown, which WHERE treats as false."
    difficulty: 2
  - id: q2
    prompt: "Which function returns the first non-NULL argument?"
    type: single
    choices:
      - "ISNULL(x, y, z)"
      - "COALESCE(x, y, z)"
      - "NULLIF(x, y)"
      - "NVL(x)"
    answer: [1]
    explanation: "COALESCE accepts many arguments and returns the first non-NULL one."
    difficulty: 1
  - id: q3
    prompt: "Why might WHERE x NOT IN (1, 2) miss rows where x is NULL?"
    type: single
    choices:
      - "It always errors on NULL"
      - "NULL NOT IN (...) is unknown, not true"
      - "NOT IN cannot read the column"
      - "NULLs sort last"
    answer: [1]
    explanation: "Unknown comparisons are dropped, so NULL rows disappear from the result."
    difficulty: 3
  - id: q4
    prompt: "Which aggregate includes NULL rows?"
    type: single
    choices:
      - "SUM(col)"
      - "AVG(col)"
      - "COUNT(*)"
      - "COUNT(col)"
    answer: [2]
    explanation: "COUNT(*) counts all rows; column-based aggregates skip NULLs."
    difficulty: 2
```