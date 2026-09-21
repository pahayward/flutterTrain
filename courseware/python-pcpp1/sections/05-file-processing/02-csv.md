---
id: 02-csv
title: Processing CSV files
order: 2
section: 05-file-processing
language: python
type: lesson
summary: Read and write CSV files using csv.reader, csv.writer, DictReader, and DictWriter with configurable delimiters.
tags: [csv, reader, writer, delimiters]
---

# Processing CSV Files

Python's `csv` module handles reading and writing Comma-Separated Values files. It abstracts away edge cases like quoting, escaping, and alternative delimiters.

> [!key] Why use the csv module?
CSV files are deceptively tricky. Naive `split(",")` breaks on fields containing commas or quotes. The `csv` module handles all of that correctly.

## Reading CSV with csv.reader

`csv.reader` wraps a file-like object and yields one list per row.

```python
import csv
import io

data = io.StringIO("name,age,city\nAlice,30,NYC\nBob,25,LA\n")

reader = csv.reader(data)
for row in reader:
    print(row)

data.close()
```

## Writing CSV with csv.writer

`csv.writer` writes rows to a file-like object. Use `io.StringIO` to build CSV in memory.

```python
import csv
import io

output = io.StringIO()
writer = csv.writer(output)
writer.writerow(["name", "age", "city"])
writer.writerow(["Alice", 30, "NYC"])
writer.writerow(["Bob", 25, "LA"])

print(output.getvalue())
output.close()
```

> [!tip] writerows for bulk writes
`writerows(sequence)` writes multiple rows at once — useful for batch output.

## DictReader and DictWriter

`DictReader` maps each row to a `dict` using the header row as keys. `DictWriter` writes from dicts to rows.

```python
import csv
import io

data = io.StringIO("name,grade\nAlice,95\nBob,82\n")

reader = csv.DictReader(data)
for row in reader:
    print(f"{row['name']} scored {row['grade']}")

data.close()
```

```python
import csv
import io

output = io.StringIO()
writer = csv.DictWriter(output, fieldnames=["name", "grade"])
writer.writeheader()
writer.writerow({"name": "Alice", "grade": 95})
writer.writerow({"name": "Bob", "grade": 82})

print(output.getvalue())
output.close()
```

> [!note] writeheader()
Call `writeheader()` before writing rows with `DictWriter` to output the column names.

## Custom Delimiters

The `delimiter` parameter changes the field separator. Tabs (`\t`), semicolons, and pipes are common alternatives.

```python
import csv
import io

data = io.StringIO("name\tage\tcity\nAlice\t30\tNYC\nBob\t25\tLA\n")

reader = csv.reader(data, delimiter="\t")
for row in reader:
    print(row)

data.close()
```

```python
import csv
import io

buf = io.StringIO()
writer = csv.writer(buf, delimiter=";")
writer.writerow(["name", "age"])
writer.writerow(["Alice", 30])

print(buf.getvalue())
buf.close()
```

## Handling Quoting

The `quoting` parameter controls how special characters are handled.

```python
import csv
import io

output = io.StringIO()
writer = csv.writer(output, quoting=csv.QUOTE_ALL)
writer.writerow(["name", "note"])
writer.writerow(["Alice", "She said, \"Hello\""])
print(output.getvalue())
output.close()
```

> [!trap] Newline handling on Windows
When opening CSV files on disk, always pass `newline=""` to `open()` to avoid extra blank lines. With in-memory `StringIO` this is not an issue.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does csv.reader yield for each row?"
    type: single
    choices: ["A dict", "A list of strings", "A tuple of mixed types", "A named tuple"]
    answer: [1]
    explanation: "csv.reader yields a list of strings, one per field."
    difficulty: 1
  - id: q2
    prompt: "What is the default delimiter for csv.reader and csv.writer?"
    type: single
    choices: ["Tab", "Semicolon", "Comma", "Pipe"]
    answer: [2]
    explanation: "The default delimiter is the comma (,)."
    difficulty: 1
  - id: q3
    prompt: "Which method writes column headers when using DictWriter?"
    type: single
    choices: ["writerow()", "writeheader()", "writelines()", "write_header()"]
    answer: [1]
    explanation: "writeheader() writes the fieldnames as the first row."
    difficulty: 2
  - id: q4
    prompt: "Why is csv.writer preferred over manual string concatenation for CSV output?"
    type: single
    choices: ["It is faster for small files", "It handles quoting, escaping, and delimiters correctly", "It automatically compresses the output", "It writes directly to the database"]
    answer: [1]
    explanation: "The csv module handles edge cases like fields containing commas or quotes."
    difficulty: 2
```
