---
id: 05-composition
title: Composition vs inheritance
order: 5
section: 01-object-oriented
language: python
type: lesson
summary: Model real-world designs with is-a (inheritance) and has-a (composition) relationships.
tags: [composition, inheritance, has-a, is-a, delegation, oop]
prereqs: [04-inheritance-polymorphism]
---

# Composition vs inheritance

Two relationships dominate object-oriented design:

- **Inheritance** — an **is-a** relationship: `class Dog(Animal)`, "a Dog is an
  Animal".
- **Composition** — a **has-a** relationship: `car.engine`, "a Car has an
  Engine".

Neither is "better"; you pick the one that truthfully models your problem.

> [!key] **A quick gut check**
>
> - Inheritance: "X **is a** Y" is true in the problem domain.
> - Composition: "X **has a** Y" is true in the problem domain.
> - If you want to *borrow implementation* but the sentence "is a" feels
>   forced, composition is probably right.

## is-a: inheritance at its best

Use inheritance when subtypes genuinely refine a base — shared interface and
overridable behavior.

```python title="shape-is-a.py"
class Shape:
    def __init__(self, label):
        self.label = label

    def describe(self):
        return f"shape '{self.label}'"

class Circle(Shape):
    def __init__(self, label, radius):
        super().__init__(label)
        self.radius = radius

    def describe(self):
        return f"circle '{self.label}' with radius {self.radius}"

print(Circle("wheel", 5).describe())
```

## has-a: composition

Composition stores other objects as *attributes* and typically **delegates**
work to them. Parts can be swapped, created lazily, or reused across classes
without a deep inheritance tree.

```python title="car-has-a.py"
class Engine:
    def start(self):
        return "engine running"

class Wheels:
    def __init__(self, count):
        self.count = count

    def describe(self):
        return f"{self.count} wheels"

class Car:
    def __init__(self):
        self.engine = Engine()      # has-a
        self.wheels = Wheels(4)     # has-a

    def start(self):
        return self.engine.start()  # delegation

    def about(self):
        return "car with " + self.wheels.describe()

car = Car()
print(car.about())
print(car.start())
```

> [!tip] **Composition favors change**
>
> Want a hybrid engine? `car.engine` is just an attribute, so swap it: build a
> `HybridEngine` and assign `car.engine = HybridEngine()` at runtime. With deep
> inheritance you would keep adding sibling classes instead.

## The classic trap: inheriting to borrow a container

A "Stack" is *not* a "List as a verb"; a list lets you `insert`, `sort`, index
arbitrarily — things a stack must forbid. Inheriting from `list` leaks the
whole API. Wrapping (composition) hides everything not in the interface.

```python title="stack-composition.py"
class Stack:
    def __init__(self):
        self._items = []

    def push(self, item):
        self._items.append(item)

    def pop(self):
        if not self._items:
            raise IndexError("pop from empty stack")
        return self._items.pop()

    def __len__(self):
        return len(self._items)

stack = Stack()
stack.push(1)
stack.push(2)
print(len(stack))
print(stack.pop(), stack.pop())
```

> [!warning] **Fragile base class**
>
> The more logic a base class has, the riskier it is to inherit from: a change
> in the base silently alters every subclass. Composition relies only on the
> stable public interface of the held object, so it tolerates change far
> better.

## Decision heuristic

| Situation | Prefer |
| --- | --- |
| True is-a relationship, shared interface | Inheritance |
| Borrowing one implementation idea | Composition |
| Swappable/replaceable behavior | Composition |
| Polymorphic collection of one family | Inheritance |

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Composition models which kind of relationship?"
    type: single
    choices: ["has-a", "is-a", "acts-as", "calls-a"]
    answer: [0]
    explanation: "Composition is has-a: one object owns or references another object."
    difficulty: 1
  - id: q2
    prompt: "A Car class that stores an Engine instance and delegates start() to it is using..."
    type: single
    choices: ["composition", "multiple inheritance", "monkey patching", "duck typing"]
    answer: [0]
    explanation: "Holding Engine as an attribute and forwarding the call is classic composition with delegation."
    difficulty: 1
  - id: q3
    prompt: "Why is subclassing a built-in list to build a Stack often a poor choice?"
    type: single
    choices:
      - "You inherit unrelated capabilities such as sort and insert that break the stack abstraction."
      - "Lists cannot be subclassed in Python."
      - "A stack from a list can never be empty."
      - "It doubles memory usage on every push."
    answer: [0]
    explanation: "Inheritance exposes the entire public API of the base class; composition hides it."
    difficulty: 2
  - id: q4
    prompt: "Select the true statements about composition vs inheritance."
    type: multi
    choices:
      - "Inheritance expresses an is-a relationship."
      - "Composition uses another object as an attribute."
      - "Composition makes behavior easy to swap at runtime."
      - "Inheritance is always faster than composition."
    answer: [0, 1, 2]
    explanation: "Composition favors runtime flexibility; performance claims like the last one are myths."
    difficulty: 2
```