---
id: 02-data-modeling
title: "Modeling domain data with types"
order: 2
section: 07-real-projects
language: typescript
summary: "Branded types, units, validated values, and parse-don't-validate"
tags: [domain-modeling, branded-types, validation, parse]
---

# Modeling domain data

Good types describe the domain so the compiler prevents mistakes. This is
where TypeScript pays off most.

## Start from the domain

```typescript
type Currency = "USD" | "EUR" | "GBP";

interface Money {
  amount: number;      // in minor units (cents)
  currency: Currency;
}

function add(a: Money, b: Money): Money {
  if (a.currency !== b.currency) {
    throw new Error("Currency mismatch");
  }
  return { amount: a.amount + b.amount, currency: a.currency };
}
```

The `Currency` union prevents mixing unknown currency strings.

## Branded types for primitives

`string` and `number` are too broad. A **brand** distinguishes them:

```typescript
type Brand<T, B> = T & { readonly __brand: B };

type UserId = Brand<number, "UserId">;
type OrderId = Brand<number, "OrderId">;

function userId(id: number): UserId {
  return id as UserId;
}

function loadUser(id: UserId): void { /* ... */ }

const uid = userId(1);
loadUser(uid);          // ✅
// loadUser(2);         // ❌ number is not UserId
```

You cannot accidentally pass an order id where a user id is expected.

## Units and measures

```typescript
type Seconds = Brand<number, "Seconds">;
type Millis = Brand<number, "Millis">;

function toMillis(s: Seconds): Millis {
  return (s * 1000) as Millis;
}
```

> [!key] Branding is compile-time only
> `as UserId` does nothing at runtime. Brands stop mix-ups in code, not
> malicious input. Combine with runtime validation at boundaries.

## Parse, don't validate

Convert untyped input into typed values **once**, at the edge:

```typescript
interface User { id: UserId; name: string }

function parseUser(input: unknown): User {
  if (
    typeof input === "object" && input !== null &&
    "id" in input && "name" in input &&
    typeof (input as any).id === "number" &&
    typeof (input as any).name === "string"
  ) {
    const { id, name } = input as { id: number; name: string };
    return { id: userId(id), name };
  }
  throw new Error("Invalid user");
}
```

After parsing, the rest of the app works with trusted `User` values.

> [!trap] Validation libraries save effort
> Hand-writing parsers gets verbose. Zod, Valibot, or io-ts derive the static
> type from the runtime schema, so validation and types never drift.

## Making invalid states unrepresentable

```typescript
// ❌ email may be missing when verified is true
interface AccountBad {
  verified: boolean;
  email?: string;
}

// ✅ verified implies an email exists
type Account =
  | { verified: false }
  | { verified: true; email: string };
```

## Enums vs unions

Prefer string-literal unions over `enum`:

```typescript
type Status = "active" | "inactive";   // ✅ erasable, tree-shakeable
enum Status { Active, Inactive }        // ⚠️ emits runtime code
```

> [!tip] Literal unions are usually the better enum
> They erase at compile time, narrow naturally, and serialize cleanly.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is a branded type for?"
    type: single
    choices:
      - "Distinguishing structurally identical primitives"
      - "Improving runtime speed"
      - "Validating at runtime"
      - "Replacing interfaces"
    answer: [0]
    explanation: "Brands make UserId distinct from OrderId though both are numbers."
    difficulty: 3
  - id: q2
    prompt: "What does 'parse, don't validate' mean?"
    type: single
    choices:
      - "Convert untyped input into typed values once at the boundary"
      - "Validate everywhere"
      - "Never check input"
      - "Use any"
    answer: [0]
    explanation: "Parse at the edge so the core works with trusted types."
    difficulty: 2
  - id: q3
    prompt: "Which is generally preferred over enum?"
    type: single
    choices: ["String-literal union", "class", "any", "namespace"]
    answer: [0]
    explanation: "Literal unions erase at compile time and narrow naturally."
    difficulty: 2
  - id: q4
    prompt: "What makes invalid states unrepresentable?"
    type: single
    choices:
      - "A union where each variant only carries fields valid for it"
      - "Optional fields"
      - "Boolean flags"
      - "any"
    answer: [0]
    explanation: "Variants that only include valid fields remove impossible combinations."
    difficulty: 3
```