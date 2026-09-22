---
id: 05-security
title: "Security: logins, users, roles"
order: 5
section: 06-performance-admin
language: sql
summary: "Server logins vs database users, roles, GRANT/DENY"
tags: [security, logins, users, roles, grants]
---

# Security: logins, users, roles

Security in SQL Server has two layers: **server** and **database**.

## Two levels to remember

- **Login** (server-level) — who can connect to the instance.
- **User** (database-level) — mapped from a login, owns what they can do
  inside a database.

```sql
-- server: create a login
CREATE LOGIN app_user WITH PASSWORD = 'StrongPassw0rd!';

-- database: map a user to it
USE Shop;
CREATE USER app_user FOR LOGIN app_user;
```

A login without a user can connect to the server but can't touch much.

## Role-based access control

Roles bundle permissions. Built-ins:

- `db_datareader` — SELECT in every table.
- `db_datawriter` — INSERT/UPDATE/DELETE.
- `db_owner` — full control (use sparingly).
- `public` — default, close to nothing.

```sql
USE Shop;
EXEC sp_addrolemember N'db_datareader', N'app_user';
```

App accounts normally get **least privilege**: reader + the procs they need.

## GRANT / DENY / REVOKE

```sql
GRANT SELECT ON dbo.Orders TO app_user;

GRANT EXECUTE ON dbo.GetOrders TO app_user;

DENY DELETE ON dbo.Orders TO app_user;
```

- `GRANT` hands permission.
- `DENY` explicitly forbids — it **wins** over a container-level GRANT.
- `REVOKE` removes the DENY or GRANT.

> [!key] DENY beats GRANT
> If a role grants SELECT but a user has DENY SELECT, they cannot read.
> That makes DENY great for carve-outs, and a gotcha for shared roles.

## Schema and ownership

Schemas separate objects and per-schema rights:

```sql
CREATE SCHEMA hr;
CREATE USER hr_writer IN schema hr?  -- alias-trick only inside CREATE
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::hr TO hr_app;
```

Then `hr.Employees` lives in the `hr` schema, governed by
`SCHEMA::hr` privileges.

> [!tip] Applications talk to procs, not tables
> The most maintainable pattern: grant `EXECUTE` on the stored procedures
> an app needs, keep tables off-limits to it. Fewer moving parts to audit.

## Passwords and policy

- Use strong passwords and `CHECK_POLICY = ON` (default).
- Consider **windows/AD auth**, Azure AD, or managed identities where
  possible — fewer secrets to store.
- Rotate sql-auth secrets; store them in a vault, not the app binary.

## Auditing the minimum

```sql
-- who are my users?
SELECT name, type_desc FROM sys.database_principals
WHERE type IN ('S','U');

-- what does a role contain?
EXEC sp_helprolemember N'db_datareader';
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Where does a LOGIN exist?"
    type: single
    choices:
      - "In a database"
      - "At the server level"
      - "Inside a view"
      - "In the role only"
    answer: [1]
    explanation: "Logins are server objects; users are database objects mapped to them."
    difficulty: 2
  - id: q2
    prompt: "Which built-in role can read all tables?"
    type: single
    choices: ["db_owner", "db_datareader", "public", "sysadmin"]
    answer: [1]
    explanation: "db_datareader grants SELECT across the database's tables."
    difficulty: 1
  - id: q3
    prompt: "What wins when a role grants SELECT but the user has DENY SELECT?"
    type: single
    choices: ["GRANT wins", "DENY wins", "It depends on order", "Neither"]
    answer: [1]
    explanation: "DENY always overrides GRANT from roles or elsewhere."
    difficulty: 2
  - id: q4
    prompt: "What is the least-privilege principle?"
    type: single
    choices:
      - "Give everyone everything"
      - "Give each account the minimum it needs"
      - "Use only sysadmin"
      - "Disable all logins"
    answer: [1]
    explanation: "Least privilege limits blast radius and simplifies audits."
    difficulty: 1
```