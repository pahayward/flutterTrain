---
id: 04-functions
title: "Typing functions"
order: 4
section: 01-type-system
language: typescript
summary: "Parameters, returns, optional, defaults, rest, overloads"
tags: [functions, parameters, overloads, this]
---

# Typing functions

Functions are where most types meet. Get the parameters and return type
right and everything downstream follows.

## Annotate parameters, return

```typescript
function area(width: number, height: number): number {
  return width * height;
}
```

## Optional and default parameters

```typescript
function greet(name: string, greeting = "Hello"): string {
  return `${greeting}, ${name}!`;
}

function log(message: string, level?: "info" | "warn"): void {
  console.log(level ?? "info", message);
}
```

Optional parameters must come after required ones. A default parameter is
optional at the call site and its type is inferred.

## Rest parameters

```typescript
function sum(...nums: number[]): number {
  return nums.reduce((a, b) => a + b, 0);
}

sum(1, 2, 3, 4);   // 10
```

## Function types

```typescript
type BinaryOp = (a: number, b: number) => number;

const add: BinaryOp = (a, b) => a + b;   // a, b inferred from the type
```

`=>` in a type means "function returning". `void` return type accepts
functions that return values (they are just ignored).

> [!key] Callback parameters are inferred
> When you assign a function to a typed slot, its parameters get contextual
> types — no need to annotate them again.

## this parameter

```typescript
interface Button {
  label: string;
  onClick(this: Button, event: Event): void;
}

function handler(this: Button, event: Event) {
  console.log(this.label);   // this is typed
}
```

The `this` parameter is erased and only informs the compiler.

## Overloads

When one function accepts several distinct call shapes, declare overload
signatures plus one implementation:

```typescript
function parse(input: string): string[];
function parse(input: number): number[];
function parse(input: string | number): string[] | number[] {
  return typeof input === "string"
    ? input.split("")
    : [input];
}

parse("abc");   // string[]
parse(42);      // number[]
```

> [!trap] Overload signatures are not implementation
> The implementation signature is not callable directly — only the overload
> signatures define the public call shapes. Keep them compatible.

## Generic functions preview

```typescript
function first<T>(items: T[]): T | undefined {
  return items[0];
}

const n = first([1, 2, 3]);   // number | undefined
```

Generics get their own section in Part 2.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Where must optional parameters appear?"
    type: single
    choices:
      - "First"
      - "After required parameters"
      - "Anywhere"
      - "Only in constructors"
    answer: [1]
    explanation: "Optional/default parameters follow required ones."
    difficulty: 1
  - id: q2
    prompt: "What does the type (a: number) => number describe?"
    type: single
    choices: ["A class", "A function taking and returning numbers", "A tuple", "An object"]
    answer: [1]
    explanation: "The arrow syntax in a type is a function type."
    difficulty: 1
  - id: q3
    prompt: "What does a void return type allow a passed function to do?"
    type: single
    choices:
      - "Nothing"
      - "Return any value, which is ignored"
      - "Only return undefined"
      - "Only throw"
    answer: [1]
    explanation: "void is permissive: returning a value is allowed and discarded."
    difficulty: 2
  - id: q4
    prompt: "What are overload signatures used for?"
    type: single
    choices:
      - "Speeding up calls"
      - "Describing several distinct call shapes"
      - "Runtime dispatch"
      - "Type conversion"
    answer: [1]
    explanation: "Overloads declare multiple accepted call signatures over one implementation."
    difficulty: 2
```