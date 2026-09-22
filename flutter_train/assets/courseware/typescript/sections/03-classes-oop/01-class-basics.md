---
id: 01-class-basics
title: "Classes, constructors, fields"
order: 1
section: 03-classes-oop
language: typescript
summary: "Typed classes, constructor parameter properties, instantiation"
tags: [classes, constructors, fields, oop]
---

# Classes

TypeScript classes are JavaScript classes plus type annotations and
visibility controls.

## A typed class

```typescript
class User {
  id: number;
  name: string;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
  }

  greet(): string {
    return `Hi, ${this.name}`;
  }
}

const u = new User(1, "Ada");
console.log(u.greet());
```

## Parameter properties (shorthand)

TypeScript lets the constructor declare and assign fields at once:

```typescript
class User {
  constructor(
    public id: number,
    private name: string,
    readonly createdAt: Date = new Date(),
  ) {}

  greet(): string {
    return `Hi, ${this.name}`;
  }
}
```

`public`, `private`, `readonly` on constructor parameters create fields
automatically — much less boilerplate.

> [!key] The modifier decides visibility and field creation
> A bare parameter is just a parameter. Adding `public`/`private`/`protected`/`readonly`
> turns it into a field.

## Fields with defaults

```typescript
class Counter {
  count = 0;                       // inferred number
  readonly startedAt = Date.now();
}
```

## Instantiation and methods

```typescript
const c = new Counter();
c.count += 1;            // ✅
// c.startedAt = 0;      ❌ readonly
```

## Classes are structural too

TypeScript compares class **shape** like it does objects, so a plain object
can satisfy a class-typed parameter if it has the same members.

```typescript
interface Named { name: string }
class Person { constructor(public name: string) {} }

function hello(n: Named) { return `Hi ${n.name}`; }
hello(new Person("Ada"));      // ✅
hello({ name: "Grace" });      // ✅
```

> [!trap] Private is compile-time only
> TypeScript's `private` is enforced by the checker, not at runtime. Use
> `#field` (ECMAScript private) when you need true runtime privacy.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does 'public id: number' in a constructor do?"
    type: single
    choices:
      - "Nothing special"
      - "Declares and assigns a public field"
      - "Makes id optional"
      - "Adds a getter"
    answer: [1]
    explanation: "A modifier on a constructor parameter creates a field and assigns it."
    difficulty: 2
  - id: q2
    prompt: "Which modifier prevents reassignment after construction?"
    type: single
    choices: ["private", "readonly", "static", "abstract"]
    answer: [1]
    explanation: "readonly fields can be set only in the constructor."
    difficulty: 1
  - id: q3
    prompt: "How does TypeScript compare class compatibility?"
    type: single
    choices:
      - "By class name"
      - "By shape (structural)"
      - "By file"
      - "By inheritance only"
    answer: [1]
    explanation: "Classes use structural typing; matching members are enough."
    difficulty: 2
  - id: q4
    prompt: "Is TypeScript private enforced at runtime?"
    type: single
    choices: ["Yes", "No, only at compile time", "Only in strict mode", "Only for static"]
    answer: [1]
    explanation: "private is erased; use # for real runtime privacy."
    difficulty: 2
```