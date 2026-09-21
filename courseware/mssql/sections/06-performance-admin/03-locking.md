---
id: 03-locking
title: "Locking, blocking, and isolation"
order: 3
section: 06-performance-admin
language: sql
summary: "Lock granularity, deadlocks, isolation levels, blocking"
tags: [locking, deadlock, isolation, blocking]
---

# Locking, blocking, and isolation

Concurrency and correctness both hang off how SQL Server manages locks.

## Locks and their sizes

The engine takes locks to protect data during changes:

- **Row / Key** — smallest, most concurrency.
- **Page** — 8 KB unit.
- **Table** — whole table (schema alter, large ops).
- **Escalation** — many row locks can escalate to a table lock.

Shared (S) locks protect reads; exclusive (X) locks own writes. Writer waits
for readers and vice versa — that wait is **blocking**.

## Blocking

When session A holds a lock and B needs the incompatible one, B waits
(WAIT type shows up in `sys.dm_exec_requests`).

```sql
-- who is blocking whom
SELECT
    r.session_id,
    blocked.session_id AS BlockedBy,
    r.command,
    r.wait_type
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_requests blocked ON blocked.blocking_session_id = r.session_id;
```

> [!key] Blocking ≠ deadlock
> Blocking resolves when the lock is released. Deadlock = two sessions wait
> on each other; the engine picks a victim and kills it.

## Deadlocks

```sql
-- classic: A holds Row1 wants Row2; B holds Row2 wants Row1
```

Diagnose with `SET DEADLOCK_PRIORITY` experiments and trace flags / Extended
Events. Fixes:

1. Consistent **access order** in all transactions.
2. Keep transactions short.
3. Use the same indexes / search paths everywhere.

## Isolation levels recap

| Level | Sees own tx | Sees committed only | Blocks phones |
|---|---|---|---|
| READ UNCOMMITTED | yes | no (dirty reads) | no |
| READ COMMITTED (default) | yes | yes | blocks writes while reading |
| REPEATABLE READ | yes | yes | holds read locks |
| SNAPSHOT | yes (row versioning) | yes | no write blocks |
| SERIALIZABLE | yes | yes | locks ranges |

```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
```

SNAPSHOT reads a consistent version without blocking writers — the reason
reporting workloads love it. Set it with `ALLOW_SNAPSHOT_ISOLATION ON` on the
database first.

> [!trap] READ UNCOMMITTED / NOLOCK
> They read uncommitted rows — your report can include data that later
> ROLLBACKs. Use row-versioning isolation instead.

## The three concurrency bugs

- **Dirty read** — reading uncommitted data (READ UNCOMMITTED).
- **Non-repeatable read** — same row, same tx, different value (default
  level risk).
- **Phantom** — new rows slip into a range between reads (SERIALIZABLE
  prevents).

## Practical advice

- Keep transactions **short** (few statements, no UI round-trips inside).
- Choose the **least strict isolation** that returns correct data.
- Handle deadlock victims with retry in the app.
- Index properly: missing indexes cause big scans that block longer.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is blocking?"
    type: single
    choices:
      - "Two sessions waiting on each other forever"
      - "One session waiting for another's lock to release"
      - "A corrupted page"
      - "A deadlock victim chose before"
    answer: [1]
    explanation: "Blocking is a wait for an incompatible held lock; it ends when released."
    difficulty: 1
  - id: q2
    prompt: "What best distinguishes a deadlock?"
    type: single
    choices:
      - "It resolves automatically"
      - "Two sessions wait on each other, so the engine kills a victim"
      - "It only reads data"
      - "It is caused by a missing index"
    answer: [1]
    explanation: "Deadlock = circular wait; the engine selects a victim to break it."
    difficulty: 2
  - id: q3
    prompt: "Which isolation allows reading uncommitted rows?"
    type: single
    choices: ["READ COMMITTED", "READ UNCOMMITTED", "SNAPSHOT", "SERIALIZABLE"]
    answer: [1]
    explanation: "READ UNCOMMITTED allows dirty reads; SNAPSHOT offers consistent versions instead."
    difficulty: 1
  - id: q4
    prompt: "Which is good advice for concurrency?"
    type: single
    choices:
      - "Keep transactions as long as possible"
      - "Keep a consistent lock order and short transactions"
      - "Always use table locks"
      - "Never use indexes"
    answer: [1]
    explanation: "Consistent lock order and short transactions reduce blocking and deadlocks."
    difficulty: 2
```