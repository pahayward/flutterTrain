---
id: 01-join-basics
title: "JOIN: combining tables"
order: 1
section: 02-joins-aggregation
language: sql
summary: "INNER JOIN, ON conditions, and avoiding cartesian products"
tags: [join, inner-join, foreign-key, relational]
---

# JOIN: combining tables

Relational data lives across tables; JOIN reassembles it into one result.

```sql
SELECT
    o.OrderID,
    c.CompanyName
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2025-01-01';
```

## How a JOIN works

`JOIN a ON predicate` produces a row for every pair of rows from `a` and `b`
where the predicate is true. `INNER JOIN` keeps only matches:

```
Orders          Customers        INNER JOIN result
1 | c1           c1 | Acme       1 | Acme
2 | c1           c2 | Globex     2 | Acme
3 | c2                          3 | Globex
4 | c9 (no such customer)       (c9 dropped)
```

> [!key] The ON predicate names how rows pair
> `o.CustomerID = c.CustomerID` says "join each order to the customer it
> belongs to". Without a correct relation you get the wrong pairs.

## Table aliases

Short an alias for each table and qualify column names:

```sql
SELECT o.OrderID, c.CompanyName
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID;
```

> [!trap] Ambiguous columns
> If both tables have `Name`, unqualified `Name` is ambiguous and the query
> fails. Always qualify with the alias.

## Joining three tables

```sql
SELECT
    o.OrderID,
    c.CompanyName,
    p.ProductName,
    oi.Quantity
FROM Orders o
JOIN Customers c  ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON oi.OrderID = o.OrderID
JOIN Products p   ON p.ProductID = oi.ProductID;
```

Every join adds another relationship step; each ON clause must be correct or
the intermediate pairs multiply.

> [!trap] The accidental cartesian product
> `FROM Orders, Customers` (comma join without a WHERE) pairs every order
> with every customer. 100 orders × 50 customers = 5000 rows. Always join on
> a real key. If counts jump, suspect a missing ON.

## Which side is which

- `Orders` is the **many** side (one per order).
- `Customers` is the **one** side (per customer).

`INNER JOIN` returns only customers that have orders, and only orders that
have customers. Keeping all of one side is the job of `OUTER JOIN` (next).

```sql
-- customers with at least one order, and how many
SELECT c.CompanyName, COUNT(o.OrderID) AS Orders
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY Orders DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does INNER JOIN keep?"
    type: single
    choices:
      - "All rows from the left table"
      - "Only rows that match in both tables"
      - "All rows from both tables"
      - "Rows unique to each table"
    answer: [1]
    explanation: "INNER JOIN returns only rows satisfying the ON predicate on both sides."
    difficulty: 1
  - id: q2
    prompt: "A missing ON clause in a comma join produces what?"
    type: single
    choices:
      - "An error"
      - "A cartesian product of all row pairs"
      - "Only matching keys"
      - "The left table's rows"
    answer: [1]
    explanation: "Every pair is returned, multiplying rows beyond what is intended."
    difficulty: 2
  - id: q3
    prompt: "Why qualify columns with the table alias?"
    type: single
    choices:
      - "Faster execution"
      - "Avoid ambiguous columns and make intent clear"
      - "Required only for LEFT joins"
      - "It is optional unless there are two tables"
    answer: [1]
    explanation: "Qualifying keeps references unambiguous and readable."
    difficulty: 1
  - id: q4
    prompt: "Which is the 'many' side in Orders JOIN Customers?"
    type: single
    choices:
      - "Customers"
      - "Orders"
      - "Both"
      - "Neither"
    answer: [1]
    explanation: "Many orders reference one customer, so Orders is the many side."
    difficulty: 2
```