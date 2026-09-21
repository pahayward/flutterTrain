---
id: 04-mapped-conditional
title: "Mapped and conditional types"
order: 4
section: 02-generics-progres
language: typescript
summary: "Transform every key; choose types based on conditions"
tags: [mapped-types, conditional-types, infer, advanced]
---

# Mapped and conditional types

This is the machinery behind the utility types. Once you see it, you can
build your own type transformations.

## Mapped types

Iterate over the keys of a type:

```typescript
type Optional<T> = {
  [K in keyof T]?: T[K];
};

type Readonly<T> = {
  readonly [K in keyof T]: T[K];
};
```

`[K in keyof T]` is a **mapped type**: it visits each key. Add modifiers
(`?`, `readonly`, `-?`, `-readonly`) to add or remove them.

```typescript
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];   // strip readonly
};
```

## Key remapping with as

```typescript
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface State { count: number; name: string }
type StateGetters = Getters<State>;
// { getCount: () => number; getName: () => string }
```

## Conditional types

Choose a type based on a condition:

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<"hi">;    // true
type B = IsString<42>;      // false
```

The `extends` here is a **type-level condition**, not a constraint.

## infer

Extract a type from within another:

```typescript
type ElementType<T> = T extends (infer U)[] ? U : never;

type E1 = ElementType<string[]>;    // string
type E2 = ElementType<number[]>;    // number

type Unwrap<T> = T extends Promise<infer U> ? U : T;
type U1 = Unwrap<Promise<string>>;  // string
```

`infer U` declares a type variable captured from the matched shape.

## Distributive conditional types

When the checked type is a naked type parameter, the conditional distributes
over unions:

```typescript
type ToArray<T> = T extends any ? T[] : never;
type R = ToArray<string | number>;   // string[] | number[]
```

Wrap in a tuple to prevent distribution: `[T] extends [any] ? ...`.

> [!key] These are the building blocks
> `Partial`, `Pick`, `ReturnType`, `Exclude` are all defined with mapped and
> conditional types. Recognizing the pattern makes the standard library
> readable.

## A practical example

```typescript
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

interface Nested { a: { b: number } }
type FrozenNested = DeepReadonly<Nested>;
// all levels readonly
```

> [!trap] Type-level recursion can explode
> Deep/recursive conditional types are powerful but can hit compiler limits
> or slow builds. Keep them shallow, add memoization patterns, and prefer
> explicit interfaces when complexity grows.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does [K in keyof T] describe?"
    type: single
    choices: ["A tuple", "A mapped type over T's keys", "A union", "An index signature"]
    answer: [1]
    explanation: "It maps over each key of T, building a new object type."
    difficulty: 2
  - id: q2
    prompt: "In T extends string ? true : false, what is extends?"
    type: single
    choices:
      - "A constraint"
      - "A conditional type test"
      - "An intersection"
      - "A runtime check"
    answer: [1]
    explanation: "In a conditional type, extends tests assignability and picks a branch."
    difficulty: 2
  - id: q3
    prompt: "What does infer U do?"
    type: single
    choices:
      - "Declares a runtime variable"
      - "Captures a type from the matched shape"
      - "Infers a value"
      - "Removes a type"
    answer: [1]
    explanation: "infer introduces a type variable captured during conditional matching."
    difficulty: 3
  - id: q4
    prompt: "What does -readonly in a mapped type do?"
    type: single
    choices:
      - "Adds readonly"
      - "Removes readonly"
      - "Errors"
      - "Makes it optional"
    answer: [1]
    explanation: "The minus modifier strips the modifier from mapped properties."
    difficulty: 2
```