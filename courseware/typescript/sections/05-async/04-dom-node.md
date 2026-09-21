---
id: 04-dom-node
title: "The DOM and Node.js types"
order: 4
section: 05-async
language: typescript
summary: "DOM element types, Node globals, and avoiding global type clashes"
tags: [dom, node, lib, globals]
---

# The DOM and Node.js types

TypeScript needs to know which runtime globals exist. That comes from the
`lib` setting and `@types/node`.

## Browser: DOM lib

With `"lib": ["ES2022", "DOM"]`, browser globals are typed:

```typescript
const button = document.querySelector("button");
// HTMLButtonElement | null

button?.addEventListener("click", (event) => {
  const target = event.currentTarget as HTMLButtonElement;
  console.log(target.textContent);
});
```

## Narrowing DOM elements

`querySelector` returns a union base type. Cast or check:

```typescript
const input = document.querySelector("input");
if (input instanceof HTMLInputElement) {
  console.log(input.value);
}
```

Or use the generic form:

```typescript
const canvas = document.querySelector<HTMLCanvasElement>("#c");
const ctx = canvas?.getContext("2d");
```

> [!key] Prefer instanceof over as for DOM
> `instanceof HTMLInputElement` both narrows and catches the wrong element at
> runtime. `as` just silences the compiler.

## Events are typed

```typescript
form.addEventListener("submit", (e: SubmitEvent) => {
  e.preventDefault();
  const data = new FormData(e.currentTarget as HTMLFormElement);
});
```

## Node: @types/node

```bash
npm install --save-dev @types/node
```

Then Node globals are available:

```typescript
import { readFile } from "node:fs/promises";
import process from "node:process";

const text: string = await readFile("data.txt", "utf8");
console.log(process.env.NODE_ENV);
```

Use the `node:` prefix for clarity and to avoid clashing with npm packages
named `fs`, `path`, etc.

## Avoid mixing DOM and Node globals

If you include both `DOM` and `@types/node`, some globals conflict (e.g.
`fetch`, `setTimeout`, `URL`). Options:

- Separate `tsconfig` files for browser and server code.
- Keep `DOM` out of server configs.
- Use project references or `types` to scope.

```json
{ "compilerOptions": { "lib": ["ES2022"], "types": ["node"] } }
```

> [!trap] The wrong lib produces confusing errors
> "Cannot find name 'document'" means DOM lib is missing; "Cannot find module
> 'fs'" means @types/node is missing. Fix the config, not the code.

## Typing environment variables

```typescript
function requireEnv(key: string): string {
  const value = process.env[key];
  if (value === undefined) throw new Error(`Missing env: ${key}`);
  return value;
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which lib enables browser globals like document?"
    type: single
    choices: ["DOM", "ES2022", "node", "webworker"]
    answer: [0]
    explanation: "The DOM lib provides browser type definitions."
    difficulty: 1
  - id: q2
    prompt: "What does querySelector return by default?"
    type: single
    choices: ["HTMLElement", "Element | null", "any", "Node"]
    answer: [1]
    explanation: "It returns a broad Element (or null) that you narrow or cast."
    difficulty: 2
  - id: q3
    prompt: "How do you get Node.js globals typed?"
    type: single
    choices: ["Install @types/node", "Add DOM lib", "Use any", "Set target"]
    answer: [0]
    explanation: "@types/node supplies Node globals and module types."
    difficulty: 1
  - id: q4
    prompt: "Why might DOM and @types/node conflict?"
    type: single
    choices:
      - "They both declare some globals (fetch, setTimeout)"
      - "They cannot coexist"
      - "Node has no types"
      - "DOM overrides everything"
    answer: [0]
    explanation: "Overlapping global declarations can clash; scope libs per environment."
    difficulty: 3
```