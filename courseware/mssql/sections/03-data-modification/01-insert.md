---
id: 01-insert
title: "INSERT: creating rows"
order: 1
section: 03-data-modification
language: sql
summary: "Adding rows one at a time, from queries, and in bulk"
tags: [insert, dml, identity, output]
---

# INSERT: creating rows

`INSERT` adds rows to a table.

## Single row

```sql
INSERT INTO Customers (CustomerID, CompanyName, City)
VALUES (20, N'Acme Socks', N'Lisbon');
```

- Column names are optional, but if omitted you must supply values in table
  column order (fragile — always name columns).
- Columns left out get their default or NULL.

> [!trap] Identity columns
> If the column is `IDENTITY`, do not insert it — the engine generates the
> value. INSERTing into it errors (or violates identity requirements).

## Multiple rows

```sql
INSERT INTO Categories (CategoryID, CategoryName)
VALUES
    (1, N'Laptops'),
    (2, N'Monitors'),
    (3, N'Peripherals');
```

## INSERT from a query

```sql
INSERT INTO ArchiveOrders (OrderID, OrderDate, TotalAmount)
SELECT OrderID, OrderDate, TotalAmount
FROM Orders
WHERE OrderDate < '2023-01-01';
```

The SELECT's result shape must match the INSERT target. This is the workhorse
for archiving, staging, and ETL.

> [!tip] INSERT-SELECT moves data without a cursor
> You never need a loop to copy large sets — one INSERT-SELECT statement is
> faster and stays atomic.

## Bulk load

Two common ways to get a large file in:

```sql
-- fast path, error-tolerant with per-row hints
BULK INSERT dbo.RawSales
FROM 'C:\data\sales.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
```

`OPENROWSET` and `BULK INSERT` load fast. For CSV on Linux/containers people
often bulk-load with rows already staged or the `bcp` utility.

## IDENTITY and OUTPUT

Get back what you inserted (often the new key):

```sql
INSERT INTO Customers (CompanyName, City)
OUTPUT INSERTED.CustomerID              -- returns the generated key
VALUES (N'Acme Socks', N'Lisbon');
```

For more than one value, insert into a table:

```sql
-- capture all new IDs at once
DECLARE @newIds TABLE (id INT);
INSERT INTO Customers (CompanyName, City)
OUTPUT INSERTED.CustomerID INTO @newIds (id)
VALUES (N'A', N'x'), (N'B', N'y');
SELECT * FROM @newIds;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens if you omit column names in INSERT?"
    type: single
    choices:
      - "The engine guesses"
      - "Values map to table column order"
      - "An error is always raised"
      - "Extra columns are ignored"
    answer: [1]
    explanation: "Unnamed INSERT maps values to the table's defined column order."
    difficulty: 2
  - id: q2
    prompt: "Which statement copies rows with a SELECT?"
    type: single
    choices:
      - "INSERT INTO t SELECT ... FROM ..."
      - "SELECT INTO copy"
      - "MERGE the SELECT"
      - "APPEND VALUES"
    answer: [0]
    explanation: "INSERT-SELECT inserts the query's result rows into the target table."
    difficulty: 1
  - id: q3
    prompt: "What does OUTPUT INSERTED return?"
    type: single
    choices:
      - "The old rows"
      - "The new rows (including generated keys)"
      - "Rows affected count only"
      - "Nothing"
    answer: [1]
    explanation: "OUTPUT INSERTED exposes the inserted rows, useful for identity values."
    difficulty: 2
  - id: q4
    prompt: "Can you insert into an IDENTITY column by default?"
    type: single
    choices:
      - "Yes, always"
      - "No, the engine generates it"
      - "Only with SELECT"
      - "Only columns named Id"
    answer: [1]
    explanation: "IDENTITY columns are auto-generated; inserting a value usually requires SET IDENTITY_INSERT ON."
    difficulty: 2
```