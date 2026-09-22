---
id: 03-utility-types
title: "Utility types: Partial, Pick, Omit"
order: 3
section: 02-generics-progres
language: typescript
summary: "Transform existing types without rewriting them"
tags: [utility-types, partial, pick, omit, record]
---

# Utility types

TypeScript ships **utility types** that transform other types. They save you
from hand-writing variants.

## Partial and Required

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

type UserPatch = Partial<User>;    // every property optional
type CompleteUser = Required<User>; // every property required
```

`Partial<User>` is exactly what an update/PATCH function wants.

## Pick and Omit

```typescript
type UserSummary = Pick<User, "id" | "name">;    // only these keys
type UserWithoutEmail = Omit<User, "email">;     // all but these
```

- `Pick<T, K>` keeps only `K`.
- `Omit<T, K>` drops `K`.

## Record

```typescript
type Role = "admin" | "editor" | "viewer";
type Permissions = Record<Role, string[]>;

const perms: Permissions = {
  admin: ["all"],
  editor: ["read", "write"],
  viewer: ["read"],
};
```

## Readonly and ReadonlyArray

```typescript
type FrozenUser = Readonly<User>;

function total(items: ReadonlyArray<number>): number {
  return items.reduce((a, b) => a + b, 0);
}
```

## ReturnType and Parameters

```typescript
function makeUser(name: string, age: number) {
  return { name, age, active: true };
}

type NewUser = ReturnType<typeof makeUser>;       // { name: string; age: number; active: boolean }
type Args = Parameters<typeof makeUser>;          // [string, number]
```

These keep types in sync automatically when a function changes.

## NonNullable and Exclude

```typescript
type T1 = string | null | undefined;
type Clean = NonNullable<T1>;      // string

type T2 = "a" | "b" | "c";
type NoB = Exclude<T2, "b">;       // "a" | "c"
```

## Combining them

```typescript
interface Order {
  id: number;
  customerId: number;
  items: string[];
  total: number;
}

type NewOrder = Omit<Order, "id" | "total">;   // what the client sends
type OrderUpdate = Partial<Pick<Order, "items" | "total">>;
```

> [!key] Utility types are just mapped types
> `Partial`, `Pick`, `Omit` are built from the mapped/conditional machinery
> in the next lesson. You can write your own the same way.

## Why this matters

Model one canonical type and derive the API's variants (create, update,
summary) from it. When the base changes, the variants follow automatically —
no drift between request/response types.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does Partial<T> produce?"
    type: single
    choices: ["All required", "All optional", "All readonly", "A union"]
    answer: [1]
    explanation: "Partial makes every property optional."
    difficulty: 1
  - id: q2
    prompt: "Which keeps only the listed keys?"
    type: single
    choices: ["Omit", "Pick", "Partial", "Record"]
    answer: [1]
    explanation: "Pick<T, K> selects the keys K; Omit removes them."
    difficulty: 1
  - id: q3
    prompt: "What does Record<'a' | 'b', number> describe?"
    type: single
    choices:
      - "A tuple [number, number]"
      - "An object with keys 'a' and 'b' mapping to numbers"
      - "A number or string"
      - "A function"
    answer: [1]
    explanation: "Record builds an object type keyed by the union with a value type."
    difficulty: 2
  - id: q4
    prompt: "What does ReturnType<typeof fn> give?"
    type: single
    choices:
      - "The argument types"
      - "The function's return type"
      - "The function name"
      - "The function body"
    answer: [1]
    explanation: "ReturnType extracts the return type from a function type."
    difficulty: 2
```