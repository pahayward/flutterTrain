---
id: 06-part-practice
title: "Part 6 Practice"
order: 6
section: 06-performance-admin
language: sql
summary: "Review and exam questions for the Performance part"
tags: [practice, exam, review]
---

# Part 6 Practice

## Section review

You've leveled up from writing queries to making them fast and safe:

- **Execution plans** — operators, scans vs seeks, lookups; the biggest %
  is usually the best target.
- **Sargable predicates** — keep the column bare; date ranges, prefix LIKE,
  aligned types.
- **Locking/isolation** — locks, blocking, deadlock victim handling;
  isolation-level trade-offs; SNAPSHOT for reporting.
- **Backup/restore** — FULL/DIFF/LOG types, recovery models, RPO/RTO,
  verified restores.
- **Security** — login vs user, roles, GRANT/DENY/REVOKE, least privilege.

```sql
-- happy path: sargable, seekable, well-indexed
SELECT o.OrderID
FROM Orders o
WHERE o.OrderDate >= '2025-01-01'
  AND o.OrderDate <  '2025-02-01'
  AND o.CustomerID = 17;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does a Table Scan in a plan mean?"
    type: single
    choices:
      - "The engine found an index"
      - "It read every row"
      - "The query is parallel"
      - "It ran on a snapshot"
    answer: [1]
    explanation: "A scan reads all data looking for matches — costly at scale."
    difficulty: 1
  - id: q2
    prompt: "Which rewrite preserves the same result but is sargable?"
    type: single
    choices:
      - "WHERE YEAR(d) = 2025"
      - "WHERE d >= '2025-01-01' AND d < '2026-01-01'"
      - "WHERE CONVERT(int, d) = 2025"
      - "WHERE d LIKE '%2025%'"
    answer: [1]
    explanation: "A bare date column with range bounds lets the index seek."
    difficulty: 2
  - id: q3
    prompt: "Which builds on the previous isolation for reporting?"
    type: single
    choices:
      - "READ UNCOMMITTED (consistency risk)"
      - "SNAPSHOT (row-versioned, no write blocking)"
      - "SERIALIZABLE (heavy locks)"
      - "REPEATABLE READ (holds locks)"
    answer: [1]
    explanation: "Snapshots read consistent data without blocking writers."
    difficulty: 2
  - id: q4
    prompt: "Which grants least-privilege table reads to an app user?"
    type: single
    choices: ["db_owner", "db_datareader", "sysadmin", "public"]
    answer: [1]
    explanation: "db_datareader is read-only across tables — minimal for readers."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which operator reads whole rows when an index exists elsewhere?"
    type: single
    choices: ["Index Seek", "Table Scan", "Key Lookup", "Hash Match"]
    answer: [1]
    explanation: "A table scan reads every row instead of seeking."
    weight: 2
    section: 06-performance-admin
  - prompt: "What is the consequence of WHERE Function(col) = x?"
    type: single
    choices: ["Faster seeks", "Scans because the column is wrapped", "Syntax is invalid", "No statistics"]
    answer: [1]
    explanation: "Function-wrapped columns resist index seeks."
    weight: 3
    section: 06-performance-admin
  - prompt: "Which isolation level enables dirty reads?"
    type: single
    choices: ["READ COMMITTED", "SNAPSHOT", "READ UNCOMMITTED", "SERIALIZABLE"]
    answer: [2]
    explanation: "READ UNCOMMITTED can read rows not yet committed."
    weight: 2
    section: 06-performance-admin
  - prompt: "What does BACKUP LOG require?"
    type: single
    choices: ["SIMPLE recovery model", "FULL or BULK_LOGGED recovery model", "A differential first", "Enterprise edition"]
    answer: [1]
    explanation: "Log backups only exist when the recovery model preserves the log."
    weight: 2
    section: 06-performance-admin
  - prompt: "Which wins: role GRANT SELECT vs user DENY SELECT?"
    type: single
    choices: ["GRANT", "DENY", "Depends on order", "Neither"]
    answer: [1]
    explanation: "DENY always outranks a granting role."
    weight: 2
    section: 06-performance-admin
```
