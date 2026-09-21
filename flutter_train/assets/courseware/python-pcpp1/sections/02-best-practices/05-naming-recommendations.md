---
id: 05-naming-recommendations
title: "PEP 8: naming conventions & programming recommendations"
order: 5
section: 02-best-practices
language: python
summary: Name classes, functions, variables, constants, and underscores; plus PEP 8 programming recommendations.
tags: [pep8, naming, style, best-practices]
---

# PEP 8: naming conventions & programming recommendations

This module covers the two most testable halves of PEP 8: **how names should
look** and the **programming recommendations** that make code behave correctly,
not just look nice.

## What names say

| Kind | Convention | Example |
|---|---|---|
| Class (incl. exceptions) | `CapitalizedWords` (CamelCase) | `class BankAccount:` |
| Functions, methods, variables | `lowercase_with_underscores` | `def get_total():` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Modules & packages | short, `lowercase` (underscore ok) | `my_package` |
| Type names / generics | Conventionally one capital letter | `T` in `def f(x: T)` |
| "Private" attribute/method | single leading underscore | `self._cache` |
| Strong name mangling | double leading underscore | `self.__secret` |
| Dunder (special) methods | single + double underscores | `__init__`, `__repr__` |

> [!trap] A leading single underscore is a *convention* — other code can still
> access `obj._cache`. Double leading underscores trigger **name mangling**
> (`_ClassName__secret`), which is real, but only within a class. Neither is a
> true `private` keyword.

Avoid single-letter names other than common loop variables and throwaway
values; PEP 8 singles out `l`, `O`, and `I` because they look like `1` and `0`.

```python
class Point:
    def __init__(self, x, y):
        self.x = x            # short attribute names are fine
        self.y = y


def manhattan(p, q):
    """Distance between two points moving on a grid."""
    return abs(p.x - q.x) + abs(p.y - q.y)


a = Point(0, 0)
b = Point(3, 4)
print("manhattan distance:", manhattan(a, b))
```

## The throwaway underscore

`_` is the conventional name for a value you will not use — a loop variable or
an unpacked element:

```python
points = [(1, "a"), (2, "b"), (3, "c")]
for _, label in points:
    print("label:", label)
```

## Programming recommendations (behavior)

PEP 8 pairs its style rules with advice that changes *correctness*:

- **Compare singletons with `is` / `is not`**, not `==`. `None` is the common
  case, and `x is None` is both idiomatic and exact.
- **Never compare to `True` or `False`** with `==` or `is`. Write `if x:`
  directly.
- **Use `in` and `.startswith()`** instead of clunkier checks.
- **Do not use `==` to check types** — use `isinstance(x, int)`, which also
  respects subclasses.
- For sequences, **test emptiness with `if seq:`** rather than
  `if len(seq) != 0:`.

```python
def process(items, cache=None):
    # Mutable default argument trap avoided with None sentinel.
    if cache is None:
        cache = {}
    for item in items:
        cache[item] = len(item)
    return cache


print(process(["aa", "b"]))
print(process(["z"], cache={"existing": 99}))
```

```python
class Greeter:
    pass


class Friend(Greeter):
    pass


someone = Friend()
print("isinstance works for subclasses:", isinstance(someone, Greeter))
print("type()== does not:", type(someone) == Greeter)
```

## Exceptions and flow

- Raise meaningfully: `raise ValueError("negative not allowed")` instead of a
  bare `raise` from nowhere, and prefer specific exception types over sweeping
  `except Exception`.
- **Catch what you can handle.** A broad `except:` that swallows everything
  hides bugs — violating the Zen ("errors should never pass silently").
- If a caller passes a wrong type, `isinstance` lets you fail early and clearly
  instead of crashing at line 40 of a big function.

```python eval=no
# BAD                                                      # GOOD
if rate == 0:                                              if rate == 0:
    pass                                                       raise ValueError("rate must be > 0")
if spam == True:                                           if spam:
if eggs == False:                                          if not eggs:
if type(item) == int:                                      if isinstance(item, int):
if len(items) > 0:                                         if items:
```

> [!note] A "bad vs good" comparison — listed as `eval=no` since the pair
> teaches style rather than execution.

## Summary table for last-minute review

- Classes: `CamelCase`. Functions, variables, methods: `snake_case`.
- Constants: `UPPER_SNAKE`. Private-by-convention: `_x`. Mangling: `__x`.
- `None` → `is` / `is not`. Booleans → truthiness. Types → `isinstance()`.
- Emptiness → `if seq:`. Exceptions → specific, with meaningful messages.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which naming style does PEP 8 prescribe for class names?"
    type: single
    choices:
      - "UPPER_SNAKE_CASE"
      - "lowercase_with_underscores"
      - "CapitalizedWords (CamelCase)"
      - "ALLCAPS single words"
    answer: [2]
    explanation: "Classes and exceptions use CapitalizedWords; functions, methods, and variables use snake_case."
    difficulty: 1
  - id: q2
    prompt: "What happens to an attribute named __x inside a class?"
    type: single
    choices:
      - "It becomes completely private and inaccessible"
      - "It is erased at runtime"
      - "Its name is mangled to _ClassName__x for the class"
      - "It raises a SyntaxError"
    answer: [2]
    explanation: "Double leading underscores cause name mangling within the class, an attempt at privacy, not a true private keyword."
    difficulty: 2
  - id: q3
    prompt: "How should you test whether a list is empty, per the recommendations?"
    type: single
    choices:
      - "if len(my_list) > 0:"
      - "if len(my_list) == 0:"
      - "if my_list:"
      - "if type(my_list) is list:"
    answer: [2]
    explanation: "PEP 8 recommends testing sequences directly for truthiness: if seq: covers the non-empty case, if not seq: the empty one."
    difficulty: 2
  - id: q4
    prompt: "What is the correct way to check a value is None?"
    type: single
    choices:
      - "if value == None:"
      - "if value is None:"
      - "if value == True:"
      - "if value:"
    answer: [1]
    explanation: "None is a singleton, so identity comparison with is (or is not) is the PEP 8-recommended check."
    difficulty: 1
  - id: q5
    prompt: "Why does PEP 8 prefer isinstance(x, int) over type(x) == int?"
    type: single
    choices:
      - "isinstance is faster in every case"
      - "isinstance also returns True for subclasses of int"
      - "type() returns a string, so the comparison never works"
      - "type() only works in interactive mode"
    answer: [1]
    explanation: "isinstance respects inheritance, so a subclass instance is accepted too; == on type() misses it."
    difficulty: 2
```