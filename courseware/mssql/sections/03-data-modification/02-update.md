---
id: 02-update
title: "UPDATE: changing rows"
order: 2
section: 03-data-modification
language: sql
summary: "Modifying existing rows, UPDATE from a query, OUTPUT"
tags: [update, dml, set, output]
---

# UPDATE: changing rows

`UPDATE` changes existing rows. It must be precise about **which** rows, or
you update many more than intended.

```sql
UPDATE Products
SET UnitPrice = UnitPrice * 1.05
WHERE CategoryID = 4;
```

> [!trap] No WHERE updates everything
> `UPDATE Products SET UnitPrice = 0` applies to every row. Always write the
> WHERE first in your head, then add the UPDATE.

## Multiple columns

```sql
UPDATE Customers
SET City = N'Porto', Region = N'North'
WHERE CustomerID = 5;
```

## UPDATE joined with other tables

T-SQL allows updating through a join:

```sql
UPDATE o
SET o.Status = N'Overdue'
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE c.City = N'Lisbon'
  AND o.Status = N'Pending';
```

The alias target (`UPDATE o`) says which table to change; the FROM pins rows
via relation.

> [!tip] Statement-based is safer than loops
> One UPDATE with a JOIN is atomic and fast; row-by-row UPDATEs in a cursor
> are slow and error-prone. Prefer set-based statements.

## Updating from a SELECT

Classic "copy a value from a related row":

```sql
-- give orders the customer's default region
UPDATE o
SET o.Region = c.Region
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID;
```

## OUTPUT for audit

Capture what changed (old and new values):

```sql
UPDATE Products
SET UnitPrice = UnitPrice * 1.1
OUTPUT deleted.ProductID, deleted.UnitPrice AS OldPrice,
       inserted.UnitPrice                     AS NewPrice
WHERE CategoryID = 1;
```

`deleted.*` = before, `inserted.*` = after. Handy for audit logs.

## sargable caution

The WHERE in an UPDATE should use indexed, sargable predicates (see Part 6).
Updating a huge fraction of a big table may still be expensive.

> [!warning] Transactions protect you
> Wrap multi-row updates in `BEGIN TRAN`, verify counts, then `COMMIT` — see
> the Transactions lesson next.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens without a WHERE clause in UPDATE?"
    type: single
    choices:
      - "Nothing happens"
      - "Every row is updated"
      - "Only the first row is updated"
      - "An error is raised"
    answer: [1]
    explanation: "UPDATE without WHERE modifies every row in the table."
    difficulty: 1
  - id: q2
    prompt: "In UPDATE joined to another table, what does UPDATE o target?"
    type: single
    choices:
      - "The alias specified before SET"
      - "All tables in the FROM"
      - "The right-most table"
      - "The base table only"
    answer: [0]
    explanation: "UPDATE <alias> names the table being changed; the rest is relation context."
    difficulty: 2
  - id: q3
    prompt: "Which pseudo-table holds the 'before' values in OUTPUT?"
    type: single
    choices: ["inserted", "deleted", "old", "previous"]
    answer: [1]
    explanation: "deleted.* is the pre-update value; inserted.* the post-update value."
    difficulty: 2
  - id: q4
    prompt: "Which pattern is preferred for multi-row changes?"
    type: single
    choices:
      - "A cursor loop"
      - "One set-based UPDATE"
      - "UPDATE then DELETE per row"
      - "Recreating the table"
    answer: [1]
    explanation: "Set-based DML is atomic and much faster than row-by-row loops."
    difficulty: 2
```