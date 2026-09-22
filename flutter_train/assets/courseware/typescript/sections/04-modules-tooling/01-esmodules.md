---
id: 01-esmodules
title: "ES modules: import and export"
order: 1
section: 04-modules-tooling
language: typescript
summary: "Named/default exports, re-exports, and type-only imports"
tags: [modules, import, export, esm]
---

# ES modules

TypeScript uses standard ECMAScript module syntax, with extra support for
importing and exporting **types**.

## Named exports

```typescript
// math.ts
export const PI = 3.14159;

export function add(a: number, b: number): number {
  return a + b;
}

export interface Point { x: number; y: number }
```

```typescript
// main.ts
import { add, PI, type Point } from "./math";

add(1, 2);
```

## Default exports

```typescript
// logger.ts
export default function log(msg: string): void {
  console.log(msg);
}
```

```typescript
import log from "./logger";
```

> [!key] Prefer named exports
> Named exports are easier to refactor, auto-import, and re-export. Default
> exports allow any local name, which hurts discoverability. Use default
> only for a module's single obvious thing.

## Importing types explicitly

With `verbatimModuleSyntax` / `isolatedModules`, type imports must be marked:

```typescript
import type { Point } from "./geometry";
import { type Config, loadConfig } from "./config";   // mixed
```

`import type` is erased at compile time and cannot be used as a value.

## Re-exports and barrels

```typescript
// index.ts
export { add, PI } from "./math";
export type { Point } from "./math";
export * from "./geometry";
```

A barrel (`index.ts`) gathers a folder's public API:

```typescript
import { add, Point } from "./lib";
```

> [!trap] Barrels can cause cycles and slow builds
> Re-exporting everything makes it easy to create import cycles and defeats
> tree-shaking. Use explicit exports for large packages.

## Aliases and renaming

```typescript
import { add as sum } from "./math";
export { add as plus } from "./math";
```

## Dynamic import

```typescript
const mod = await import("./heavy");
mod.doWork();
```

Returns a promise — great for lazy-loading.

## `import =` and CommonJS interop

TypeScript can import CommonJS modules with ES syntax when `esModuleInterop`
is on. Default-import a CJS module and the compiler synthesizes the interop.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which import is erased at compile time?"
    type: single
    choices: ["import { add }", "import type { Point }", "import log", "await import(...)"]
    answer: [1]
    explanation: "import type is type-only and produces no runtime code."
    difficulty: 2
  - id: q2
    prompt: "What is a barrel file?"
    type: single
    choices:
      - "An index that re-exports a folder's API"
      - "A build cache"
      - "A test fixture"
      - "A type guard"
    answer: [0]
    explanation: "index.ts barrels gather and re-export modules for a cleaner import path."
    difficulty: 2
  - id: q3
    prompt: "Why prefer named exports over default?"
    type: single
    choices:
      - "They are faster at runtime"
      - "They refactor and auto-import more reliably"
      - "They are required by TS"
      - "They avoid types"
    answer: [1]
    explanation: "Named exports keep a stable name across the codebase and tooling."
    difficulty: 2
  - id: q4
    prompt: "What does await import('./x') return?"
    type: single
    choices: ["The module namespace", "A string", "void", "A class"]
    answer: [0]
    explanation: "Dynamic import resolves to the module's namespace object."
    difficulty: 3
```