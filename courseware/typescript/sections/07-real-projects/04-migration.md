---
id: 04-migration
title: "Migrating JavaScript to TypeScript"
order: 4
section: 07-real-projects
language: typescript
summary: "Incremental migration, allowJs, checkJs, and the any escape hatch"
tags: [migration, javascript, allowjs, incremental]
---

# Migrating JavaScript to TypeScript

You rarely rewrite a JS codebase at once. Migrate **incrementally**, keeping
the build green the whole way.

## Step 1: Add TypeScript without changing behavior

```bash
npm install --save-dev typescript @types/node
npx tsc --init
```

Configure `allowJs` so `.js` files are included:

```json
{
  "compilerOptions": {
    "allowJs": true,
    "checkJs": false,
    "noEmit": true,
    "strict": false
  }
}
```

Everything still builds; nothing is typed yet.

## Step 2: Turn on checking gradually

Enable `checkJs` to check `.js` files, or start converting leaf modules.

```json
{ "compilerOptions": { "checkJs": true, "strict": false } }
```

Then tighten options one at a time:

1. `noImplicitAny`
2. `strictNullChecks`
3. `strict`

Turning on all of `strict` at once on a large codebase is painful. Ratchet.

> [!key] Migrate leaves first
> Modules with no internal dependencies are easiest to convert and unlock
> their importers. Work from the bottom of the dependency graph up.

## Step 3: Rename and type

Rename `foo.js` → `foo.ts`. Fix errors file by file.

```typescript
// before (foo.js)
export function add(a, b) { return a + b; }

// after (foo.ts)
export function add(a: number, b: number): number { return a + b; }
```

## Using any as a temporary bridge

`any` lets you defer typing at boundaries:

```typescript
function legacyCall(data: any): any { /* ... */ }
```

Prefer `unknown` for inputs and narrow later. Leave a TODO and burn down
`any` over time.

> [!trap] Do not let any spread
> Each `any` disables checking downstream. Isolate it at the edge, count
> them, and ratchet down. Consider `@typescript-eslint/no-explicit-any`.

## Step 4: Type the boundaries

The most valuable places to add types first:

- Public module APIs (what others import).
- Network/DTO shapes (parse, don't validate).
- Shared domain types.

Internal locals can stay inferred.

## Step 5: Enforce it

- Add `tsc --noEmit` to CI.
- Ban new `.js` files (lint rule).
- Enable stricter flags as debt shrinks.

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "allowJs": true
  }
}
```

## Common migration wins

- Find real bugs (typos, null derefs) immediately.
- Editor autocomplete and safe renames.
- Self-documenting interfaces for onboarding.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which option includes .js files in a TS project?"
    type: single
    choices: ["allowJs", "checkJs", "strict", "noEmit"]
    answer: [0]
    explanation: "allowJs lets .js files be part of the program."
    difficulty: 2
  - id: q2
    prompt: "Why migrate leaf modules first?"
    type: single
    choices:
      - "They have no internal dependencies, so they are easiest and unlock importers"
      - "They are shortest"
      - "They are unused"
      - "They compile faster"
    answer: [0]
    explanation: "Starting at the dependency graph's bottom minimizes churn."
    difficulty: 3
  - id: q3
    prompt: "How should strict mode be adopted on a large codebase?"
    type: single
    choices: ["All at once", "Ratchet options one at a time", "Never", "Only in tests"]
    answer: [1]
    explanation: "Turning on checks incrementally keeps the build green."
    difficulty: 2
  - id: q4
    prompt: "What is the risk of any?"
    type: single
    choices: ["It disables checking downstream", "It is slow", "It throws", "It is deprecated"]
    answer: [0]
    explanation: "any silences the checker and can spread through call chains."
    difficulty: 2
```