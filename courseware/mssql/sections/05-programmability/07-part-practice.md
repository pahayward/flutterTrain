---
id: 07-part-practice
title: "Part 5 Practice"
order: 7
section: 05-programmability
language: sql
summary: "Review and exam questions for the Programmability part"
tags: [practice, exam, review]
---

# Part 5 Practice

## Section review

You've built programmable SQL:

- **Variables & flow** — `DECLARE/SET`, IF/ELSE, WHILE; loop-for-bulk is a
  warning sign; cursors rarely needed.
- **Stored procedures** — parameterized (`DEFAULT`, `OUTPUT`), EXEC,
  security via EXECUTE.
- **Functions** — scalar, inline table-valued (preferred), multi-statement
  TVF caveats.
- **CTEs** — named, reusable steps and recursive hierarchies.
- **Window functions** — `OVER`, ROW_NUMBER/RANK/DENSE_RANK, LAG/LEAD,
  frames and running totals, "top per group".
- **Error handling** — TRY/CATCH, THROW, rollback discipline.

```sql
CREATE OR ALTER PROCEDURE dbo.TopProducts
    @CategoryID INT,
    @N INT = 10
AS
BEGIN
    WITH Ranked AS (
        SELECT
            p.ProductID,
            p.ProductName,
            p.UnitPrice,
            ROW_NUMBER() OVER (ORDER BY p.UnitPrice DESC) AS rn
        FROM Products p
        WHERE p.CategoryID = @CategoryID
    )
    SELECT ProductID, ProductName, UnitPrice
    FROM Ranked
    WHERE rn <= @N;
END;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the main reason to avoid scalar UDFs in SELECT lists?"
    type: single
    choices:
      - "They leak memory"
      - "They run per row with overhead on large scans"
      - "They are not permitted in SELECT"
      - "They ignore indexes always"
    answer: [1]
    explanation: "Per-row T-SQL overhead scales poorly on big result sets."
    difficulty: 2
  - id: q2
    prompt: "Which returns a window function value that restarts per customer?"
    type: single
    choices:
      - "OVER (PARTITION BY CustomerID ...)"
      - "OVER (ORDER BY CustomerID ...)"
      - "GROUP BY CustomerID"
      - "CURSOR per customer"
    answer: [0]
    explanation: "PARTITION BY reseeds the window for each customer."
    difficulty: 2
  - id: q3
    prompt: "What is the recursion default limit in SQL Server?"
    type: single
    choices: ["10", "100", "1000", "Unlimited"]
    answer: [1]
    explanation: "Recursive CTEs cap at 100 levels unless MAXRECURSION is set."
    difficulty: 2
  - id: q4
    prompt: "Which is a benefit of storing logic in stored procedures?"
    type: single
    choices:
      - "Faster disk writes"
      - "Users need only EXECUTE rights"
      - "Shorter table names"
      - "Automatic backups"
    answer: [1]
    explanation: "Procedures encapsulate permissions behind EXECUTE."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - prompt: "What is the inline table-valued function advantage?"
    type: single
    choices:
      - "It can modify data"
      - "The optimizer can inline it like a view"
      - "It never scans"
      - "It stores results"
    answer: [1]
    explanation: "Inline TVFs are expanded by the optimizer for fast, indexable access."
    weight: 3
    section: 05-programmability
  - prompt: "Which window function gives 1,1,3 for tied values?"
    type: single
    choices: ["ROW_NUMBER", "RANK", "DENSE_RANK", "NTILE"]
    answer: [1]
    explanation: "RANK ties share a rank and skip the next number; DENSE_RANK does not skip."
    weight: 3
    section: 05-programmability
  - prompt: "What catches runtime errors in modern T-SQL?"
    type: single
    choices: ["ON ERROR", "BEGIN CATCH", "CATCH THROW", "IF @@ERROR"]
    answer: [1]
    explanation: "TRY/CATCH is the structured runtime-error handler."
    weight: 2
    section: 05-programmability
  - prompt: "Which is used to pass a value back from a procedure?"
    type: single
    choices: ["INPUT", "OUTPUT", "RETURN SET", "EXTERNAL"]
    answer: [1]
    explanation: "OUTPUT parameters hand computed values back to callers."
    weight: 2
    section: 05-programmability
```
