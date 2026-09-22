---
id: 06-part-practice
title: "Part 2 Practice"
order: 6
section: 02-joins-aggregation
language: sql
summary: "Review and exam questions for the Joins and Aggregation part"
tags: [practice, exam, review]
---

# Part 2 Practice

## Section review

You've mastered the relational toolbox:

- **INNER JOIN** — pair rows on a real key; each additional join is a new
  relation; avoid accidental cartesian products.
- **OUTER joins** — LEFT keeps all left rows; the `right.key IS NULL` probe
  finds "no match" rows; filter in ON to preserve unmatched rows.
- **Grouping** — `GROUP BY` splits rows; aggregates collapse them; every
  non-aggregated SELECT column must be in GROUP BY.
- **HAVING** — group filter run after aggregation; `WHERE` = rows first.
- **Set operators** — `UNION [ALL]`, `INTERSECT`, `EXCEPT` combine result
  sets vertically, matching column shapes.

```sql
SELECT
    c.CompanyName,
    COUNT(o.OrderID)                          AS Orders,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS Revenue
FROM Customers c
LEFT JOIN Orders o     ON o.CustomerID = c.CustomerID
LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY c.CompanyName
HAVING COUNT(o.OrderID) > 0
ORDER BY Revenue DESC;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which suppresses unmatched left rows when filtering a LEFT JOIN?"
    type: single
    choices:
      - "Putting the filter in the ON clause"
      - "Putting the filter in the WHERE clause"
      - "Using INNER JOIN"
      - "Using RIGHT JOIN"
    answer: [1]
    explanation: "Filtering the right table in WHERE drops NULL-filled left rows."
    difficulty: 3
  - id: q2
    prompt: "What is the effect of adding a second one-to-many join?"
    type: single
    choices:
      - "Rows multiply before aggregation"
      - "Rows are removed"
      - "Performance improves"
      - "Aggregates get smaller"
    answer: [0]
    explanation: "Two one-to-many joins can duplicate rows for a single fact."
    difficulty: 3
  - id: q3
    prompt: "Which uses UNION ALL?"
    type: single
    choices:
      - "Two tables with the same columns of compatible types"
      - "Two tables with different column counts"
      - "One table, two different filters"
      - "A table and its index"
    answer: [0]
    explanation: "Set operators stack result sets with equal shapes."
    difficulty: 2
  - id: q4
    prompt: "Where does WHERE run relative to GROUP BY?"
    type: single
    choices:
      - "After"
      - "Before"
      - "In parallel"
      - "It never runs with GROUP BY"
    answer: [1]
    explanation: "Rows are filtered before grouping; HAVING filters groups after."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which keeps all rows from the left table?"
    type: single
    choices: ["INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "CROSS JOIN"]
    answer: [1]
    explanation: "LEFT OUTER JOIN keeps every left row, filling unmatched right columns with NULL."
    weight: 3
    section: 02-joins-aggregation
  - prompt: "Which finds customers with no orders?"
    type: single
    choices:
      - "INNER JOIN then COUNT"
      - "LEFT JOIN ... WHERE Orders.OrderID IS NULL"
      - "FULL JOIN ... GROUP BY"
      - "CROSS JOIN with a filter"
    answer: [1]
    explanation: "The IS NULL probe after a LEFT JOIN selects left rows with no match."
    weight: 3
    section: 02-joins-aggregation
  - prompt: "What does SUM(x) return over an empty group?"
    type: single
    choices: ["0", "NULL", "An error", "MIN value"]
    answer: [1]
    explanation: "Aggregates over no rows return NULL; reports wrap with ISNULL."
    weight: 2
    section: 02-joins-aggregation
  - prompt: "Which clause filters aggregated groups?"
    type: single
    choices: ["WHERE", "HAVING", "FILTER", "TOP"]
    answer: [1]
    explanation: "HAVING runs after grouping and can reference aggregates."
    weight: 2
    section: 02-joins-aggregation
  - prompt: "What does EXCEPT return?"
    type: single
    choices:
      - "Rows in the left set minus the right set"
      - "Rows shared by both sets"
      - "All rows from both sets"
      - "Only identical key names"
    answer: [0]
    explanation: "EXCEPT subtracts the right operand's rows from the left operand's."
    weight: 2
    section: 02-joins-aggregation
```
