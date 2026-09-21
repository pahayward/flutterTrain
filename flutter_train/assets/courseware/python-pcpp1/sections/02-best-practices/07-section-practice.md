---
id: 07-section-practice
title: Section 2 Practice
order: 7
section: 02-best-practices
language: python
summary: Rapid review of PEPs, PEP 8 layout, naming, docstrings, and type hints, with exam-style questions.
tags: [pep, pep8, pep20, pep257, pep484, review]
---

# Section 2 Practice

A compact, last-minute review of everything from this section. Use it to check
you can *recall*, not just recognize.

## PEPs you must name

- **PEP 1** — what a PEP is: types (Standards Track, Informational, Process),
  formats (header + rationale + spec), and statuses (Draft → Accepted → Final,
  Rejected, Superseded...).
- **PEP 20** — the Zen of Python: 19 aphorisms; know the *meaning* words:
  explicit/implicit, simple/complex, readability, one obvious way, errors
  should not pass silently, now vs never, namespaces.
- **PEP 8** — style: layout, imports, whitespace, comments, naming,
  programming recommendations.
- **PEP 257** — docstring conventions: one-line vs multi-line, position,
  closing quotes.
- **PEP 484** — type hints: annotations, `Optional`, builtin generics; used by
  `mypy`, not enforced at runtime.

## PEP 8 cheat sheet

- **Layout:** 4 spaces; continuation via parentheses; 79 columns (72 for
  comments/docstrings); operator-first wraps; 2 blank lines at top level,
  1 between methods; UTF-8 default.
- **Imports:** top of file; stdlib → third-party → local, alphabetized,
  blank lines between groups; no `*`.
- **Whitespace:** one space around binary operators, none inside brackets,
  one space after commas; no space around `=` in defaults/keyword args;
  trailing commas in multi-line literals.
- **Comments:** say why; `# ` after indent; 2+ spaces before inline `#`.
- **Naming:** `CamelCase` classes, `snake_case` funcs/vars/methods,
  `UPPER_SNAKE` constants, `_private`, `__mangled`, avoid `l/O/I`.
- **Behavior:** `is None` not `== None`; truthiness instead of
  `== True/False`; `isinstance()` not `type() ==`; `if seq:` not `if len(seq)`.

```python
# Example: every review rule in one tiny module.
MAX_RETRIES = 3


class RetryCounter:
    def __init__(self, limit=MAX_RETRIES):
        self.left = limit

    def use(self):
        if self.left is None:          # singleton comparison, not == None
            raise ValueError("already exhausted")
        self.left -= 1
        return self.left


r = RetryCounter()
print(r.use(), r.use(), r.use())
```

```python
def cache(hits, miss=None):
    """Return a hits counter, computing it on first call."""
    if hits is None:
        hits = 0
    hits += 1
    return hits


print("hit counts:", cache(None), cache(None))
print("docstring:", cache.__doc__.strip())
```

## Before the exam bank

Self-test these six moves quickly — each is worth a question or two:

1. `import this` prints the **Zen of Python** — not a poem or system info.
2. 79/72, 4-space indent, 2/1 blank lines are the numbers to know cold.
3. `from os import *` is the import style to **avoid**.
4. `.startswith()`, `in`, truthiness, `is None`, `isinstance` replace the
   clunky alternatives.
5. Docstrings live in `__doc__` and appear in `help()`; comments do not.
6. `Optional[int]`, `int | None`, and `list[int]` are PEP 484 hints — and every
   annotate/call pair the examiner likes.

## ExamQuestions

```yaml
bank:
  - prompt: "What is a PEP used for in the Python ecosystem?"
    type: single
    choices:
      - "A bug report submitted by users"
      - "A design document proposing or recording a change to Python"
      - "A compiled binary distribution of a module"
      - "The name of the Python package manager"
    answer: [1]
    explanation: "A Python Enhancement Proposal is a design document describing a new language feature, standard, process, or informational guideline."
    section: 02-best-practices
    weight: 4
    difficulty: 1
  - prompt: "Which PEP establishes the process for writing and approving PEPs themselves?"
    type: single
    choices: ["PEP 20", "PEP 1", "PEP 8", "PEP 257"]
    answer: [1]
    explanation: "PEP 1 defines the purpose, types, format, statuses, and guidelines of the PEP process."
    section: 02-best-practices
    weight: 4
    difficulty: 2
  - prompt: "Which Zen of Python aphorism matches 'the if-statement should fail loudly when given bad data'?"
    type: single
    choices:
      - "Nationality is not the subject of this class."
      - "Errors should never pass silently."
      - "Although practicality beats purity."
      - "Now is better than never."
    answer: [1]
    explanation: "Failing loudly on bad data is 'errors should never pass silently' in practice."
    section: 02-best-practices
    weight: 4
    difficulty: 1
  - prompt: "Where do PEP 8-smart programmers place imports in a module file?"
    type: single
    choices:
      - "At the point where they are first used"
      - "At the very end of the file"
      - "At the top, after the module docstring, grouped as stdlib/third-party/local"
      - "Bundled into one def at the bottom"
    answer: [2]
    explanation: "PEP 8 wants imports at the top, in three alphabetized groups separated by blank lines, after the module docstring."
    section: 02-best-practices
    weight: 4
    difficulty: 1
  - prompt: "Which snippet follows PEP 8's programming recommendations?"
    type: single
    choices:
      - "if x == True:"
      - "if x is not None:"
      - "if type(x) == int:"
      - "if len(lst) > 0:"
    answer: [1]
    explanation: "None-ness is checked with is; True/False tests use truthiness, types use isinstance, emptiness uses if lst:."
    section: 02-best-practices
    weight: 4
    difficulty: 2
  - prompt: "A member named __token, defined inside class Server, becomes which actual attribute?"
    type: single
    choices:
      - "server.__token"
      - "__token"
      - "_Server__token"
      - "token_private"
    answer: [2]
    explanation: "Name mangling turns __token into _Server__token inside the class, an attempt at privacy."
    section: 02-best-practices
    weight: 4
    difficulty: 2
  - prompt: "What prints from this code?\n\nprint(celsius_to_fahrenheit.__doc__)\n\ndef celsius_to_fahrenheit(c):\n    \"\"\"Convert Celsius degrees to Fahrenheit.\"\"\""
    type: single
    choices:
      - "None"
      - "Convert Celsius degrees to Fahrenheit."
      - "A TypeError"
      - "The function's source code"
    answer: [1]
    explanation: "A function's first string is its docstring, exposed as __doc__, so print shows the sentence."
    section: 02-best-practices
    weight: 4
    difficulty: 2
```