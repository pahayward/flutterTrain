---
id: 04-part-practice
title: "Part 6 Practice"
order: 4
section: 06-design-patterns
language: typescript
summary: "Review and exam questions for Design Patterns and Idioms"
tags: [practice, exam, review]
---

# Part 6 Practice

## Section review

- **Discriminated unions** — tagged variants, exhaustive switches,
  impossible states.
- **Functional idioms** — `map`/`filter`/`reduce`, type predicates,
  immutability.
- **Dependency injection** — interfaces as seams, constructor injection,
  testability.

```typescript
type Loadable<T> =
  | { state: "idle" }
  | { state: "loading" }
  | { state: "ready"; value: T }
  | { state: "failed"; error: Error };

function valueOr<T>(l: Loadable<T>, fallback: T): T {
  return l.state === "ready" ? l.value : fallback;
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What makes a union discriminable?"
    type: single
    choices: ["A shared literal tag field", "Optional fields", "Any", "Booleans"]
    answer: [0]
    explanation: "A shared literal field lets the compiler pick the variant."
    difficulty: 2
  - id: q2
    prompt: "How do you narrow filter's output type?"
    type: single
    choices: ["filter(x => !!x)", "A type predicate (x): x is T", "map", "reduce"]
    answer: [1]
    explanation: "A type predicate removes other union members from the result."
    difficulty: 2
  - id: q3
    prompt: "Which method mutates the array?"
    type: single
    choices: ["map", "filter", "reverse", "slice"]
    answer: [2]
    explanation: "reverse mutates in place; copy or use toReversed."
    difficulty: 2
  - id: q4
    prompt: "What is the goal of dependency injection?"
    type: single
    choices:
      - "Decouple components and enable testing"
      - "Improve runtime speed"
      - "Reduce file count"
      - "Avoid types"
    answer: [0]
    explanation: "DI lets you swap implementations and test in isolation."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - prompt: "What does an exhaustive switch on a discriminated union rely on?"
    type: single
    choices: ["A literal tag field", "Optional data", "any", "Booleans"]
    answer: [0]
    explanation: "The literal tag enables narrowing and exhaustiveness."
    weight: 2
    section: 06-design-patterns
  - prompt: "Which signals an unhandled union variant at compile time?"
    type: single
    choices: ["assertNever(x: never)", "return null", "throw any", "default: any"]
    answer: [0]
    explanation: "A never parameter makes missed cases compile errors."
    weight: 3
    section: 06-design-patterns
  - prompt: "What should a service depend on for swappable implementations?"
    type: single
    choices: ["Interfaces", "Concrete classes", "Globals", "Singletons"]
    answer: [0]
    explanation: "Depending on abstractions allows substitution and fakes."
    weight: 2
    section: 06-design-patterns
  - prompt: "Which is the immutable alternative to sort?"
    type: single
    choices: ["toSorted", "reverse", "splice", "push"]
    answer: [0]
    explanation: "toSorted returns a new sorted array without mutating."
    weight: 2
    section: 06-design-patterns
  - prompt: "What does a type predicate in filter do?"
    type: single
    choices: ["Narrows the result element type", "Sorts", "Mutates", "Casts to any"]
    answer: [0]
    explanation: "The predicate teaches the compiler which members remain."
    weight: 3
    section: 06-design-patterns
``````
