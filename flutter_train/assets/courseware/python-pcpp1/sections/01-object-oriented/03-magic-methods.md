---
id: 03-magic-methods
title: Magic methods
order: 3
section: 01-object-oriented
language: python
type: lesson
summary: "Dunder methods that make objects behave like built-ins: __eq__, __abs__, __int__, __str__, __repr__, __getattr__, __getitem__, __iter__, __len__, __hash__."
tags: [magic-methods, dunder, protocol, operators, oop]
prereqs: [01-oop-basics]
---

# Magic methods

Magic (dunder) methods are the double-underscore hooks Python calls behind the
scenes so your objects behave like built-ins. Write `X == Y` and Python
silently invokes `X.__eq__(Y)`. Write `len(obj)` and Python invokes
`obj.__len__()`. There is no syntax these methods do not unlock.

> [!key] **"Extending core syntax"**
>
> Defining a dunder is the standard way to make a plain class participate in
> Python's core syntax and operators: `==`, `str()`, `int()`, `abs()`,
> indexing, iteration, `len()`, hashing, argument unpacking, and more.

## The object trio: __str__, __repr__, __eq__

- `__repr__` — the **unambiguous** representation, meant for developers. Fallback
  printed in lists and at the REPL.
- `__str__` — the **readable** representation, used by `str()` and `print()`.
- `__eq__` — the equality operator. If types do not match, return `NotImplemented`.

```python title="money.py"
class Money:
    def __init__(self, amount, currency="USD"):
        self.amount = amount
        self.currency = currency

    def __str__(self):
        return f"{self.amount} {self.currency}"

    def __repr__(self):
        return f"Money({self.amount!r}, {self.currency!r})"

    def __eq__(self, other):
        if not isinstance(other, Money):
            return NotImplemented
        return (self.amount, self.currency) == (other.amount, other.currency)

    def __hash__(self):
        return hash((self.amount, self.currency))

    def __add__(self, other):
        if self.currency != other.currency:
            raise ValueError("currency mismatch")
        return Money(self.amount + other.amount, self.currency)

    def __abs__(self):
        return Money(abs(self.amount), self.currency)

    def __int__(self):
        return int(self.amount)

m1 = Money(10, "USD")
m2 = Money(10, "USD")
m3 = Money(-5, "EUR")
print(m1)                  # str()
print(repr(m1))            # repr
print(m1 == m2, m1 == m3)  # __eq__
print(abs(m3))             # __abs__
print(int(m3))             # __int__
print(m1 + Money(7, "USD"))  # __add__
print({m1, m2, m3})        # __hash__ + __eq__ enable set membership
```

> [!note] **`print(x)` uses `__str__`**
>
> A bare `x` at the REPL would use `__repr__`; inside `print()` it is `__str__`.
> In script examples we call `repr(x)` explicitly to show both.

## Container and size protocols: __len__, __getitem__, __iter__

`len(obj)` requires `__len__` to return a non-negative integer. Indexing
`obj[i]` and slicing call `__getitem__`. Iteration calls `__iter__`, which
returns an iterator object (here we reuse `iter(self._items)`).

> [!trap] **`len()` must be a non-negative int**
>
> Returning a float, a negative value, or a huge value raises `ValueError`.
> Do not use `len()` to signal "absence" with -1.

```python title="inventory.py"
class Inventory:
    def __init__(self, items=None):
        self._items = list(items or [])

    def __len__(self):
        return len(self._items)

    def __getitem__(self, index):
        return self._items[index]

    def __iter__(self):
        return iter(self._items)

bag = Inventory(["rope", "map", "lantern"])
print(len(bag))          # __len__
print(bag[0], bag[2], bag[-1])  # __getitem__
for item in bag:
    print(item.title())  # __iter__
```

## Fallback hooks: __getattr__

`__getattr__` runs **only when normal attribute lookup fails**. It lets you
produce dynamic attributes (for example a missing key, a lazy value, or a
helphul default) instead of raising `AttributeError`.

```python
class Config:
    def __init__(self, values):
        self._values = values

    def __getattr__(self, name):
        if name in self._values:
            return self._values[name]
        raise AttributeError(name)

cfg = Config({"debug": True})
print(cfg.debug)                 # found through __getattr__
print(cfg._values)               # real attribute, normal lookup
try:
    cfg.missing
except AttributeError:
    print("AttributeError raised for unknown name")
```

> [!warning] **`__getattr__` is not `__setattr__`**
>
> `__getattr__` only handles *reads of missing* attributes. Writes and
> set-on-every-attempt hooks are separate: `__setattr__` (all writes) and
> `__getattribute__` (all reads). Overwriting those is advanced and easy to get
> wrong — prefer `property` for validation (see module 09).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the main purpose of __repr__?"
    type: single
    choices:
      - "An unambiguous representation mainly used for debugging."
      - "The pretty string shown to end users."
      - "The hash value of the object."
      - "The length of the object."
    answer: [0]
    explanation: "__repr__ is developer-facing and should be unambiguous; __str__ is user-facing and readable."
    difficulty: 1
  - id: q2
    prompt: "You define __eq__ without defining __hash__. What happens when you try to use an instance in a set?"
    type: single
    choices:
      - "A TypeError is raised because instances become unhashable."
      - "hash() silently uses id()."
      - "The set stores it using __str__."
      - "Nothing changes."
    answer: [0]
    explanation: "Defining __eq__ sets __hash__ to None unless you define it explicitly, so instances become unhashable."
    difficulty: 2
  - id: q3
    prompt: "Select the methods that make len(obj) and obj[i] work."
    type: multi
    choices: ["__len__", "__getitem__", "__iter__", "__next__"]
    answer: [0, 1]
    explanation: "__len__ powers len(); __getitem__ powers indexing. __iter__/__next__ handle iteration."
    difficulty: 1
  - id: q4
    prompt: "When is __getattr__ called?"
    type: single
    choices:
      - "Only when normal attribute lookup fails."
      - "For every attribute read."
      - "Only for attributes starting with underscore."
      - "When the object is about to be destroyed."
    answer: [0]
    explanation: "__getattr__ is a fallback for missing attributes; the eager hooks are __getattribute__ and __setattr__."
    difficulty: 2
```