---
id: 02-constraints
title: "Constraints and defaults"
order: 2
section: 02-generics-progres
language: typescript
summary: "Limiting type parameters with extends, and defaults"
tags: [generics, constraints, extends, keyof]
---

# Constraints and defaults

Unconstrained generics accept anything. A **constraint** (`extends`) says
what a type parameter is allowed to be, so you can use its members.

## The need for constraints

```typescript
function longest<T>(a: T, b: T): T {
  return a.length >= b.length ? a : b;   // ❌ T has no length
}
```

The compiler is right: `T` could be a number. Constrain it:

```typescript
function longest<T extends { length: number }>(a: T, b: T): T {
  return a.length >= b.length ? a : b;
}

longest("abc", "de");        // ✅ string has length
longest([1, 2], [3]);        // ✅ array has length
longest(1, 2);               // ❌ number has no length
```

## keyof constraints

A very common pattern: accept any key of an object.

```typescript
function get<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = { id: 1, name: "Ada" };
const id = get(user, "id");       // number
const name = get(user, "name");   // string
get(user, "email");               // ❌ not a key
```

`keyof T` is a union of T's property names; `T[K]` is the type of that
property — an **indexed access type**.

## Defaults

Type parameters can have defaults:

```typescript
interface ApiResult<T = unknown> {
  data: T;
  ok: boolean;
}

const r: ApiResult = { data: {}, ok: true };       // T defaults to unknown
const r2: ApiResult<string> = { data: "hi", ok: true };
```

## Multiple constraints

Combine with `&`:

```typescript
function copy<T extends { id: number } & { name: string }>(x: T): T {
  return { ...x };
}
```

> [!key] Constraints are compile-time only
> `T extends X` adds no runtime check. It only tells the checker what
> members `T` guarantees.

## Constraining with unions

```typescript
function setMode<T extends "on" | "off">(mode: T): T {
  return mode;
}

setMode("on");     // ✅
setMode("auto");   // ❌
```

## Constraints enable safe building

```typescript
function merge<T extends object, U extends object>(a: T, b: U): T & U {
  return { ...a, ...b };
}

const merged = merge({ id: 1 }, { name: "Ada" });
// { id: number } & { name: string }
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does T extends { length: number } allow you to do?"
    type: single
    choices:
      - "Nothing new"
      - "Use .length on values of type T"
      - "Convert T to number"
      - "Skip type checking"
    answer: [1]
    explanation: "The constraint guarantees a length member, so it can be used."
    difficulty: 2
  - id: q2
    prompt: "What is keyof T?"
    type: single
    choices:
      - "The values of T"
      - "A union of T's property names"
      - "The constructor of T"
      - "A generic function"
    answer: [1]
    explanation: "keyof produces a union of the property keys of T."
    difficulty: 2
  - id: q3
    prompt: "What does T[K] represent when K extends keyof T?"
    type: single
    choices:
      - "The key type"
      - "The property type at key K"
      - "The whole object"
      - "A tuple"
    answer: [1]
    explanation: "Indexed access T[K] yields the type of property K."
    difficulty: 2
  - id: q4
    prompt: "What is a type parameter default?"
    type: single
    choices:
      - "A runtime fallback value"
      - "A type used when none is supplied"
      - "A required argument"
      - "A constraint"
    answer: [1]
    explanation: "Defaults like <T = unknown> apply when the caller omits the argument."
    difficulty: 1
```