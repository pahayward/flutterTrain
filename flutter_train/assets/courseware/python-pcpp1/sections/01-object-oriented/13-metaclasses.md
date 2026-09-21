---
id: 13-metaclasses
title: Metaprogramming & metaclasses
order: 13
section: 01-object-oriented
language: python
type: lesson
summary: Classes are objects built by metaclasses; create classes dynamically with type(name, bases, dict) and inspect __name__, __class__, __bases__, __dict__.
tags: [metaclass, type, metaprogramming, introspection, class-object]
prereqs: [01-oop-basics, 04-inheritance-polymorphism, 12-copy-serialization]
---

# Metaprogramming & metaclasses

Everything in Python is an object — **including classes**. The metaclass is
the class of a class: the entity responsible for *constructing* a class object
when it is created. Knowing this unlocks dynamic class creation and
class-level program logic.

## Classes are objects, type is the metaclass

- `type(obj)` of an instance returns its class.
- `type(SomeClass)` returns the **metaclass** — almost always `type`.
- `object` is the root of the *class* hierarchy; `type` is the root of the
  *metaclass* hierarchy.

```python title="metaclass-basics.py"
print(type(3))          # int
print(type(int))        # type
print(type(type))       # type
```

For a class `Circle`, `type(Circle)` is `type` — the default metaclass.

## type() with three arguments

`type(name, bases, namespace)` creates a **new class** at runtime. The three
arguments are:

| Argument | Meaning |
|---|---|
| `name` | class name, stored in `__name__` |
| `bases` | tuple of base classes, stored in `__bases__` |
| `namespace` | dict of attributes/methods |

```python title="dynamic-class.py"
def area(self):
    return 3.14159 * self.radius ** 2

Circle = type("Circle", (), {"radius": 5, "area": area})

c = Circle()
print(c.__class__.__name__)
print(isinstance(c, Circle))
print(round(c.area(), 2))
```

> [!note] **`type(x)` on an instance vs `type("...", ...)`**
>
> All three are the same built-in: one argument reports the type of an object;
> three arguments build a new class.

## Inspecting class objects: __name__, __class__, __bases__, __dict__

Every class object carries the classic attributes:

- `__name__` — the class's name (a string).
- `__class__` — its metaclass (usually `type`).
- `__bases__` — a tuple of its direct base classes.
- `__dict__` — a mapping of the class's own attributes and methods.

```python title="class-attrs.py"
class Base:
    kind = "base"
    def hello(self):
        return "hi"

class Derived(Base):
    extra = 1

print(Derived.__name__)
print(Derived.__bases__)
print(Base.__bases__)
print(type(Derived), type(3))
print(sorted(Derived.__dict__.keys()))
print(Derived.kind)
```

> [!key] **__dict__ is not the whole story**
>
> `Derived.__dict__` lists only *its own* definitions (plus some machinery),
> not inherited ones. Look up `kind` — found on `Base` — through normal
> attribute resolution, not through `Derived.__dict__`.

## Writing your own metaclass

Define a metaclass by subclassing `type` and overriding `__new__` (or
`__init__`). It runs when a class is being created, so it is the natural place
for registration, validation, or transformation of the class dict.

```python title="registry-meta.py"
class RegistryMeta(type):
    registry = []

    def __new__(mcs, name, bases, namespace):
        cls = super().__new__(mcs, name, bases, namespace)
        RegistryMeta.registry.append(name)
        return cls

class A(metaclass=RegistryMeta):
    pass

class B(A):          # inherits the metaclass
    pass

class C(metaclass=RegistryMeta):
    pass

print(RegistryMeta.registry)
```

> [!tip] **When a> subclass inherits the metaclass**
>
> `B` inherits `RegistryMeta` from `A`, so `__new__` also runs for `B` — that
> is why "B" appears in the registry even though `B` has no explicit
> `metaclass=`.

> [!warning] **Don't overuse metaclasses**
>
> Metaclasses are powerful but easy to over-engineer. Prefer a plain
> classmethod or a decorator until you genuinely need to intervene *during
> class creation* (registration of subclasses is the classic, sane use).

## Putting the pieces together

```python title="full-circuit.py"
class Meta(type):
    def __new__(mcs, name, bases, namespace):
        print("creating class:", name)
        return super().__new__(mcs, name, bases, namespace)

class Widget(metaclass=Meta):
    def spin(self):
        return "spinning"

print(Widget.__name__)
print(Widget.__class__)
print(Widget.__bases__)
print(Widget().spin())
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "type(name, bases, namespace) does what?"
    type: single
    choices:
      - "Creates a new class object from a name, a tuple of bases, and a dict of attributes."
      - "Returns the module in which a class lives."
      - "Casts the value to a string."
      - "Returns whether two objects have the same id."
    answer: [0]
    explanation: "The three-argument form is the dynamic way to build classes; its first argument alone just reports the type."
    difficulty: 2
  - id: q2
    prompt: "What is the default metaclass that builds most classes?"
    type: single
    choices: ["type", "object", "ABC", "MetaClass"]
    answer: [0]
    explanation: "type is the metaclass of almost all classes, including int, str, and your own."
    difficulty: 1
  - id: q3
    prompt: "What does Circle.__dict__ contain?"
    type: single
    choices:
      - "The class's own attributes and methods as a dict."
      - "The instances of Circle."
      - "The resolution order as a list."
      - "All global variables."
    answer: [0]
    explanation: "__dict__ is the class namespace -- its own definitions, not inherited ones."
    difficulty: 2
  - id: q4
    prompt: "Select the true statements."
    type: multi
    choices:
      - "type(Circle) is type."
      - "Circle.__name__ is the string 'Circle'."
      - "Circle.__bases__ is a tuple of base classes."
      - "Classes are objects just like instances."
    answer: [0, 1, 2, 3]
    explanation: "All four are correct: classes are objects built by metaclasses and carry __name__, __bases__, __dict__."
    difficulty: 2
```