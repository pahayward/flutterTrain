---
id: 01-sqlite3
title: Database programming with sqlite3
order: 1
section: 05-file-processing
language: python
type: lesson
summary: Connect to SQLite databases, create tables, perform CRUD operations, and manage transactions using the sqlite3 module.
tags: [sqlite3, database, sql, transactions]
---

# Database Programming with sqlite3

Python's built-in `sqlite3` module lets you work with SQLite databases — a lightweight, file-based (or in-memory) relational database engine. No external packages needed.

> [!key] Why sqlite3?
SQLite is ideal for local data storage, prototyping, and mobile apps. The `sqlite3` module is part of the Python stdlib and maps closely to the DB-API 2.0 specification (PEP 249).

## Connecting to a Database

Use `sqlite3.connect()` to open (or create) a database. Pass `":memory:"` for a temporary in-memory database.

```python
import sqlite3

conn = sqlite3.connect(":memory:")
print("Connected successfully")

conn.close()
```

> [!tip] Always close your connection
Use `conn.close()` or a context manager (`with`) to ensure resources are released.

## Creating Tables and Inserting Data

After connecting, obtain a `Cursor` object and call `execute()` with a `CREATE TABLE` statement, then insert rows with `INSERT`.

```python
import sqlite3

conn = sqlite3.connect(":memory:")
cur = conn.cursor()

cur.execute("""
    CREATE TABLE students (
        id    INTEGER PRIMARY KEY,
        name  TEXT NOT NULL,
        grade INTEGER
    )
""")

cur.execute("INSERT INTO students (name, grade) VALUES (?, ?)", ("Alice", 92))
cur.execute("INSERT INTO students (name, grade) VALUES (?, ?)", ("Bob", 85))

conn.commit()
print("Inserted 2 rows")

cur.execute("SELECT * FROM students")
print(cur.fetchall())

conn.close()
```

> [!warning] Always use parameter placeholders (`?`)
Never use f-strings or `%` formatting to build SQL. Parameterized queries protect against SQL injection.

## executemany — Batch Inserts

`executemany()` executes a single SQL statement against every item in a sequence of parameters.

```python
import sqlite3

conn = sqlite3.connect(":memory:")
cur = conn.cursor()

cur.execute("CREATE TABLE scores (id INTEGER PRIMARY KEY, val REAL)")
rows = [(10.5,), (20.0,), (30.5,), (40.0,)]
cur.executemany("INSERT INTO scores (val) VALUES (?)", rows)
conn.commit()

cur.execute("SELECT * FROM scores")
print(cur.fetchall())

conn.close()
```

## SELECT — Fetching Data

Three fetch methods exist on a cursor after `execute()`:

| Method | Returns |
|---|---|
| `fetchone()` | Next single row, or `None` |
| `fetchmany(n)` | List of up to `n` rows |
| `fetchall()` | List of all remaining rows |

```python
import sqlite3

conn = sqlite3.connect(":memory:")
cur = conn.cursor()

cur.execute("CREATE TABLE items (name TEXT, price REAL)")
for item, price in [("Pen", 1.5), ("Book", 12.0), ("Bag", 25.0)]:
    cur.execute("INSERT INTO items VALUES (?, ?)", (item, price))
conn.commit()

cur.execute("SELECT name, price FROM items WHERE price > 10")
for row in cur.fetchall():
    print(f"{row[0]}: ${row[1]}")

conn.close()
```

## UPDATE and DELETE

```python
import sqlite3

conn = sqlite3.connect(":memory:")
cur = conn.cursor()

cur.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, active INTEGER)")
cur.execute("INSERT INTO users (name, active) VALUES (?, ?)", ("Alice", 1))
cur.execute("INSERT INTO users (name, active) VALUES (?, ?)", ("Bob", 0))
conn.commit()

cur.execute("UPDATE users SET active = 1 WHERE name = 'Bob'")
print(f"Rows updated: {cur.rowcount}")

cur.execute("DELETE FROM users WHERE active = 0")
print(f"Rows deleted: {cur.rowcount}")

cur.execute("SELECT * FROM users")
print(cur.fetchall())

conn.close()
```

> [!note] `rowcount`
After `execute()` for DML statements, `cursor.rowcount` tells you how many rows were affected.

## Transaction Demarcation

SQLite uses implicit transactions. You **must** call `conn.commit()` to persist changes, or `conn.rollback()` to undo them.

```python
import sqlite3

conn = sqlite3.connect(":memory:")
cur = conn.cursor()

cur.execute("CREATE TABLE ledger (id INTEGER PRIMARY KEY, amount REAL)")
cur.execute("INSERT INTO ledger (amount) VALUES (100)")
conn.rollback()

cur.execute("SELECT * FROM ledger")
print("After rollback:", cur.fetchall())

cur.execute("INSERT INTO ledger (amount) VALUES (200)")
conn.commit()
cur.execute("SELECT * FROM ledger")
print("After commit:", cur.fetchall())

conn.close()
```

> [!trap] Autocommit is OFF by default
If you forget `commit()`, changes are lost when the connection closes.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which string tells sqlite3.connect() to create an in-memory database?"
    type: single
    choices: ["\":memory:\"", "\"temp\"", "\"file::memory:\"", "\"none\""]
    answer: [0]
    explanation: "The special string \":memory:\" creates a temporary in-memory database."
    difficulty: 1
  - id: q2
    prompt: "What does cursor.rowcount return after a successful UPDATE?"
    type: single
    choices: ["The number of columns in the table", "The number of rows modified", "The total number of rows in the table", "1 if any row was modified"]
    answer: [1]
    explanation: "rowcount holds the number of rows affected by the last DML statement."
    difficulty: 1
  - id: q3
    prompt: "Which method executes one SQL statement against every item in a sequence?"
    type: single
    choices: ["execute()", "executemany()", "fetchmany()", "executescript()"]
    answer: [1]
    explanation: "executemany() takes an SQL statement and a sequence of parameter sets."
    difficulty: 2
  - id: q4
    prompt: "Why should you use parameter placeholders (?) instead of f-strings in SQL?"
    type: single
    choices: ["f-strings are slower", "To prevent SQL injection", "f-strings don't work with sqlite3", "Parameter placeholders auto-commit"]
    answer: [1]
    explanation: "Parameterized queries let the DB engine separate SQL from data, preventing injection attacks."
    difficulty: 2
  - id: q5
    prompt: "What happens to uncommitted changes when you call conn.rollback()?"
    type: single
    choices: ["They are permanently saved", "They are undone", "They are committed automatically", "An error is raised"]
    answer: [1]
    explanation: "rollback() undoes all changes since the last commit, restoring the previous transaction state."
    difficulty: 1
```
