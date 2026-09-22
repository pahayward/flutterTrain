---
id: 01-inference-annotations
title: "Inference and annotations"
order: 1
section: 01-type-system
language: typescript
summary: "When to let TypeScript infer and when to annotate"
tags: [inference, annotations, best-practice]
---

# Inference and annotations

TypeScript is smart about guessing types. Good style is to annotate the
**boundaries** and let inference handle the **internals**.

## Inference in action

```typescript
let count = 42;                 // inferred: number
let name = "Ada";               // inferred: string
const pi = 3.14;                // inferred: 3.14 (literal) — const is precise
let tags = ["a", "b"];          // inferred: string[]
let user = { id: 1, name: "A" }; // inferred: { id: number; name: string }
```

The compiler widens literal values for `let` (mutable) but keeps the exact
literal for `const`:

```typescript
let mode = "dark";      // type: string
const MODE = "dark";    // type: "dark"  (literal)
```

## Return type inference

Functions infer their return type from the body:

```typescript
function add(a: number, b: number) {
  return a + b;          // inferred return: number
}
```

Annotate the return type anyway when the function is public — it becomes a
contract and produces better errors if the body changes.

## When to annotate

- **Function parameters** — required (no inference possible).
- **Public function returns** — documents the contract.
- **Variables with no initial value** — no initializer, no inference.
- **When the inferred type is too wide** — e.g. you want a union or literal.

```typescript
let status: "idle" | "loading" | "done" = "idle";   // narrow on purpose
let maybe: number | undefined;                      // no initializer
```

> [!key] Annotate the edges, infer the middle
> Parameter and return annotations at API boundaries; local variables rely
> on inference. This keeps code concise and types precise.

## The `any` leak

An untyped import or `JSON.parse` gives `any`, which spreads:

```typescript
const data = JSON.parse(text);   // any
data.foo.bar.baz;                // no error — and no help
```

Fix by asserting or validating into a known type:

```typescript
interface ApiUser { id: number; name: string }
const user = JSON.parse(text) as ApiUser;
```

Better: validate at runtime (Part 5).

> [!trap] Inference can't read your mind
> `const x = [];` infers `any[]` until you push, then it can evolve. For a
> fixed element type, annotate: `const x: number[] = [];`.

## Contextual typing

The expected type flows into a callback:

```typescript
const nums = [1, 2, 3];
nums.map((n) => n * 2);   // n inferred as number from nums
```

```typescript
window.addEventListener("click", (e) => {
  console.log(e.clientX);  // e inferred as MouseEvent
});
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What type does const mode = 'dark' infer?"
    type: single
    choices: ["string", "\"dark\"", "any", "unknown"]
    answer: [1]
    explanation: "const keeps the literal type, so it is \"dark\"."
    difficulty: 2
  - id: q2
    prompt: "Which should you annotate explicitly?"
    type: single
    choices:
      - "Every local variable"
      - "Function parameters and public return types"
      - "Nothing; inference always wins"
      - "Only arrays"
    answer: [1]
    explanation: "Annotate API boundaries; let locals infer."
    difficulty: 2
  - id: q3
    prompt: "Why is any dangerous?"
    type: single
    choices:
      - "It slows the compiler"
      - "It disables checking and spreads silently"
      - "It cannot be printed"
      - "It is removed at runtime"
    answer: [1]
    explanation: "any opts out of type checking, so errors hide until runtime."
    difficulty: 1
  - id: q4
    prompt: "What is contextual typing?"
    type: single
    choices:
      - "Types inferred from the surrounding expected type"
      - "Types loaded from a file"
      - "Types set by the OS"
      - "Types added by a bundler"
    answer: [0]
    explanation: "Callback parameters get types from the context they appear in."
    difficulty: 2
```