---
id: 04-views
title: "Views"
order: 4
section: 04-ddl-schema
language: sql
summary: "Stored queries as virtual tables, security, and indexed views"
tags: [views, virtual-tables, security, ddl]
---

# Views

A **view** is a named SELECT stored in the database. Querying it runs the
stored query.

```sql
CREATE VIEW vwActiveOrders AS
SELECT o.OrderID, c.CompanyName, o.OrderDate, o.TotalAmount
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE o.Status <> N'Cancelled';
```

```sql
-- reads like a table
SELECT * FROM vwActiveOrders
WHERE OrderDate >= '2025-01-01';
```

## Why use views

- **Consistency** — one definition of "active orders" everywhere.
- **Security** — expose only some columns/rows to some users.
- **Joins capsule** — a stable facade over a changing schema.
- **Simplicity** — complex queries become one named object.

> [!note] Views are not materialized by default
> Every select through a normal view runs the underlying query live. The data
> is not copied; a view is a saved expression.

## Updatable views

Simple single-table views can accept INSERT/UPDATE/DELETE that flow to the
base table:

```sql
UPDATE vwActiveOrders SET TotalAmount = 0 WHERE OrderID = 5;
```

Only when the view maps cleanly to one table and the change resolves
unambiguously. Multi-table joins are usually not updatable.

## Schema-bound and indexed views

`WITH SCHEMABINDING` prevents accidental column changes and is also required
for an **indexed** (materialized) view:

```sql
CREATE VIEW vwSalesByCategory
WITH SCHEMABINDING AS
SELECT c.CategoryName,
       SUM(oi.Quantity * oi.UnitPrice) AS Gross
FROM dbo.Products p
JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
JOIN dbo.OrderItems oi ON oi.ProductID = p.ProductID
GROUP BY c.CategoryName;
```

Then:

```sql
CREATE UNIQUE CLUSTERED INDEX UCI_vwSalesByCategory
ON vwSalesByCategory (CategoryName);
```

Now the engine maintains the aggregation like an index — fast precomputed
summaries, at the cost of write overhead.

> [!trap] Indexed view restrictions
> Schema-bound, deterministic, and grouped with only specific aggregates
> (`COUNT_BIG` always required). Enterprise/Developer editions for query
> hints to use them. Keep them simple or they are more trouble than value.

## Renaming and dropping

```sql
EXEC sp_rename 'dbo.vwOld', 'vwActiveOrders';   -- rename a view
DROP VIEW dbp.vwActiveOrders;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is a view?"
    type: single
    choices:
      - "A copy of table data"
      - "A stored SELECT readable as a table"
      - "An index on multiple tables"
      - "A permission"
    answer: [1]
    explanation: "A view is a named query exposed like a virtual table."
    difficulty: 1
  - id: q2
    prompt: "What does WITH SCHEMABINDING do?"
    type: single
    choices:
      - "Speeds up the view"
      - "Binds the view to underlying table definitions"
      - "Makes the view updatable"
      - "Adds a clustered index"
    answer: [1]
    explanation: "SCHEMABINDING ties the view to the base schema and enables indexed views."
    difficulty: 2
  - id: q3
    prompt: "Which makes a view physically precomputed?"
    type: single
    choices:
      - "A normal view"
      - "An indexed (materialized) view"
      - "WITH READ ONLY"
      - "A CTE"
    answer: [1]
    explanation: "Only an indexed view with a unique clustered index stores results physically."
    difficulty: 2
  - id: q4
    prompt: "What is the main security benefit of views?"
    type: single
    choices:
      - "They encrypt data"
      - "They expose a filtered seen-of-the-schema to users"
      - "They remove the need for logins"
      - "They cache results"
    answer: [1]
    explanation: "Views present a controlled subset of columns/rows without base-table access."
    difficulty: 1
```