---
id: 04-data-types
title: "T-SQL data types"
order: 4
section: 00-foundations
language: sql
summary: "The core numeric, string, date, and binary types"
tags: [types, int, nvarchar, datetime, decimal]
---

# T-SQL data types

Every column has a type. Choosing well affects correctness, storage, and
performance. These are the types you will actually use.

## Exact numeric

| Type | Range / precision | Notes |
|---|---|---|
| `INT` | -2.1B to 2.1B | The default integer; use it for keys and counts |
| `BIGINT` | ±9.2 quintillion | When INT overflows (IDs, metrics) |
| `SMALLINT` | ±32767 | Tiny counters |
| `TINYINT` | 0–255 | Never a key; handy for levels |
| `DECIMAL(p,s)` | exact, p digits, s after point | **money**: use this, not FLOAT |
| `MONEY` | exact 4 dp | Legacy; `DECIMAL` is preferred |

> [!trap] Never use FLOAT for money
> `FLOAT` is approximate binary floating point. `0.1 + 0.2` can be
> `0.30000000000000004`. Use `DECIMAL(10,2)` for currency — it is exact.

## Character strings

| Type | Meaning | Use |
|---|---|---|
| `CHAR(n)` | fixed-length, ASCII | Codes, fixed keys |
| `VARCHAR(n)` | variable-length, ASCII | Plain text (older systems) |
| `NCHAR(n)` / `NVARCHAR(n)` | Unicode | **Anything that may hold non-English text** |
| `NVARCHAR(MAX)` | up to 2 GB | Long documents, JSON, XML |

> [!key] Prefer NVARCHAR
> `N` types store Unicode. Names, addresses, and descriptions should be
> `NVARCHAR`. Prefix string literals with `N` when comparing: `WHERE City = N'Paris'`.

## Date and time

| Type | Details |
|---|---|
| `DATE` | 0001-01-01 … 9999-12-31 |
| `TIME(p)` | time of day, optional fractional precision |
| `DATETIME2(p)` | **Prefer this** — date + time, up to nanoseconds |
| `DATETIME` | legacy, 3.33ms precision, 1753–9999 |
| `SMALLDATETIME` | minute precision |
| `DATETIMEOFFSET` | with UTC offset, for global apps |

## Binary and other

- `BIT` — 0/1/NULL, maps to bool in most clients.
- `UNIQUEIDENTIFIER` — a GUID, useful for distributed keys.
- `ROWVERSION` — auto-incrementing version stamp.
- `XML`, `JSON` — rich types; JSON is usually better as `NVARCHAR(MAX)`.

## Nullability

A column is either nullable or `NOT NULL`. NULL means **unknown / not
supplied**, not zero and not empty string — a distinction that bites in
WHERE clauses (see Part 1).

```sql
CREATE TABLE sample_products (
    ProductID   INT            NOT NULL,
    ProductName NVARCHAR(120)  NOT NULL,
    UnitPrice   DECIMAL(10,2)  NULL,     -- price not known yet = NULL
    LaunchedOn  DATE           NULL
);
```

> [!tip] Check a value's type
> `SELECT SQL_VARIANT_PROPERTY(1.5, 'BaseType') AS t;` prints the numeric
> type SQL Server infers for a literal.

## A matching function: CAST

```sql
SELECT
    CAST(12345 AS NVARCHAR(20))                    AS to_text,
    CAST('2025-03-01' AS DATE)                     AS to_date,
    CAST(7 AS DECIMAL(10,2))                       AS to_money,
    CAST(99 AS BIT)                                AS as_bit;
```

Implicit conversions also happen (INT→DECIMAL is safe; VARCHAR→INT is not
if it contains non-digits). `CAST`/`CONVERT` make conversions explicit.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which type should you use for a price column?"
    type: single
    choices:
      - "FLOAT"
      - "DECIMAL(10,2)"
      - "INT"
      - "VARCHAR(10)"
    answer: [1]
    explanation: "DECIMAL is exact, so money never suffers floating-point rounding."
    difficulty: 1
  - id: q2
    prompt: "Why prefer NVARCHAR over VARCHAR for names?"
    type: single
    choices:
      - "It sorts faster"
      - "It stores Unicode characters"
      - "It is always shorter"
      - "It cannot be NULL"
    answer: [1]
    explanation: "NVARCHAR holds Unicode and correctly represents non-English text."
    difficulty: 1
  - id: q3
    prompt: "What does NULL mean in a column?"
    type: single
    choices:
      - "The number zero"
      - "An empty string"
      - "An unknown or missing value"
      - "The minimum value of the type"
    answer: [2]
    explanation: "NULL stands for unknown/not supplied and behaves differently from 0 or ''."
    difficulty: 2
  - id: q4
    prompt: "Which modern date type should you prefer?"
    type: single
    choices:
      - "DATETIME"
      - "DATETIME2"
      - "SMALLDATETIME"
      - "TIMESTAMP"
    answer: [1]
    explanation: "DATETIME2 supports wider range and higher precision than legacy DATETIME."
    difficulty: 2
```