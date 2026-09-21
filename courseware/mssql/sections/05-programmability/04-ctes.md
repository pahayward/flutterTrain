---
id: 04-ctes
title: "CTEs and recursion"
order: 4
section: 05-programmability
language: sql
summary: "WITH queries, reusability, and recursive CTEs"
tags: [cte, recursion, with, hierarchies]
---

# CTEs and recursion

A **Common Table Expression** (CTE) names a subquery you can reuse in the same
statement.

## Basic CTE

```sql
WITH ActiveCustomers AS (
    SELECT CustomerID, CompanyName
    FROM Customers
    WHERE DeactivatedOn IS NULL
)
SELECT *
FROM ActiveCustomers c
JOIN Orders o ON o.CustomerID = c.CustomerID;
```

Read it as: "define ActiveCustomers, then use it." It exists for the one
statement only — nothing is stored.

> [!key] CTEs make complex queries readable
> Break a big query into named steps. Each step is testable and the whole
> thing stays readable.

## Multiple CTEs

```sql
WITH
    HighValue AS (
        SELECT CustomerID, SUM(TotalAmount) AS Spend
        FROM Orders
        GROUP BY CustomerID
        HAVING SUM(TotalAmount) > 5000
    ),
    Missed AS (
        SELECT CustomerID
        FROM HighValue
        EXCEPT
        SELECT DISTINCT CustomerID FROM Orders WHERE Status = N'Shipped'
    )
SELECT c.CompanyName
FROM Missed m
JOIN Customers c ON c.CustomerID = m.CustomerID;
```

CTEs can reference earlier CTEs in the same WITH.

> [!tip] CTE vs derived table vs temp table
> - CTE: readable names in one statement; no re-use across statements.
> - Derived table: inline `(SELECT ...) AS x`.
> - Temp table `#t`: persists for the session, has statistics, reusable —
>   better for multi-step heavy work.

## Recursive CTE

A CTE that references itself, driven by an anchor + recursive term:

```sql
WITH Org AS (
    -- anchor: the root
    SELECT EmployeeID, ManagerID, FirstName, 0 AS Level
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- recursive term: children of the level above
    SELECT e.EmployeeID, e.ManagerID, e.FirstName, Org.Level + 1
    FROM Employees e
    JOIN Org ON Org.EmployeeID = e.ManagerID
)
SELECT * FROM Org;
```

Materializes a hierarchy (org chart, part trees, category trees) in one
statement. Default recursion limit is 100 levels; raise it via
`OPTION (MAXRECURSION 0)` when you must.

> [!trap] Recursive cycles
> If your data has a cycle (A reports to B, B reports to A), a recursive CTE
> loops. Bound it with `MAXRECURSION n` and clean the data first. Beware also
> accidental `UNION` (deduping) where you need `UNION ALL` for paths.

## CTEs in context

```sql
WITH Details AS (
    SELECT
        o.OrderID,
        o.OrderDate,
        SUM(oi.Quantity * oi.UnitPrice) AS Total
    FROM Orders o
    JOIN OrderItems oi ON oi.OrderID = o.OrderID
    GROUP BY o.OrderID, o.OrderDate
)
SELECT *
FROM Details
WHERE Total > 500
ORDER BY Total DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How long does a CTE exist?"
    type: single
    choices:
      - "For the session"
      - "For one statement only"
      - "Until the next backup"
      - "Until the buffer cache empties"
    answer: [1]
    explanation: "A CTE is scoped to the single statement that defines it."
    difficulty: 1
  - id: q2
    prompt: "Which two parts make a recursive CTE?"
    type: single
    choices:
      - "Anchor and recursive term"
      - "Filter and sort"
      - "Base table and view"
      - "Query and cursor"
    answer: [0]
    explanation: "A recursive CTE seeds with an anchor then repeatedly expands."
    difficulty: 2
  - id: q3
    prompt: "What can an unguarded recursive CTE hit?"
    type: single
    choices:
      - "The recursion limit"
      - "A syntax error"
      - "The server's timezone"
      - "Nothing; it is always bounded"
    answer: [0]
    explanation: "Recursion defaults to 100 levels; cycles exceed it and error."
    difficulty: 2
  - id: q4
    prompt: "When is a temp table better than a CTE?"
    type: single
    choices:
      - "For a one-statement query"
      - "When you need to reuse a step across statements"
      - "When the query is short"
      - "Never"
    answer: [1]
    explanation: "Temp tables persist for the session and have statistics for reuse."
    difficulty: 2
```