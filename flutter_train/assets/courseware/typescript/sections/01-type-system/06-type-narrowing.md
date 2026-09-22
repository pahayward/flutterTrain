---
id: 06-type-narrowing
title: "Narrowing: guards, typeof, in"
order: 6
section: 01-type-system
language: typescript
summary: "How control flow refines a union to a single member"
tags: [narrowing, typeof, instanceof, type-guards]
---

# Narrowing

When you have a union, **narrowing** uses runtime checks to prove which member
you have — and the compiler tracks it through control flow.

## typeof

```typescript
function pad(value: string | number): string {
  if (typeof value === "number") {
    return value.toFixed(2);      // value: number
  }
  return value.trim();            // value: string
}
```

`typeof` narrows primitives: `"string"`, `"number"`, `"boolean"`,
`"bigint"`, `"symbol"`, `"undefined"`, `"object"`, `"function"`.

## Truthiness and null checks

```typescript
function greet(name?: string): string {
  if (name) {
    return `Hi ${name}`;         // name: string (not undefined/"")
  }
  return "Hi there";
}

function length(s: string | null): number {
  if (s !== null) return s.length;
  return 0;
}
```

> [!trap] Truthiness also excludes empty strings and 0
> `if (value)` narrows out `""`, `0`, and `NaN` too. If those are valid, use
> explicit `value !== undefined && value !== null` checks.

## Equality narrowing

```typescript
type Mode = "on" | "off" | number;

function describe(m: Mode): string {
  if (m === "on") return "enabled";
  if (m === "off") return "disabled";
  return `level ${m}`;           // m: number
}
```

## The in operator

```typescript
type Fish = { swim: () => void };
type Bird = { fly: () => void };

function move(animal: Fish | Bird) {
  if ("swim" in animal) {
    animal.swim();               // animal: Fish
  } else {
    animal.fly();                // animal: Bird
  }
}
```

## instanceof

```typescript
function format(value: Date | string): string {
  if (value instanceof Date) {
    return value.toISOString();  // value: Date
  }
  return value;                  // value: string
}
```

## Discriminated unions

A shared literal field narrows exhaustively:

```typescript
type Result =
  | { ok: true; value: number }
  | { ok: false; error: string };

function unwrap(r: Result): number {
  if (r.ok) return r.value;      // r: { ok: true; ... }
  throw new Error(r.error);      // r: { ok: false; ... }
}
```

## User-defined type guards

When built-ins can't narrow, write a predicate returning `x is T`:

```typescript
function isString(x: unknown): x is string {
  return typeof x === "string";
}

function process(x: unknown) {
  if (isString(x)) {
    console.log(x.toUpperCase());   // x: string
  }
}
```

> [!key] Narrowing is flow-sensitive
> The compiler tracks assignments and branches. Reassigning a variable
> inside a branch can widen it again — narrow into a `const` when possible.

## Exhaustiveness with never

```typescript
function assertNever(x: never): never {
  throw new Error(`Unhandled: ${JSON.stringify(x)}`);
}

type Shape = { kind: "circle" } | { kind: "square" };

function area(s: Shape): number {
  switch (s.kind) {
    case "circle": return 1;
    case "square": return 1;
    default: return assertNever(s);   // compile error if a case is missed
  }
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which operator narrows a string | number value?"
    type: single
    choices: ["in", "typeof", "as", "keyof"]
    answer: [1]
    explanation: "typeof value === 'string' narrows primitives."
    difficulty: 1
  - id: q2
    prompt: "What is a user-defined type guard's return annotation?"
    type: single
    choices: ["boolean", "x is T", "void", "T | undefined"]
    answer: [1]
    explanation: "A predicate like (x): x is string teaches the compiler to narrow."
    difficulty: 2
  - id: q3
    prompt: "How does a discriminated union narrow?"
    type: single
    choices:
      - "By checking a shared literal field"
      - "By casting with as"
      - "By using any"
      - "It cannot narrow"
    answer: [0]
    explanation: "A common literal property (kind/ok/type) identifies the member."
    difficulty: 2
  - id: q4
    prompt: "Why can if (value) narrow out valid 0 and ''?"
    type: single
    choices:
      - "Because 0 and '' are falsy"
      - "Because they are null"
      - "Because TypeScript forbids them"
      - "It does not; they stay"
    answer: [0]
    explanation: "Truthiness excludes all falsy values; use explicit null/undefined checks."
    difficulty: 3
  - id: q5
    prompt: "What does the never type signal in a switch default?"
    type: single
    choices:
      - "A missed case (compile error)"
      - "A runtime crash"
      - "An infinite loop"
      - "A no-op"
    answer: [0]
    explanation: "assertNever(x: never) makes an unhandled member a compile error."
    difficulty: 3
```