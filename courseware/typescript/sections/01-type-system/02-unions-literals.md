---
id: 02-unions-literals
title: "Union and literal types"
order: 2
section: 01-type-system
language: typescript
summary: "Combining types, exact values, and narrowing basics"
tags: [union, literal, narrowing, discriminated]
---

# Union and literal types

A **union** means "one of several types". A **literal type** means one exact
value. Together they model real-world state precisely.

## Unions

```typescript
function formatId(id: number | string): string {
  return `ID: ${id}`;
}
```

Inside the function you can only use operations common to **all** members
until you narrow:

```typescript
function formatId(id: number | string): string {
  if (typeof id === "number") {
    return id.toFixed(0);      // narrowed to number
  }
  return id.toUpperCase();     // narrowed to string
}
```

## Literal types

```typescript
let direction: "north" | "south" | "east" | "west";
direction = "north";   // ✅
direction = "up";      // ❌ not assignable
```

Literal unions are how you model finite sets without enums.

## Combining literal unions with objects

```typescript
type Circle = { kind: "circle"; radius: number };
type Square = { kind: "square"; side: number };
type Shape = Circle | Square;

function area(s: Shape): number {
  switch (s.kind) {
    case "circle":
      return Math.PI * s.radius ** 2;   // s narrowed to Circle
    case "square":
      return s.side ** 2;               // s narrowed to Square
  }
}
```

A shared literal field (`kind`) is a **discriminant** — it tells the compiler
which member you have. This pattern is covered in depth in Part 6.

> [!key] The compiler is exhaustive-aware
> With `strict`, if you forget a case in a discriminated union, the function
> can be proven to return `undefined`. Add a `default: never` check to make
> missing cases compile errors.

## Enums vs literal unions

```typescript
enum Direction { North, South }         // runtime object, numeric by default
type Direction2 = "north" | "south";    // erased, string-friendly
```

> [!tip] Prefer literal unions to enums
> Literal unions have no runtime footprint, serialize to strings cleanly,
> and integrate with discriminated unions. Use `enum` mainly when you need
> reverse mapping or a named runtime object.

## Nullable unions

```typescript
function findUser(id: number): User | null {
  return id === 1 ? { id, name: "Ada" } : null;
}

const u = findUser(1);
if (u !== null) {
  console.log(u.name);    // narrowed to User
}
```

Optional chaining is a related convenience:

```typescript
const city = user?.address?.city;   // string | undefined
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does number | string mean?"
    type: single
    choices: ["A number and a string", "A number or a string", "A string of numbers", "A tuple"]
    answer: [1]
    explanation: "The pipe means the value is one of the listed types."
    difficulty: 1
  - id: q2
    prompt: "Why can't you call .toUpperCase() on a number | string value directly?"
    type: single
    choices:
      - "It works fine"
      - "The method is not common to all union members"
      - "Strings have no methods"
      - "Unions are always any"
    answer: [1]
    explanation: "You must narrow to string first, since number lacks the method."
    difficulty: 2
  - id: q3
    prompt: "What is a discriminant field?"
    type: single
    choices:
      - "A numeric key"
      - "A shared literal field that identifies the union member"
      - "An optional property"
      - "A private field"
    answer: [1]
    explanation: "A common literal property (like kind) lets the compiler narrow the union."
    difficulty: 2
  - id: q4
    prompt: "What is an advantage of literal unions over enums?"
    type: single
    choices:
      - "They have a runtime footprint"
      - "They are erased and serialize as plain strings"
      - "They support reverse mapping"
      - "They cannot be combined"
    answer: [1]
    explanation: "Literal unions exist only at compile time and map to strings naturally."
    difficulty: 2
```