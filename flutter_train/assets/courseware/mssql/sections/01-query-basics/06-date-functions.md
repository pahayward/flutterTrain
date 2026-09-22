---
id: 06-date-functions
title: "Date and time functions"
order: 6
section: 01-query-basics
language: sql
summary: "Current time, date arithmetic, formatting, and parsing"
tags: [dates, datetime, dateadd, datediff, format]
---

# Date and time functions

Date handling is where many queries go wrong. These functions keep it under
control.

## The current moment

```sql
SELECT
    GETDATE()              AS now,       -- datetime, server local
    SYSDATETIME()          AS precise,   -- datetime2, high precision
    CURRENT_TIMESTAMP      AS also_now,  -- standard SQL alias
    SYSUTCDATETIME()       AS utc;       -- UTC, for global apps
```

> [!tip] Store UTC, display local
> Distributed systems normally store `DATETIMEOFFSET` or UTC and only format
> into a user's time zone at presentation time.

## Arithmetic

```sql
SELECT
    DATEADD(day, 30, '2025-01-01')   AS plus_a_month,    -- 2025-01-31
    DATEDIFF(day, '2025-01-01', '2025-03-01') AS days,    -- 59
    DATEADD(year, -1, GETDATE())     AS last_year;
```

Parts for `DATEADD`/`DATEDIFF`: `year`, `quarter`, `month`, `day`,
`hour`, `minute`, `second`, `millisecond`, `week`, `weekday`.

`DATEDIFF` counts *boundaries crossed*, so the difference between 23:59 and
00:01 next day is 1 "day" even though 2 minutes passed. For elapsed time use
`DATEDIFF_BIG(second, ...)`.

## Extracting parts

```sql
SELECT
    DATEPART(year,   '2025-03-07')    AS y,    -- 2025
    DATEPART(month,  '2025-03-07')    AS m,    -- 3
    DAY('2025-03-07')                 AS d,    -- 7
    DATENAME(month, '2025-03-07')     AS mname; -- March
```

`DATEPART` returns a number; `DATENAME` returns the name of the part.

## Truncating to a day

Dates store time too. "This month's orders" needs a range, not a point:

```sql
-- every order placed this month (works regardless of time-of-day)
SELECT OrderID
FROM Orders
WHERE OrderDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND OrderDate <  DATEADD(month, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
```

> [!trap] = GETDATE() misses most of the day
> `WHERE OrderDate = '2025-03-07'` matches only exactly midnight. Half-open
> ranges `>= start AND < next` are the reliable pattern.

## EOMONTH

The last day of the month:

```sql
SELECT EOMONTH('2025-02-10');     -- 2025-02-28
SELECT EOMONTH(GETDATE());        -- end of current month
```

Also handy: `EOMONTH(GETDATE(), 1)` gives end of next month; `. , -1` gives
the previous month's end.

## Formatting

```sql
SELECT
    FORMAT(GETDATE(), 'yyyy-MM-dd')           AS iso,
    FORMAT(GETDATE(), 'dd MMM yyyy')          AS friendly,
    FORMAT(GETDATE(), 'HH:mm')                AS clock;
```

> [!note] FORMAT costs CPU
> `FORMAT` is slow on big result sets. For plain conversions prefer
> `CONVERT(varchar, date, 126)` (ISO format) and keep FORMAT for small
> display layers.

## Grouping by day for a report

```sql
SELECT
    CONVERT(DATE, OrderDate)     AS OrderDay,
    COUNT(*)                     AS Orders
FROM Orders
GROUP BY CONVERT(DATE, OrderDate)
ORDER BY OrderDay;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which function adds an interval to a date?"
    type: single
    choices:
      - "DATEDIFF"
      - "DATEADD"
      - "DATEPART"
      - "EOMONTH"
    answer: [1]
    explanation: "DATEADD(part, amount, date) shifts the date by the interval."
    difficulty: 1
  - id: q2
    prompt: "Why is WHERE OrderDate = '2025-03-07' usually wrong?"
    type: single
    choices:
      - "It only matches exactly at midnight"
      - "It is too slow"
      - "OrderDate is a string"
      - "It ignores indexes"
    answer: [0]
    explanation: "Datetime columns have times; equality matches midnight only. Use a half-open range."
    difficulty: 2
  - id: q3
    prompt: "What does EOMONTH('2025-02-10') return?"
    type: single
    choices:
      - "2025-02-28"
      - "2025-02-10"
      - "2025-03-01"
      - "2025-02-01"
    answer: [0]
    explanation: "EOMONTH returns the last day of the month: 2025-02-28."
    difficulty: 1
  - id: q4
    prompt: "Which function returns the number of boundaries crossed between two dates?"
    type: single
    choices:
      - "DATEADD"
      - "DATEDIFF"
      - "DATEDELTA"
      - "DATEPART"
    answer: [1]
    explanation: "DATEDIFF counts interval boundaries between the two dates."
    difficulty: 2
```