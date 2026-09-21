---
id: 01-create-tables
title: "CREATE TABLE and constraints"
order: 1
section: 04-ddl-schema
language: sql
summary: "Tables, primary keys, foreign keys, unique, check, default"
tags: [create, ddl, constraints, primary-key, foreign-key]
---

# CREATE TABLE and constraints

The database's skeleton is defined by DDL — and constraints make that
skeleton honest.

## A well-constrained table

```sql
CREATE TABLE Products (
    ProductID     INT           NOT NULL,
    ProductName   NVARCHAR(120) NOT NULL,
    CategoryID    INT           NOT NULL,
    UnitPrice     DECIMAL(10,2) NOT NULL,
    StockQty      INT           NOT NULL DEFAULT 0,
    Discontinued  BIT           NOT NULL DEFAULT 0,
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_Products_Name UNIQUE (ProductName),
    CONSTRAINT CK_Products_Price CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Products_Stock CHECK (StockQty >= 0)
);
```

## Constraint types

| Constraint | Guarantees |
|---|---|
| `PRIMARY KEY` | unique + NOT NULL; identifies each row |
| `FOREIGN KEY` | value exists in another table's key |
| `UNIQUE` | no duplicate values (one NULL allowed) |
| `CHECK` | row satisfies an expression |
| `DEFAULT` | value used when none supplied |

> [!key] A primary key is also an index
> The PK creates the clustering and speeds lookups by that key.

## Named constraints are friendlier

`CONSTRAINT FK_... FOREIGN KEY ...` — named constraints give you predictable
errors and easy alteration later. Anonymous inline constraints are possible
but harder to manage.

## Composite keys

A PK can span several columns:

```sql
CREATE TABLE OrderItems (
    OrderID   INT NOT NULL,
    LineNo    INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity  INT NOT NULL,
    CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, LineNo),
    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
```

## Referential actions

What happens to children when the parent row goes away:

```sql
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
      ON DELETE CASCADE      -- rows flow away
      ON UPDATE CASCADE      -- key changes propagate
```

- `CASCADE` — delete/update children along with the parent.
- `NO ACTION` (default) — refuse to delete the parent while children exist.
- `SET NULL` / `SET DEFAULT` — blank out the child's key.

> [!trap] CASCADE chains
> Cascades are convenient but can delete far more than you expect across
> several tables, and they bypass triggers. For financial/audit systems,
> prefer `NO ACTION` plus explicit cleanup.

> [!note] Setting up the shop schema
> This course's running example — `Customers`, `Orders`, `OrderItems`,
> `Products`, `Categories` — is built from exactly these pattern tables.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which constraint enforces uniqueness and NOT NULL together?"
    type: single
    choices: ["FOREIGN KEY", "UNIQUE", "PRIMARY KEY", "CHECK"]
    answer: [2]
    explanation: "A PRIMARY KEY guarantees unique, non-NULL values per row."
    difficulty: 1
  - id: q2
    prompt: "Which action deletes child rows with their parent?"
    type: single
    choices: ["NO ACTION", "CASCADE", "RESTRICT", "SET NULL"]
    answer: [1]
    explanation: "ON DELETE CASCADE removes dependent child rows too."
    difficulty: 1
  - id: q3
    prompt: "What does a CHECK constraint do?"
    type: single
    choices:
      - "Checks the table is not empty"
      - "Requires rows to satisfy an expression"
      - "Logs every change"
      - "Creates an index"
    answer: [1]
    explanation: "CHECK validates each row against a boolean expression."
    difficulty: 2
  - id: q4
    prompt: "Which constraint is used when a value must match a parent's key?"
    type: single
    choices: ["PRIMARY KEY", "FOREIGN KEY", "UNIQUE", "DEFAULT"]
    answer: [1]
    explanation: "The foreign key references an existing primary key value."
    difficulty: 1
```