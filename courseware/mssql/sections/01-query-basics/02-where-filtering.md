---
id: 02-where-filtering
title: "Filtering rows with WHERE"
order: 2
section: 01-query-basics
language: sql
summary: "Comparison operators, AND/OR/NOT, IN, BETWEEN, LIKE"
tags: [where, filtering, comparison, like, between]
---

# Filtering rows with WHERE

`WHERE` restricts which rows reach the result set. Rows that do not match are
discarded before grouping and projection.

```sql
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > 100;
```

## Comparison operators

| Operator | Meaning |
|---|---|
| `=` `<>` | equal, not equal |
| `>` `<` `>=` `<=` | ordering |
| `IS NULL` / `IS NOT NULL` | null checks |
| `IN (...)`, `BETWEEN` | membership / range |
| `LIKE` | pattern matching |

## AND / OR / NOT

Combine conditions with boolean logic:

```sql
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE CategoryID = 4
  AND UnitPrice >= 10
  AND UnitPrice <= 100;
```

`NOT` inverts:

```sql
WHERE NOT (CategoryID IN (2, 3))
```

> [!trap] AND binds harder than OR
> `WHERE a = 1 OR a = 2 AND b = 3` means `a=1 OR (a=2 AND b=3)`. When the
> intent is both conditions applied with OR, use parentheses.

## IN

Short for a chain of equals:

```sql
SELECT * FROM Orders
WHERE Status IN ('Shipped', 'Invoiced');
```

## BETWEEN

An inclusive range — `x BETWEEN 5 AND 10` is `x >= 5 AND x <= 10`:

```sql
SELECT * FROM Orders
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-01-31';
```

> [!trap] Midnight is inside
> `BETWEEN '2025-01-01' AND '2025-01-31'` includes 2025-01-31 23:59:59, not
> just that whole day. To catch one day exactly, use
> `OrderDate >= '2025-01-31' AND OrderDate < '2025-02-01'`.

## LIKE patterns

| Pattern | Meaning |
|---|---|
| `'A%'` | starts with A |
| `'%ta'` | ends with "ta" |
| `'%ard%'` | contains "ard" |
| `'_ike'` | any single char, then "ike" |
| `'[A-C]%'` | starts with A, B, or C |

```sql
SELECT * FROM Customers
WHERE CompanyName LIKE '%Toys%';
```

> [!tip] LIKE wildcard at the front kills indexes
> `%text%` cannot use an index efficiently because the leading character is
> unknown (see "sargable queries" in Part 6).

## Filtering into practice

```sql
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Orders
WHERE CustomerID = 42
  AND OrderDate >= '2024-01-01'
ORDER BY OrderDate DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which operator matches rows where a column is unknown?"
    type: single
    choices:
      - "= NULL"
      - "== NULL"
      - "IS NULL"
      - "LIKE NULL"
    answer: [2]
    explanation: "NULL checks use IS NULL / IS NOT NULL; = never matches NULL."
    difficulty: 1
  - id: q2
    prompt: "What does x BETWEEN 5 AND 10 mean?"
    type: single
    choices:
      - "x > 5 AND x < 10"
      - "x >= 5 AND x <= 10"
      - "x IN (5,10)"
      - "x = 5 OR x = 10 only"
    answer: [1]
    explanation: "BETWEEN is inclusive at both ends."
    difficulty: 1
  - id: q3
    prompt: "Which pattern matches any string containing 'ard'?"
    type: single
    choices:
      - "'ard'"
      - "'%ard%'"
      - "'_ard_'"
      - "LIKE '[ard]'"
    answer: [1]
    explanation: "%ard% matches zero or more chars, 'ard', zero or more chars."
    difficulty: 1
  - id: q4
    prompt: "How is WHERE a = 1 OR a = 2 AND b = 3 evaluated?"
    type: single
    choices:
      - "(a=1 OR a=2) AND b=3"
      - "a=1 OR (a=2 AND b=3)"
      - "a=1 AND (a=2 OR b=3)"
      - "(a=1) OR (a=2) OR (b=3)"
    answer: [1]
    explanation: "AND has higher precedence than OR, so the phrase groups as a=1 OR (a=2 AND b=3)."
    difficulty: 2
  - id: q5
    prompt: "What is the risk of pattern '%text%' on a large table?"
    type: single
    choices:
      - "It returns no rows"
      - "It cannot use an index efficiently"
      - "It always errors"
      - "It ignores upper/lower case"
    answer: [1]
    explanation: "A leading wildcard usually forces a full scan of the leading columns."
    difficulty: 2
```