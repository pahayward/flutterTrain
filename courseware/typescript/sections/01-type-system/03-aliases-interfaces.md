---
id: 03-aliases-interfaces
title: "Type aliases and interfaces"
order: 3
section: 01-type-system
language: typescript
summary: "Naming shapes: interface vs type alias, extension, merging"
tags: [interface, type-alias, extension, declaration-merging]
---

# Type aliases and interfaces

Both name a type. They overlap a lot; the differences matter in a few spots.

## Interfaces

Describe object shapes and can be extended:

```typescript
interface User {
  id: number;
  name: string;
  email?: string;          // optional
}

interface Admin extends User {
  permissions: string[];
}

const a: Admin = { id: 1, name: "Ada", permissions: ["all"] };
```

## Type aliases

Name **any** type, not just objects:

```typescript
type UserId = number;
type Point = { x: number; y: number };
type Status = "idle" | "loading" | "done";
type Handler = (event: string) => void;
type Maybe<T> = T | null;
```

## Which to use

| Capability | interface | type alias |
|---|---|---|
| Object shapes | ✅ | ✅ |
| Unions / primitives | ❌ | ✅ |
| Extends another | ✅ `extends` | ✅ `&` intersection |
| Declaration merging | ✅ | ❌ |
| Implements by class | ✅ | ✅ |
| Recursive self-reference | ✅ | ✅ |

> [!key] Default guidance
> Use `interface` for public object contracts (it merges and reads well in
> errors); use `type` when you need unions, tuples, mapped types, or a name
> for a non-object type. Mixing both is normal and fine.

## Extending and intersecting

```typescript
interface Animal { name: string }
interface Dog extends Animal { breed: string }

type HasId = { id: number };
type Entity = User & HasId;          // intersection: must have both
```

`extends` and `&` both combine; intersection means "all members at once".

## Declaration merging

Two interfaces with the same name merge — type aliases cannot:

```typescript
interface Config { host: string }
interface Config { port: number }

const c: Config = { host: "localhost", port: 8080 };   // both required
```

Useful for augmenting third-party library types.

> [!trap] Merging can surprise you
> Accidental duplicate interface names merge silently. Keep interfaces in
> modules and import explicitly to avoid global collisions.

## Structural typing

TypeScript compares **shapes**, not names:

```typescript
interface Point { x: number; y: number }

function plot(p: Point) { /* ... */ }

const p = { x: 1, y: 2, z: 3 };
plot(p);   // ✅ extra property allowed when passing a variable
plot({ x: 1, y: 2, z: 3 });   // ❌ excess property check on object literal
```

> [!note] Excess property checks
> Object **literals** get a stricter check: unknown properties are flagged.
> Values from variables are checked by structural compatibility and may
> carry extra properties.

## Readonly and index signatures

```typescript
interface Settings {
  readonly apiKey: string;           // cannot be reassigned
  [key: string]: string | number;    // arbitrary extra keys
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which can name a union type?"
    type: single
    choices: ["interface", "type alias", "Both", "Neither"]
    answer: [1]
    explanation: "Interfaces describe object shapes; type aliases can name unions."
    difficulty: 2
  - id: q2
    prompt: "Which supports declaration merging?"
    type: single
    choices: ["type alias", "interface", "Both", "Neither"]
    answer: [1]
    explanation: "Duplicate interface declarations merge; type aliases do not."
    difficulty: 2
  - id: q3
    prompt: "What does A & B mean?"
    type: single
    choices: ["A or B", "Both A and B", "A minus B", "Not A"]
    answer: [1]
    explanation: "Intersection requires all members of both types."
    difficulty: 1
  - id: q4
    prompt: "Why does plot({x:1,y:2,z:3}) error but plot(p) not, when p has z?"
    type: single
    choices:
      - "A bug in TypeScript"
      - "Excess property checks apply to object literals"
      - "p is any"
      - "z is optional"
    answer: [1]
    explanation: "Fresh object literals are checked for excess properties; variables are shape-checked."
    difficulty: 3
```