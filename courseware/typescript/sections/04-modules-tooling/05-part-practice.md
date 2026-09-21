---
id: 05-part-practice
title: "Part 4 Practice"
order: 5
section: 04-modules-tooling
language: typescript
summary: "Review and exam questions for Modules and Tooling"
tags: [practice, exam, review]
---

# Part 4 Practice

## Section review

- **ES modules** — named/default exports, `import type`, barrels, dynamic
  import.
- **Declarations** — `.d.ts`, `@types`, ambient modules, augmentation.
- **tsconfig** — `strict`, `target`, `lib`, `moduleResolution`,
  `noUncheckedIndexedAccess`, `paths`.
- **Tooling** — tsc vs ts-node/tsx, Vite/webpack/esbuild, and the
  transpile-vs-typecheck split.

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "noUncheckedIndexedAccess": true,
    "declaration": true,
    "outDir": "dist"
  }
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which import form is erased at compile time?"
    type: single
    choices: ["import { x }", "import type { T }", "import x from", "import * as"]
    answer: [1]
    explanation: "import type exists only for the checker."
    difficulty: 2
  - id: q2
    prompt: "Where do types for untyped packages come from?"
    type: single
    choices: ["@types packages", "tsconfig paths", "The DOM", "The bundler"]
    answer: [0]
    explanation: "DefinitelyTyped's @types packages supply declarations."
    difficulty: 1
  - id: q3
    prompt: "Which tsconfig option makes arr[0] possibly undefined?"
    type: single
    choices: ["strict", "noUncheckedIndexedAccess", "exactOptionalPropertyTypes", "lib"]
    answer: [1]
    explanation: "It adds undefined to indexed access results."
    difficulty: 3
  - id: q4
    prompt: "What must accompany a fast transpiler in CI?"
    type: single
    choices: ["A tsc --noEmit type-check step", "Another bundler", "A formatter", "Nothing"]
    answer: [0]
    explanation: "Transpilers strip types without checking, so CI needs tsc --noEmit."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which export style is easiest to auto-import and refactor?"
    type: single
    choices: ["Default export", "Named export", "Namespace export", "Dynamic export"]
    answer: [1]
    explanation: "Named exports keep stable identifiers across the codebase."
    weight: 2
    section: 04-modules-tooling
  - prompt: "What is a .d.ts file?"
    type: single
    choices: ["Runtime code", "Type declarations only", "A test", "A bundle"]
    answer: [1]
    explanation: "Declaration files describe types and are erased at build."
    weight: 1
    section: 04-modules-tooling
  - prompt: "Which tsconfig option enables strictNullChecks and noImplicitAny?"
    type: single
    choices: ["strict", "target", "lib", "outDir"]
    answer: [0]
    explanation: "strict enables the whole family of strict checks."
    weight: 1
    section: 04-modules-tooling
  - prompt: "What does moduleResolution: Bundler target?"
    type: single
    choices: ["Modern bundler import resolution", "Node CJS only", "Browser globals", "Tests"]
    answer: [0]
    explanation: "It matches how bundlers resolve extensions and package exports."
    weight: 3
    section: 04-modules-tooling
  - prompt: "Do bundlers type-check TypeScript?"
    type: single
    choices: ["Yes", "No, they strip types only", "Only in production", "Only for .tsx"]
    answer: [1]
    explanation: "Bundlers transpile; use tsc --noEmit for checking."
    weight: 2
    section: 04-modules-tooling
``````
