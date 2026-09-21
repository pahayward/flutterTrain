---
id: 03-abstract
title: "Abstract classes and implements"
order: 3
section: 03-classes-oop
language: typescript
summary: "Base classes that cannot be instantiated, and interfaces via implements"
tags: [abstract, implements, inheritance, contracts]
---

# Abstract classes and implements

Two tools for building on top of a base: **abstract classes** for shared
implementation, **interfaces** for pure contracts.

## Abstract classes

An abstract class cannot be instantiated and may declare abstract members
that subclasses must implement:

```typescript
abstract class Shape {
  abstract area(): number;          // no body — subclasses must provide

  describe(): string {              // shared implementation
    return `A shape with area ${this.area().toFixed(2)}`;
  }
}

class Circle extends Shape {
  constructor(private radius: number) { super(); }

  area(): number {
    return Math.PI * this.radius ** 2;
  }
}

// new Shape();   ❌ cannot instantiate an abstract class
const c = new Circle(2);
console.log(c.describe());   // uses shared describe + own area
```

> [!key] Abstract = partial implementation + required holes
> Use abstract classes when subclasses share real code but must fill in
> specific members.

## implements — a class contract

A class can implement one or more interfaces:

```typescript
interface Serializable {
  serialize(): string;
}

interface Comparable<T> {
  compareTo(other: T): number;
}

class Money implements Serializable, Comparable<Money> {
  constructor(private cents: number) {}

  serialize(): string {
    return JSON.stringify({ cents: this.cents });
  }

  compareTo(other: Money): number {
    return this.cents - other.cents;
  }
}
```

`implements` checks the class shape; the interface contributes no code.

## extends vs implements

| | extends | implements |
|---|---|---|
| Inherits code | ✅ | ❌ |
| Multiple | ❌ (one class) | ✅ (many interfaces) |
| Must call super | ✅ | ❌ |
| Instantiable base | usually | interface has no instances |

A class can do both:

```typescript
abstract class Base {
  abstract id(): number;
}

class Entity extends Base implements Serializable {
  constructor(private key: number) { super(); }
  id() { return this.key; }
  serialize() { return String(this.key); }
}
```

> [!trap] Overriding needs compatible types
> An override must be assignable to the base member's type. Changing a
> parameter type incompatibly is a compile error (unlike some dynamic
> languages).

## When to prefer interfaces

- You only need a contract, no shared code → interface.
- You need shared implementation → abstract class.
- You need multiple inheritance of contracts → interfaces via `implements`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Can you instantiate an abstract class?"
    type: single
    choices: ["Yes", "No", "Only in the same file", "Only with new Shape<>()"]
    answer: [1]
    explanation: "Abstract classes exist to be extended, not instantiated."
    difficulty: 1
  - id: q2
    prompt: "What must a subclass do with abstract members?"
    type: single
    choices:
      - "Ignore them"
      - "Implement them"
      - "Make them private"
      - "Declare them again as abstract"
    answer: [1]
    explanation: "Abstract members must be implemented by concrete subclasses."
    difficulty: 1
  - id: q3
    prompt: "How many interfaces can a class implement?"
    type: single
    choices: ["One", "Two", "Any number", "Only if abstract"]
    answer: [2]
    explanation: "A class can implement multiple interfaces."
    difficulty: 1
  - id: q4
    prompt: "What does implements check?"
    type: single
    choices:
      - "The class shape matches the interface"
      - "The class inherits implementation"
      - "The interface is abstract"
      - "The class is sealed"
    answer: [0]
    explanation: "implements requires the class to satisfy the interface's shape."
    difficulty: 2
```