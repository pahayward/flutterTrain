---
id: 06-docstrings-type-hints
title: "PEP 257 docstrings + PEP 484 type hints"
order: 6
section: 02-best-practices
language: python
summary: One-line vs multi-line docstrings, PEP 257 conventions, and PEP 484 type hint basics with linters.
tags: [pep257, docstrings, pep484, type-hints]
---

# PEP 257 docstrings + PEP 484 type hints

Two PEPs complete the "self-documenting code" story: **PEP 257** defines how
docstrings are written, **PEP 484** lets you declare types. Together they are
the exam's answer to "how do professionals write maintainable Python".

## PEP 257 — docstring conventions

**One-line docstrings:**

- Delimited by **triple double quotes**: `"""Return the net total."""`
- The quotes open and close on the **same line**, content ends with a period.
- No blank line before or inside the one line.

**Multi-line docstrings:**

- Summary line first, then a **blank line**, then the detailed description.
- The closing quotes sit on their **own line** for multi-line docstrings.
- On a one-line docstring the closing quotes stay on the same line.

```python eval=no
# GOOD — one-line
def area(w, h):
    """Return the area of a rectangle."""

# GOOD — multi-line (summary + blank line + details, quotes on own line)
def connect(host, port):
    """Open a socket connection.

    The function retries three times with a backoff and
    raises ConnectionError when all attempts fail.
    """

# BAD — one-liner split across lines
def area(w, h):
    """Return the area of a rectangle.
    """
```

> [!note] Listing tagged `eval=no`: special-form examples used purely to
> illustrate formatting conventions. Demonstrate the *same* pattern live below.

- Module docstrings document the module; class docstrings precede methods and
  summarize the class responsibility.
- Docstrings should state **what** the code does, the arguments, the return,
  and any exceptions that matter — that is their contract.

```python
def celsius_to_fahrenheit(c):
    """Convert Celsius degrees to Fahrenheit."""
    return c * 9 / 5 + 32


def describe_temp(c):
    """Give a human-readable temperature summary.

    Arguments:
        c: temperature in Celsius.
    Returns:
        A string describing warmth.
    """
    if c >= 30:
        warmth = "hot"
    elif c <= 5:
        warmth = "cold"
    else:
        warmth = "mild"
    return f"{warmth} ({celsius_to_fahrenheit(c):.1f} F)"


print(celsius_to_fahrenheit.__doc__.strip())
print(describe_temp(33))
print(describe_temp.__doc__.splitlines()[0])
```

## PEP 484 — type hints

Type hints annotate arguments and return values so tools (and humans) can check
consistency before runtime. **Python does not enforce them** — hints are
metadata, they do not change behavior.

- Annotate parameters after a colon: `def greet(name: str) -> str:`
- Defaults go after the type: `def greet(name: str = "World") -> str:`
- Return type after `->`.
- `None` return implies no `->` needed, but `-> None` is idiomatic for
  procedures.

```python
from typing import Optional


def greet(name: str, prefix: Optional[str] = None) -> str:
    """Return a greeting, optionally with a custom prefix."""
    word = prefix if prefix is not None else "Hello"
    return f"{word}, {name}!"


print(greet("Ada"))
print(greet("Ada", prefix="Hi"))
print("annotations:", greet.__annotations__)
```

## Generic container hints

Modern Python (3.9+, fully in 3.13) lets builtin containers carry element
types directly — no need to import `typing.List`:

- `list[int]` — list of ints
- `dict[str, float]` — mapping with str keys and float values
- `tuple[int, str]` — fixed 2-tuple; `tuple[int, ...]` — any length

Optional values: both `Optional[int]` and `int | None` mean "an int or None".

```python
def describe(value: int | str) -> str:
    """Return a short description of a number or a string."""
    if isinstance(value, int):
        return f"int, twice is {value * 2}"
    return f"str, upper is {value.upper()}"


print(describe(21))
print(describe("hi"))
```

## Linters and fixers

- **Linters** (e.g. `pylint`, `pyflakes`, `ruff`) check style and detect bugs
  *without running* the program — unused imports, typos, PEP 8 violations.
- **Type checkers** (e.g. `mypy`) read the PEP 484 hints and flag mismatches
  like passing a `str` where `int` is declared.
- **Fixers / formatters** (e.g. `autopep8`, `black`, `isort`) rewrite code to
  conform automatically. `black` is opinionated: it applies style for you.
- In an offline Android app, linters/fixers run *off-device* as build tools —
  the on-device examples here just demonstrate what they check.

> [!tip] Lifetime workflow professionals use on every project:
> format (fixer) → lint (style + smells) → type-check (mypy) → test. The exam
> wants you to name these tool categories, not to use them.

## Docstrings + type hints = documentation for free

A documented function with annotations tells a reader everything the interface
promises:

```python
def apply_discount(price: int, pct: int) -> int:
    """Apply a percentage discount and return the rounded total."""
    return round(price * (100 - pct) / 100)


print("after 20% off 80:", apply_discount(80, 20))
print("docstring:", apply_discount.__doc__.strip())
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In a multi-line docstring, where do the closing triple quotes go?"
    type: single
    choices:
      - "On the same line as the last sentence"
      - "On a line of their own"
      - "At the top, before the summary"
      - "Anywhere between the summary and details"
    answer: [1]
    explanation: "PEP 257 prescribes the closing quotes on their own line for multi-line docstrings; one-line docstrings close on the same line."
    difficulty: 2
  - id: q2
    prompt: "What separates the summary line from the detailed part of a multi-line docstring?"
    type: single
    choices:
      - "A horizontal rule"
      - "An empty line"
      - "Exactly three spaces"
      - "Nothing — they must be one paragraph"
    answer: [1]
    explanation: "The summary is followed by a blank line, then the detailed explanation."
    difficulty: 1
  - id: q3
    prompt: "Which statement about PEP 484 type hints is true?"
    type: single
    choices:
      - "Python raises TypeError if a hint is violated"
      - "Hints are metadata and are not enforced at runtime"
      - "Hints must be imported from the typing module"
      - "Variables, not functions, can carry hints"
    answer: [1]
    explanation: "Hints are annotations for tools like mypy; CPython ignores them at runtime."
    difficulty: 2
  - id: q4
    prompt: "What is the correct return annotation for a function returning an int or None?"
    type: single
    choices:
      - "-> int or None"
      - "-> Optional[int]"
      - "-> int?"
      - "-> any"
    answer: [1]
    explanation: "Optional[int] (or int | None in modern Python) expresses an int that may be None."
    difficulty: 2
  - id: q5
    prompt: "Which tool reads type hints to statically catch wrong argument types?"
    type: single
    choices:
      - "autopep8"
      - "black"
      - "mypy"
      - "isort"
    answer: [2]
    explanation: "mypy is a static type checker; autopep8/black are formatters and isort sorts imports."
    difficulty: 1
  - id: q6
    prompt: "Which hint best describes a list of integers?"
    type: single
    choices: ["list[int]", "int[list]", "List<int>", "integer_array"]
    answer: [0]
    explanation: "Builtin generics like list[int] are the modern, standard way to annotate a list of ints."
    difficulty: 1
```