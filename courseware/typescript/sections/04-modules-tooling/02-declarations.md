---
id: 02-declarations
title: "Declaration files and @types"
order: 2
section: 04-modules-tooling
language: typescript
summary: "How TypeScript learns the types of plain JavaScript libraries"
tags: [declarations, "d.ts", "@types", ambient]
---

# Declaration files and @types

Most npm packages are JavaScript. **Declaration files** (`*.d.ts`) describe
their types so TypeScript can check your usage.

## What a declaration file is

A `.d.ts` contains types only — no runtime code:

```typescript
// greeter.d.ts
export function greet(name: string): string;
export interface Options { loud?: boolean }
```

The compiler uses it for checking; the actual `.js` runs.

## DefinitelyTyped and @types

When a library ships no types, install them from DefinitelyTyped:

```bash
npm install --save-dev @types/node
npm install --save-dev @types/lodash
```

TypeScript automatically includes `@types/*` packages from `node_modules`.

## Ambient declarations

Declare globals or modules that exist at runtime but have no types:

```typescript
// globals.d.ts
declare const APP_VERSION: string;

declare module "legacy-lib" {
  export function run(input: string): number;
}
```

`declare` says "trust me, this exists" — no output is generated.

## Augmenting existing types

Add fields to a library's types:

```typescript
// express.d.ts
import "express";

declare module "express" {
  interface Request {
    userId?: string;
  }
}
```

Now `req.userId` is allowed everywhere.

> [!key] One declaration file can cover a whole library
> A hand-written `.d.ts` is often all you need to use a JS package safely.
> You do not have to rewrite the library in TypeScript.

## Generating declarations

Compile with `declaration: true` to emit `.d.ts` files for your own package:

```json
{
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true
  }
}
```

`declarationMap` lets editors jump from a declaration to the source.

> [!trap] Do not put runtime code in .d.ts
> A `.d.ts` is erased. If you write a function body there, it never runs.
> Keep implementations in `.ts`; declarations describe them.

## Checking for types

Before adding a package, check whether it ships its own types
(`"types"` field in package.json) or needs `@types`. Editors show this
instantly as red squiggles on the import.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does a .d.ts file contain?"
    type: single
    choices: ["Runtime code", "Type declarations only", "Tests", "Config"]
    answer: [1]
    explanation: "Declaration files describe types and are erased at build."
    difficulty: 1
  - id: q2
    prompt: "Where do types for untyped npm packages usually come from?"
    type: single
    choices: ["@types on DefinitelyTyped", "The compiler guesses", "The .js file", "tsconfig"]
    answer: [0]
    explanation: "Community-maintained @types packages supply declarations."
    difficulty: 1
  - id: q3
    prompt: "What does declare module 'x' do?"
    type: single
    choices:
      - "Provides ambient types for module x"
      - "Imports module x"
      - "Runs module x"
      - "Deletes module x"
    answer: [0]
    explanation: "Ambient module declarations tell the compiler what x's shape is."
    difficulty: 2
  - id: q4
    prompt: "What does declaration: true emit?"
    type: single
    choices: [".d.ts files for your package", "Source maps", "Bundles", "Tests"]
    answer: [0]
    explanation: "The declaration option emits declaration files alongside JS."
    difficulty: 2
```