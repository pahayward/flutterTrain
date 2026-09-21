---
id: 02-functional
title: "Functional idioms: map, filter, reduce"
order: 2
section: 06-design-patterns
language: typescript
summary: "Typed array methods, immutability, and composition"
tags: [functional, map, filter, reduce, immutability]
---

# Functional idioms

TypeScript types the standard array methods precisely, so data pipelines stay
safe.

## map

Transforms each element, preserving length:

```typescript
const nums = [1, 2, 3];
const doubled = nums.map((n) => n * 2);        // number[]
const labels = nums.map((n) => `#${n}`);       // string[]
```

The callback's return type becomes the new element type.

## filter

`filter` does not narrow by itself unless you use a type guard:

```typescript
const mixed: (string | null)[] = ["a", null, "b"];

const strings1 = mixed.filter((x) => x !== null);   // still (string | null)[]!
const strings2 = mixed.filter((x): x is string => x !== null);  // string[]
```

> [!key] Use a type predicate with filter
> `(x): x is T => ...` tells the compiler the result excludes the other
> members. Without it, the union is unchanged.

## reduce

`reduce` folds a list into a single value. Provide the accumulator type:

```typescript
const total = [1, 2, 3].reduce((sum, n) => sum + n, 0);   // number

const byId = users.reduce<Record<number, User>>((acc, u) => {
  acc[u.id] = u;
  return acc;
}, {});
```

The explicit `<Record<number, User>>` (or the initial value) fixes the
accumulator type.

## Chaining

```typescript
const result = users
  .filter((u) => u.active)
  .map((u) => u.name)
  .sort()
  .join(", ");
```

Each step is typed; the pipeline reads top to bottom.

## Immutability

Prefer non-mutating operations:

```typescript
const added = [...items, newItem];         // new array
const updated = items.map((i) => i.id === id ? { ...i, done: true } : i);
const removed = items.filter((i) => i.id !== id);
```

`readonly T[]` parameters enforce this at the boundary:

```typescript
function summarize(items: readonly Item[]): number {
  return items.length;
}
```

> [!trap] reduce with a mutable accumulator
> Mutating the accumulator object is common but hides sharing. Return a new
> object when the value is shared across components/state.

## Avoiding mutation bugs

```typescript
// ❌ mutates the original
items.sort();

// ✅ copy first
const sorted = [...items].sort((a, b) => a.localeCompare(b));
```

`sort`, `reverse`, and `splice` mutate; `toSorted`, `toReversed`,
`toSpliced` (newer targets) return copies.

## Typed higher-order functions

```typescript
function pipe<A, B, C>(f: (a: A) => B, g: (b: B) => C): (a: A) => C {
  return (a) => g(f(a));
}
```

Types flow through composition — change a step and downstream types update.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How do you narrow a filter result from (string | null)[] to string[]?"
    type: single
    choices: ["filter(x => x)", "filter((x): x is string => x !== null)", "map", "reduce"]
    answer: [1]
    explanation: "A type predicate tells the compiler the result excludes other members."
    difficulty: 2
  - id: q2
    prompt: "What does map preserve?"
    type: single
    choices: ["Length", "Order only", "Nothing", "The element type"]
    answer: [0]
    explanation: "map returns an array of the same length with transformed elements."
    difficulty: 1
  - id: q3
    prompt: "Which array method mutates the original?"
    type: single
    choices: ["map", "filter", "sort", "slice"]
    answer: [2]
    explanation: "sort mutates in place; copy first or use toSorted."
    difficulty: 2
  - id: q4
    prompt: "Why annotate reduce's accumulator type?"
    type: single
    choices:
      - "To fix the accumulator type when inference cannot"
      - "To make it faster"
      - "It is required"
      - "To avoid the callback"
    answer: [0]
    explanation: "An explicit type parameter or initial value anchors the accumulator type."
    difficulty: 3
```