---
id: 05-type-assertions
title: "Assertions, unknown, never"
order: 5
section: 02-generics-progres
language: typescript
summary: "as, satisfies, unknown, never, and assertion functions"
tags: [assertions, as, satisfies, unknown, never]
---

# Assertions, unknown, never

Sometimes you know more than the compiler. Use these tools to say so — but
honestly.

## as — type assertion

```typescript
const el = document.getElementById("app") as HTMLDivElement;
el.innerHTML = "hi";
```

`as` does **not** convert anything at runtime; it just tells the compiler to
trust you. A wrong assertion is a bug the compiler cannot catch.

> [!trap] Assertions are a promise, not a check
> `x as string` on a number compiles and then fails at runtime. Narrow with
> guards when you can; assert only when you have external knowledge.

## unknown — the safe any

```typescript
function handle(input: unknown) {
  // input.toUpperCase();  ❌ must narrow first
  if (typeof input === "string") {
    input.toUpperCase();   // ✅
  }
}
```

`unknown` accepts anything on the way in but allows almost nothing until you
prove the type.

## never

`never` is the empty type: no value belongs to it.

- A function that never returns: `function fail(): never { throw ... }`.
- Exhaustiveness checks (Part 1).
- Impossible branches after narrowing.

```typescript
function assertNever(x: never): never {
  throw new Error(`Unexpected: ${JSON.stringify(x)}`);
}
```

## satisfies — check without widening

`satisfies` validates a value against a type **while keeping the narrow
inferred type**:

```typescript
const config = {
  host: "localhost",
  port: 8080,
} satisfies { host: string; port: number };

config.host.toUpperCase();   // still typed as string literal "localhost"
```

Compare with an annotation, which would widen:

```typescript
const config2: { host: string; port: number } = { host: "localhost", port: 8080 };
// config2.host is just string, not "localhost"
```

> [!key] satisfies = validate, don't coerce
> Use `satisfies` when you want a value checked against a shape but also
> want to preserve its precise type (great for config and lookup tables).

## Non-null assertion (!)

```typescript
const el = document.getElementById("app")!;   // asserts not null
```

The `!` postfix removes `null | undefined`. Convenient but unsafe; prefer
guards. Reserve it for cases the compiler truly cannot know.

## Assertion functions

A function that narrows via a `asserts` signature:

```typescript
function assertDefined<T>(val: T): asserts val is NonNullable<T> {
  if (val === null || val === undefined) {
    throw new Error("Expected value");
  }
}

let name: string | undefined = getName();
assertDefined(name);
name.toUpperCase();   // narrowed to string
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does x as T do at runtime?"
    type: single
    choices: ["Converts the value", "Nothing — it is compile-time only", "Throws", "Validates the value"]
    answer: [1]
    explanation: "Assertions are erased and perform no runtime conversion or check."
    difficulty: 2
  - id: q2
    prompt: "Why is unknown safer than any?"
    type: single
    choices:
      - "It is faster"
      - "It requires narrowing before use"
      - "It stores more data"
      - "It cannot be assigned"
    answer: [1]
    explanation: "unknown forces a check; any skips checking entirely."
    difficulty: 1
  - id: q3
    prompt: "What does satisfies preserve that an annotation does not?"
    type: single
    choices:
      - "The precise inferred type"
      - "The runtime value"
      - "Readonly"
      - "Optionality"
    answer: [0]
    explanation: "satisfies validates against a shape while keeping the literal/narrow type."
    difficulty: 3
  - id: q4
    prompt: "What does the ! postfix do?"
    type: single
    choices:
      - "Negates a boolean"
      - "Removes null and undefined from the type"
      - "Makes it optional"
      - "Calls a function"
    answer: [1]
    explanation: "The non-null assertion strips null | undefined from the type."
    difficulty: 2
```