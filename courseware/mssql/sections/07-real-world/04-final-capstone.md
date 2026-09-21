---
id: 04-final-capstone
title: "Capstone: a complete project"
order: 4
section: 07-real-world
language: sql
summary: "Build a small sales-tracking system end to end"
tags: [capstone, project, practice, final]
---

# Capstone: a complete project

Put the whole course together: design a schema, load data, write the
reporting queries, and make them fast. The running example: a small
sales-tracking system.

## 1. Schema

```sql
CREATE TABLE Customers (
    CustomerID  INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName NVARCHAR(120) NOT NULL,
    City        NVARCHAR(80)  NULL,
    Active      BIT NOT NULL DEFAULT 1
);

CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(120) NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    CategoryID  INT NULL REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT NOT NULL REFERENCES Customers(CustomerID),
    OrderDate   DATE NOT NULL,
    Status      NVARCHAR(20) NOT NULL DEFAULT N'Open'
                CHECK (Status IN (N'Open', N'Shipped', N'Cancelled'))
);

CREATE TABLE OrderItems (
    OrderID    INT NOT NULL REFERENCES Orders(OrderID),
    LineNo     INT NOT NULL,
    ProductID  INT NOT NULL REFERENCES Products(ProductID),
    Quantity   INT NOT NULL CHECK (Quantity > 0),
    UnitPrice  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, LineNo)
);
```

## 2. Seed

```sql
INSERT INTO Customers (CompanyName, City) VALUES
    (N'Acme', N'Lisbon'), (N'Globex', N'Porto');

INSERT INTO Products (ProductName, UnitPrice) VALUES
    (N'Laptop', 900.00), (N'Monitor', 250.00), (N'Keyboard', 45.00);

INSERT INTO Orders (CustomerID, OrderDate, Status) VALUES
    (1, '2025-03-01', N'Shipped'), (1, '2025-03-02', N'Open'),
    (2, '2025-03-03', N'Open');

INSERT INTO OrderItems (OrderID, LineNo, ProductID, Quantity, UnitPrice) VALUES
    (1, 1, 1, 1, 900.00), (1, 2, 3, 2, 45.00),
    (2, 1, 2, 3, 250.00), (3, 1, 1, 1, 900.00);
```

> [!note] Check your constraints as you go — each INSERT should now honor
> the FK/CHECK/IDENTITY rules you wrote.

## 3. A core view

```sql
CREATE VIEW dbo.vwOrderTotals AS
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.Status,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalAmount
FROM Orders o
LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.Status;
```

## 4. Reporting

```sql
WITH Totals AS (SELECT * FROM dbo.vwOrderTotals)
SELECT
    c.CompanyName,
    COUNT(t.OrderID)                    AS Orders,
    ISNULL(SUM(t.TotalAmount), 0)       AS Revenue,
    COALESCE(MAX(t.OrderDate), CAST('9999-01-01' AS date)) AS LastOrder
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
LEFT JOIN Totals t ON t.OrderID = o.OrderID
GROUP BY c.CompanyName
ORDER BY Revenue DESC;
```

## 5. Performance check

```sql
SET STATISTICS IO ON;
SELECT * FROM vwOrderTotals WHERE CustomerID = 1;

CREATE INDEX IX_OrderItems_Order ON OrderItems (OrderID);
-- re-run: fewer reads if the join seeks instead of scans
```

## 6. The final pass — questions to answer

- Are all the keys, defaults, and checks in place?
- Do the reports use sargable predicates?
- Do the aggregates reflect reality (no double-count from two one-to-many
  joins)?
- Would `MERGE` or `INSERT ... SELECT` work for loading more rows?

> [!key] You have the full stack now
> Schema → constraints → queries → views → aggregates → indexes → reporting
> → backups → security. That is a "zero to hero" SQL Server course. Ship it.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which constraint protects a negative price in the capstone schema?"
    type: single
    choices: ["FOREIGN KEY", "CHECK (UnitPrice >= 0)", "UNIQUE", "DEFAULT"]
    answer: [1]
    explanation: "A CHECK constraint rejects negative prices."
    difficulty: 1
  - id: q2
    prompt: "Why is a composite primary key used on OrderItems?"
    type: single
    choices:
      - "It is faster"
      - "An order can have several lines"
      - "It stores NULLs"
      - "To avoid indexes"
    answer: [1]
    explanation: "(OrderID, LineNo) identifies each line within an order."
    difficulty: 2
  - id: q3
    prompt: "Which index supports fast per-order lookups?"
    type: single
    choices:
      - "INDEX ON OrderItems (OrderID)"
      - "INDEX ON Orders (OrderDate)"
      - "INDEX ON Customers (City)"
      - "INDEX ON Products (ProductName)"
    answer: [0]
    explanation: "OrderItems.OrderID is the join key for order line lookups."
    difficulty: 2
  - id: q4
    prompt: "What does validating the schema's data give you at this stage?"
    type: single
    choices:
      - "Slower loading"
      - "Confidence the model stays honest"
      - "Larger files"
      - "Nothing"
    answer: [1]
    explanation: "Constraints stop bad data at the gate, keeping totals trustworthy."
    difficulty: 1
```