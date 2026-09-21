---
id: 14-section-practice
title: "Section 1 Practice"
order: 14
section: 01-object-oriented
language: python
type: lesson
summary: Rapid review of the whole Advanced OOP section plus a full practice exam bank.
tags: [practice, review, exam, oop]
prereqs: [13-metaclasses]
---

# Section 1 Practice

This page reviews all thirteen lessons at exam speed. If a bullet is fuzzy,
jump back to the module — then try the exam-bank questions at the bottom.

## Section review

- **01 — Classes, instances, attributes, methods.** A class is a blueprint,
  an instance is one object of that class. `__init__` sets up the fresh
  instance; `self` is that instance. Class variables are shared, instance
  variables are per-object; assignment through an instance creates a shadow.
  `obj.method()` and `Class.method(obj)` are equivalent.
- **02 — Reflection.** `isinstance` follows inheritance, `type(obj)` is exact.
  `issubclass` works on classes, not instances. `bool` subclasses `int`.
- **03 — Magic methods.** `__str__` for humans, `__repr__` for developers,
  `__eq__` (return `NotImplemented` for foreign types), `__hash__`, `__abs__`,
  `__int__`, `__len__` (non-negative int), `__getitem__`, `__iter__`,
  `__getattr__` (fallback only).
- **04 — Inheritance & polymorphism.** Override methods and call the next
  implementation with `super()`. Multiple inheritance resolves conflicts via
  the C3 MRO in `__mro__`. Duck typing relies on behavior, not declared type.
- **05 — Composition vs inheritance.** Inheritance is "is-a", composition is
  "has-a" plus delegation. When all you want is implementation reuse,
  composition is usually the safer choice.
- **06 — *args & decorators.** `*args`/`**kwargs` collect and forward
  arguments; closures capture enclosing state with `nonlocal`; `@` is sugar for
  `f = dec(f)`; decorators stack bottom-up; classes decorate via `__call__`;
  factories return decorators.
- **07 — Static & class methods.** Instance methods take `self`, classmethods
  take `cls` and can modify class state or act as alternative constructors,
  staticmethods take neither.
- **08 — Abstract classes.** Inherit from `abc.ABC`, mark requirements with
  `@abstractmethod`. Missing overrides surface as `TypeError` at
  instantiation; several ABCs stack cleanly.
- **09 — Encapsulation.** Properties via `@property`/`@x.setter`/
  `@x.deleter` intercept access; `__name` is name-mangled to
  `_Class__name` — a collision-avoidance convention, not security.
- **10 — Subclassing built-ins.** Override documented hooks
  (`append`, `__missing__`, `add`, `__iadd__`); some C code paths bypass
  overridden internals, so rely on the public methods.
- **11 — Advanced exceptions.** Exceptions are objects with `args`; custom
  classes add named attributes; `raise X from old` sets `__cause__`;
  `__context__` is set implicitly; `from None` suppresses the context;
  `__traceback__` holds the stack trail.
- **12 — Copy & serialization.** `is`/`id()` check identity, `==` checks
  value. `copy.copy` shares nested objects; `copy.deepcopy` duplicates
  everything. `pickle.dumps`/`loads` convert to bytes and back (never load
  untrusted data); `shelve` is a persistent dict with string keys.
- **13 — Metaclasses.** Classes are objects built by `type`; `type(name,
  bases, namespace)` creates one dynamically; classes expose `__name__`,
  `__class__`, `__bases__`, `__dict__`; custom metaclasses subclass `type`.

## Two-minute recap examples

```python title="mro-recap.py"
class A:
    def talk(self):
        return "A"

class B(A):
    def talk(self):
        return super().talk() + "B"

class C(A):
    def talk(self):
        return super().talk() + "C"

class D(B, C):
    pass

print(" -> ".join(cls.__name__ for cls in D.__mro__))
print(D().talk())
```

`D -> B -> C -> A -> object`, and the chained call via `super()` visits B, then
C, then A — you can trace exactly why the string becomes `ACB`.

```python title="copy-magic-recap.py"
import copy

class Box:
    def __init__(self, items):
        self.items = list(items)

    def __len__(self):
        return len(self.items)

    def __getitem__(self, i):
        return self.items[i]

    def __repr__(self):
        return f"Box({self.items})"

b = Box([1, 2, 3])
d = copy.deepcopy(b)
d.items.append(9)
print(len(b), b[0], repr(b), repr(d))
```

`len`, indexing, and `repr` all work because of magic methods; `deepcopy`
guarantees `d` and `b` share nothing.

## ExamQuestions

