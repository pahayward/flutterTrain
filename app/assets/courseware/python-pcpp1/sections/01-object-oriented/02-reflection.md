---
id: 02-reflection
title: "Reflection: isinstance, issubclass, type checks"
order: 2
section: 01-object-oriented
language: python
type: lesson
summary: Introspect objects and classes at runtime with isinstance, issubclass, and type.
tags: [reflection, isinstance, issubclass, type, introspection]
prereqs: [01-oop-basics]
---

# Reflection: isinstance, issubclass, type checks

Reflection means a program can inspect its own objects at runtime. Python
gives you three workhorses for type inspection: `isinstance`, `issubclass`,
and `type`.

- `isinstance(obj, cls)` — is `obj` an instance of `cls` **or of a subclass**
  of `cls`?
- `issubclass(sub, base)` — is `sub` a class derived from `base` (or the same
  class)?
- `type(obj)` — the **exact** class the object was instantiated as.

## isinstance: instance checks that respect inheritance

`isinstance` walks the whole inheritance chain. A `Dog` is "an `Animal`" too,
because `Dog` inherits from `Animal`.

```python title="reflection.py"
class Animal:
    pass

class Dog(Animal):
    pass

d = Dog()
print(isinstance(d, Dog))      # True
print(isinstance(d, Animal))   # True, honors inheritance
print(isinstance(d, object))   # everything is an object
print(type(d) is Dog)          # exact type is Dog
print(issubclass(Dog, Animal)) # Dog derives from Animal
print(issubclass(Dog, object))
```

> [!key] **Major rule**
>
> `isinstance` follows the class tree; `type(...) is SomeClass` gives the exact
> class. Prefer `isinstance` when you accept subtypes (that is almost always).

## Multiple types in one check

Both built-ins accept a **tuple of classes**. The check returns `True` if any
of them matches. This keeps your code short and clear.

`issubclass` accepts a tuple for the base argument too.

```python title="tuple-check.py"
class Animal:
    pass

class Dog(Animal):
    pass

class Cat(Animal):
    pass

print(isinstance(Dog(), (Dog, Cat)))       # True
print(isinstance(Cat(), (Dog, Cat)))       # True
print(issubclass(Dog, (Cat, Animal)))      # True (Animal is in the tuple)
print(issubclass(Dog, (Cat,)))
```

## The bool/int trap

`bool` is a subclass of `int` in Python. So `isinstance(True, int)` is `True`,
while `type(True) is int` is `False`. This produces surprising results in
code that branches on `type(obj) is int`.

```python
print(isinstance(True, int))    # True  -> bool inherits from int
print(type(True) is int)        # False -> the exact type is bool
print(type(True) is bool)       # True
print(issubclass(bool, int))    # True
```

> [!trap] **Never rely on `type(x) is int` for booleans**
>
> Numeric code that rejects `True`/`False` often wants `isinstance(x, int)`
> *and* `type(x) is not bool`, or `isinstance(x, (int, bool))` depending on
> intent. Check the exam wording carefully.

## Probing an object's own class

Every instance knows its class through the `__class__` attribute, which
`type(obj)` reports as well. You can use it to fetch fresh instances or to
branch on the concrete type.

```python
class Animal:
    pass

class Dog(Animal):
    pass

d = Dog()
print(d.__class__.__name__)
print(type(d) is d.__class__)   # True
print(isinstance(d, d.__class__))
```

> [!note] **`issubclass` needs classes**
>
> `issubclass(3, int)` raises `TypeError` because `3` is an instance, not a
> class. Swap the arguments: `isinstance(3, int)`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which of these expressions evaluates to True?"
    type: single
    choices:
      - "isinstance([], (list, tuple))"
      - "isinstance(list, tuple)"
      - "isinstance(3.5, int)"
      - "issubclass(3, int)"
    answer: [0]
    explanation: "An empty list is an instance of list; the other three are false or raise TypeError (issubclass needs classes)."
    difficulty: 2
  - id: q2
    prompt: "Select the correct statements."
    type: multi
    choices:
      - "bool is a subclass of int, so isinstance(True, int) is True."
      - "type(True) is bool, not int."
      - "isinstance(True, int) is False."
      - "isinstance ignores the inheritance chain."
    answer: [0, 1]
    explanation: "isinstance follows inheritance, which is exactly why bool matches int."
    difficulty: 2
  - id: q3
    prompt: "What does issubclass check?"
    type: single
    choices:
      - "Whether one class derives from another class."
      - "Whether an object is an instance of a class."
      - "Whether two objects share an id."
      - "Whether a function is decorated."
    answer: [0]
    explanation: "issubclass works on classes; isinstance works on instances."
    difficulty: 1
  - id: q4
    prompt: "type(obj) returns what?"
    type: single
    choices:
      - "The exact class of obj."
      - "True or False depending on equality."
      - "The module where the class was defined."
      - "A tuple of base classes."
    answer: [0]
    explanation: "type(obj) is the concrete class; base classes are available as obj.__class__.__bases__."
    difficulty: 1
```