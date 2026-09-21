---
id: 06-part-practice
title: "Part 4 Practice"
order: 6
section: 04-ddl-schema
language: sql
summary: "Review and exam questions for the Schema Design part"
tags: [practice, exam, review]
---

# Part 4 Practice

## Section review

You've learned to shape the schema:

- **CREATE TABLE + constraints** — PK, FK, UNIQUE, CHECK, DEFAULT; composite
  keys; referential actions.
- **IDENTITY / SEQUENCE** — auto keys; SCOPE_IDENTITY vs @@IDENTITY vs
  IDENT_CURRENT; reseeding; cross-table numbering.
- **Indexes** — clustered vs nonclustered, seek vs scan, covering and
  composite indexes.
- **Views** — stored SELECTs, security facades, SCHEMABINDING, indexed
  (materialized) views.
- **ALTER / DROP** — adding and removing columns, constraints, migrations.

```sql
CREATE TABLE Invoices (
    InvoiceID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID   INT NOT NULL REFERENCES Customers(CustomerID),
    IssuedOn     DATE NOT NULL,
    Amount       DECIMAL(12,2) NOT NULL CHECK (Amount >= 0)
);

CREATE NONCLUSTERED INDEX IX_Invoices_Customer
ON Invoices (CustomerID, IssuedOn) INCLUDE (Amount);
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which is the best default for a single-table key?"
    type: single
    choices: ["Global SEQUENCE", "IDENTITY column", "Random VARCHAR", "Composite of all columns"]
    answer: [1]
    explanation: "An IDENTITY column is the standard auto-key for one table."
    difficulty: 1
  - id: q2
    prompt: "What blocks a DROP TABLE?"
    type: single
    choices:
      - "Data in the table"
      - "A foreign key referencing the table"
      - "An index on the table"
      - "A default constraint"
    answer: [1]
    explanation: "Referencing FKs must be dropped before the parent table can go."
    difficulty: 2
  - id: q3
    prompt: "Which index type physically orders the table?"
    type: single
    choices: ["Nonclustered", "Clustered", "Filtered", "Hash"]
    answer: [1]
    explanation: "The clustered index IS the table's physical order; only one exists."
    difficulty: 1
  - id: q4
    prompt: "What makes an indexed (materialized) view possible?"
    type: single
    choices:
      - "WITH SCHEMABINDING and a unique clustered index"
      - "Any normal view"
      - "A CETAS statement"
      - "Enabling row versioning"
    answer: [0]
    explanation: "SCHEMABINDING plus a unique clustered index turns a view into a indexed object."
    difficulty: 3
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which constraint guarantees unique non-NULL values?"
    type: single
    choices: ["UNIQUE", "PRIMARY KEY", "CHECK", "FOREIGN KEY"]
    answer: [1]
    explanation: "A primary key is unique and NOT NULL."
    weight: 3
    section: 04-ddl-schema
  - prompt: "What does ON DELETE CASCADE do?"
    type: single
    choices:
      - "Refuses the delete"
      - "Deletes child rows with the parent"
      - "Sets child keys to NULL"
      - "Archives the parent"
    answer: [1]
    explanation: "CASCADE propagates the delete to dependent rows."
    weight: 2
    section: 04-ddl-schema
  - prompt: "How many clustered indexes can a table have?"
    type: single
    choices: ["Zero", "One", "Two", "Limited by edition"]
    answer: [1]
    explanation: "Physical order is singular, so at most one clustered index."
    weight: 2
    section: 04-ddl-schema
  - prompt: "Which returns the identity value of your own last INSERT?"
    type: single
    choices: ["IDENT_CURRENT('t')", "SCOPE_IDENTITY()", "@@IDENTITY always", "NEWID()"]
    answer: [1]
    explanation: "SCOPE_IDENTITY() returns your session's last inserted identity value."
    weight: 3
    section: 04-ddl-schema
  - prompt: "A view is best described as what?"
    type: single
    choices: ["A stored copy of data", "A stored query shown as a virtual table", "An index", "A permission"]
    answer: [1]
    explanation: "Views are saved SELECTs; they read underlying tables when queried."
    weight: 2
    section: 04-ddl-schema
```
