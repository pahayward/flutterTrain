---
id: 10-subclassing-builtins
title: Subclassing built-in classes
order: 10
section: 01-object-oriented
language: python
type: lesson
summary: Safely extend list, dict, str, and set by overriding documented hooks and understanding their limitations.
tags: [builtin, subclass, list, dict, str, set, override, oop]
prereqs: [01-oop-basics, 04-inheritance-polymorphism]
---

# Subclassing built-in classes

Python's built-in containers — `list`, `dict`, `str`, `set` — are full
classes. Subclassing them lets you add methods or override behavior while
keeping the familiar interface. The catch is understanding which internal
operations call your overridden methods and which bypass them.

> [!key] **Why it matters**
>
> The exam tests whether you understand that *some operations in C code may
> bypass overridden Python methods*. A safe subclass relies only on the
> documented hooks and exercises the rest through those hooks.

## Extending list

`list` stores items in a fast C array. Most public methods (`append`,
`extend`, `pop`, `del`) call corresponding dunder methods (`__setitem__`,
`__delitem__`, `__getitem__`), so overriding those hooks or the methods
themselves works well.

> [!trap] **`list += other` calls `__iadd__`, not `__setitem__`**
>
> If you override `__setitem__` only, `list += [3]` will silently skip it
> because `__iadd__` is defined in C and writes directly. Overriding
> `__iadd__` too fixes this. Alternatively override `extend` instead.

```python title="verbose-list.py"
class VerboseList(list):
    def append(self, item):
        print(f"appending {item}")
        super().append(item)

    def extend(self, items):
        converted = list(items)
        print(f"extending with {len(converted)} items")
        super().extend(converted)

v = VerboseList([1])
v.append(2)
v.extend([3, 4])
print(list(v))
```

## Extending dict

`dict` exposes two hooks that subclasses routinely override: `__missing__`
(called when a key is absent) and `__setitem__` (called for every assignment).
`get` calls `__getitem__` and falls back to `__missing__` if it exists.

```python title="count-dict.py"
class CountDict(dict):
    def __missing__(self, key):
        print(f"key '{key}' missing — returning 0")
        return 0

counts = CountDict()
counts["apples"] = 3
print("apples:", counts["apples"])
print("pears:", counts["pears"])
print("get mango:", counts.get("mango", 0))
```

> [!tip] **`__missing__` vs `__getitem__`**
>
> `__getitem__` handles *every* read; `__missing__` is called only when the key
> is absent. Prefer `__missing__` when you want a silent fallback for missing
> keys, and `__getitem__` when you want to intercept every access.

## Extending str

`str` is **immutable**. You cannot store extra instance state, but you can add
methods and control how the string behaves in composition. An immutable object
is inherently safe from most aliasing bugs.

```python title="title-str.py"
class Title(str):
    def titleize(self):
        return self.title()

print(Title("pCpp1").titleize())
print(isinstance(Title("x"), str))
```

## Extending set

`set` is mutable, so overriding `add`, `update`, or `discard` works via
`super()`. `set` also supports `__contains__` for membership tests.

```python title="lower-set.py"
class LowerSet(set):
    def add(self, item):
        super().add(str(item).lower())

    def __contains__(self, item):
        return super().__contains__(str(item).lower())

s = LowerSet()
s.add("PYTHON")
s.add("Python")
print(sorted(s))
print("python" in s)
```

> [!warning] **Bypassed methods in built-ins**
>
> Because built-ins are implemented in C, some code paths do not call your
> Python overrides. You must test thoroughly: use `super()` for the core
> operation and override the *high-level* method that callers actually use
> (like `append` for `list`).

## When to subclass vs when to compose

Subclassing built-ins is clean when you want a `list`-compatible type with
extra convenience methods (like `append` with logging). If you need an
interface that is *not* list-like — or you want to hide list methods —
composition (holding a list inside another object) is safer.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In class MyList(list), what is the correct way to customize append?"
    type: single
    choices:
      - "Override append and call super().append(item) to actually store the value."
      - "Override __new__ instead."
      - "You cannot subclass list."
      - "list.append is read-only."
    answer: [0]
    explanation: "super().append delegates to the C implementation; your override runs the custom logic."
    difficulty: 1
  - id: q2
    prompt: "What does __missing__ do in a dict subclass?"
    type: single
    choices:
      - "Called by __getitem__ (and get) when a key is absent."
      - "Called every time any key is accessed."
      - "Returns True if the dict is empty."
      - "Removes missing keys from the dict."
    answer: [0]
    explanation: "__missing__ is the missing-key fallback, invoked only when the key is not found."
    difficulty: 2
  - id: q3
    prompt: "Select the true statements about subclassing built-ins safely."
    type: multi
    choices:
      - "Override the documented hooks such as __setitem__ and append."
      - "Internal C code may bypass your overridden dunder methods."
      - "A str subclass is still immutable after subclassing."
      - "set.add can be overridden and must return a bool."
    answer: [0, 1, 2]
    explanation: "set.add mutates the set and returns None; only __contains__ returns bool. The first three are true."
    difficulty: 2
  - id: q4
    prompt: "Which built-in container is immutable, making it safe from accidental aliasing?"
    type: single
    choices: ["str", "list", "dict", "set"]
    answer: [0]
    explanation: "str is immutable; the other three are mutable and can be modified through shared references."
    difficulty: 1
```