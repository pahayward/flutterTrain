---
id: 01-select-essentials
title: "SELECT: columns, aliases, expressions"
order: 1
section: 01-query-basics
language: sql
summary: "Projection, aliases, computed columns, DISTINCT"
tags: [select, aliases, expressions, distinct]
---

# SELECT essentials

`SELECT` is how you read data. The full query grammar has a standard order:

```sql
SELECT   columns / expressions
FROM     table(s)
WHERE    filter rows
GROUP BY group rows
HAVING   filter groups
ORDER BY sort rows
```

> [!key] Logical order that is written
> Despite being written first, `SELECT` runs almost last: FROM → WHERE →
> GROUP BY → HAVING → SELECT → ORDER BY. Aliases defined in SELECT are
> **not** visible in WHERE, but are in ORDER BY.

## Projection

```sql
SELECT
    ProductID,
    ProductName,
    UnitPrice
FROM Products;
```

One column per line, each row of the result = one product. Return every
column with a star — useful when exploring:

```sql
SELECT * FROM Customers;
```

> [!trap] Star and order
> `SELECT *` returns columns in table definition order, which is fragile if
> the schema changes. In production reports, always name the columns.

## Aliases

Rename a column in the output. Three syntaxes, one meaning:

```sql
SELECT
    ProductName              AS Product,
    UnitPrice                Price,           -- AS is optional
    UnitCost           = UnitPrice * 0.6      -- legacy syntax
FROM Products;
```

## Computed columns

Any expression of columns, literals, and functions:

```sql
SELECT
    OrderID,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS LineTotal
FROM OrderItems;
```

String concatenation:

```sql
SELECT
    FirstName + ' ' + LastName AS FullName
FROM Customers;
```

## DISTINCT

Return unique combinations — removing exact duplicate rows:

```sql
-- every city that appears at least once
SELECT DISTINCT City
FROM Customers;
```

DISTINCT looks across all selected columns. `SELECT DISTINCT City, State`
deduplicates on the pair.

> [!tip] DISTINCT hides problems
> If you need DISTINCT to fix wrong row counts, the join is probably
> duplicating rows. Fix the join, drop the DISTINCT.

## ORDER BY basics (preview)

```sql
SELECT ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC;       -- or ASC, or a column ordinal 2
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In which order does SQL logically execute clauses?"
    type: single
    choices:
      - "SELECT, FROM, WHERE, ORDER BY"
      - "FROM, WHERE, SELECT, ORDER BY"
      - "WHERE, SELECT, FROM, ORDER BY"
      - "ORDER BY, WHERE, FROM, SELECT"
    answer: [1]
    explanation: "FROM runs first, then WHERE, then SELECT, then ORDER BY."
    difficulty: 2
  - id: q2
    prompt: "Why should production queries avoid SELECT *?"
    type: single
    choices:
      - "It is slower to type"
      - "Column order and set are fragile as the schema changes"
      - "It returns NULLs"
      - "It cannot be aliased"
    answer: [1]
    explanation: "Star selects every current column; schema changes silently change output."
    difficulty: 1
  - id: q3
    prompt: "What does DISTINCT do?"
    type: single
    choices:
      - "Sorts the result set"
      - "Removes duplicate rows from the result"
      - "Filters NULLs"
      - "Groups identical values"
    answer: [1]
    explanation: "DISTINCT returns only unique combinations of the selected columns."
    difficulty: 1
  - id: q4
    prompt: "In what part of the query can you use a SELECT alias?"
    type: single
    choices:
      - "WHERE"
      - "FROM"
      - "ORDER BY"
      - "ON"
    answer: [2]
    explanation: "SELECT aliases are visible in ORDER BY and HAVING, but not WHERE."
    difficulty: 3
```