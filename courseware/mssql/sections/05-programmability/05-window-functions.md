---
id: 05-window-functions
title: "Window functions"
order: 5
section: 05-programmability
language: sql
summary: "ROW_NUMBER, RANK, LEAD/LAG, running totals with OVER"
tags: [window-functions, over, row-number, rank, lag]
---

# Window functions

Window functions compute a value **across a window of rows** without
collapsing them — every row keeps its identity while also seeing its
neighbors' context.

```sql
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    ROW_NUMBER()   OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS Rank
FROM Orders;
```

Each order gets a per-customer sequence. No GROUP BY collapse.

> [!key] OVER is the heart
> `OVER ([PARTITION BY ...] [ORDER BY ...] [ROWS ...])` defines the window:
> partitioning by group + ordering within it + frame limits.

## The ranking family

```sql
SELECT
    ProductID,
    UnitPrice,
    ROW_NUMBER() OVER (ORDER BY UnitPrice DESC)            AS RowNum,
    RANK()       OVER (ORDER BY UnitPrice DESC)            AS Rank,
    DENSE_RANK() OVER (ORDER BY UnitPrice DESC)            AS DenseRank,
    NTILE(4)     OVER (ORDER BY UnitPrice DESC)            AS Quartile
FROM Products;
```

- `ROW_NUMBER()` — 1,2,3,... always distinct.
- `RANK()` — ties share a number, then skip (1,1,3).
- `DENSE_RANK()` — ties share, no skip (1,1,2).
- `NTILE(n)` — splits into n buckets (percentiles/quartiles).

## Row-to-row: LAG and LEAD

```sql
SELECT
    OrderDate,
    TotalAmount,
    LAG(TotalAmount, 1, 0)  OVER (ORDER BY OrderDate) AS PreviousDay, -- waits
    LEAD(TotalAmount, 1)    OVER (ORDER BY OrderDate) AS NextDay
FROM DayTotals;
```

LAG = row before, LEAD = row after (offset 1 by default). Great for deltas:

```sql
WITH Moves AS (
    SELECT
        OrderDate,
        TotalAmount,
        LAG(TotalAmount) OVER (ORDER BY OrderDate) AS Prev
    FROM DayTotals
)
SELECT OrderDate,
       TotalAmount,
       TotalAmount - Prev AS Delta
FROM Moves;
```

## Running totals and frame

`ROWS BETWEEN` narrows the window to a frame:

```sql
SELECT
    OrderID,
    OrderDate,
    SUM(TotalAmount) OVER (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM Orders;
```

> [!key] Partitioning isolates groups
> `PARTITION BY CustomerID` restarts every window computation for each
> customer. Without it, the window spans all rows.

## When window beats GROUP BY

Sometimes you need a group aggregate **alongside** every row:

```sql
SELECT
    CustomerID,
    OrderID,
    TotalAmount,
    SUM(TotalAmount) OVER (PARTITION BY CustomerID) AS CustomerSpend
FROM Orders;
```

One pass, every row keeps its data, the total rides along.

> [!trap] Window functions and ORDER BY
> In an `OVER (ORDER BY ...)`, the framing defaults to RANGE between
> unbounded preceding and current row. If you wanted a whole-group value,
> omit ORDER BY or set `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
> FOLLOWING`.

## Per-group best row

Delete/pick the best row per group without a GROUP BY collapse:

```sql
WITH Ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TotalAmount DESC) AS rn
    FROM Orders
)
SELECT * FROM Ranked WHERE rn = 1;
```

Each customer's single largest order — a pattern so common it has a name.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What makes window functions different from GROUP BY?"
    type: single
    choices:
      - "They collapse rows"
      - "They keep every row while computing group context"
      - "They only work on numbers"
      - "They cannot use SUM"
    answer: [1]
    explanation: "Window functions compute over a frame without collapsing output rows."
    difficulty: 1
  - id: q2
    prompt: "Which returns 1,1,3 for ties?"
    type: single
    choices: ["ROW_NUMBER()", "RANK()", "DENSE_RANK()", "NTILE(2)"]
    answer: [1]
    explanation: "RANK ties share a number and skip; DENSE_RANK does not skip."
    difficulty: 2
  - id: q3
    prompt: "Which function sees the previous row's value?"
    type: single
    choices: ["LEAD", "LAG", "FIRST_VALUE", "ROW_NUMBER"]
    answer: [1]
    explanation: "LAG returns the prior row's value within the window order."
    difficulty: 1
  - id: q4
    prompt: "What does PARTITION BY do?"
    type: single
    choices:
      - "Sorts the whole result"
      - "Restarts the window per group"
      - "Removes duplicates"
      - "Limits rows to 1 per group"
    answer: [1]
    explanation: "PARTITION BY reseeds each window function's frame per partition."
    difficulty: 2
  - id: q5
    prompt: "How do you pick the top row per group?"
    type: single
    choices:
      - "GROUP BY the group columns"
      - "ROW_NUMBER() OVER (PARTITION BY ...) then filter rn = 1"
      - "TOP (1) with ORDER BY"
      - "MAX() in a subquery"
    answer: [1]
    explanation: "Rank rows within a partition and keep rn = 1 — the 'top per group' idiom."
    difficulty: 2
```