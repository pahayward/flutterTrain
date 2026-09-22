---
id: 04-basic-types
title: "The basic types"
order: 4
section: 00-foundations
language: typescript
summary: "string, number, boolean, arrays, objects, and special types"
tags: [types, primitives, any, void, never]
---

# The basic types

TypeScript's primitives mirror JavaScript's values, plus a few types that
only exist at compile time.

## The primitives

```typescript
let title: string = "Zero to Hero";
let pages: number = 350;
let published: boolean = true;
let big: bigint = 9007199254740991n;
let id: symbol = Symbol("id");
```

Lowercase `string`, `number`, `boolean` are the types. Do **not** use the
wrapper types `String`, `Number`, `Boolean` — they mean something different
and are almost always wrong.

> [!trap] String vs string
> `let s: String` is an object wrapper type. `let s: string` is the
> primitive. Always use the lowercase form.

## Arrays and tuples

```typescript
let scores: number[] = [90, 85, 77];
let names: Array<string> = ["Ada", "Grace"];   // equivalent

let point: [number, number] = [3, 4];           // tuple: fixed length + types
let pair: [string, number] = ["age", 36];
```

A tuple pins positions; a plain array allows any number of elements.

## Objects

```typescript
let user: { name: string; age: number } = {
  name: "Ada",
  age: 36,
};
```

Usually you name this shape with an interface or type alias (next part).

## Special types

| Type | Meaning |
|---|---|
| `any` | opt out of checking — avoid it |
| `unknown` | a value of unknown type — must narrow before use |
| `void` | a function returns nothing |
| `never` | a value that can never occur (always throws/loops) |
| `null` / `undefined` | explicit absence (with strict mode) |
| `object` | any non-primitive value |

```typescript
function log(msg: string): void {
  console.log(msg);            // returns nothing
}

function fail(msg: string): never {
  throw new Error(msg);        // never returns
}

let data: unknown = JSON.parse(input);
if (typeof data === "string") {
  console.log(data.toUpperCase());   // narrowed to string
}
```

> [!key] Prefer unknown to any
> `any` disables all checks and spreads silently. `unknown` forces you to
> prove the type before use — safe and explicit.

## null and undefined

With `strictNullChecks` (part of `strict`), `null` and `undefined` are not
automatically assignable to everything:

```typescript
let nickname: string = null;          // ❌ under strict
let nickname2: string | null = null;  // ✅ explicit

function len(s?: string): number {    // s: string | undefined
  return s ? s.length : 0;
}
```

Optional parameter `s?: string` is sugar for `string | undefined`.

## Union shorthand

```typescript
let status: "open" | "closed" | "pending" = "open";
let value: number | string = 42;
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which is the correct primitive boolean type?"
    type: single
    choices: ["Boolean", "bool", "boolean", "bit"]
    answer: [2]
    explanation: "Lowercase boolean is the primitive; Boolean is an object wrapper."
    difficulty: 1
  - id: q2
    prompt: "What is the difference between a tuple and an array?"
    type: single
    choices:
      - "Tuples are faster"
      - "A tuple has fixed length and per-position types"
      - "Arrays cannot hold numbers"
      - "Tuples are readonly only"
    answer: [1]
    explanation: "[number, number] fixes both length and element types."
    difficulty: 2
  - id: q3
    prompt: "Which type forces you to narrow before use?"
    type: single
    choices: ["any", "unknown", "string", "void"]
    answer: [1]
    explanation: "unknown must be checked/narrowed; any skips all checking."
    difficulty: 2
  - id: q4
    prompt: "What does a function returning void mean?"
    type: single
    choices:
      - "It always throws"
      - "It returns no meaningful value"
      - "It returns null"
      - "It is async"
    answer: [1]
    explanation: "void marks a function whose return value is not used."
    difficulty: 1
  - id: q5
    prompt: "What is string | null an example of?"
    type: single
    choices: ["An interface", "A union type", "A tuple", "A generic"]
    answer: [1]
    explanation: "The pipe combines alternatives into a union type."
    difficulty: 1
```