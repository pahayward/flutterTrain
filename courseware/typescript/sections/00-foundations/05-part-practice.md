---
id: 05-part-practice
title: "Part 0 Practice"
order: 5
section: 00-foundations
language: typescript
summary: "Review and exam questions for the Foundations part"
tags: [practice, exam, review]
---

# Part 0 Practice

## Section review

You've covered the foundations:

- **What TypeScript is** — a typed superset of JavaScript; types are erased
  at compile time; tsc type-checks and transpiles.
- **Tooling** — `npm install typescript`, `tsconfig.json` with
  `"strict": true`, `tsc --watch`, npm scripts.
- **First program** — annotations, inferred variables, compile/run loop,
  deliberate type errors.
- **Basic types** — `string/number/boolean`, arrays, tuples, objects,
  `any`/`unknown`/`void`/`never`, `null`/`undefined`, unions.

```typescript
interface Product {
  id: number;
  name: string;
  price: number;
}

const catalog: Product[] = [
  { id: 1, name: "Laptop", price: 900 },
  { id: 2, name: "Monitor", price: 250 },
];

function totalPrice(items: Product[]): number {
  return items.reduce((sum, p) => sum + p.price, 0);
}

console.log(totalPrice(catalog));   // 1150
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which command type-checks without emitting output?"
    type: single
    choices: ["tsc --noEmit", "tsc --check", "tsc --dry", "tsc --safe"]
    answer: [0]
    explanation: "--noEmit runs the checker but writes no JS files."
    difficulty: 2
  - id: q2
    prompt: "What type does 'let x: number[]' describe?"
    type: single
    choices: ["A tuple of one number", "An array of numbers", "A number", "A set"]
    answer: [1]
    explanation: "number[] is an array whose elements are numbers."
    difficulty: 1
  - id: q3
    prompt: "Which is safer than any for an unknown input?"
    type: single
    choices: ["never", "unknown", "void", "object"]
    answer: [1]
    explanation: "unknown requires narrowing, unlike any which disables checking."
    difficulty: 2
  - id: q4
    prompt: "What does s?: string mean on a parameter?"
    type: single
    choices:
      - "s is required"
      - "s is string | undefined and may be omitted"
      - "s is any"
      - "s defaults to ''"
    answer: [1]
    explanation: "The ? makes the parameter optional, adding undefined to its type."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "TypeScript is best described as what?"
    type: single
    choices: ["A JS runtime", "A typed superset of JavaScript", "A CSS preprocessor", "A database"]
    answer: [1]
    explanation: "TS is JavaScript plus a compile-time type system."
    weight: 2
    section: 00-foundations
  - prompt: "What happens to type annotations in compiled output?"
    type: single
    choices: ["They remain", "They are erased", "They become comments", "They become tests"]
    answer: [1]
    explanation: "Types exist only at compile time and are stripped from emitted JS."
    weight: 2
    section: 00-foundations
  - prompt: "Which tsconfig setting enables the full set of type checks?"
    type: single
    choices: ["\"target\"", "\"strict\"", "\"module\"", "\"outDir\""]
    answer: [1]
    explanation: "\"strict\": true enables strictNullChecks, noImplicitAny, and more."
    weight: 3
    section: 00-foundations
  - prompt: "Which type means a function never returns?"
    type: single
    choices: ["void", "never", "null", "unknown"]
    answer: [1]
    explanation: "never describes a function that always throws or loops forever."
    weight: 2
    section: 00-foundations
  - prompt: "What is the primitive string type spelled as?"
    type: single
    choices: ["String", "string", "str", "char[]"]
    answer: [1]
    explanation: "Use lowercase string for the primitive type."
    weight: 1
    section: 00-foundations
``````
