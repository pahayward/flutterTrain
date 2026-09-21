---
id: 05-string-functions
title: "String functions"
order: 5
section: 01-query-basics
language: sql
summary: "Case, trimming, splitting, searching, replacing text"
tags: [strings, functions, left, right, substring]
---

# String functions

T-SQL gives you a toolbox for cleaning and reshaping text.

## Case, trimming, length

```sql
SELECT
    UPPER(N'microsoft')            AS upped,     -- MICROSOFT
    LOWER(N'SQL')                  AS lowered,   -- sql
    LEN(N'hello '),                               -- 5, space trimmed on right
    LTRIM('  x'), RTRIM('x  '),                   -- remove side spaces
    TRIM('  x  ')                  AS trimmed;    -- both sides
```

`LEN` ignores trailing spaces; `DATALENGTH` gives the byte count.

## Left / right / substring

```sql
SELECT
    LEFT(N'AdventureWorks', 9)     AS first9,    -- Adventure
    RIGHT(N'AdventureWorks', 5)    AS last5,     -- Works
    SUBSTRING(N'AdventureWorks', 2, 5) AS mid,   -- dvent
    CHARINDEX(N'Works', N'AdventureWorks') AS at; -- 10
```

`CHARINDEX` finds the starting position of one string inside another; returns
0 when absent.

## Concatenation — modern way

```sql
SELECT CONCAT(N'Ada', N' ', N'Lovelace') AS fullName;
```

`CONCAT` ignores NULLs rather than propagating them (won't help arithmetic,
but it is safe for building display strings).

## Replace and things around it

```sql
SELECT
    REPLACE(N'1-800-1234', N'-', N'')       AS digits,   -- 18001234
    STUFF(N'Hello World', 7, 5, N'SQL')     AS swapped;  -- Hello SQL
```

- `REPLACE(s, old, new)` — substitute every occurrence.
- `STUFF(s, start, length, insert)` — delete *length* chars at *start* and
  insert `insert` there.

## PARSE / TRY_PARSE

Convert text to numbers or dates with culture awareness:

```sql
SELECT
    TRY_PARSE(N'12,50' AS DECIMAL(4,2) USING 'fr-FR') AS parsed,
    PARSE(N'01/02/2025' AS DATE USING 'en-GB') AS d;
```

`TRY_*` returns NULL instead of raising an error on bad input.

> [!key] Prefer STRING_AGG over manual loops
> To join row values into one string, SQL Server 2017+ offers
> `STRING_AGG`. We cover it with aggregates in Part 2.

## Cleaning a name column

```sql
SELECT
    ProductID,
    TRIM(ProductName)                    AS CleanName,
    UPPER(LEFT(ProductName, 1)) + LOWER(SUBSTRING(ProductName, 2, 500)) AS TitleCase
FROM Products
WHERE LEN(ProductName) > 0;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which function finds the position of one string inside another?"
    type: single
    choices:
      - "LOCATE"
      - "CHARINDEX"
      - "INDEX"
      - "FIND"
    answer: [1]
    explanation: "CHARINDEX returns the 1-based position, or 0 when not found."
    difficulty: 1
  - id: q2
    prompt: "What does CONCAT do differently from the + operator?"
    type: single
    choices:
      - "It is faster"
      - "It ignores NULL arguments"
      - "It converts to uppercase"
      - "It removes spaces"
    answer: [1]
    explanation: "CONCAT treats NULL as an empty string, unlike + which propagates it."
    difficulty: 2
  - id: q3
    prompt: "What does SUBSTRING('AdventureWorks', 2, 5) return?"
    type: single
    choices:
      - "'Advent'"
      - "'dvent'"
      - "'Adventu'"
      - "'venture'"
    answer: [1]
    explanation: "Start at position 2 (a) and take 5 characters: dvent."
    difficulty: 2
  - id: q4
    prompt: "Which function replaces every occurrence of a substring?"
    type: single
    choices:
      - "STUFF"
      - "REPLACE"
      - "SWAP"
      - "TRANSLATE"
    answer: [1]
    explanation: "REPLACE(s, find, replace) swaps all occurrences of the find string."
    difficulty: 1
```