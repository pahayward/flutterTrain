---
id: 01-what-is-typescript
title: "What TypeScript is: JS + types"
order: 1
section: 00-foundations
language: typescript
summary: "A typed superset of JavaScript that compiles back to JS"
tags: [typescript, javascript, compiled, superset]
---

# What TypeScript is

**TypeScript** is a **typed superset of JavaScript**. Every valid JavaScript
program is also valid TypeScript — you write JS, then add types on top.

```typescript
// This is valid JavaScript AND valid TypeScript:
const greet = (name) => `Hello, ${name}!`;
console.log(greet("Ada"));
```

## What the compiler does

`tsc` (the TypeScript compiler) does two jobs:

1. **Type-checks** your code at build time, catching bugs before runtime.
2. **Transpiles** (compiles) it to plain JavaScript the runtime understands.

```
source.ts ──► tsc ──► source.js
                 │
                 └── type errors reported here
```

> [!key] Types vanish at runtime
> The types you write are erased when compiled. The output `.js` contains no
> type annotations — just ordinary JS plus whatever the runtime supports.

## Why add types at all

| Without types | With types |
|---|---|
| First error at runtime | First error at compile time |
| "What fields does this object have?" | Editor auto-completes them |
| Refactoring is risky | The compiler checks every caller |
| `undefined` surprises | Null-safety and narrowing |

The core promise: **move more bugs from production to compile time**, and let
the editor do the remembering.

> [!note] This course's running example
> Examples build up a small typed e-commerce domain (Product, Cart,
> checkout) across the course; later parts reuse it. Earlier parts use
> self-contained snippets.

## The language family

TypeScript sits between JavaScript and your editor:

```
JavaScript  ── 15 years this way ──►  TypeScript  ──►  .js output
plain, untyped                        typed, checked        browser/Node
```

Anything JavaScript can do, TypeScript can express — with better guardrails.

## A taste of the difference

```typescript
// JS: silent runtime failure
function double(x) { return x * 2; }
double("text");   // no error today → NaN at runtime

// TS: compile error, caught now
function double(x: number): number { return x * 2; }
double("text");   // ❌ Argument of type 'string' is not assignable to 'number'
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What relation does TypeScript have to JavaScript?"
    type: single
    choices:
      - "It replaces it completely"
      - "It is a typed superset"
      - "It is a different language with no link"
      - "It is a JavaScript framework"
    answer: [1]
    explanation: "Every valid JS program is valid TS; TS adds types."
    difficulty: 1
  - id: q2
    prompt: "What happens to type annotations after compilation?"
    type: single
    choices:
      - "They stay in the output"
      - "They are erased"
      - "They become comments"
      - "They crash the compiler"
    answer: [1]
    explanation: "TypeScript removes types during transpilation; the .js output is plain JS."
    difficulty: 1
  - id: q3
    prompt: "Where does TypeScript catch most type bugs?"
    type: single
    choices:
      - "At runtime"
      - "At compile time"
      - "In the browser console"
      - "On the server only"
    answer: [1]
    explanation: "tsc reports type errors before the code ever runs."
    difficulty: 1
  - id: q4
    prompt: "What is the main benefit promised by TypeScript?"
    type: single
    choices:
      - "Faster runtime code"
      - "More bugs caught at compile time and better editor support"
      - "Smaller file sizes"
      - "No need for Node.js"
    answer: [1]
    explanation: "Compile-time checking moves errors earlier and powers autocomplete."
    difficulty: 1
```