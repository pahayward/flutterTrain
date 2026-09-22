---
id: 03-order-by-top
title: "Ordering and TOP"
order: 3
section: 01-query-basics
language: sql
summary: "ORDER BY sorts; TOP limits rows; OFFSET-FETCH paginates"
tags: [order-by, top, offset-fetch, sorting]
---

# Ordering and TOP

Rows in a table have no inherent order — you request one with `ORDER BY`, and
you limit the set with `TOP`.

## ORDER BY

Sort by one or more columns, ascending or descending:

```sql
SELECT ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC;

-- multiple keys: price desc, then name asc for ties
SELECT ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC, ProductName ASC;
```

Also allowed: column ordinals and aliases.

> [!key] TOP without ORDER BY is arbitrary
> `SELECT TOP 10 * FROM Orders` returns ten rows, but which ten? The engine
> picks. "Top ten by amount" is `TOP (10) ... ORDER BY TotalAmount DESC`.

## TOP

```sql
-- the 5 most expensive products
SELECT TOP (5) ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC;

-- at least 5, include ties at rank 5
SELECT TOP (5) WITH TIES ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC;
```

`WITH TIES` adds every row equal in the sort key to the last selected row.
`TOP` also accepts a percentage: `TOP (10) PERCENT`.

## Types and sorting

- Numbers: by value.
- Text: by **collation** — the rules of character comparison for the
  database (usually case-insensitive, accent-sensitive).
- Dates: by chronological order.

```sql
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
ORDER BY OrderDate DESC, TotalAmount DESC;
```

## OFFSET-FETCH — pagination

Standard way to walk through a large result set in pages:

```sql
-- page 3, 25 rows per page
SELECT OrderID, OrderDate
FROM Orders
ORDER BY OrderDate DESC
OFFSET 50 ROWS                -- skip first 50
FETCH NEXT 25 ROWS ONLY;      -- take next 25
```

> [!trap] OFFSET-FETCH needs ORDER BY
> Unlike TOP, OFFSET-FETCH throws an error if ORDER BY is missing — ordering
> is what defines "next page".

## Using it together

```sql
-- five biggest customers by total spend
SELECT TOP (5)
    c.CustomerID,
    c.CompanyName,
    SUM(o.TotalAmount) AS TotalSpend
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "SELECT TOP 10 * ... ORDER BY makes the TOP rows what?"
    type: single
    choices:
      - "Random"
      - "The first 10 in table order"
      - "The 10 rows matching the ORDER BY ordering"
      - "The largest 10"
    answer: [2]
    explanation: "ORDER BY defines which rows are the 'top 10' for TOP to return."
    difficulty: 1
  - id: q2
    prompt: "Which keyword includes ties in a TOP query?"
    type: single
    choices:
      - "WITH TIES"
      - "INCLUDE TIES"
      - "ALL TIES"
      - "WITHIN"
    answer: [0]
    explanation: "TOP (n) WITH TIES adds rows tied with the nth row in the sort."
    difficulty: 2
  - id: q3
    prompt: "What paginates a query by skipping rows and fetching a page?"
    type: single
    choices:
      - "TOP (n)"
      - "OFFSET .. FETCH NEXT .."
      - "LIMIT .. OFFSET .."
      - "PAGE(..)"
    answer: [1]
    explanation: "OFFSET .. ROWS FETCH NEXT .. ROWS ONLY is the T-SQL paging syntax."
    difficulty: 2
  - id: q4
    prompt: "Is the order of rows guaranteed without ORDER BY?"
    type: single
    choices:
      - "Yes, insertion order"
      - "Yes, primary key order"
      - "No"
      - "Only for small tables"
    answer: [2]
    explanation: "Relational result sets have no guaranteed order unless ORDER BY is used."
    difficulty: 1
```