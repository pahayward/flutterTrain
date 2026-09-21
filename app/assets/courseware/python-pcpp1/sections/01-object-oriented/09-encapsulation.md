---
id: 09-encapsulation
title: Attribute encapsulation
order: 9
section: 01-object-oriented
language: python
type: lesson
summary: Controlled access with properties, getters/setters/deleters, and Python's name-mangling rules.
tags: [encapsulation, property, getter, setter, deleter, name-mangling, oop]
prereqs: [01-oop-basics, 03-magic-methods]
---

# Attribute encapsulation

Python does not enforce access control, but it provides **conventions** and
**mechanisms** that make the intent clear and let you intercept attribute
reads, writes, and deletes without changing the caller's syntax.

## Public, protected, private

| Convention | Example | Meaning |
|---|---|---|
| public | `self.name` | Readable and writable everywhere. |
| `_protected` | `self._name` | **Convention only** — "intended for internal use." No runtime enforcement. |
| `__private` | `self.__name` | Name-mangled to `self._ClassName__name` at class-body level. |

> [!trap] **Python's "private" is a mangling, not a wall**
>
> `_protected` is purely a convention; `__private` is name-mangled
> automatically, but external code can still reach `_ClassName__name` if it
> wants to. Both are meant to express intent, not to guarantee security.

## Properties: controlled attribute access

The `property` built-in (and its decorator forms) lets you intercept reads,
writes, and deletes via familiar attribute syntax. This is the standard
mechanism for validation and computed attributes.

```python title="thermostat.py"
class Thermostat:
    def __init__(self, celsius=20.0):
        self._celsius = celsius

    @property
    def celsius(self):
        return self._celsius

    @celsius.setter
    def celsius(self, value):
        if value < -273.15:
            raise ValueError("below absolute zero")
        self._celsius = value

    @celsius.deleter
    def celsius(self):
        print("deleting temperature")
        del self._celsius

t = Thermostat(21)
print(t.celsius)
t.celsius = 30
print(t.celsius)

try:
    t.celsius = -999
except ValueError:
    print("caught")

del t.celsius
```

The user sees `t.celsius = 30` — plain assignment. Internally the setter runs
first, validating the value before storing it.

> [!note] **Read-only properties**
>
> Omit the `@celsius.setter` (and `@celsius.deleter`). A write attempt then
> raises `AttributeError`. This is a clean way to expose a computed attribute.

## Computed properties

A property that has no `setter` can compute its value on the fly:

```python title="computed-area.py"
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height

    @property
    def area(self):
        return self.width * self.height

r = Rectangle(3, 4)
print("area:", r.area)

try:
    r.area = 12
except AttributeError:
    print("area is read-only")
```

## Name mangling: double underscore prefixes

A name with **two leading underscores** inside a class body is silently
rewritten to `_ClassName__name`. This avoids accidental collisions in
inheritance, but it does not make the attribute invisible.

```python title="mangling.py"
class Secret:
    def __init__(self):
        self.__code = 42
        self.public = "open"

    def reveal(self):
        return self.__code

s = Secret()
print(s.reveal(), s.public)
print(s._Secret__code)     # mangling rule applied manually

try:
    s.__code               # no attribute without the class prefix
except AttributeError:
    print("__code is inaccessible via that name outside the class")
```

> [!tip] **When mangling matters**
>
> If a subclass defines `__code` too, the two attributes do not collide
> because they are stored under different mangled names. This is the main
> reason mangling exists — safe subclass naming, not security.

## Putting it together: getter, setter, deleter

All three operations in one place make the interface complete. The pattern is
common in exam questions and in real-world libraries.

```python title="full-property.py"
class Cached:
    def __init__(self, value):
        self._value = value

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, new_val):
        print(f"setting value to {new_val}")
        self._value = new_val

    @value.deleter
    def value(self):
        print("clearing value")
        self._value = None

c = Cached(10)
print(c.value)
c.value = 20
del c.value
print(c.value)
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the purpose of the @property decorator?"
    type: single
    choices:
      - "To make a method behave like a readable attribute."
      - "To make a method private to the class."
      - "To mark a method as deprecated."
      - "To cache the return value of a method."
    answer: [0]
    explanation: "@property turns a method into a descriptor that intercepts attribute reads (and optionally writes/deletes)."
    difficulty: 1
  - id: q2
    prompt: "Why include a setter on a property?"
    type: single
    choices:
      - "To add validation or side-effects when the attribute is assigned."
      - "To delete the attribute."
      - "To make the attribute read-only."
      - "To rename the attribute at runtime."
    answer: [0]
    explanation: "A setter intercepts assignments so you can validate or transform values before storing them."
    difficulty: 1
  - id: q3
    prompt: "If class K has an attribute __secret, how does it appear outside K?"
    type: single
    choices:
      - "As _K__secret after name mangling."
      - "As __K__secret."
      - "As K__secret."
      - "It is inaccessible."
    answer: [0]
    explanation: "Two leading underscores trigger mangling: __secret becomes _K__secret."
    difficulty: 2
  - id: q4
    prompt: "Select the true statements about name mangling."
    type: multi
    choices:
      - "It applies to names with two leading underscores."
      - "It does not apply to names with trailing underscores."
      - "Mangled names remain accessible if you know the pattern."
      - "It provides true runtime access control."
    answer: [0, 1, 2]
    explanation: "Mangling is a syntactic transform to avoid collisions; it is not a security boundary."
    difficulty: 2
```