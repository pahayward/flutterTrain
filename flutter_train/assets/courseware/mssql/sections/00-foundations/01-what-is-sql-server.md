---
id: 01-what-is-sql-server
title: "What is SQL Server and T-SQL"
order: 1
section: 00-foundations
language: sql
summary: "SQL Server editions, databases, and the T-SQL language"
tags: [sql-server, tsql, database, overview]
---

# What is SQL Server and T-SQL

**Microsoft SQL Server** is a relational database management system (RDBMS).
You write queries in **T-SQL** (Transact-SQL) — Microsoft's extension of the
standard SQL language — to read, create, and manage data.

## The pieces

- **SQL Server engine** — the service that stores data and processes queries.
- **Database** — a logical container of tables, views, procedures, and more.
- **T-SQL** — the language used to talk to the engine.
- **Tools** — SQL Server Management Studio (SSMS), Azure Data Studio, `sqlcmd`.

> [!key] A database ≠ SQL Server
> One SQL Server instance can host many databases. Each has its own tables,
> its own security, and often its own applications.

## Editions you will meet

- **Developer** — full-featured, free for development and testing.
- **Standard** — common for production web/line-of-business workloads.
- **Enterprise** — adds advanced features: high availability, partitioning,
  in-memory OLTP, parallel scanning.
- **Express** — free, small (10 GB per database limit).
- **Azure SQL Database** — the managed cloud version, near-identical T-SQL.

> [!note] The course targets syntax
> Everything in this course runs identically on Developer, Standard,
> Express, and most Azure SQL Database tiers. "MS SQL Server focused" means
> T-SQL, not MySQL or PostgreSQL.

## T-SQL flavors of statement

| Category | Purpose | Examples |
|---|---|---|
| DQL | Read data | `SELECT` |
| DML | Modify data | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| DDL | Define schema | `CREATE`, `ALTER`, `DROP` |
| DCL | Control permissions | `GRANT`, `DENY`, `REVOKE` |
| TCL | Manage transactions | `BEGIN TRAN`, `COMMIT`, `ROLLBACK` |

## Hello T-SQL

```sql
SELECT 'Hello, SQL Server!' AS greeting;
```

One query, one result set, one row:

| greeting |
|---|
| Hello, SQL Server! |

You'll spend 90% of your time on `SELECT` — reading data the right way.
Most of this course is about making `SELECT` statements precise and fast.

> [!tip] T-SQL is case-insensitive
> `select`, `SELECT`, and `Select` are the same. Uppercasing keywords is a
> convention for readability, not a requirement.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which statement category does SELECT belong to?"
    type: single
    choices:
      - "DML"
      - "DDL"
      - "DQL"
      - "DCL"
    answer: [2]
    explanation: "SELECT reads data, so it is data query language (DQL)."
    difficulty: 1
  - id: q2
    prompt: "What is T-SQL?"
    type: single
    choices:
      - "The MySQL dialect"
      - "Microsoft's extension of standard SQL"
      - "A GUI tool for editing tables"
      - "A NoSQL query language"
    answer: [1]
    explanation: "Transact-SQL is Microsoft's proprietary extension of standard SQL."
    difficulty: 1
  - id: q3
    prompt: "Which edition is free and full-featured for development use?"
    type: single
    choices:
      - "Enterprise"
      - "Standard"
      - "Developer"
      - "Express"
    answer: [2]
    explanation: "Developer edition is free to develop and test with and has all Enterprise features."
    difficulty: 2
```