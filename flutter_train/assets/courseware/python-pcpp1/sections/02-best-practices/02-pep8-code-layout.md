---
id: 02-pep8-code-layout
title: "PEP 8: code layout"
order: 2
section: 02-best-practices
language: python
summary: Indentation, continuation lines, the 79/72 column rule, line breaks, blank lines, and encoding.
tags: [pep8, layout, indentation, style]
---

# PEP 8: code layout

PEP 8 is a **Standards Track** PEP that standardizes how Python code *looks*.
It does not change the language — it changes how readable it is. The exam
checks your grasp of the concrete layout rules, so learn the numbers.

## Indentation

- Use **4 spaces** per level. Never mix tabs and spaces; on modern Python a mix
  is a `TabError`.
- The first line of a block may not be indented after a colon.
- To split a long expression, **prefer implicit continuation** (inside
  parentheses) instead of a backslash.

> [!trap] Cutting and pasting code from the web often pastes tabs. A leading
> tab where spaces are expected fails with `IndentationError` (or
> `TabError` when both appear).

## Continuation lines

Two accepted styles for wrapped lines:

1. **Hanging indent** — wrap to the open parenthesis and indent once more
   (usually 4 spaces + the opening indent):
2. **Aligned** with the opening delimiter.

> [!warning] In the *hanging* style, the first line must not contain arguments;
> put the opening delimiter at the end of the first line.

```python eval=no
# GOOD (aligned)                                    # GOOD (hanging)
result = function_name(arg_one,                      result = function_name(
                      arg_two,                                  arg_one,
                      arg_three)                                arg_two,
                                                                arg_three,
                                                                )
# BAD — first line keeps an argument inside a                                           # BAD — no extra indent
# hanging indent                                            result = function_name(
result = function_name(arg_one,                                 arg_one,
          arg_two,                                              arg_two)
          arg_three)
```

> [!note] The lines above are shortened for demonstration; real projects would
> wrap at column 79. This pairing is tagged `eval=no` because it is illustrative
> "bad vs good" code, not something you run on the device.

```python
# Runnable: implicit continuation keeps the call under 79 columns.
def add(*numbers):
    return sum(numbers)


result = add(
    1, 2, 3,
    4, 5,
)
print("continuation call sum:", result)

config = {
    "name": "PCPP1",
    "level": "professional",
    "active": True,
}
print("items sorted:", sorted(config.items()))
```

## Max line length

- **79 columns** for code. Use 72 for docstrings/comments if they must be
  readable in narrow terminals.
- Wrap at the **operator** of a long logical line, not after it (e.g. put `+`
  at the *start* of a continuation line).
- Avoid backslash continuation; parentheses, brackets, and braces do the job
  without it.

```python
def report_ok():
    # Adjacent string literals concatenate at compile time,
    # keeping every line under 79 columns.
    message = (
        "PEP 8 suggests 79 columns for code "
        "and 72 for comments; both are "
        "readability targets, not compiler limits."
    )
    return message


m = report_ok()
print("length of wrapped string:", len(m))
print("all lines under 79 chars:", all(len(l) <= 79 for l in m.splitlines()))
```

## Line breaks and operators

When a math or logic expression is too long:

```python
gross, tax, rebate = 100, 20, 5
total = (
    gross
    + tax
    - rebate
)
print("operator-first continuation total:", total)
```

Putting the **operator first** on the continuation line (as shown) makes the
intended grouping obvious — you can see at a glance that everything belongs to
the same expression.

## Blank lines

- **Two blank lines** between top-level definitions (functions, classes).
- **One blank line** between methods inside a class.
- Sparse blank lines inside a function to separate logical steps; keep them
  few.

```python
class Counter:
    def __init__(self, start=0):
        self.value = start

    def bump(self):
        self.value += 1
        return self.value


def times_two(n):
    return n * 2
```

The rule keeps code scannable: definitions stand out, methods group visually.

## Encoding

- Python 3 source is **UTF-8 by default**. You do not need a coding cookie.
- A `# -*- coding: utf-8 -*-` comment is only needed for other encodings or
  legacy compatibility — including it "for safety" is redundant in Python 3.
- Module files should start with the module docstring, then imports; shebang
  and encoding comments, if present, come *first*.

> [!key] Remember the column numbers for the exam: **79** for code, **72** for
> comments/docstrings, **4** spaces per indent, **2** blank lines at top level,
> **1** between methods.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What column width does PEP 8 recommend as the maximum for Python code lines?"
    type: single
    choices: ["72", "79", "100", "120"]
    answer: [1]
    explanation: "PEP 8 recommends 79 columns for code and 72 for comments and docstrings."
    difficulty: 1
  - id: q2
    prompt: "How many spaces are recommended per indentation level in PEP 8?"
    type: single
    choices: ["2", "4", "8", "A single tab stop"]
    answer: [1]
    explanation: "PEP 8 specifies 4 spaces per indentation level and warns against mixing tabs and spaces."
    difficulty: 1
  - id: q3
    prompt: "Where are two blank lines required by PEP 8?"
    type: single
    choices:
      - "Between every line of a function"
      - "Between top-level function and class definitions"
      - "After every import statement"
      - "Before every comment"
    answer: [1]
    explanation: "Top-level definitions are separated by two blank lines; methods inside a class by one."
    difficulty: 2
  - id: q4
    prompt: "Which is the preferred way to split an expression that is too long?"
    type: single
    choices:
      - "Implicit continuation inside parentheses"
      - "A backslash at the end of each line"
      - "Putting the whole expression on one very long line"
      - "Using a semicolon to join statements"
    answer: [0]
    explanation: "Parentheses/brackets/braces give implicit continuation; backslashes are deprecated in style and error-prone."
    difficulty: 2
  - id: q5
    prompt: "Is the coding cookie # -*- coding: utf-8 -*- required in Python 3?"
    type: single
    choices:
      - "Yes, in every module"
      - "No, UTF-8 is the default"
      - "Only when using tkinter"
      - "Only in interactive mode"
    answer: [1]
    explanation: "Python 3 source code is UTF-8 by default, so the encoding declaration is redundant unless a non-default encoding is used."
    difficulty: 2
```