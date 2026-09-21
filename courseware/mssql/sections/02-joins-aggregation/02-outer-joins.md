---
id: 02-outer-joins
title: "OUTER joins and self joins"
order: 2
section: 02-joins-aggregation
language: sql
summary: "LEFT/RIGHT/FULL OUTER JOIN and joining a table to itself"
tags: [join, left-join, outer-join, self-join]
---

# OUTER joins and self joins

Sometimes you want rows even when there is no match — customers with zero
orders, products never sold, children with no parent.

## LEFT OUTER JOIN

Keep every row from the **left** table; fill unmatched right-side columns
with NULL:

```sql
-- every customer, with order count (0 for never ordering)
SELECT
    c.CompanyName,
    COUNT(o.OrderID) AS NumberOfOrders
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName;
```

> [!key] One row per left-side row
> A LEFT join on a well-constructed FK yields one row per left row — but if
> the right side has several matches (e.g. one customer with many orders)
> the join produces one row per match. That is where aggregates come in.

> [!trap] The filter-in-WHERE trap
> `LEFT JOIN ... WHERE o.Status = 'Open'` converts the join back into an
> inner join, dropping customers with no orders (their `o.Status` is NULL,
> not 'Open'). Move the filter into the ON clause to preserve unmatched rows:

```sql
SELECT c.CompanyName, COUNT(o.OrderID) AS OpenOrders
FROM Customers c
LEFT JOIN Orders o
       ON o.CustomerID = c.CustomerID AND o.Status = 'Open'
GROUP BY c.CompanyName;
```

## RIGHT and FULL OUTER

- `RIGHT OUTER` — the mirror image; keep all rows of the right table.
- `FULL OUTER` — keep rows from both sides; unmatched columns are NULL.

```sql
-- every product and every order item, whether matched or not
SELECT p.ProductName, oi.Quantity
FROM Products p
FULL OUTER JOIN OrderItems oi ON oi.ProductID = p.ProductID;
```

> [!tip] RIGHT JOIN is rarely needed
> Reorder the tables so the "keep everything" table is on the left; RIGHT
> joins exist mainly to pair with someone else's query shape.

## Self join

A table joined to itself. Classic: employees and their managers, both in
`Employees`.

```sql
SELECT
    e.FirstName AS Employee,
    m.FirstName AS Manager
FROM Employees e
LEFT JOIN Employees m ON m.EmployeeID = e.ManagerID;
```

Two aliases (`e`, `m`) give the same table two roles in one query.

Another classic: pairs of products bought together, or "find dates where an
order follows another in the same list".

```sql
-- customers paired with other customers in the same city
SELECT a.CompanyName AS Who, b.CompanyName AS WithThem
FROM Customers a
JOIN Customers b
  ON a.City = b.City
 AND a.CustomerID < b.CustomerID;
```

`a.CustomerID < b.CustomerID` keeps each pair once, avoiding mirror dups.

## "Rows that are NOT there"

Outer joins are the standard way to find gaps — e.g. customers who have zero
orders:

```sql
SELECT c.CompanyName
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;
```

> [!key] The IS NULL probe
> After a LEFT JOIN, `WHERE right.key IS NULL` selects left rows with no
> match. This is the anti-join pattern.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does a LEFT JOIN keep?"
    type: single
    choices:
      - "Only rows that match"
      - "All left rows plus matched right rows"
      - "All right rows"
      - "Rows unique to the right table"
    answer: [1]
    explanation: "Every left row survives; unmatched right columns become NULL."
    difficulty: 1
  - id: q2
    prompt: "What happens when you filter a LEFT join's right column in WHERE?"
    type: single
    choices:
      - "Nothing changes"
      - "It becomes an inner join, dropping unmatched left rows"
      - "It fills NULLs with defaults"
      - "It speeds the query up"
    answer: [1]
    explanation: "WHERE rightcol = x excludes NULL-filled unmatched rows, undoing the LEFT."
    difficulty: 3
  - id: q3
    prompt: "How do you SELECT employees with no manager?"
    type: single
    choices:
      - "LEFT JOIN Employees m ... WHERE m.EmployeeID IS NULL"
      - "JOIN Employees m ... WHERE e.ManagerID = m.EmployeeID"
      - "FULL JOIN then filter on EmployeeID"
      - "RIGHT JOIN and drop matched"
    answer: [0]
    explanation: "The IS NULL probe after a LEFT JOIN finds 'no match' rows."
    difficulty: 2
  - id: q4
    prompt: "Why alias e and m when self-joining Employees?"
    type: single
    choices:
      - "Aliases are required for self joins"
      - "Each alias plays a different role in the same table"
      - "It sorts faster"
      - "It avoids a cartesian product by itself"
    answer: [1]
    explanation: "Self joins need distinct aliases so conditions can refer to each role."
    difficulty: 2
```