```yaml
bank:
  - prompt: "Which best describes an instance attribute created inside __init__?"
    type: single
    choices:
      - "A value owned by each individual instance."
      - "A value shared by all instances of the class."
      - "A value stored only on the class object."
      - "A value that can never change after creation."
    answer: [0]
    explanation: "Assignments on self create per-instance attributes; class attributes are shared."
    difficulty: 1
    weight: 4
    section: 01-object-oriented
  - prompt: "Which expression evaluates to True in CPython?"
    type: single
    choices:
      - "isinstance(True, int)"
      - "type(True) is int"
      - "issubclass(3, int)"
      - "isinstance(int, True)"
    answer: [0]
    explanation: "bool inherits from int, so isinstance(True, int) is True, while the exact type is bool."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "You define __eq__ on a class but no __hash__. Trying to put instances in a set will ..."
    type: single
    choices:
      - "raise a TypeError because instances become unhashable"
      - "use id() as the hash automatically"
      - "use len() as the hash automatically"
      - "silently ignore the duplicates"
    answer: [0]
    explanation: "Defining __eq__ sets __hash__ to None unless __hash__ is also defined, making the instances unhashable."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "For class D(B, C) where both B and C inherit from A, which class comes directly after D in D.__mro__?"
    type: single
    choices: ["B", "C", "A", "object"]
    answer: [0]
    explanation: "The MRO visits bases left-to-right first: D -> B -> C -> A -> object."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "Two unrelated classes both define quack(). Code that calls quack() on either works because ..."
    type: single
    choices:
      - "callers rely on behavior rather than a declared type"
      - "both inherit quack from object"
      - "they must be registered subclasses of an ABC"
      - "duck typing performs explicit type checks"
    answer: [0]
    explanation: "Duck typing means an object qualifies by its methods (behavior), not by its class."
    difficulty: 1
    weight: 4
    section: 01-object-oriented
  - prompt: "A Drone class that holds a Camera instance as an attribute and delegates photo() to it is modeling which relationship?"
    type: single
    choices: ["has-a (composition)", "is-a (inheritance)", "a metaclass hierarchy", "name mangling"]
    answer: [0]
    explanation: "Holding another object and forwarding calls is the has-a composition pattern."
    difficulty: 1
    weight: 4
    section: 01-object-oriented
  - prompt: "How do you forward every argument unchanged from one function to another?"
    type: single
    choices:
      - "return target(*args, **kwargs)"
      - "return target(args, kwargs)"
      - "return target(**args, *kwargs)"
      - "call target() without any arguments"
    answer: [0]
    explanation: "*args re-spreads positional arguments and **kwargs re-spreads keyword arguments."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "What does a class used as a decorator rely on to become callable?"
    type: single
    choices:
      - "A __call__ method on the instance."
      - "A __str__ method on the function."
      - "Inheriting from list."
      - "Overriding object.__new__."
    answer: [0]
    explanation: "__call__ makes an instance callable, which is how the decorator wrapper is invoked."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "Select the true statements about classmethods and staticmethods."
    type: multi
    choices:
      - "A classmethod receives the class as its first argument, conventionally cls."
      - "A classmethod can modify class-level state."
      - "A staticmethod receives neither self nor cls."
      - "A staticmethod automatically receives the instance."
    answer: [0, 1, 2]
    explanation: "staticmethods take no automatic arguments; the last option describes instance methods."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "What happens when you instantiate a subclass that has not overridden an abstract method?"
    type: single
    choices:
      - "A TypeError is raised at instantiation time."
      - "The base implementation runs automatically."
      - "The import of abc fails."
      - "The method is skipped silently."
    answer: [0]
    explanation: "Abstract methods are enforced when the concrete subclass is instantiated."
    difficulty: 1
    weight: 4
    section: 01-object-oriented
  - prompt: "A property defined with only a @property getter will raise what when assigned to?"
    type: single
    choices: ["AttributeError", "ValueError", "KeyError", "nothing"]
    answer: [0]
    explanation: "Without a setter, assignment to a property raises AttributeError, making it read-only."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "Why might my_list += [3] bypass an overridden __setitem__ on a list subclass?"
    type: single
    choices:
      - "+= is implemented by __iadd__ directly in C, so it may not call __setitem__."
      - "list.__setitem__ always raises."
      - "strings are immutable in Python."
      - "You cannot subclass list in CPython."
    answer: [0]
    explanation: "In-place operations go through __iadd__; override that hook (or extend) rather than only __setitem__."
    difficulty: 3
    weight: 4
    section: 01-object-oriented
  - prompt: "raise NewError() from None has which effect?"
    type: single
    choices:
      - "Suppresses the implicit context so only NewError is shown."
      - "Raises NewError twice in a row."
      - "Automatically logs to stderr."
      - "It is invalid syntax."
    answer: [0]
    explanation: "from None sets __suppress_context__, hiding the currently handled exception from the traceback."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "After deep = copy.deepcopy(lst), appending to deep's nested list will ..."
    type: single
    choices:
      - "leave the original list untouched"
      - "also modify the original list"
      - "raise a recursion error"
      - "share memory with the original"
    answer: [0]
    explanation: "deepcopy duplicates the whole object graph, so mutations on the copy never reach the original."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
  - prompt: "A custom metaclass must be a subclass of which built-in?"
    type: single
    choices: ["type", "object", "ABC", "class"]
    answer: [0]
    explanation: "Metaclasses subclass type so they can build and return class objects."
    difficulty: 2
    weight: 4
    section: 01-object-oriented
```