---
id: 03-aggregates
title: "Aggregate functions and GROUP BY"
order: 3
section: 02-joins-aggregation
language: sql
summary: "SUM, AVG, COUNT, MIN, MAX and grouping rows into sets"
tags: [aggregates, group-by, sum, avg, count]
---

# Aggregate functions and GROUP BY

Aggregates collapse many rows into one summary value. `GROUP BY` splits rows
into groups, computing an aggregate **per group**.

## The five core aggregates

```sql
SELECT
    COUNT(*)            AS RowCount,
    COUNT(UnitPrice)    AS PriceCount,   -- non-NULL only
    SUM(TotalAmount)    AS Total,
    AVG(UnitPrice)      AS Average,
    MIN(UnitPrice)      AS Cheapest,
    MAX(UnitPrice)      AS Costliest
FROM Products;
```

All aggregates (except `COUNT(*)`) ignore NULLs.

> [!trap] SUM of an empty set is NULL
> `SUM` and `AVG` over zero rows return NULL, not 0. Use `ISNULL(SUM(x), 0)`
> when a report must show 0.

## GROUP BY

Turn rows into groups and aggregate within each:

```sql
SELECT CategoryID, COUNT(*) AS Products
FROM Products
GROUP BY CategoryID;
```

| CategoryID | Products |
|---|---|
| 1 | 12 |
| 2 | 8 |

Rules:

- Every non-aggregated column in SELECT must appear in GROUP BY.
- A group collapses rows — you cannot show individual row values per group.

```sql
SELECT
    p.CategoryID,
    COUNT(*)                    AS ProductCount,
    AVG(p.UnitPrice)            AS AvgPrice
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY p.CategoryID;
```

## Grouping across a join

Aggregates over joined data describe whole groups:

```sql
-- per customer: how many orders and total spent
SELECT
    c.CompanyName,
    COUNT(*)                 AS Orders,
    SUM(o.TotalAmount)       AS Spend
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY Spend DESC;
```

> [!warning] Watch for duplicate joins
> Joining a one-to-many and then a second one-to-many doubles rows before
> aggregation. The classic rule: join `Customers` → `Orders` → `OrderItems`
> and the ORDER count becomes the item count. Fix by aggregating each level
> separately (see Part 5 CTEs / window functions).

## STRING_AGG

Newer sibling: concatenate per-group values into one string.

```sql
SELECT
    c.CategoryName,
    STRING_AGG(p.ProductName, ', ') WITHIN GROUP (ORDER BY p.ProductName) AS Products
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does AVG(UnitPrice) do with NULL prices?"
    type: single
    choices:
      - "Treats them as zero"
      - "Ignores them"
      - "Errors"
      - "Counts them as one row"
    answer: [1]
    explanation: "Column aggregates skip NULL rows, so AVG averages non-NULL values."
    difficulty: 2
  - id: q2
    prompt: "What is SUM(x) over zero rows?"
    type: single
    choices: ["0", "NULL", "An error", "The identity value of the type"]
    answer: [1]
    explanation: "SUM/AVG over no rows returns NULL. Wrap with ISNULL for reports."
    difficulty: 2
  - id: q3
    prompt: "What rule applies to GROUP BY?"
    type: single
    choices:
      - "Every SELECT column must be in GROUP BY or be aggregated"
      - "GROUP BY must include at least two columns"
      - "Aggregates belong before GROUP BY"
      - "GROUP BY sorts the output"
    answer: [0]
    explanation: "Non-aggregated columns in SELECT must each appear in GROUP BY."
    difficulty: 1
  - id: q4
    prompt: "Which function joins per-group values into one string?"
    type: single
    choices:
      - "CONCAT_AGG"
      - "STRING_AGG"
      - "LISTAGG"
      - "JOIN_TEXT"
    answer: [1]
    explanation: "STRING_AGG concatenates values within a group, with optional ordering."
    difficulty: 2
```