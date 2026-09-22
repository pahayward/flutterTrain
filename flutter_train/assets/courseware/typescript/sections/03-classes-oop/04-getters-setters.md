---
id: 04-getters-setters
title: "Getters, setters, static"
order: 4
section: 03-classes-oop
language: typescript
summary: "Computed accessors, validation on assignment, and static members"
tags: [getters, setters, static, accessors]
---

# Getters, setters, static

Accessors let a property read/write look like a field while running code
behind the scenes. Static members live on the class, not instances.

## Getters and setters

```typescript
class Temperature {
  constructor(private celsius: number) {}

  get fahrenheit(): number {
    return this.celsius * 9 / 5 + 32;
  }

  set fahrenheit(value: number) {
    this.celsius = (value - 32) * 5 / 9;
  }
}

const t = new Temperature(25);
console.log(t.fahrenheit);   // 77 — no parentheses
t.fahrenheit = 32;           // calls the setter
```

A getter is a **read-only computed property**; add a setter to allow writes.

## Validation on assignment

Setters are the natural place to validate:

```typescript
class Person {
  private _age = 0;

  get age(): number {
    return this._age;
  }

  set age(value: number) {
    if (value < 0 || !Number.isInteger(value)) {
      throw new RangeError("Age must be a non-negative integer");
    }
    this._age = value;
  }
}
```

> [!key] Use a backing field with _
> A getter/setter pair can't share the same name as a field. Store the value
> in `_age` (or `#age`) and expose `age` through the accessor.

## Getters can be readonly

Define only a getter to make a property effectively read-only:

```typescript
class Circle {
  constructor(private radius: number) {}
  get area(): number { return Math.PI * this.radius ** 2; }
}

const c = new Circle(1);
// c.area = 5;   ❌ no setter
```

## Static members

Static fields and methods belong to the class itself:

```typescript
class MathUtils {
  static readonly PI = 3.14159;

  static square(n: number): number {
    return n * n;
  }
}

MathUtils.PI;            // ✅
MathUtils.square(4);     // 16
// new MathUtils();      // possible, but statics are not on instances
```

## Static factory methods

A common pattern for named constructors:

```typescript
class User {
  private constructor(public readonly id: number, public readonly name: string) {}

  static create(name: string): User {
    return new User(Math.random(), name);
  }

  static fromJSON(json: string): User {
    const { id, name } = JSON.parse(json);
    return new User(id, name);
  }
}

const u = User.create("Ada");   // private constructor forces the factory
```

> [!trap] `this` in static methods
> Inside a static method, `this` refers to the class, not an instance. You
> cannot access instance fields without an instance.

## Static initialization blocks

```typescript
class Config {
  static defaults: Record<string, string>;

  static {
    Config.defaults = { theme: "dark" };
  }
}
```

Runs once when the class is defined — useful for non-trivial static setup.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How do you read a getter?"
    type: single
    choices: ["t.fahrenheit()", "t.fahrenheit", "t.getFahrenheit()", "t['get']"]
    answer: [1]
    explanation: "Getters are accessed like properties, without parentheses."
    difficulty: 1
  - id: q2
    prompt: "Where should validation on assignment live?"
    type: single
    choices: ["Getter", "Setter", "Constructor only", "Static method"]
    answer: [1]
    explanation: "The setter runs on every assignment and can reject bad values."
    difficulty: 2
  - id: q3
    prompt: "Where do static members live?"
    type: single
    choices: ["On each instance", "On the class itself", "In a closure", "On the prototype only"]
    answer: [1]
    explanation: "Statics are accessed via the class, not instances."
    difficulty: 1
  - id: q4
    prompt: "Why use a private constructor with a static factory?"
    type: single
    choices:
      - "To force creation through controlled factory methods"
      - "To make the class abstract"
      - "To improve performance"
      - "To add getters"
    answer: [0]
    explanation: "A private constructor prevents new outside, funneling creation through factories."
    difficulty: 3
```