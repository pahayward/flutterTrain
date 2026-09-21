---
id: 07-static-class-methods
title: Static and class methods
order: 7
section: 01-object-oriented
language: python
type: lesson
summary: The difference between instance methods, class methods (@classmethod), and static methods (@staticmethod).
tags: [classmethod, staticmethod, cls, alternative-constructor, oop]
prereqs: [01-oop-basics, 06-args-kwargs-decorators]
---

# Static and class methods

Python classes support three kinds of methods. Each receives a different first
argument (or none at all), and each serves a distinct purpose.

| Kind | Decorator | First arg | Knows the instance? |
|---|---|---|---|
| Instance method | — | `self` (the instance) | Yes |
| Class method | `@classmethod` | `cls` (the class) | No — but knows the class |
| Static method | `@staticmethod` | None | No |

## Instance method (baseline)

An ordinary method receives the instance as `self` and reads or modifies
instance data.

```python title="instance-method.py"
class Counter:
    def __init__(self, start=0):
        self.value = start

    def increment(self):
        self.value += 1
        return self.value

c = Counter(10)
print(c.increment())   # 11
print(c.increment())   # 12
```

## Class methods: shared state and alternative constructors

A `@classmethod` receives the *class itself* as its first argument, `cls`.
This lets it modify class-level state (not instance state) and is the
standard way to write alternative constructors.

```python title="classmethod.py"
class Registry:
    count = 0
    roster = []

    def __init__(self, name):
        self.name = name
        Registry.count += 1
        Registry.roster.append(name)

    @classmethod
    def how_many(cls):
        return cls.count

    @classmethod
    def names(cls):
        return list(cls.roster)

Registry("first")
Registry("second")
print(Registry.how_many())
print(Registry.names())
```

> [!tip] **`cls` vs the class name**
>
> Use `cls` — not the class literal — so that subclass calls inherit
> correctly. If `Registry.names()` hard-codes `Registry.roster`, a subclass
> `VeteranRegistry` still reaches the same shared list. Using `cls` avoids that
> bug for future subclasses.

## Alternative constructors

A classmethod that calls `cls(...)` is the idiomatic way to add extra
constructors without duplicating logic:

```python title="temp.py"
class Temperature:
    def __init__(self, kelvin):
        self.kelvin = kelvin

    @classmethod
    def from_celsius(cls, c):
        return cls(c + 273.15)

    @classmethod
    def from_fahrenheit(cls, f):
        return cls((f - 32) * 5 / 9 + 273.15)

    def __repr__(self):
        return f"Temperature({self.kelvin:.2f} K)"

print(Temperature.from_celsius(25))
print(Temperature.from_fahrenheit(212))
```

Because `from_celsius` calls `cls(...)`, a subclass like
`SafeTemperature(Temperature)` gets its own type back without overriding the
classmethod — no code duplication.

> [!note] **`super()` in an alternative constructor**
>
> A subclass that overrides `__init__` can still use `super().__init__` inside
> the classmethod: `cls.__mro__` is respected. The point is that `cls` is
> bound by the caller.

## Static methods: unbound utilities

A `@staticmethod` takes neither `self` nor `cls`. It behaves like a plain
function that is just scoped inside the class namespace — useful for small
helpers that do not need the class or any instance.

```python title="staticmethod.py"
class MathUtils:
    @staticmethod
    def clamp(value, lo, hi):
        return max(lo, min(hi, value))

print(MathUtils.clamp(5, 0, 10))
print(MathUtils.clamp(-3, 0, 10))

mu = MathUtils()
print(mu.clamp(99, 0, 10))
```

> [!warning] **Don't confuse classmethods with staticmethods**
>
> A common exam trap: asking for the parameter that lets a method *modify the
> class state*. That is only the classmethod's `cls`. A staticmethod cannot
> access the class at all.

## When to use each

- **Instance method** — the default; you need the instance's data.
- **Class method** — alternative constructors, class-level mutations, factory
  patterns.
- **Static method** — utility logic that logically belongs to the class but
  needs neither the class nor any instance.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "A @classmethod receives what as its first argument?"
    type: single
    choices:
      - "The class itself, conventionally called cls."
      - "The instance, conventionally called self."
      - "Nothing at all."
      - "A copy of the class dictionary."
    answer: [0]
    explanation: "cls is the class that was called; it is not the parent class literal."
    difficulty: 1
  - id: q2
    prompt: "Select the typical uses of @classmethod."
    type: multi
    choices:
      - "Alternative constructors like from_string or from_celsius."
      - "Modifying class-level state such as a counter or registry."
      - "Utility functions that need no access to the class or an instance."
      - "Setting a single instance's attribute to a default."
    answer: [0, 1]
    explanation: "classmethods know the class; staticmethods are for utilities, and the last item is an instance-level action."
    difficulty: 2
  - id: q3
    prompt: "Which best describes a @staticmethod?"
    type: single
    choices:
      - "It does not receive self or cls."
      - "It always receives cls."
      - "It is called on the metaclass."
      - "It automatically makes the function private."
    answer: [0]
    explanation: "staticmethods are pure utility functions scoped inside a class, with no implicit arguments."
    difficulty: 1
  - id: q4
    prompt: "An alternative constructor like Temperature.from_celsius calls cls(c + 273.15). Why use cls instead of the literal class name?"
    type: single
    choices:
      - "Subclasses get their own type back, since cls is the actual class."
      - "cls is required by the Python grammar."
      - "The class name is not accessible inside a method."
      - "It prevents subclassing."
    answer: [0]
    explanation: "Using cls ensures the MRO is respected and a subclass gets its own type without overriding the factory."
    difficulty: 2
```