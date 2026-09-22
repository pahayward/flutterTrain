---
id: 04-build-tooling
title: "Bundlers: ts-node, webpack, Vite"
order: 4
section: 04-modules-tooling
language: typescript
summary: "Running and bundling TypeScript across dev and production"
tags: [tooling, bundler, vite, webpack, ts-node, esbuild]
---

# Bundlers and runners

TypeScript must be **compiled** (types erased) before it runs. Several tools
do this, each with a different trade-off.

## tsc — the baseline

```bash
npx tsc              # type-check + emit
npx tsc --noEmit     # type-check only
npx tsc --watch      # recompile on change
```

`tsc` is the reference implementation. It is thorough but slow for large
projects and does not bundle.

## Running directly: ts-node / tsx

For scripts and Node development:

```bash
npx ts-node src/index.ts
npx tsx src/index.ts        # faster, esbuild-based
```

`ts-node` type-checks then runs; `tsx` strips types without checking (much
faster). Use `tsx` for dev speed, `tsc --noEmit` in CI for checking.

## Bundlers

A bundler resolves imports, transpiles, and produces one or more output
files.

### Vite

The default choice for new web apps:

```bash
npm create vite@latest my-app -- --template react-ts
npm run dev       # instant dev server with HMR
npm run build     # production bundle
```

Vite uses esbuild for TS (types stripped, not checked). Run `tsc --noEmit`
separately for type errors.

### webpack

Mature and configurable, common in larger/legacy projects:

```js
// webpack.config.js
module.exports = {
  entry: "./src/index.ts",
  module: {
    rules: [{ test: /\.tsx?$/, use: "ts-loader", exclude: /node_modules/ }],
  },
  resolve: { extensions: [".ts", ".tsx", ".js"] },
};
```

### esbuild / swc

Extremely fast transpilers used by other tools. They strip types only — pair
them with `tsc --noEmit` for checking.

> [!key] Transpile ≠ type-check
> esbuild, swc, Vite, and tsx strip types without checking them. Keep a
> `tsc --noEmit` step in CI so errors are not silently shipped.

## The standard split

- **Dev**: fast transpile + watch (Vite, tsx).
- **CI**: `tsc --noEmit` for full type checking, tests.
- **Build**: bundler emits production JS.

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "typecheck": "tsc --noEmit"
  }
}
```

> [!trap] Do not ship untypechecked code
> Because bundlers erase types, a "successful" build can still contain type
> errors. Always run the type-checker in CI.

## Source maps

Enable source maps (`sourceMap: true`) so stack traces point to your `.ts`
source, not compiled output. Bundlers produce them automatically in dev.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does tsc --noEmit do?"
    type: single
    choices: ["Type-checks without output", "Bundles", "Runs the app", "Installs types"]
    answer: [0]
    explanation: "--noEmit checks types only, emitting no files."
    difficulty: 1
  - id: q2
    prompt: "Do Vite and esbuild fully type-check TypeScript?"
    type: single
    choices: ["Yes", "No, they strip types only", "Only in prod", "Only with plugins"]
    answer: [1]
    explanation: "They transpile (strip types) but do not run the checker."
    difficulty: 2
  - id: q3
    prompt: "Which tool runs a TS file directly and fast by stripping types?"
    type: single
    choices: ["tsx", "tsc", "npm", "jest"]
    answer: [0]
    explanation: "tsx uses esbuild to strip types and execute quickly."
    difficulty: 2
  - id: q4
    prompt: "Why keep tsc --noEmit in CI?"
    type: single
    choices:
      - "Bundlers skip type checking, so errors would otherwise ship"
      - "It bundles the app"
      - "It installs dependencies"
      - "It formats code"
    answer: [0]
    explanation: "A dedicated type-check step catches errors transpilers ignore."
    difficulty: 3
```