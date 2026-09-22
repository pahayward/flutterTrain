---
id: 03-tsconfig
title: "tsconfig options that matter"
order: 3
section: 04-modules-tooling
language: typescript
summary: "strict, target, module, lib, paths, and the options worth turning on"
tags: [tsconfig, strict, compiler-options]
---

# tsconfig options that matter

`tsconfig.json` controls how the compiler checks and emits. A few options do
most of the work.

## A solid baseline

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
```

## strict — the big one

`strict: true` turns on a family of checks:

- `strictNullChecks` — `null`/`undefined` are not assignable to everything.
- `noImplicitAny` — parameters must be typed (or inferrable).
- `strictFunctionTypes`, `strictPropertyInitialization`, and more.

Always enable `strict` for new code. It is the single highest-value option.

## target and lib

- `target` — the JS version emitted (`ES2015` … `ES2022`, `ESNext`).
- `lib` — which built-in type definitions are available.

```json
{ "target": "ES2020", "lib": ["ES2020", "DOM"] }
```

Add `"DOM"` for browser code; omit it for Node (use `@types/node`).

## module and moduleResolution

- `module` — output module format (`ESNext`, `CommonJS`, `NodeNext`).
- `moduleResolution` — how imports are resolved (`node`, `bundler`,
  `nodenext`).

For modern bundlers, `"moduleResolution": "Bundler"`; for pure Node ESM,
`"NodeNext"`.

> [!key] noUncheckedIndexedAccess catches real bugs
> With it on, `arr[0]` is `T | undefined`, forcing you to handle the empty
> case. Slightly noisier, much safer.

## paths — import aliases

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@app/*": ["src/*"] }
  }
}
```

```typescript
import { add } from "@app/math";
```

> [!trap] paths are compile-time only
> `paths` does not rewrite runtime imports. Your bundler or a runtime alias
> (tsconfig-paths) must also resolve them.

## Useful extras

- `noImplicitOverride` — require `override` on overrides.
- `noFallthroughCasesInSwitch` — catch missing `break`.
- `exactOptionalPropertyTypes` — distinguish `{x?: T}` from `{x: T | undefined}`.
- `skipLibCheck` — skip checking `.d.ts` files (faster; usually safe).

## include, exclude, files

```json
{
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which option enables the family of null/any checks?"
    type: single
    choices: ["strict", "target", "outDir", "lib"]
    answer: [0]
    explanation: "strict turns on strictNullChecks, noImplicitAny, and more."
    difficulty: 1
  - id: q2
    prompt: "What does target control?"
    type: single
    choices: ["Emitted JS version", "Module format", "Type checking", "Folder layout"]
    answer: [0]
    explanation: "target selects the JavaScript language level for output."
    difficulty: 1
  - id: q3
    prompt: "What does noUncheckedIndexedAccess change?"
    type: single
    choices:
      - "arr[0] becomes T | undefined"
      - "Arrays become readonly"
      - "Indexes are removed"
      - "It adds types"
    answer: [0]
    explanation: "It makes indexed access include undefined for safety."
    difficulty: 3
  - id: q4
    prompt: "What does lib add when set to DOM?"
    type: single
    choices: ["Browser global types", "A bundler", "Node APIs", "Tests"]
    answer: [0]
    explanation: "lib selects built-in type libraries such as DOM globals."
    difficulty: 2
```