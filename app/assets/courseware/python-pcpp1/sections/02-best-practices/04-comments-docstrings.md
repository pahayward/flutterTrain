---
id: 04-comments-docstrings
title: Comments vs documentation strings
order: 4
section: 02-best-practices
language: python
summary: When comments help, block vs inline comment style, and how docstrings differ from comments.
tags: [pep8, comments, docstrings, pep257]
---

# Comments vs documentation strings

A **comment** explains code for the human reading it; a **docstring** is a
string literal that Python attaches to a module, class, function, or method as
its official documentation. Both follow their own rules.

## When to comment — and when not to

PEP 8's advice is blunt:

- Comments say **why**, not **what**. The code already says what it does.
- **Update comments** when the code changes; a stale comment is worse than none.
- Use comments for *non-obvious* decisions, TODOs, and warnings:
  `# NB: do not reorder — parser depends on this`.
- **Do not contradict the code.** If the behavior differs, that is a bug, not a
  comment opportunity.

> [!trap] "Comment the why, not the how." When your comment re-explains the
> statement above it, it is noise — delete it.

## Block comments

- Each line starts with `#` followed by a **space**: `# like this`.
- Indent the comment to match the code it explains.
- Multi-line block comments use `#` at the start of **every** line.

```python
def classify(n):
    # We only classify positive integers; negatives arrive
    # already clamped by the caller, so no guard is needed here.
    if n % 2 == 0:
        return "even"
    return "odd"


print(classify(4), classify(7))
```

## Inline comments

- An inline comment shares a line with code, separated by **at least two
  spaces** before the `#`.
- Use them sparingly — only for genuinely useful notes.

```python
counter = 0
counter += 1  # reset at midnight triggers a full recalculation
print("counter:", counter)
```

> [!note] Two spaces of separation keep the comment from colliding with code
> when the column limit is tight. A single space looks accidental.

## Docstrings — the documented contract

A docstring is a string literal **as the first statement** of a module,
class, function, or method. If it is not first, it is not a docstring — just an
orphaned string.

- Delimited by **triple double quotes**: `"""..."""`.
- Available at runtime via `__doc__` and shown by `help()`.
- Its content is *usage documentation for other writers*, not an explanation of
  internals (that is the comment's job).
- A docstring may span lines; single vs multi-line rules belong to PEP 257
  (covered in the next module).

```python
def area(length, width):
    """Return the area of a rectangle in square units."""
    # length and width were validated upstream; trust them here.
    return length * width


print(area.__doc__.strip())
print("area:", area(4, 5))
```

Notice the split: the **comment** records an internal assumption, the
**docstring** tells any caller what the function guarantees.

## Module-level docstrings

A file may start with a module docstring describing its purpose before its
first import:

```python
"""Utility functions for safe arithmetic."""
import math
```

The constant text `math.floor` etc. is not special — what matters is position:
the string sits at the top of the module, so Python records it as the module
`__doc__`.

```python
def total(items):
    """Return the sum of a sequence of numbers."""
    return sum(items)


print("docstring empty?", total.__doc__ is None)
print("total:", total([1, 2, 3, 4]))
```

## Summarizing the difference

| Aspect | Comment | Docstring |
|---|---|---|
| Syntax | `# text` | `"""text"""` as first statement |
| Audience | humans maintaining the code | users of the API; also `help()` |
| Topic | *why/context* (internal) | *what/contract* (interface) |
| Attached to | nothing at runtime | `__doc__` on the object |
| Column limit | 72 | 72 |

> [!key] Exam one-liner: **comments explain implementation, docstrings
> document interfaces.**

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What should a well-written comment explain?"
    type: single
    choices:
      - "What the next statement literally does"
      - "Why the code is the way it is"
      - "The full history of the file"
      - "Nothing — comments are forbidden by PEP 8"
    answer: [1]
    explanation: "PEP 8 says code shows what it does; comments should convey the why, such as rationale and non-obvious decisions."
    difficulty: 1
  - id: q2
    prompt: "How many spaces separate an inline comment from the statement before it?"
    type: single
    choices: ["One space minimum", "At least two spaces", "A tab character", "No space required"]
    answer: [1]
    explanation: "PEP 8 requires at least two spaces between an inline statement and the trailing # comment."
    difficulty: 2
  - id: q3
    prompt: "Which property must hold for a string to be a real docstring?"
    type: single
    choices:
      - "It must be a triple-quoted string"
      - "It must start with a capital letter"
      - "It must be the first statement of the module, class, function, or method"
      - "It must contain at least one sentence"
    answer: [2]
    explanation: "Position is what makes it a docstring; only the first statement is recorded in __doc__."
    difficulty: 2
  - id: q4
    prompt: "How do you access a function's docstring at runtime?"
    type: single
    choices: ["func.info", "func.__doc__", "help(func).__doc__", "dir(func, 'doc')"]
    answer: [1]
    explanation: "Every documented object exposes its docstring through the __doc__ attribute."
    difficulty: 1
  - id: q5
    prompt: "When is the best time to use an inline comment?"
    type: single
    choices:
      - "Always, after every line of code"
      - "Only when the line re-states what it does"
      - "For genuinely useful, non-obvious notes"
      - "Never, under any circumstances"
    answer: [2]
    explanation: "Inline comments are for useful asides and should be used sparingly so they do not become noise."
    difficulty: 2
```