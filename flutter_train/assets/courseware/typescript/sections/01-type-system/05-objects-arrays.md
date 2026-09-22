---
id: 05-objects-arrays
title: "Objects, arrays, and tuples"
order: 5
section: 01-type-system
language: typescript
summary: "Object types, arrays, tuples, readonly, and index signatures"
tags: [objects, arrays, tuples, readonly]
---

# Objects, arrays, and tuples

These three shapes cover almost all data in a TypeScript program.

## Object types

Inline or named:

```typescript
const point: { x: number; y: number } = { x: 1, y: 2 };

interface Point { x: number; y: number }
```

Optional and readonly properties:

```typescript
interface Config {
  readonly host: string;
  port?: number;         // number | undefined
}
```

## Arrays

```typescript
const ids: number[] = [1, 2, 3];
const names: Array<string> = ["a", "b"];   // same thing

const matrix: number[][] = [
  [1, 2],
  [3, 4],
];
```

`readonly number[]` prevents mutation:

```typescript
function total(items: readonly number[]): number {
  return items.reduce((a, b) => a + b, 0);
  // items.push(1);  ❌ not allowed
}
```

> [!tip] Accept readonly arrays in function params
> If a function only reads, type its parameter `readonly T[]`. Callers can
> then pass both mutable and frozen arrays.

## Tuples

Fixed length, per-position types:

```typescript
type Point = [number, number];
type Entry = [string, number];

const p: Point = [3, 4];
const entries: Entry[] = [["a", 1], ["b", 2]];
```

Named tuple members improve readability:

```typescript
type Range = [start: number, end: number];
```

Tuples shine for small fixed groups (coordinates, key-value pairs, React
hook returns) where an object would be overkill.

> [!trap] Tuples are arrays at runtime
> A tuple is a compile-time description of an array. Nothing stops a JS
> caller passing the wrong length at runtime; validate when crossing a
> boundary.

## Index signatures and records

For dictionary-like objects:

```typescript
interface Scores {
  [name: string]: number;
}

const scores: Scores = { ada: 10, grace: 12 };
```

The `Record` utility is the common shorthand:

```typescript
const scores: Record<string, number> = { ada: 10 };
```

## Destructuring keeps types

```typescript
const { x, y }: { x: number; y: number } = point;
const [first, second] = [1, 2];        // both number

function draw({ x, y }: Point) {
  console.log(x, y);
}
```

> [!key] Excess property checks protect object literals
> `const c: Config = { host: "h", extra: 1 }` errors — the literal has a
> property not in Config. Variables carrying extras are allowed by
> structural typing.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which describes a fixed [number, number] value?"
    type: single
    choices: ["An array", "A tuple", "A record", "An interface"]
    answer: [1]
    explanation: "A tuple fixes length and per-position types."
    difficulty: 1
  - id: q2
    prompt: "What does readonly number[] prevent?"
    type: single
    choices:
      - "Reading elements"
      - "Mutating the array (push, index assign)"
      - "Passing to functions"
      - "Iterating"
    answer: [1]
    explanation: "readonly arrays cannot be mutated, but can be read."
    difficulty: 2
  - id: q3
    prompt: "What does Record<string, number> describe?"
    type: single
    choices:
      - "A tuple of strings and numbers"
      - "An object with string keys and number values"
      - "A function"
      - "A union"
    answer: [1]
    explanation: "Record is shorthand for an index-signature object type."
    difficulty: 2
  - id: q4
    prompt: "Why does an object literal with an extra property error?"
    type: single
    choices:
      - "Excess property checking on literals"
      - "It is a runtime error"
      - "Interfaces are sealed at runtime"
      - "It does not error"
    answer: [0]
    explanation: "Fresh literals get excess property checks against the target type."
    difficulty: 3
```