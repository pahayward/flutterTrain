---
id: 03-first-query
title: "Your first query: databases and tools"
order: 3
section: 00-foundations
language: sql
summary: "Connecting to an instance, choosing a database, running SELECT"
tags: [ssms, select, database, get-started]
---

# Your first query

Let's connect, pick a database, and run your first real query. The SQL is
the same everywhere; the tools just make it comfortable.

## Connect to an instance

- **SSMS**: File → New → Database Engine Query, enter `localhost` (or
  a server name), Connect. You now have a query window.
- **Azure Data Studio**: same idea, cross-platform.
- **`sqlcmd`**: the command-line client.

```bash
sqlcmd -S localhost -E
```

## Pick a database

An instance hosts many databases. The current database matters: `SELECT * FROM
Customers` resolves against the *current* database's `Customers`.

```sql
USE AdventureWorks2022;   -- switch current database
GO
```

> [!tip] `GO` is not T-SQL
> `GO` is a batch separator understood by SSMS/sqlcmd, not by the engine. Use
> it between batches in the tools; it is not part of the SELECT language.

> [!trap] dbo.MissingTable
> If a table "does not exist", first check which database you are in. The most
> common beginner error is querying `master` instead of the business database.

## A real first query

```sql
SELECT TOP 10
    BusinessEntityID,
    FirstName,
    LastName
FROM Person.Person;
```

Returns ten people. `Person.Person` is a **two-part name** — schema `Person`,
table `Person`.

- The **schema** is a namespace (folder) of objects.
- The default schema is `dbo`; `dbo.Customers` means the `Customers` table in
  `dbo`.

## Diagnostic trio

```sql
SELECT @@VERSION;                 -- engine version (a system function)
SELECT DB_NAME();                 -- current database name
SELECT * FROM sys.tables;         -- every user table in this database
```

> [!key] `sys.*` catalog views
> The engine keeps its own metadata in views like `sys.tables`,
> `sys.columns`, `sys.indexes`. Reading them is how you inspect a database.

## How SELECT reaches the engine

1. Parser — validates syntax.
2. Binding — matches names to real objects (errors like "invalid column
   name" appear here).
3. Optimization — builds an execution plan (Part 6).
4. Execution — returns a result set.

```sql
-- Everything is a query; the result set is just a table.
SELECT
    'Hello'          AS Word,
    7 * 6            AS Answer,
    DB_NAME()        AS CurrentDatabase;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does the USE statement do?"
    type: single
    choices:
      - "Creates a new database"
      - "Switches the current database"
      - "Grants permissions"
      - "Starts a transaction"
    answer: [1]
    explanation: "USE changes which database the session's queries run against."
    difficulty: 1
  - id: q2
    prompt: "In Person.Person, what is the first part called?"
    type: single
    choices:
      - "A database"
      - "An alias"
      - "A schema"
      - "An owner role"
    answer: [2]
    explanation: "Two-part names are schema.object; Person is the schema."
    difficulty: 2
  - id: q3
    prompt: "What is the default schema when none is specified?"
    type: single
    choices:
      - "admin"
      - "public"
      - "dbo"
      - "data"
    answer: [2]
    explanation: "Objects without an explicit schema live in dbo by default."
    difficulty: 1
  - id: q4
    prompt: "Which catalog view lists the user tables in a database?"
    type: single
    choices:
      - "sys.tables"
      - "sys.objects_only"
      - "information.views"
      - "master.tables"
    answer: [0]
    explanation: "sys.tables is the catalog view of user tables."
    difficulty: 2
```