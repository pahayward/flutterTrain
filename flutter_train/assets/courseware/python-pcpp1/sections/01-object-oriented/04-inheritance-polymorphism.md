---
id: 04-inheritance-polymorphism
title: Inheritance, polymorphism, MRO
order: 4
section: 01-object-oriented
language: python
type: lesson
summary: Designing class hierarchies, single and multiple inheritance, the Method Resolution Order, and duck typing.
tags: [inheritance, polymorphism, mro, subclass, super, duck-typing]
prereqs: [01-oop-basics, 03-magic-methods]
---

# Inheritance, polymorphism, MRO

Inheritance lets a class reuse and refine the code of another class: the
subclass **is-a** version of the base class, gains its methods and attributes,
and can override them.

## A first hierarchy: overriding and super()

A subclass that redeclares a method *overrides* it. Inside the override you can
call the parent version with `super()`.

```python title="animals.py"
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return f"{self.name} makes a sound"

class Dog(Animal):
    def speak(self):
        return f"{self.name} says Woof!"

class Cat(Animal):
    def speak(self):
        return f"{self.name} says Meow!"

for pet in [Dog("Rex"), Cat("Mia"), Animal("Echo")]:
    print(pet.speak())
```

The loop does not care which class each object has: it only needs each object
to answer `speak()`. That is **polymorphism** — one interface, many
implementations.

> [!key] **is-a relationship**
>
> Every `Dog` *is an* `Animal`. Code written against `Animal` accepts subclass
> instances. `isinstance(dog, Animal)` is `True` (module 02).

## Duck typing

Python is dynamically typed, so the loop above works even if the objects have
nothing in common — they just need the right method. "If it walks like a duck
and quacks like a duck, then it may be treated as a duck."

```python title="duck-typing.py"
class Duck:
    def quack(self):
        return "Quack!"

class Robot:
    def quack(self):
        return "Robotic quack"

def make_noise(thing):
    print(thing.quack())

make_noise(Duck())
make_noise(Robot())
```

> [!note] **Duck typing vs abstract contracts**
>
> Duck typing checks behavior at the call site and needs no shared base class.
> Abstract base classes (module 08) are the strict, explicit alternative used
> when you want to *force* a contract.

## Multiple inheritance and the MRO

A class may list several bases: `class D(B, C)`. When both `B` and `C` define
the same method, Python must decide which wins. The decision is the **Method
Resolution Order (MRO)**, computed by the C3 linearization algorithm, available
as `D.__mro__`.

```python title="mro.py"
class A:
    def m(self):
        print("A.m")

class B(A):
    def m(self):
        print("B.m")
        super().m()

class C(A):
    def m(self):
        print("C.m")
        super().m()

class D(B, C):
    pass

for cls in D.__mro__:
    print(cls.__name__)

d = D()
d.m()
```

Output:

```
D
B
C
A
object
B.m
C.m
A.m
```

`super()` inside `B.m` continues with the *next* class in `D`'s MRO, which is
`C`, not `A`. That is the key insight for multiple inheritance: `super()` does
not mean "parent class" — it means "next in line".

> [!trap] **MRO order is "depth-first, then left-to-right"**
>
> `class D(B, C)` yields `D -> B -> C -> A -> object`. The C3 algorithm also
> rejects inconsistent hierarchies at class-creation time with a `TypeError`
> ("MRO conflict").

## Checking the order

Never memorize an MRO by hand for complex graphs — print it:

```python
class Left:
    pass

class Right:
    pass

class Both(Left, Right):
    pass

print(" -> ".join(c.__name__ for c in Both.__mro__))
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What decides which method wins in multiple inheritance?"
    type: single
    choices:
      - "The Method Resolution Order computed by C3 linearization."
      - "Alphabetical order of class names."
      - "The order classes appear in the source module."
      - "A random choice at runtime."
    answer: [0]
    explanation: "Python linearizes the hierarchy into D.__mro__; the first class defining a method wins."
    difficulty: 2
  - id: q2
    prompt: "What is duck typing?"
    type: single
    choices:
      - "Objects qualify by behavior (the method they provide), not by declared type."
      - "Only classes named Duck can be used."
      - "Methods may be called at most three times."
      - "A design for validating csv rows."
    answer: [0]
    explanation: "Duck typing relies on runtime capabilities instead of a shared inheritance contract."
    difficulty: 1
  - id: q3
    prompt: "Select the true statements about method overriding."
    type: multi
    choices:
      - "A subclass method with the same name replaces the parent's for that class."
      - "Overrides can delegate to the next implementation via super()."
      - "Overriding also changes the parent's method."
      - "Overriding requires abstract classes."
    answer: [0, 1]
    explanation: "Overriding is per-class; the parent is untouched and super() continues the chain."
    difficulty: 2
  - id: q4
    prompt: "For class D(B, C) where both B and C inherit from A, what is D.__mro__?"
    type: single
    choices:
      - "[D, B, C, A, object]"
      - "[D, C, B, A, object]"
      - "[A, B, C, D, object]"
      - "[D, A, B, C]"
    answer: [0]
    explanation: "Left-to-right bases first, then the shared base A, then object."
    difficulty: 3
```