---
id: 02-setting-up
title: "Tooling: tsc, tsconfig, npm"
order: 2
section: 00-foundations
language: typescript
summary: "Installing the compiler, tsconfig.json, and npm scripts"
tags: [tooling, tsc, tsconfig, npm]
---

# Tooling: tsc, tsconfig, npm

You need a tiny toolchain: Node.js, the TypeScript compiler, and a config
file that tells it what to do.

## Install the compiler

TypeScript ships via npm. Install it wherever you are (shown: global,
options; project-local is encouraged):

```bash
npm install -g typescript      # global
# or project-local:
npm install --save-dev typescript
```

Check it works:

```bash
tsc --version
```

## tsconfig.json — the config file

`tsc` reads `tsconfig.json` to know what to compile and how strictly:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true
  },
  "include": ["src"]
}
```

Generate a starter with:

```bash
tsc --init
```

> [!key] strict matters most
> `"strict": true` turns on the checks that make TypeScript worth it:
> strictNullChecks, noImplicitAny, strictFunctionTypes, and more. Keep it on.

## The standard workflow

```
src/*.ts  ──►  tsc -p tsconfig.json  ──►  dist/*.js
     ▲                                           │
     └── ts-node / tsx for quick runs            └── node dist/app.js
```

```bash
tsc            # compile once, respecting tsconfig
tsc --watch    # recompile on every save
node dist/app.js   # run the output
```

## npm scripts

Put the commands where everyone expects them — `package.json`:

```json
{
  "name": "hello-ts",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "start": "node dist/app.js"
  }
}
```

```bash
npm run build
npm run start
```

> [!tip] tsx for frictionless dev
> `npx tsx src/app.ts` runs TypeScript directly without a separate build
> step — great for scripts and demos. Not for final artifacts.

## What you won't see yet

Editor tooling (IntelliSense) plugs in automatically: VS Code pairs with
tsc through the language service, so hover/types errors appear as you type --
no plugin needed.

> [!note] The editor is a compiler too
> Your IDE runs TypeScript in the background. A red squiggle in the editor
> is the same error `tsc` would report on the command line.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which file configures the TypeScript compiler?"
    type: single
    choices: ["package.json", "tsconfig.json", "env.json", "config.ts"]
    answer: [1]
    explanation: "tsconfig.json holds compiler options and which files to include."
    difficulty: 1
  - id: q2
    prompt: "What does 'strict': true primarily enable?"
    type: single
    choices:
      - "Faster compilation"
      - "Strict null checks and no implicit any"
      - "Automatic bundling"
      - "ES module syntax"
    answer: [1]
    explanation: "Strict mode turns on the type-safety checks (strictNullChecks, noImplicitAny, ...)."
    difficulty: 2
  - id: q3
    prompt: "Which command recompiles on every file save?"
    type: single
    choices: ["tsc --watch", "tsc --live", "tsc -p", "tsc --rebuild"]
    answer: [0]
    explanation: "--watch recompiles the project whenever a source file changes."
    difficulty: 1
  - id: q4
    prompt: "Where does tsc put compiled JavaScript files?"
    type: single
    choices:
      - "Beside each source file always"
      - "In the outDir specified in tsconfig"
      - "In node_modules"
      - "In a cache directory"
    answer: [1]
    explanation: "The outDir compiler option tells tsc where to emit output."
    difficulty: 1
```