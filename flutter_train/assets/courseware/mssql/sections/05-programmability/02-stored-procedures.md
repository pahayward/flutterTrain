---
id: 02-stored-procedures
title: "Stored procedures and parameters"
order: 2
section: 05-programmability
language: sql
summary: "Creating procs, parameters, default values, OUTPUT"
tags: [procedures, stored-procedure, parameters, ddl]
---

# Stored procedures

A stored procedure packages T-SQL into a reusable, parameterized unit.

## Why procedures

- **Reuse** — call the same logic from any app.
- **Security** — app users get `EXECUTE`, not table rights.
- **Performance** — plans reuse; reduced network chatter.
- **Maintainability** — logic lives with the database.

## Create and call

```sql
CREATE OR ALTER PROCEDURE dbo.GetOrders
    @CustomerID INT,
    @After DATE = NULL      -- optional
AS
BEGIN
    SELECT OrderID, OrderDate, TotalAmount
    FROM Orders
    WHERE CustomerID = @CustomerID
      AND (@After IS NULL OR OrderDate >= @After)
    ORDER BY OrderDate DESC;
END;
```

```sql
EXEC dbo.GetOrders @CustomerID = 5;
EXEC dbo.GetOrders @CustomerID = 5, @After = '2024-01-01';
```

> [!key] Named vs positional parameters
> Named arguments (`@CustomerID = 5`) are self-documenting and safe when you
> later add parameters. Positional values are shorter but order-dependent.

## Defaults and NULL-optional patterns

A parameter with a default is optional. The `(@After IS NULL OR ...)` guard
turns "no value passed" into "apply no filter" — a common idiom.

## OUTPUT parameters

Return computed values back to the caller:

```sql
CREATE PROCEDURE dbo.InsertCustomer
    @CompanyName NVARCHAR(120),
    @NewID INT OUTPUT
AS
BEGIN
    INSERT INTO Customers (CompanyName) VALUES (@CompanyName);
    SET @NewID = SCOPE_IDENTITY();
END;
```

```sql
DECLARE @id INT;
EXEC dbo.InsertCustomer N'Acme', @NewID = @id OUTPUT;
SELECT @id;
```

## Return codes

`RETURN n` sets an integer status:

```sql
CREATE PROCEDURE dbo.TryArchive
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        RETURN 1;           -- 0 = success, non-zero = something happened
    END
    INSERT INTO ArchiveOrders (...) SELECT ... FROM Orders WHERE OrderID = @OrderID;
    RETURN 0;
END;
```

## Avoids

- **Dynamic SQL in procs** — flexible but hard to tune and injectable; use
  parameters first.
- **SELECT * in procs** — breaks schema evolution.
- **Heavy DDL inside procs** — keep DDL mostly in migrations.

> [!tip] Encapsulation is a discipline
> Prefer procs for writes. Reads can also use views, but a procedure that
> hides `JOIN + filter + sort` gives every caller the correct shape.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How do you call a proc by named parameters?"
    type: single
    choices:
      - "CALL proc 5"
      - "EXEC proc @CustomerID = 5"
      - "RUN proc(5)"
      - "SELECT proc(5)"
    answer: [1]
    explanation: "EXEC with named args makes the call explicit and robust."
    difficulty: 1
  - id: q2
    prompt: "What does OUTPUT do in a procedure?"
    type: single
    choices:
      - "Prints to the console"
      - "Returns a scalar value to the caller"
      - "Logs the query"
      - "Enables parallelism"
    answer: [1]
    explanation: "An OUTPUT parameter hands a value back to the invoking batch."
    difficulty: 2
  - id: q3
    prompt: "What is one clear security benefit of procedures?"
    type: single
    choices:
      - "They encrypt data at rest"
      - "Users can run them without direct table access"
      - "They hide the database name"
      - "They avoid logins"
    answer: [1]
    explanation: "Grant EXECUTE only; the proc owns the underlying permissions."
    difficulty: 1
  - id: q4
    prompt: "What does @After DATE = NULL mean?"
    type: single
    choices:
      - "The parameter is required"
      - "The parameter is optional with a NULL default"
      - "The parameter only accepts NULL"
      - "A syntax error"
    answer: [1]
    explanation: "A default makes the parameter optional; callers may omit it."
    difficulty: 2
```