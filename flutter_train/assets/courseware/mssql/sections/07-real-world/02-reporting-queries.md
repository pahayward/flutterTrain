---
id: 02-reporting-queries
title: "Building reporting queries"
order: 2
section: 07-real-world
language: sql
summary: "Designing readable, correct, fast reports with dates and totals"
tags: [reporting, aggregation, date-buckets, windowing]
---

# Building reporting queries

Reports are SELECT performed with discipline: correct numbers, stable shape,
and fast execution on real data.

## Design from the question down

Ask: what is the grain? "Per day" vs "per order" changes everything.
Write the line-items first, then aggregate.

```sql
-- daily sales: one row per day, correct with multi-level data
SELECT
    CONVERT(DATE, o.OrderDate)                     AS SaleDay,
    SUM(oi.Quantity * oi.UnitPrice)                AS Revenue
FROM Orders o
JOIN OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY CONVERT(DATE, o.OrderDate)
ORDER BY SaleDay;
```

> [!trap] Aggregating after two joins hides a multiplier
> `SUM(oi.Quantity)` after joining `Orders → OrderItems → Products` is
> correct for *order items* only if Products are one-to-one with items. When
> multiple one-to-many joins meet, the numbers inflate. Aggregate each level
> first, then combine (CTEs/window).

## Date buckets by week / month

```sql
SELECT
    DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS MonthStart,
    COUNT(*)    AS Orders,
    SUM(o.TotalAmount) AS Revenue
FROM Orders o
GROUP BY DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)  -- sargable!?
ORDER BY MonthStart;
```

> [!note] Sargability in GROUP frameworks
> Batching by a *function of the column* inside GROUP BY is fine for
> grouping — the heavy scan happens regardless, and indexes help less with
> bucketing. For the *filter* on dates keep ranges (previous lesson).

## Running totals and moving averages

```sql
WITH Sales AS (
    SELECT
        OrderDate,
        SUM(TotalAmount) AS DayTotal
    FROM Orders
    GROUP BY OrderDate
)
SELECT
    OrderDate,
    DayTotal,
    SUM(DayTotal) OVER (ORDER BY OrderDate
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Rolling30,
    ROUND(AVG(DayTotal) OVER (ORDER BY OrderDate
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS Avg7
FROM Sales
ORDER BY OrderDate;
```

## Customer summaries with flags

```sql
WITH Stats AS (
    SELECT
        c.CustomerID,
        COUNT(o.OrderID)                       AS OrderCount,
        ISNULL(SUM(o.TotalAmount), 0)          AS Lifetime,
        MIN(o.OrderDate)                       AS FirstOrder,
        MAX(o.OrderDate)                       AS LastOrder
    FROM Customers c
    LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerID
)
SELECT
    c.CompanyName,
    s.OrderCount,
    s.Lifetime,
    CASE
        WHEN s.OrderCount = 0 THEN N'New'
        WHEN DATEDIFF(day, s.LastOrder, GETDATE()) > 180 THEN N'At risk'
        ELSE N'Active'
    END AS Segment
FROM Customers c
JOIN Stats s ON s.CustomerID = c.CustomerID
ORDER BY s.Lifetime DESC;
```

## Output shape conventions

- Name every column for the reader.
- Sort for the view, not the engine.
- Keep currency as DECIMAL — `FORMAT` only at display time.
- Never `SELECT *` into a report that outlives this month.

> [!tip] Build the pipeline in layers
> Report = facts + calculation + presentation. Keep the intensive work in
> the engine (T-SQL), deliver tidy sets, and let the client only render.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the correct grain for a daily-sales report?"
    type: single
    choices:
      - "Per order item"
      - "One row per day of totals"
      - "Per customer"
      - "Per page"
    answer: [1]
    explanation: "A day report aggregates item-level facts up to one row per day."
    difficulty: 2
  - id: q2
    prompt: "Why can double one-to-many joins inflate report totals?"
    type: single
    choices:
      - "They lose NULLs"
      - "Rows get multiplied before aggregation"
      - "They sort the data"
      - "They disable aggregates"
    answer: [1]
    explanation: "Two one-to-many joins can duplicate rows, inflating sums."
    difficulty: 2
  - id: q3
    prompt: "Which gives a rolling window in a report?"
    type: single
    choices: ["OVER (PARTITION BY ...)", "OVER (ORDER BY ... ROWS BETWEEN ...)", "GROUP BY with CASE", "DISTINCT"]
    answer: [1]
    explanation: "A frame (ROWS BETWEEN) inside OVER defines the rolling window."
    difficulty: 2
  - id: q4
    prompt: "For report display, when is FORMAT appropriate?"
    type: single
    choices:
      - "In the final display layer"
      - "On every row of a big export"
      - "In the WHERE clause"
      - "Never"
    answer: [0]
    explanation: "Keep heavy formatting out of big scans; apply it at display time."
    difficulty: 2
```