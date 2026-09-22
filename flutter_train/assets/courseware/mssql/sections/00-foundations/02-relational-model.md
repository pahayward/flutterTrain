---
id: 02-relational-model
title: "The relational model: tables, rows, keys"
order: 2
section: 00-foundations
language: sql
summary: "Relations, keys, cardinality, and why this design wins"
tags: [relational, keys, normalization, modeling]
---

# The relational model

At its heart SQL Server stores data in **tables**. A table is a collection of
**rows**; every row has the same set of **columns**.

Think of a table as a spreadsheet whose columns have fixed, enforced types:

| CustomerID | Name | City |
|---|---|---|
| 1 | Alice | London |
| 2 | Bob | Paris |

## The rules of a relation

- Every **row** is unique (a table is a *set*, not a list).
- Every **column** has a name and a type.
- **Row order is not significant** — you always ask for an order explicitly.
- Cells hold single atomic values.

> [!key] Order is never guaranteed
> Without an `ORDER BY`, SQL Server may return rows in any order — and that
> order can change between runs. If order matters, say so in the query.

## Keys

- **Primary key (PK)** — the column (or columns) that uniquely identifies each
  row. One per table, never NULL.
- **Foreign key (FK)** — a column whose values must reference an existing
  primary key in another table. This is how tables relate to each other.
- **Unique key** — like a PK but allows one NULL and is mostly for uniqueness.

Foreign keys enforce **referential integrity**: you cannot insert an
`Order` for a customer that does not exist.

## Relationships

| Relationship | Example | How modeled |
|---|---|---|
| One-to-many | Customer → Orders | `CustomerID` FK on the `Orders` table |
| Many-to-many | Student ↔ Course | Junction table with two FKs |
| One-to-one | User → Profile | Same PK on both tables |

> [!trap] Many-to-many tables
> Do not put one column of comma-separated course IDs on a student row.
> Model many-to-many with a separate junction table containing one row per
> student-course pair.

## Why this design wins

1. **No duplicated data** — one Customer row, referenced by many Orders.
2. **Integrity** — the engine refuses inconsistent data.
3. **Query power** — `JOIN` lets you reconstruct any view of the data.
4. **Concurrency** — rows lock independently.

Normalization is the discipline of removing duplication (see Part 4), but the
core concept is simple: store each fact once, reference it by key.

```sql
-- A minimal but proper relational pair of tables
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name       NVARCHAR(100) NOT NULL,
    City       NVARCHAR(50)
);

CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Total      DECIMAL(10,2),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
```

> [!note] This course's running example
> Many examples use a small shop schema: `Customers`, `Orders`,
> `OrderItems`, `Products`. The DDL appears in "CREATE TABLE and
> constraints" in Part 4; earlier parts use self-contained tables.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Without ORDER BY, when is row order guaranteed?"
    type: single
    choices:
      - "Always, in insertion order"
      - "Never"
      - "Only when the table has a clustered index"
      - "Always, in primary key order"
    answer: [1]
    explanation: "Relational tables are unordered sets. Guarantee order yourself with ORDER BY."
    difficulty: 1
  - id: q2
    prompt: "How is a one-to-many relationship modeled?"
    type: single
    choices:
      - "A primary key on the child table"
      - "A foreign key on the child table referencing the parent"
      - "A comma-separated list on the parent row"
      - "A separate junction table"
    answer: [1]
    explanation: "The 'many' side carries a foreign key pointing at the parent's primary key."
    difficulty: 2
  - id: q3
    prompt: "Which of these is NOT a valid table in a well-designed relational model?"
    type: single
    choices:
      - "A Products table with a ProductID primary key"
      - "An Orders table with a comma-separated product list column"
      - "An OrderItems junction table"
      - "A Customers table with a City column"
    answer: [1]
    explanation: "Comma-separated lists break atomicity and cannot enforce referential integrity."
    difficulty: 2
  - id: q4
    prompt: "What does a foreign key enforce?"
    type: single
    choices:
      - "Unique column values"
      - "Referential integrity between tables"
      - "Fast query performance"
      - "Column data types"
    answer: [1]
    explanation: "A foreign key guarantees a value exists as a primary key in the referenced table."
    difficulty: 1
```