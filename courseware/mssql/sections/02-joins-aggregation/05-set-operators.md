---
id: 05-set-operators
title: "UNION, INTERSECT, EXCEPT"
order: 5
section: 02-joins-aggregation
language: sql
summary: "Stacking and comparing whole result sets"
tags: [union, intersect, except, set-operators]
---

# Set operators

JOIN combines rows **side by side**. Set operators combine whole result sets
**vertically** — they stack rows.

## UNION ALL vs UNION

```sql
-- all customers and all suppliers in one list
SELECT CompanyName, City FROM Customers
UNION ALL
SELECT CompanyName, City FROM Suppliers;
```

- `UNION ALL` — append, no deduplication, fastest.
- `UNION` — append **and remove duplicates**.

> [!key] Both inputs must match shapes
> Both sides need the same number of columns with compatible types. Column
> *names* come from the first query.

```sql
SELECT 'C' AS Kind, CompanyName, City FROM Customers
UNION ALL
SELECT 'S' AS Kind, CompanyName, City FROM Suppliers
ORDER BY City;
```

## INTERSECT and EXCEPT

- `INTERSECT` — rows present in **both** result sets.
- `EXCEPT` — rows in the first set but not the second.

```sql
-- cities where we have both customers and suppliers
SELECT City FROM Customers
INTERSECT
SELECT City FROM Suppliers;

-- customers living in cities with no supplier
SELECT City FROM Customers
EXCEPT
SELECT City FROM Suppliers;
```

Both deduplicate their output and compare whole-row equality.

> [!trap] INTERSECT/EXCEPT = it is not JOIN
> This is row-set logic, not row pairing. To keep both sides of a match in
> one row with values from each, use a JOIN — set operators return only the
> compared columns.

## Real-world usage

Typical: combine two sources into a single report, or reconcile lists.

```sql
-- member addresses by role
SELECT FullName, Email FROM ActiveMembers
UNION
SELECT FullName, Email FROM AlumniMembers
ORDER BY FullName;
```

> [!tip] Duplicates matter to UNION
> When you need *every* incident (validation, log lines) use UNION ALL.
> UNION's dedup costs time and can silently hide real repeats. Default to
> UNION ALL and reach for UNION only when you truly want distinct rows.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does UNION ALL do to duplicate rows?"
    type: single
    choices:
      - "Removes them"
      - "Keeps them"
      - "Sorts them first"
      - "Errors"
    answer: [1]
    explanation: "UNION ALL appends without deduplication; UNION removes duplicates."
    difficulty: 1
  - id: q2
    prompt: "Which operator returns rows in both result sets?"
    type: single
    choices: ["UNION ALL", "JOIN", "INTERSECT", "EXCEPT"]
    answer: [2]
    explanation: "INTERSECT returns rows present in both operand sets."
    difficulty: 1
  - id: q3
    prompt: "Which returns rows in the first set but not in the second?"
    type: single
    choices: ["EXCEPT", "INTERSECT", "UNION", "MINUS"]
    answer: [0]
    explanation: "EXCEPT subtracts the second set from the first (MINUS is Oracle)."
    difficulty: 1
  - id: q4
    prompt: "What must the two operand queries have in common?"
    type: single
    choices:
      - "The same table name"
      - "The same number and types of columns"
      - "Identical column names"
      - "A common primary key"
    answer: [1]
    explanation: "Set operators need equal column counts with compatible types."
    difficulty: 2
```