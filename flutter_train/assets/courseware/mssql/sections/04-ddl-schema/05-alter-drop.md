---
id: 05-alter-drop
title: "ALTER and DROP: evolving schema"
order: 5
section: 04-ddl-schema
language: sql
summary: "Adding/removing columns, changing types, and dropping objects"
tags: [alter, drop, ddl, migration]
---

# ALTER and DROP

Databases grow. `ALTER` changes objects in place; `DROP` removes them.

## ALTER TABLE

```sql
-- add a column
ALTER TABLE Customers ADD TaxID NVARCHAR(32) NULL;

-- add a column with a default
ALTER TABLE Customers ADD CreditLimit DECIMAL(10,2) NOT NULL
    CONSTRAINT DF_Customers_Credit DEFAULT 0;

-- drop a column
ALTER TABLE Customers DROP COLUMN LegacyFlag;

-- change a type (same type family usually)
ALTER TABLE Products ALTER COLUMN UnitPrice DECIMAL(12,2);
```

> [!trap] Type changes can fail or rewrite the table
> Changing `INT` → `NVARCHAR` is usually fine, but going `VARCHAR` → `INT`
> fails if existing data does not convert, and casting down in precision
> can fail too. Big tables may be rebuilt — plan for downtime.

## Defaults and constraints via ALTER

```sql
ALTER TABLE Customers
    ADD CONSTRAINT DF_Customers_Region DEFAULT N'EU' FOR Region;

ALTER TABLE Orders
    ADD CONSTRAINT FK_Orders_Customers
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

-- remove one
ALTER TABLE Orders DROP CONSTRAINT FK_Orders_Customers;
```

## Renaming

```sql
EXEC sp_rename 'dbo.OldTable', 'NewTable';
EXEC sp_rename 'dbo.Orders.Total', 'TotalAmount', 'COLUMN';
```

`sp_rename` warns that scripts and views referencing the object must be
updated — renaming does not rewrite dependencies.

> [!tip] Schema changes belong in migrations
> Track every ALTER in a versioned migration script (Git, Flyway-style). A
> database without migration history is un-deployable.

## DROP

```sql
DROP TABLE IF EXISTS dbo.StagingOrders;   -- removes table + its data
DROP VIEW IF EXISTS dbo.vwOld;
DROP INDEX IF EXISTS IX_Products_UnitPrice ON dbo.Products;
```

- Tables referenced by FK cannot be dropped until the referencing constraint
  is dropped too.
- `DROP TABLE` needs `DROP` permission, and always removes data (the table's
  rows go with it).

> [!warning] Dropping is permanent
> `DROP` does not go to the recycle bin. Back up before dropping anything
> you cannot recreate.

## ALTER for object structure

```sql
ALTER VIEW dbo.vwActiveOrders AS
SELECT ... ;   -- replaces the view's definition

ALTER PROCEDURE dbo.P_ShipOrder
    @OrderID INT
AS
BEGIN
    ...
END;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does ALTER TABLE ADD COLUMN do?"
    type: single
    choices:
      - "Inserts values into every row"
      - "Adds a new column safely"
      - "Rewrites the whole table"
      - "Creates an identity"
    answer: [1]
    explanation: "ALTER TABLE ... ADD adds a column; existing rows get its default/NULL."
    difficulty: 1
  - id: q2
    prompt: "Which change can fail when existing data cannot convert?"
    type: single
    choices:
      - "Adding a NULL column"
      - "ALTER COLUMN to an incompatible type"
      - "Adding a DEFAULT constraint"
      - "Creating a view"
    answer: [1]
    explanation: "Type conversion applies to existing data; failures abort the ALTER."
    difficulty: 2
  - id: q3
    prompt: "What comes before DROPping a referenced table?"
    type: single
    choices:
      - "Truncing it"
      - "Dropping referencing foreign keys"
      - "Inserting a dummy row"
      - "Nothing"
    answer: [1]
    explanation: "Foreign key relationships block dropping the referenced table."
    difficulty: 2
  - id: q4
    prompt: "How should schema evolution be tracked?"
    type: single
    choices:
      - "Ad-hoc SSMS clicks only"
      - "Versioned migration scripts"
      - "By rebuilding the database"
      - "ALTER statements in chat only"
    answer: [1]
    explanation: "Versioned migration scripts give reproducible, auditable schema history."
    difficulty: 1
```