---
id: 03-imports-quotes-whitespace
title: "PEP 8: imports, quotes, whitespace"
order: 3
section: 02-best-practices
language: python
summary: Where and how to order imports, quoting styles, whitespace around operators, and trailing commas.
tags: [pep8, imports, whitespace, style]
---

# PEP 8: imports, quotes, whitespace

PEP 8 does not only talk about layout — it also standardizes how you import
modules, quote strings, and surround operators with whitespace.

## Imports: placement and ordering

**Placement:** imports go at the **top of the file**, after the module
docstring and any comments, before other code. A blank line separates imports
from the following code.

**Ordering (within the groups):**
1. Future imports (`from __future__ import annotations`)
2. Standard library modules
3. Third-party modules
4. Local / application-specific modules

Each group is alphabetical (`import math` before `import os`), one import per
line, and groups separated by blank lines.

> [!key] The PCPP1 exam loves the ordering question: *stdlib first, then
> third-party, then local*, each group alphabetized.

```python eval=no
# WRONG order — stdlib mixed with third-party, not alphabetical
import requests
import math
import myapp.helpers
import os

# CORRECT: stdlib, blank line, third-party, blank line, local
import math
import os

import requests

import myapp.helpers
```

> [!note] Shown as a listing only (`eval=no`) because the exam cares about the
> ordering, not about running third-party or local packages on the device.

## Import forms

- Prefer `import module` and `from module import name` over `import *`.
- A **wildcard / star import** (`from module import *`) dumps every public name
  into your namespace — a readability and collision hazard. PEP 8 says avoid it.
- Wrapping imports in parentheses is fine when a group must wrap:

```python
from os import (getcwd, path)
```

```python
# Runnable: imports placed at top, the rest of the program below.
import math
from math import sqrt

side = 4.0
print("sqrt(16) via qualified name:", math.sqrt(16.0))
print("sqrt(16) via imported name:", sqrt(16.0))
print("both agree:", math.sqrt(16.0) == sqrt(16.0))
```

## String quotes

- Pick **single or double quotes** and stay consistent across your project;
  PEP 8 does not favor one over the other.
- Switching to the *other* quote avoids backslash-escaping inside a string
  (e.g. `"it's"` or `'say "hi"'`).
- Triple quotes are reserved for docstrings (and multi-line strings).

```python
# Consistent double quotes; single quotes avoid escapes here.
single_escaped = 'it\'s'          # ugly, needed backslash
cleaner = "it's"
print(cleaner, "==", single_escaped, cleaner == single_escaped)
```

## Whitespace rules

PEP 8's whitespace rules are exact. Memorize the list:

- **One space** on each side of binary operators: `a = b + c`.
- **No space** just inside parentheses/brackets/braces: `foo(x)`, `my_list[0]`.
- **One space after** commas, colons, semicolons: `f(a, b)`.
- **No space before** a comma, colon, or semicolon.
- **One space after** a `,` in a slice; but `a[1:4]`, `a[x:y:2]` keep no spaces
  around the slice colons (colons act like binary operators there).
- **No space** around `=` when it is a keyword argument or a default value.
- A comparison inside a slice boundary may keep light spacing:
  `a[lower : upper]` is allowed; `a[lower:upper:step]` is preferred.

```python
# Runnable: spaced operators, tight parens, neat slices.
prices = [1, 5, 9, 12, 20]
high = len([p for p in prices if p >= 9])
print("count >= 9:", high)
print("slices equal:", prices[1:3] == prices[1:3])
```

```python eval=no
# BAD spacing                                                        # GOOD
spam( ham[ 1 ], { eggs: 2 } )                                        spam(ham[1], {eggs: 2})
a=1 ; b=2                                                             a = 1
x             = 5                                                     x = 5
if x > 0 : print( x )                                                 if x > 0:
                                                                          print(x)
```

> [!note] The right-hand column is the same logic with PEP 8 spacing — the
> listing is only for comparison, so it is marked `eval=no`. Note how the "BAD"
> column even puts the whole statement after a comment character.

## Other layout details

- **Trailing commas** are encouraged for multi-line collections and calls — 
  they make future edits one-line diffs and prevent accidental string
  concatenation:
  ```python
  names = [
      "alice",
      "bob",
  ]   # trailing comma — next name appends cleanly
  ```
- **Empty collections**: no spaces inside; `[]` and `{}` are the empty list and
  dict, not `set()`. A bare `{}` is a dict.
- Assignment operators need **one space on each side** (`x == y` to compare, 
  `x = y` to assign) — and `==` vs `=` confusion is a classic bug.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In what order does PEP 8 group import statements?"
    type: single
    choices:
      - "Local, then third-party, then stdlib, each alphabetical"
      - "stdlib, then third-party, then local, each alphabetical"
      - "Alphabetical across all modules regardless of origin"
      - "Third-party first, then stdlib, then local"
    answer: [1]
    explanation: "PEP 8 orders imports as standard library, then third-party, then local, each group sorted alphabetically and separated by blank lines."
    difficulty: 2
  - id: q2
    prompt: "Which import style does PEP 8 recommend avoiding?"
    type: single
    choices:
      - "from module import specific_name"
      - "import module"
      - "from module import *"
      - "import module as short_alias"
    answer: [2]
    explanation: "Wildcard imports put every public name into your namespace, hurting readability and risking name collisions."
    difficulty: 1
  - id: q3
    prompt: "Which whitespace style follows PEP 8?"
    type: single
    choices:
      - "foo( ham[ 1 ], { eggs: 2 } )"
      - "foo(ham[1], {eggs: 2})"
      - "foo(ham [1],{eggs : 2})"
      - "foo(ham[1], { eggs : 2 } )"
    answer: [1]
    explanation: "No spaces inside brackets/parens/braces, one space after commas. The other options add forbidden inner spaces."
    difficulty: 2
  - id: q4
    prompt: "Why are trailing commas encouraged in multi-line collections?"
    type: single
    choices:
      - "They make lines longer, which is better for the 79-column rule"
      - "They allow clean line-oriented edits and prevent accidental string concatenation"
      - "They make the collection a tuple instead of a list"
      - "They are required by the CPython parser"
    answer: [1]
    explanation: "Trailing commas make additions a one-line diff and stop adjacent string literals from merging into one."
    difficulty: 2
  - id: q5
    prompt: "What does a bare {} mean in Python?"
    type: single
    choices: ["An empty set", "An empty tuple", "An empty dictionary", "A syntax error"]
    answer: [2]
    explanation: "A bare {} is an empty dictionary; set() is required for an empty set."
    difficulty: 1
```