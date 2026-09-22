---
id: 05-part-practice
title: "Part 0 Practice"
order: 5
section: 00-foundations
language: sql
summary: "Review and exam questions for the Foundations part"
tags: [practice, exam, review]
---

# Part 0 Practice

## Section review

You've covered the foundations:

- **SQL Server anatomy** — the engine hosts databases; T-SQL is Microsoft's
  SQL dialect; DQL/DML/DDL/DCL/TCL classes of statements.
- **Relational model** — tables are unordered sets of rows; primary and
  foreign keys give integrity and structure.
- **First query** — `USE` picks the database, two-part names are
  `schema.object`, `SELECT` returns result sets.
- **Data types** — exact numerics (`INT`, `DECIMAL`) for keys/money,
  `NVARCHAR` for text, `DATETIME2` for timestamps, NULL for unknown.

```sql
SELECT
    DB_NAME()                              AS current_database,
    CAST(19.99 AS DECIMAL(10,2))           AS price,
    N'SQL Server'                          AS engine_name;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which statement type changes table data?"
    type: single
    choices:
      - "SELECT"
      - "INSERT"
      - "CREATE"
      - "GRANT"
    answer: [1]
    explanation: "INSERT, UPDATE, DELETE, and MERGE are data modification (DML)."
    difficulty: 1
  - id: q2
    prompt: "A table is best described as which mathematical structure?"
    type: single
    choices:
      - "A list ordered by insertion"
      - "An unordered set of rows"
      - "A tree of records"
      - "A linked list of cells"
    answer: [1]
    explanation: "Tables are relations: unordered sets of rows with defined columns."
    difficulty: 2
  - id: q3
    prompt: "Which column type best stores a product's unit price?"
    type: single
    choices:
      - "FLOAT"
      - "DECIMAL(10,2)"
      - "NVARCHAR(12)"
      - "REAL"
    answer: [1]
    explanation: "DECIMAL gives exact fixed-point arithmetic suitable for money."
    difficulty: 1
  - id: q4
    prompt: "What does a foreign key guarantee?"
    type: single
    choices:
      - "Values are unique across the table"
      - "Values reference a valid primary key in another table"
      - "The column never contains NULL"
      - "The column is indexed"
    answer: [1]
    explanation: "A foreign key enforces that its values exist in the referenced table's key."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "What is the default schema for objects in SQL Server?"
    type: single
    choices: ["dbo", "public", "sys", "master"]
    answer: [0]
    explanation: "Objects are placed in dbo unless another schema is given."
    weight: 2
    section: 00-foundations
  - prompt: "Why should money columns use DECIMAL rather than FLOAT?"
    type: single
    choices:
      - "DECIMAL is faster to sort"
      - "FLOAT is approximate and can round money incorrectly"
      - "DECIMAL supports NULL"
      - "FLOAT cannot store negative numbers"
    answer: [1]
    explanation: "FLOAT is binary floating point; DECIMAL is exact, so currency stays exact."
    weight: 2
    section: 00-foundations
  - prompt: "Which data type supports Unicode text?"
    type: single
    choices: ["VARCHAR", "CHAR", "NVARCHAR", "TEXT"]
    answer: [2]
    explanation: "NVARCHAR stores Unicode; VARCHAR stores a single-byte code page."
    weight: 2
    section: 00-foundations
  - prompt: "What does NULL represent in a table column?"
    type: single
    choices: ["Zero", "An empty string", "Unknown or missing", "The default value"]
    answer: [2]
    explanation: "NULL is a special marker meaning the value is unknown or not supplied."
    weight: 2
    section: 00-foundations
```
