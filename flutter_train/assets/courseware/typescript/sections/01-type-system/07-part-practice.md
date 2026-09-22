---
id: 07-part-practice
title: "Part 1 Practice"
order: 7
section: 01-type-system
language: typescript
summary: "Review and exam questions for the Type System part"
tags: [practice, exam, review]
---

# Part 1 Practice

## Section review

You've built the type toolkit:

- **Inference** — annotate boundaries, infer internals; avoid `any`.
- **Unions and literals** — `A | B`, exact values, discriminants.
- **Aliases vs interfaces** — `interface` for object contracts and merging,
  `type` for unions/tuples; structural typing.
- **Functions** — parameters, returns, optional/default/rest, overloads,
  `this`, callbacks.
- **Objects/arrays/tuples** — readonly, index signatures, `Record`, tuples.
- **Narrowing** — `typeof`, `in`, `instanceof`, truthiness, discriminated
  unions, user-defined guards, `never` exhaustiveness.

```typescript
type ApiResponse =
  | { status: "ok"; data: string[] }
  | { status: "error"; message: string };

function handle(res: ApiResponse): string[] {
  return res.status === "ok" ? res.data : [];
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which combination of type names an exact set of strings?"
    type: single
    choices: ["string[]", "string | string", "\"a\" | \"b\"", "Record<string>"]
    answer: [2]
    explanation: "Literal unions enumerate exact allowed string values."
    difficulty: 1
  - id: q2
    prompt: "What does A & B require?"
    type: single
    choices: ["Either A or B", "All members of both A and B", "A without B", "A or B optionally"]
    answer: [1]
    explanation: "Intersection combines all members of both types."
    difficulty: 1
  - id: q3
    prompt: "Which operator checks membership of a property for narrowing?"
    type: single
    choices: ["typeof", "in", "instanceof", "as"]
    answer: [1]
    explanation: "'prop' in value narrows object unions by property presence."
    difficulty: 2
  - id: q4
    prompt: "What does a function typed (n: number) => string mean?"
    type: single
    choices: ["Takes a string, returns a number", "Takes a number, returns a string", "Returns a number", "Takes no args"]
    answer: [1]
    explanation: "Parameters are on the left of =>, return on the right."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which can name a union type?"
    type: single
    choices: ["interface", "type alias", "enum only", "class"]
    answer: [1]
    explanation: "Type aliases can name any type, including unions."
    weight: 2
    section: 01-type-system
  - prompt: "What narrows a string | number value?"
    type: single
    choices: ["typeof", "as", "in", "keyof"]
    answer: [0]
    explanation: "typeof checks distinguish the primitive alternatives."
    weight: 2
    section: 01-type-system
  - prompt: "Which supports declaration merging?"
    type: single
    choices: ["type alias", "interface", "union", "tuple"]
    answer: [1]
    explanation: "Interfaces with the same name merge; type aliases cannot."
    weight: 3
    section: 01-type-system
  - prompt: "What is an optional parameter's type?"
    type: single
    choices: ["T", "T | undefined", "any", "never"]
    answer: [1]
    explanation: "The ? adds undefined, since callers may omit the argument."
    weight: 2
    section: 01-type-system
  - prompt: "How do you signal an exhaustive check?"
    type: single
    choices: ["return null", "assertNever(x: never)", "throw any", "default: any"]
    answer: [1]
    explanation: "A never-typed parameter makes missed cases compile errors."
    weight: 3
    section: 01-type-system
``````
