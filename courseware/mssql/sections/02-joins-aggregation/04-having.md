---
id: 04-having
title: "HAVING and filtering groups"
order: 4
section: 02-joins-aggregation
language: sql
summary: "Filtering aggregated results with HAVING vs WHERE"
tags: [having, group-by, filtering, aggregates]
---

# HAVING and filtering groups

`WHERE` filters **rows before** grouping. `HAVING` filters **groups after**
aggregation. They are not interchangeable.

```sql
-- WHERE: rows first
SELECT CategoryID, COUNT(*) AS Products
FROM Products
WHERE UnitPrice > 50          -- keep only these rows
GROUP BY CategoryID;

-- HAVING: groups after
SELECT CategoryID, COUNT(*) AS Products
FROM Products
GROUP BY CategoryID
HAVING COUNT(*) >= 5;         -- only groups with 5+ products
```

> [!key] WHERE wins the rows
> The engine evaluates WHERE first, discards non-matching rows, groups the
> rest, then evaluates HAVING against the aggregates. HAVING can reference
> aggregates; WHERE cannot.

## HAVING with aggregates

```sql
-- categories that have shipped more than 200 items
SELECT
    Cat.CategoryName,
    COUNT(*)              AS TotalItems
FROM OrderItems oi
JOIN Products p   ON p.ProductID = oi.ProductID
JOIN Categories Cat ON Cat.CategoryID = p.CategoryID
GROUP BY Cat.CategoryName
HAVING COUNT(*) > 200
ORDER BY TotalItems DESC;
```

## When you might combine both

```sql
-- rows filtered first, groups filtered after
SELECT
    c.City,
    COUNT(*) AS Orders
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE o.TotalAmount > 100          -- rows only
GROUP BY c.City
HAVING COUNT(*) >= 10              -- groups only
ORDER BY Orders DESC;
```

## Aliases in HAVING

SELECT aliases are allowed in HAVING:

```sql
SELECT
    COUNT(*) AS Cnt,
    CategoryID
FROM Products
GROUP BY CategoryID
HAVING COUNT(*) > 3;
```

> [!trap] Misplaced aggregate in WHERE
> `WHERE COUNT(*) > 3` is an error — WHERE runs before aggregation. Combine
> on the grouping column: `WHERE CategoryID = 5 AND ...`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does HAVING filter?"
    type: single
    choices:
      - "Rows before grouping"
      - "Groups after aggregation"
      - "Columns of the result"
      - "The ORDER BY order"
    answer: [1]
    explanation: "HAVING applies to aggregated groups; WHERE applies to rows first."
    difficulty: 1
  - id: q2
    prompt: "Which is valid T-SQL?"
    type: single
    choices:
      - "WHERE COUNT(*) > 5"
      - "HAVING COUNT(*) > 5"
      - "WHERE COUNT > 5"
      - "HAVING UnitPrice > 5"   # non-aggregate ok in GROUP BY context
    answer: [1]
    explanation: "HAVING can use aggregates; WHERE cannot because it runs before aggregation."
    difficulty: 2
  - id: q3
    prompt: "In what order do WHERE and HAVING run?"
    type: single
    choices:
      - "HAVING then WHERE"
      - "WHERE then HAVING"
      - "They run together"
      - "Either order"
    answer: [1]
    explanation: "Rows are filtered first (WHERE), then grouped, then groups filtered (HAVING)."
    difficulty: 2
  - id: q4
    prompt: "What is the point of putting a filter in WHERE instead of HAVING?"
    type: single
    choices:
      - "It runs on fewer rows before grouping"
      - "It changes the result set only"
      - "It is required for grouped queries"
      - "It makes ORDER BY work"
    answer: [0]
    explanation: "Filtering rows first usually processes less data than grouping everything."
    difficulty: 2
```