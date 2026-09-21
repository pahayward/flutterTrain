---
id: 02-identity
title: "IDENTITY and SEQUENCE"
order: 2
section: 04-ddl-schema
language: sql
summary: "Auto-incrementing keys, seeds, and the SEQUENCE object"
tags: [identity, sequence, keys, ddl]
---

# IDENTITY and SEQUENCE

Auto-generated numeric keys are the most common primary key pattern.

## IDENTITY

```sql
CREATE TABLE Customers (
    CustomerID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CompanyName NVARCHAR(120)     NOT NULL
);

INSERT INTO Customers (CompanyName) VALUES (N'Acme');   -- ID 1
INSERT INTO Customers (CompanyName) VALUES (N'Globex'); -- ID 2
```

`IDENTITY(seed, increment)` = start value and step. You never supply the
value; the engine allocates it.

> [!trap] Identity gaps are normal
> A rolled-back INSERT consumes the value anyway. Keys are meant to identify
> rows, not to be contiguous. Do not "repair" gaps.

## Reading the current value

```sql
SELECT SCOPE_IDENTITY();          -- last inserted in THIS session/scope
SELECT @@IDENTITY;                -- last inserted in THIS session (any trigger)
SELECT IDENT_CURRENT('Customers'); -- last inserted anywhere
```

- `SCOPE_IDENTITY()` — the value your own INSERT just created. Use this.
- `@@IDENTITY` — can be overridden by a trigger's insert.
- `IDENT_CURRENT()` — global latest, race-prone.

> [!key] Prefer SCOPE_IDENTITY for the new key
> `OUTPUT INSERTED.CustomerID` is even more explicit and survives multi-row
> inserts.

## Reseeding

```sql
DBCC CHECKIDENT ('Customers', RESEED, 0);
```

`DBCC CHECKIDENT` resets the identity counter — used after a TRUNCATE or
explicit re-seed, careful in production.

## SEQUENCE — identity without a table

A standalone number generator, usable by several tables or as a stateless
key factory:

```sql
CREATE SEQUENCE OrderSeq AS INT START WITH 1000 INCREMENT BY 1;

SELECT NEXT VALUE FOR OrderSeq;   -- 1000, then 1001, ...
SELECT PREVIOUS VALUE FOR OrderSeq; -- last value in this session
```

Use `NEXT VALUE FOR` in an INSERT:

```sql
INSERT INTO Orders (OrderID, CustomerID)
VALUES (NEXT VALUE FOR OrderSeq, 5);
```

| | IDENTITY | SEQUENCE |
|---|---|---|
| Scope | one table | database object |
| Triggered by | engine on insert | explicit `NEXT VALUE FOR` |
| Reuse | no | by design |
| Restart | `DBCC CHECKIDENT` | `ALTER SEQUENCE RESTART` |

> [!tip] When to pick which
> Plain single-table keys: IDENTITY. Multi-table or reusable/consolidated
> numbering (tickets across partitions, ledger batches): SEQUENCE.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does IDENTITY(1,1) mean?"
    type: single
    choices:
      - "Starts at 1, increments by 1"
      - "Starts at 0, increments by 1"
      - "Starts at 1, increments by 0"
      - "Random values from 1"
    answer: [0]
    explanation: "IDENTITY(seed, increment): first value 1, each next +1."
    difficulty: 1
  - id: q2
    prompt: "Why do identity values often have gaps?"
    type: single
    choices:
      - "An engine bug"
      - "Failed or rolled-back inserts consume values"
      - "DELETE removes them"
      - "Keys are contiguous by design"
    answer: [1]
    explanation: "Allocated values are never reused, even if the insert later rolls back."
    difficulty: 2
  - id: q3
    prompt: "Which returns YOUR session's last generated identity?"
    type: single
    choices:
      - "IDENT_CURRENT('t')"
      - "SCOPE_IDENTITY()"
      - "@@IDENTITY only"
      - "GETIDENTITY()"
    answer: [1]
    explanation: "SCOPE_IDENTITY() scopes to your current statement/session."
    difficulty: 2
  - id: q4
    prompt: "What distinguishes SEQUENCE from IDENTITY?"
    type: single
    choices:
      - "SEQUENCE is per-table only"
      - "SEQUENCE is a database object usable across tables"
      - "SEQUENCE is always BIGINT"
      - "SEQUENCE does not support START WITH"
    answer: [1]
    explanation: "A SEQUENCE is stored schema, consumed via NEXT VALUE FOR anywhere."
    difficulty: 2
```