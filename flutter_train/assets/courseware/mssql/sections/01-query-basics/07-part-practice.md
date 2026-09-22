---
id: 07-part-practice
title: "Part 1 Practice"
order: 7
section: 01-query-basics
language: sql
summary: "Review and exam questions for the Querying Basics part"
tags: [practice, exam, review]
---

# Part 1 Practice

## Section review

You've built the SELECT toolkit:

- **SELECT essentials** — projection, aliases, computed columns, DISTINCT;
  logical clause order FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY.
- **WHERE** — comparisons, AND/OR/NOT, IN, BETWEEN, LIKE; watch parentheses.
- **ORDER BY / TOP** — requested ordering, TOP n (+ TIES), OFFSET-FETCH
  pagination.
- **NULL** — three-valued logic, `IS NULL`, `COALESCE`, `ISNULL`, `NULLIF`;
  aggregates skip NULLs except `COUNT(*)`.
- **Strings** — `UPPER/LOWER`, `TRIM`, `LEFT/RIGHT/SUBSTRING`, `CHARINDEX`,
  `CONCAT`, `REPLACE`, `STUFF`, `TRY_PARSE`.
- **Dates** — `GETDATE`, `DATEADD`, `DATEDIFF`, `DATEPART`, `EOMONTH`,
  `FORMAT`; half-open ranges for whole days.

```sql
SELECT
    TRIM(ProductName)                          AS Product,
    FORMAT(UnitPrice * 1.21, 'C')              AS PriceIncVAT,
    COALESCE(CategoryID, 0)                    AS Category
FROM Products
WHERE UnitPrice BETWEEN 10 AND 100
ORDER BY UnitPrice DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which clause order is correct?"
    type: single
    choices:
      - "SELECT, WHERE, FROM, ORDER BY"
      - "FROM, WHERE, SELECT, ORDER BY"
      - "FROM, SELECT, WHERE, ORDER BY"
      - "WHERE, FROM, GROUP BY, SELECT"
    answer: [1]
    explanation: "Logical order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY."
    difficulty: 2
  - id: q2
    prompt: "What does COALESCE(NULL, 5, 10) return?"
    type: single
    choices: ["NULL", "5", "10", "15"]
    answer: [1]
    explanation: "COALESCE returns the first non-NULL argument, which is 5."
    difficulty: 1
  - id: q3
    prompt: "Which finds the position of N'Works' inside N'AdventureWorks'?"
    type: single
    choices: ["LOCATE", "INDEX", "CHARINDEX", "FIND"]
    answer: [2]
    explanation: "CHARINDEX returns the starting position of the search string."
    difficulty: 1
  - id: q4
    prompt: "Which paginates with OFFSET and FETCH?"
    type: single
    choices:
      - "ORDER BY ... LIMIT"
      - "OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY"
      - "TOP 25 OFFSET 50"
      - "PAGE(2) SIZE(25)"
    answer: [1]
    explanation: "OFFSET-FETCH is the T-SQL syntax for server-side pagination."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "What is NULL = NULL?"
    type: single
    choices: ["TRUE", "FALSE", "UNKNOWN", "An error"]
    answer: [2]
    explanation: "Comparisons with NULL yield unknown, not true or false."
    weight: 3
    section: 01-query-basics
  - prompt: "How do you test whether a column is NULL?"
    type: single
    choices: ["= NULL", "IS NULL", "== NULL", "IN (NULL)"]
    answer: [1]
    explanation: "Use IS NULL / IS NOT NULL for null checks."
    weight: 2
    section: 01-query-basics
  - prompt: "Which pattern matches a string containing 'ard' anywhere?"
    type: single
    choices: ["'ard'", "'%ard%'", "'_ard_'", "'[ard]'"]
    answer: [1]
    explanation: "%ard% allows any characters before and after 'ard'."
    weight: 2
    section: 01-query-basics
  - prompt: "Which TOP option includes tied rows?"
    type: single
    choices: ["WITH TIES", "INCLUDE TIES", "PLUS TIES", "ALL"]
    answer: [0]
    explanation: "TOP (n) WITH TIES adds rows equal to the nth row's sort key."
    weight: 3
    section: 01-query-basics
  - prompt: "Chapter 1 risk: what happens without ORDER BY?"
    type: single
    choices:
      - "Rows come back in a guaranteed but slow order"
      - "No guaranteed order"
      - "An error message"
      - "Only one row is returned"
    answer: [1]
    explanation: "Without ORDER BY the engine may return rows in any order."
    weight: 2
    section: 01-query-basics
```
