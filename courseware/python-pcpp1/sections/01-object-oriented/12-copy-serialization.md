---
id: 12-copy-serialization
title: "Shallow & deep copy + (de)serialization"
order: 12
section: 01-object-oriented
language: python
type: lesson
summary: Compare objects with id()/is, distinguish shallow vs deep copies, and persist objects with pickle and shelve.
tags: [copy, deepcopy, shallow, id, is, pickle, shelve, serialization]
prereqs: [01-oop-basics]
---

# Shallow & deep copy + (de)serialization

This module covers two grouping of skills: comparing object identity, then
copying and persisting objects. Together they explain why `a == b` can be
`True` while `a is b` is `False`.

## Identity: id() and is

- `id(obj)` returns a process-unique integer identifying the object (often the
  memory address).
- `a is b` is short for `id(a) == id(b)`.
- `a == b` compares *values* (via `__eq__`); `a is b` compares *identity*.

```python title="identity.py"
a = [1, 2]
b = a
c = [1, 2]
print("b is a:", b is a)     # same object
print("c is a:", c is a)     # different objects
print("c == a:", c == a)     # equal values
print("small ints: 7 == 7:", 7 == 7, "7 is 7:", 7 is 7)
print("True is 1:", True is 1, "True == 1:", True == 1)
```

> [!key] **is vs ==**
>
> Use `is` (or `is not`) to test identity — the canonical case is comparing to
> `None` (`value is None`). Use `==` to test value equality. Never rely on
> `id` as a "unique forever" key: ids can be reused after garbage collection.

## Shallow copy: copy.copy

`copy.copy(obj)` (shallow copy) creates a **new container** but the *contents*
are the same objects. Nested mutable objects are **shared** between the
original and the copy.

## Deep copy: copy.deepcopy

`copy.deepcopy(obj)` recursively duplicates everything, including nested
lists, dicts, and objects. The result shares **nothing** with the original.

```python title="copy.py"
import copy

original = [1, [2, 3], {"n": 4}]
shallow = copy.copy(original)
deep = copy.deepcopy(original)

print("shallow shares inner list:", original[1] is shallow[1])
print("deep owns its inner list:", original[1] is deep[1])

shallow[1].append(99)
print("original after shallow mutation:", original[1])
print("deep after shallow mutation:", deep[1])
```

> [!trap] **A shallow copy is not a deep copy**
>
> Modifying a nested object through a shallow copy changes the original too —
> they share it. This is the #1 cause of subtle bugs. Use `deepcopy` when the
> structure contains mutable nested objects.

> [!note] **`copy.copy` also duplicates immutable types safely**
>
> Copying an `int` or `str` returns the object itself; that is fine because
> immutable objects cannot be modified through a shared reference.

## Serialization with pickle

`pickle` converts a Python object graph to bytes and back. Use `dumps` to get
bytes, `loads` to restore. In-memory serialization is convenient and touches
no disk (shown below); files are equally simple with `dump`/`load`.

```python title="pickle-io.py"
import pickle
import io

payload = {"name": "Ada", "scores": [3, 1, 4], "ratio": 0.5}
buf = io.BytesIO()
pickle.dump(payload, buf)
print("serialized bytes:", len(buf.getvalue()))

buf.seek(0)
restored = pickle.load(buf)
print(restored)
print("same values:", restored == payload)
print("independent copy:", restored is not payload)
```

> [!note] **Custom classes and scope**
>
> Classes defined in a real module are pickled *by reference* to their module
> path (`module.QualName`). A class created inside an `exec` block (as in this
> playground) cannot be pickled because there is no importable module to point
> at — a good reminder to only pickle classes defined at module top level.

> [!warning] **Never unpickle untrusted data**
>
> `pickle.loads` can execute arbitrary code during deserialization. Only load
> data you trust. JSON is safe to exchange between systems; pickle is a Python
> implementation-specific format.

## Persistence with shelve

`shelve` is a persistent, dict-like database whose values can be any picklable
object. Use a `with` context manager to ensure buffers are flushed. Keys must
be strings.

```python title="shelve-demo.py"
import shelve
import tempfile
import os
import shutil

tmp = tempfile.mkdtemp()
path = os.path.join(tmp, "prefs")

with shelve.open(path) as db:
    db["theme"] = "dark"
    db["volume"] = 0.8

with shelve.open(path) as db:
    print(db["theme"], db["volume"])

shutil.rmtree(tmp, ignore_errors=True)
```

> [!note] **shelve on disk**
>
> `shelve.open(path)` uses an underlying database file (dbm); assigning a value
> with a string key stores it compressed/pickled. On Android the app sandbox
> provides a writable scratch directory exactly for this pattern.

## Deep copy vs pickle on custom classes

Both `deepcopy` and `pickle` handle custom classes, but they differ:
`pickle` serializes to bytes (or files); `deepcopy` duplicates in memory and
works even without pickling support (e.g., lambdas and open file handles
cannot be pickled but may be deep-copied).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "a in a == b compares what vs what?"
    type: single
    choices:
      - "== compares values; is compares identity."
      - "== compares identity; is compares values."
      - "Both compare memory addresses."
      - "Both compare the class name only."
    answer: [0]
    explanation: "== goes through __eq__ and compares values; is compares identity via id()."
    difficulty: 1
  - id: q2
    prompt: "After copy.copy(lst), what is shared between the original and the copy?"
    type: single
    choices:
      - "The nested mutable objects."
      - "The outer list object itself."
      - "Nothing at all."
      - "Only the integers at the top level."
    answer: [0]
    explanation: "A shallow copy duplicates the outer container but shares every nested object."
    difficulty: 2
  - id: q3
    prompt: "Which statement about pickle and deepcopy is true?"
    type: single
    choices:
      - "pickle yields a byte stream; deepcopy yields an in-memory copy."
      - "pickle and deepcopy always return the same object."
      - "deepcopy accepts only strings."
      - "pickle cannot serialize any custom class."
    answer: [0]
    explanation: "pickle serializes to bytes or files and back; deepcopy clones in memory."
    difficulty: 2
  - id: q4
    prompt: "Select the true statements about shelve."
    type: multi
    choices:
      - "It behaves like a persistent dictionary."
      - "Keys must be strings."
      - "Values must be picklable objects."
      - "You may store integer keys."
    answer: [0, 1, 2]
    explanation: "shelve requires string keys; values are stored as pickled blobs."
    difficulty: 2
```