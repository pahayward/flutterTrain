---
id: 06-part-practice
title: "Part 2 Practice"
order: 6
section: 02-generics-progres
language: typescript
summary: "Review and exam questions for Generics and Advanced Types"
tags: [practice, exam, review]
---

# Part 2 Practice

## Section review

You've learned to build and transform types:

- **Generics** — type parameters that preserve relationships; generic
  functions, interfaces, classes.
- **Constraints** — `T extends ...`, `keyof`, indexed access `T[K]`,
  defaults.
- **Utility types** — `Partial`, `Pick`, `Omit`, `Record`, `Readonly`,
  `ReturnType`, `Parameters`.
- **Mapped/conditional types** — `[K in keyof T]`, `T extends X ? A : B`,
  `infer`, key remapping.
- **Assertions** — `as`, `satisfies`, `unknown`, `never`, `!`, assertion
  functions.

```typescript
type User = { id: number; name: string; email: string };

type CreateUser = Omit<User, "id">;
type UserPatch = Partial<CreateUser>;

function update(id: number, patch: UserPatch): void {
  // merge patch into stored user
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which constraint lets you use obj[key] safely and type it?"
    type: single
    choices: ["K extends keyof T", "T extends object", "K extends string", "T = any"]
    answer: [0]
    explanation: "K extends keyof T restricts keys and T[K] types the result."
    difficulty: 2
  - id: q2
    prompt: "Which utility makes every property optional?"
    type: single
    choices: ["Required", "Partial", "Readonly", "Pick"]
    answer: [1]
    explanation: "Partial<T> marks all properties optional."
    difficulty: 1
  - id: q3
    prompt: "What is infer used for?"
    type: single
    choices:
      - "Capturing a type inside a conditional type"
      - "Inferring runtime values"
      - "Making a type optional"
      - "Asserting non-null"
    answer: [0]
    explanation: "infer extracts a type variable from a matched type pattern."
    difficulty: 3
  - id: q4
    prompt: "What does satisfies do?"
    type: single
    choices:
      - "Validates a value against a type while keeping its narrow type"
      - "Converts the value at runtime"
      - "Removes null"
      - "Makes a type generic"
    answer: [0]
    explanation: "satisfies checks assignability but preserves the precise inferred type."
    difficulty: 3
```

## ExamQuestions

```yaml
bank:
  - prompt: "What does a generic type parameter preserve?"
    type: single
    choices: ["Runtime values", "The relationship between input and output types", "Memory layout", "Comments"]
    answer: [1]
    explanation: "Generics keep type relationships instead of erasing to any."
    weight: 2
    section: 02-generics-progres
  - prompt: "What does keyof T produce?"
    type: single
    choices: ["A union of T's property names", "T's values", "A tuple", "A class"]
    answer: [0]
    explanation: "keyof yields the union of an object's keys."
    weight: 2
    section: 02-generics-progres
  - prompt: "Which utility removes selected keys?"
    type: single
    choices: ["Pick", "Omit", "Partial", "Record"]
    answer: [1]
    explanation: "Omit<T, K> drops keys K from T."
    weight: 2
    section: 02-generics-progres
  - prompt: "What is the safe alternative to any?"
    type: single
    choices: ["never", "unknown", "object", "void"]
    answer: [1]
    explanation: "unknown requires narrowing before use, unlike any."
    weight: 2
    section: 02-generics-progres
  - prompt: "What does satisfies do?"
    type: single
    choices: ["Checks a value against a type, keeping its narrow type", "Casts at runtime", "Adds a constraint", "Creates a union"]
    answer: [0]
    explanation: "satisfies validates assignability without widening the value's type."
    weight: 3
    section: 02-generics-progres
``````
