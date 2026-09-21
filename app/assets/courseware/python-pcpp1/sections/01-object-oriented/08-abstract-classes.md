---
id: 08-abstract-classes
title: Abstract classes and methods
order: 8
section: 01-object-oriented
language: python
type: lesson
summary: Define mandatory contracts with abc.ABC and @abstractmethod; override requirements in subclasses and multiple inheritance.
tags: [abstract, abc, abstractmethod, abc, contract, oop]
prereqs: [04-inheritance-polymorphism]
---

# Abstract classes and methods

An **abstract base class (ABC)** is a class that cannot be instantiated
directly and requires subclasses to implement certain methods. ABCs are the
strict alternative to duck typing: they enforce a *contract* at class-creation
time.

## Defining an ABC

Import `ABC` and `@abstractmethod` from `abc`. A subclass that forgets to
override any abstract method raises `TypeError` when it is *instantiated* —
not when it is defined.

```python title="shape-abc.py"
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        ...  # no default implementation

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2

class Triangle(Shape):
    pass   # forgot area()

print(Square(4).area())

try:
    Triangle()
except TypeError:
    print("abstract class: cannot instantiate without overriding area")

try:
    Shape()
except TypeError:
    print("Shape itself is abstract")
```

> [!note] **"Define, not call"**
>
> `...` inside an abstract method is a valid body, but you could also put a
> default call via `super()` if that makes sense. The requirement is simply to
> override the method before instantiation.

## @abstractmethod and the override chain

The decorator marks the method as unimplemented. A subclass must provide its
own body. Multiple overrides work naturally through the inheritance tree.

```python title="override-chain.py"
from abc import ABC, abstractmethod

class Greeter(ABC):
    @abstractmethod
    def greet(self):
        print("Hello from base")

class Friend(Greeter):
    def greet(self):
        super().greet()    # call the parent's version
        print("Nice to see you again!")

Friend().greet()
```

The subclass calls `super()` so the base's default body (printing "Hello from
base") runs first — exactly the same `super()` mechanics as any override.

## Mixing multiple ABCs

A class may inherit from several abstract bases. It must implement *every*
abstract method from *every* base. A missing method results in `TypeError`.

```python title="multi-abc.py"
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        ...

class Drawable(ABC):
    @abstractmethod
    def draw(self):
        ...

class Rect(Shape, Drawable):
    def __init__(self, w, h):
        self.w, self.h = w, h

    def area(self):
        return self.w * self.h

    def draw(self):
        print(f"drawing rect {self.w}x{self.h}")

r = Rect(3, 4)
print("area:", r.area())
r.draw()
```

> [!trap] **Overriding one base is not enough**
>
> `class Bad(Rect): def area(self): ...` — forgetting `draw` means `Bad()`
> still raises `TypeError`. The check is *all abstracts for the final class*.

## Registering a virtual subclass

`ABC` exposes a `register` classmethod that registers a class as implementing
an ABC *without* requiring it to inherit. This is useful when you cannot
modify the original class (e.g., built-ins or third-party types).

```python title="register.py"
from abc import ABC, abstractmethod

class SupportPrint(ABC):
    @abstractmethod
    def nice_print(self):
        ...

SupportPrint.register(int)
print(issubclass(int, SupportPrint))
print(isinstance(42, SupportPrint))
```

> [!warning] **`register` is informal**
>
> The registered class has not actually implemented the method; calling
> `nice_print()` on an `int` would fail at runtime. The registered relationship
> only satisfies `isinstance` / `issubclass`. Use it sparingly.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens when you try to instantiate a subclass that forgot to override an abstract method?"
    type: single
    choices:
      - "A TypeError is raised at instantiation time."
      - "The parent's method is used silently."
      - "A NameError is raised."
      - "An empty method body is auto-generated."
    answer: [0]
    explanation: "Abstract methods enforce the contract when the subclass is instantiated, not when it is defined."
    difficulty: 1
  - id: q2
    prompt: "Which two imports from the abc module are required to create a basic abstract base class?"
    type: single
    choices:
      - "ABC and abstractmethod."
      - "ABC and abstractproperty."
      - "abc and abstractmethod."
      - "ABC and abstract_base_class."
    answer: [0]
    explanation: "ABC is the base class; abstractmethod marks methods as unimplemented."
    difficulty: 1
  - id: q3
    prompt: "Select the true statements about ABCs."
    type: multi
    choices:
      - "An abstract method may have a default body."
      - "A subclass can call super() inside an abstract method."
      - "A class may inherit from several ABCs."
      - "An ABC prevents all subclassing."
    answer: [0, 1, 2]
    explanation: "ABCs have normal inheritance mechanics; the only new constraint is the abstract-method check."
    difficulty: 2
  - id: q4
    prompt: "What does MyClass.register(OtherClass) do?"
    type: single
    choices:
      - "Marks OtherClass as a subclass of MyClass for isinstance/issubclass checks without requiring inheritance."
      - "Copies the methods of MyClass into OtherClass."
      - "Prevents OtherClass from being subclassed."
      - "Instantiates OtherClass."
    answer: [0]
    explanation: "register is a formal marker for isinstance/issubclass; no method copying happens."
    difficulty: 2
```