---
id: 01-generics-basics
title: "Generics"
order: 1
section: 02-generics-progres
language: typescript
summary: "Type parameters, generic functions, and reusable containers"
tags: [generics, type-parameters, reusable]
---

# Generics

Generics let a function, class, or type work with **many types while keeping
the relationship between them**. Instead of `any`, you keep the type.

## The problem without generics

```typescript
function firstAny(items: any[]): any {
  return items[0];
}

const n = firstAny([1, 2, 3]);   // n: any — no help
```

The type is lost. Generics preserve it:

```typescript
function first<T>(items: T[]): T | undefined {
  return items[0];
}

const n = first([1, 2, 3]);      // n: number | undefined
const s = first(["a", "b"]);     // s: string | undefined
```

`<T>` is a **type parameter**; at the call site TypeScript infers `T` from
the argument.

## Naming conventions

Single uppercase letters are conventional: `T` (type), `K` (key), `V`
(value), `U`, `R` (result). Descriptive names (`TItem`, `TResult`) are fine
for public APIs.

## Generic interfaces and type aliases

```typescript
interface Box<T> {
  value: T;
}

const b: Box<number> = { value: 42 };

type Pair<A, B> = { first: A; second: B };
const p: Pair<string, number> = { first: "age", second: 36 };
```

## Generic classes

```typescript
class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  get size(): number {
    return this.items.length;
  }
}

const nums = new Stack<number>();
nums.push(1);
nums.push(2);
```

> [!key] Explicit type arguments are optional
> `new Stack<number>()` documents intent; often the compiler infers from
> usage. Be explicit when inference cannot decide.

## Multiple type parameters

```typescript
function pair<A, B>(a: A, b: B): [A, B] {
  return [a, b];
}

const p = pair("id", 7);   // [string, number]
```

## Generic arrow functions

```typescript
const identity = <T,>(x: T): T => x;   // the comma avoids JSX ambiguity
```

> [!trap] Generic arrows in .tsx files
> In `.tsx`, `<T>` starts a JSX element, so write `<T,>` (or `<T extends unknown>`) to disambiguate.

## When to use generics

Use them when a function or type should work for many types **and** the
types relate to each other (input type flows to output type). If types do
not relate, a union or overload may be simpler.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the main advantage of generics over any?"
    type: single
    choices:
      - "Faster runtime"
      - "Preserves type relationships through the call"
      - "Smaller output"
      - "No compiler checks"
    answer: [1]
    explanation: "Generics keep the input/output type link instead of erasing to any."
    difficulty: 1
  - id: q2
    prompt: "In function first<T>(items: T[]): T | undefined, what is T?"
    type: single
    choices: ["A type parameter", "A variable", "A runtime value", "An interface"]
    answer: [0]
    explanation: "T is a type parameter inferred at each call."
    difficulty: 1
  - id: q3
    prompt: "Why write <T,> in a .tsx generic arrow?"
    type: single
    choices:
      - "It is a typo"
      - "To avoid parsing as JSX"
      - "It means optional"
      - "It adds a constraint"
    answer: [1]
    explanation: "The trailing comma disambiguates from a JSX opening tag."
    difficulty: 3
  - id: q4
    prompt: "Which is a good use of generics?"
    type: single
    choices:
      - "A function whose output type depends on its input type"
      - "A function that always returns string"
      - "A constant"
      - "A CSS rule"
    answer: [0]
    explanation: "Generics shine when types are linked across inputs and outputs."
    difficulty: 2
```