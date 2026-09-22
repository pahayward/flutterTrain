---
id: 02-async-await
title: "async and await"
order: 2
section: 05-async
language: typescript
summary: "Async functions, await, return types, and concurrency"
tags: [async, await, concurrency]
---

# async and await

`async`/`await` is syntax over promises that reads like synchronous code.
TypeScript types it precisely.

## Async functions always return a Promise

```typescript
async function getCount(): Promise<number> {
  return 42;                 // returning number → Promise<number>
}

async function logIt(): Promise<void> {
  console.log("hi");         // no return → Promise<void>
}
```

You never write `return Promise.resolve(42)` — returning `42` is enough.

## await unwraps a promise

```typescript
async function main(): Promise<void> {
  const count: number = await getCount();   // Promise<number> → number
  console.log(count + 1);
}
```

`await` can only be used inside `async` functions (or top-level ESM modules
with the right config).

## Sequential vs concurrent

```typescript
// ❌ sequential: waits for each before starting the next
const a = await fetchA();
const b = await fetchB();

// ✅ concurrent: start both, then await together
const [a, b] = await Promise.all([fetchA(), fetchB()]);
```

> [!key] Start promises first, await later
> `await` pauses the function. Kick off independent work before awaiting so
> requests overlap instead of running one-by-one.

## Loops and async

`await` inside a loop runs sequentially:

```typescript
for (const id of ids) {
  await process(id);          // one at a time
}
```

For concurrency:

```typescript
await Promise.all(ids.map((id) => process(id)));
```

> [!trap] forEach does not await
> `ids.forEach(async (id) => { await process(id); })` returns immediately and
> ignores the promises. Use `for...of` for sequential, `Promise.all(map)` for
> concurrent.

## Return type of await

```typescript
const value = await Promise.resolve("x");   // string
const arr = await Promise.all([1, 2].map(async (n) => n * 2)); // number[]
```

TypeScript infers through `await` and `Promise.all`.

## Top-level await

In ES modules, `await` can be used at the top level:

```typescript
const config = await loadConfig();
export default config;
```

Requires `"module": "ESNext"`/`NodeNext` and a supporting environment.

## Async arrow functions and callbacks

```typescript
const load = async (id: number): Promise<string> => {
  const res = await getCount();
  return `${id}:${res}`;
};
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does an async function always return?"
    type: single
    choices: ["T", "Promise<T>", "void", "T | undefined"]
    answer: [1]
    explanation: "async functions wrap their return value in a Promise."
    difficulty: 1
  - id: q2
    prompt: "What does await do?"
    type: single
    choices: ["Wraps in a promise", "Unwraps a promise to its value", "Rejects", "Cancels"]
    answer: [1]
    explanation: "await pauses until the promise settles and yields its value."
    difficulty: 1
  - id: q3
    prompt: "How do you run independent requests concurrently?"
    type: single
    choices: ["Sequential awaits", "Promise.all([...])", "forEach with async", "Nested then"]
    answer: [1]
    explanation: "Promise.all starts them together and awaits the group."
    difficulty: 2
  - id: q4
    prompt: "Why is ids.forEach(async ...) a bug for awaiting?"
    type: single
    choices:
      - "forEach ignores the returned promises"
      - "async is not allowed"
      - "It throws"
      - "It is sequential"
    answer: [0]
    explanation: "forEach does not await; use for...of or Promise.all(map)."
    difficulty: 3
```