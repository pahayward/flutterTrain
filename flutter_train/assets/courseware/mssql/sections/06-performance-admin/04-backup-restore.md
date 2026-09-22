---
id: 04-backup-restore
title: "Backup and restore"
order: 4
section: 06-performance-admin
language: sql
summary: "Backup types, RESTORE basics, recovery models, RPO/RTO"
tags: [backup, restore, recovery, admin]
---

# Backup and restore

Backups answer the question "what happens when the disk dies?" — your
database survives only if the backup strategy is tested.

## Backup types

| Type | Contents | Used for |
|---|---|---|
| **Full** | entire database | baseline |
| **Differential** | changes since last full | smaller steps |
| **Transaction log** | log since last log/full backup | point-in-time restore |

RPO (how much data you can lose) and RTO (how fast you must be back) drive
the schedule: full + differentials daily, log backups every few minutes for
minimal loss.

```sql
BACKUP DATABASE Shop TO DISK = 'D:\backups\Shop.bak'
WITH INIT, COMPRESSION;

BACKUP DATABASE Shop TO DISK = 'D:\backups\Shop_diff.bak'
WITH DIFFERENTIAL;

BACKUP LOG Shop TO DISK = 'D:\backups\Shop_log.trn';
```

> [!tip] COMPRESSION shrinks files a lot
> `WITH COMPRESSION` costs a little CPU but usually shrinks backup size
> several fold. On by default in Enterprise/Developer.

## Recovery models

- **FULL** — log is preserved → point-in-time restore possible. Required for
  `BACKUP LOG`.
- **SIMPLE** — log auto-truncates → no log backups; restore is full/diff only.
- **BULK_LOGGED** — like full, but big operations log minimally.

Choose FULL for production data you care about; SIMPLE for scrap/scratch.

## Restore

```sql
RESTORE DATABASE Shop
FROM DISK = 'D:\backups\Shop.bak'
WITH REPLACE;

-- point in time, after log restore
RESTORE LOG Shop FROM DISK = 'D:\backups\Shop_log.trn'
WITH STOPAT = '2025-06-01T10:30:00';
```

> [!warning] Restoring to a live DB overwrites it
> `WITH REPLACE` destroys the target's current content. Restore to a *test*
> database first when in doubt.

```sql
-- to a new name/nor on same instance
RESTORE DATABASE Shop_Test
FROM DISK = 'D:\backups\Shop.bak'
WITH MOVE 'Shop_data' TO 'D:\data\Shop_test.mdf',
     MOVE 'Shop_log'  TO 'D:\data\Shop_test_log.ldf';
```

## Verify, verify, verify

A backup you never restored is a rumor. Regularly test a restore into a
scratch database and run `RESTORE VERIFYONLY`:

```sql
RESTORE VERIFYONLY FROM DISK = 'D:\backups\Shop.bak';
```

> [!key] Test restores are part of the job
> The goal is not "we have backups"; it is "we have restore we trust."

## Backup cadence summary

- Nightly **full** + **differential** most days.
- **Log** every few minutes (full recovery).
- Confirm **RPO/RTO** match the business.
- Off-site a copy; watch for retention of daily/weekly/monthly.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which backup type captures only changes since the last full?"
    type: single
    choices: ["Full", "Differential", "Transaction log", "Verify"]
    answer: [1]
    explanation: "A differential backs up data changed since the last full backup."
    difficulty: 1
  - id: q2
    prompt: "What does the recovery model FULL enable?"
    type: single
    choices:
      - "RESTORE VERIFYONLY"
      - "Transaction log backups and point-in-time restore"
      - "Compression"
      - "Encryption only"
    answer: [1]
    explanation: "FULL preserves the log, enabling log backups and STOPAT."
    difficulty: 2
  - id: q3
    prompt: "What is the difference between RPO and RTO?"
    type: single
    choices:
      - "RPO = data you may lose; RTO = how fast to recover"
      - "They are synonyms"
      - "RPO = speed; RTO = data loss"
      - "Both measure backup size"
    answer: [0]
    explanation: "RPO is acceptable data loss; RTO is acceptable recovery time."
    difficulty: 2
  - id: q4
    prompt: "Why restore into a test database regularly?"
    type: single
    choices:
      - "It makes backups faster"
      - "It proves the restore path actually works"
      - "It frees disk space"
      - "It is required by licensing"
    answer: [1]
    explanation: "Only a practiced restore proves the backups are usable."
    difficulty: 1
```