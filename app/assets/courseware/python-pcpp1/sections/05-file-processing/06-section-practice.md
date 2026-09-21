---
id: 06-section-practice
title: Section 5 Practice
order: 6
section: 05-file-processing
language: python
type: lesson
summary: Compact review of file processing topics and 7 exam-style practice questions covering sqlite3, csv, XML, logging, and configparser.
tags: [practice, exam, file-processing]
---

# Section 5: File Processing — Practice

## Section Review

This section covered five key stdlib modules for file and data processing:

| Module | Purpose |
|---|---|
| `sqlite3` | In-process SQL database — connect, create tables, CRUD, transactions |
| `csv` | Read/write CSV with `reader`, `writer`, `DictReader`, `DictWriter` |
| `xml.etree.ElementTree` | Parse and build XML trees with `find`, `findall`, `SubElement` |
| `logging` | Structured diagnostic output with levels, handlers, formatters |
| `configparser` | Read/write `.ini` files with sections, interpolation, defaults |

### Key Takeaways

- **sqlite3**: Always parameterize queries; `commit()` persists, `rollback()` undoes; `executemany()` for batch inserts.
- **csv**: Use the module instead of `split()`; `DictReader`/`DictWriter` map to dicts; configure `delimiter` for non-comma separators.
- **XML**: `fromstring()` parses, `tostring()` serializes; `Element`/`SubElement` build; use `indent()` for pretty output.
- **logging**: Five levels; `basicConfig()` for quick setup; `StreamHandler(io.StringIO())` for in-memory capture; `LogRecord` attributes in format strings.
- **configparser**: Sections and key-value pairs; `DEFAULT` section provides fallbacks; `%(key)s` interpolation.

> [!tip] Exam strategy
The PCPP1 exam tests *practical knowledge*: knowing which function to call, what it returns, and common pitfalls. Review the code examples in each module — they mirror exam-style questions.

## ExamQuestions

```yaml
bank:
  - prompt: "Which sqlite3 method executes a single SQL statement against each item in a sequence of parameters?"
    type: single
    choices: ["execute()", "executemany()", "executescript()", "fetchall()"]
    answer: [1]
    explanation: "executemany() takes an SQL string and an iterable of parameter tuples."
    weight: 4
    section: 05-file-processing
  - prompt: "What does csv.DictReader use as dictionary keys by default?"
    type: single
    choices: ["Integer indices", "Column positions", "The first row values (header)", "Alphabetical labels"]
    answer: [2]
    explanation: "DictReader uses the first row of the file as field names (keys) by default."
    weight: 4
    section: 05-file-processing
  - prompt: "Which ElementTree function creates a child element and appends it to a parent?"
    type: single
    choices: ["ET.Element()", "ET.SubElement()", "ET.append()", "ET.create()"]
    answer: [1]
    explanation: "ET.SubElement(parent, tag, attrib) creates a new element as a child of parent."
    weight: 4
    section: 05-file-processing
  - prompt: "What is the default logging level when no basicConfig() or setLevel() is called?"
    type: single
    choices: ["DEBUG", "INFO", "WARNING", "ERROR"]
    answer: [2]
    explanation: "The root logger defaults to WARNING, meaning DEBUG, INFO, and WARNING(only root) are suppressed."
    weight: 4
    section: 05-file-processing
  - prompt: "In configparser, what happens when a value references %(undefined_key)s?"
    type: single
    choices: ["Empty string is returned", "InterpolationMissingOptionError is raised at access time", "The literal text is returned", "It is silently skipped"]
    answer: [1]
    explanation: "Accessing a value with a missing interpolation target raises an error."
    weight: 4
    section: 05-file-processing
  - prompt: "Which of these is NOT a method for fetching query results from a sqlite3 cursor?"
    type: single
    choices: ["fetchone()", "fetchmany()", "fetchall()", "fetchdict()"]
    answer: [3]
    explanation: "sqlite3 provides fetchone, fetchmany, and fetchall — but not fetchdict."
    weight: 4
    section: 05-file-processing
  - prompt: "What must you call after executing INSERT/UPDATE/DELETE to persist changes in sqlite3?"
    type: single
    choices: ["cursor.flush()", "conn.commit()", "conn.save()", "conn.persist()"]
    answer: [1]
    explanation: "conn.commit() writes the current transaction to the database."
    weight: 4
    section: 05-file-processing
```
