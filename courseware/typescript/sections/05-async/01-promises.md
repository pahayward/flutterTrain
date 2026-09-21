---
id: 01-promises
title: "Promises"
order: 1
section: 05-async
language: typescript
summary: "Typed promises, then/catch/finally, combinators"
tags: [promises, async, then, all]
---

# Promises

A `Promise<T>` represents a value of type `T` that will arrive later (or
fail). TypeScript types both the success value and the error path.

## Creating and typing

```typescript
const p: Promise<number> = Promise.resolve(42);

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
```

The executor receives `resolve` and `reject`:

```typescript
function fetchCount(url: string): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!url) reject(new Error("url required"));
    else resolve(1);
  });
}
```

## Consuming with then/catch/finally

```typescript
fetchCount("/api/count")
  .then((n) => {
    console.log(n + 1);   // n: number
  })
  .catch((err: unknown) => {
    console.error(err);
  })
  .finally(() => {
    console.log("done");
  });
```

`.then` transforms the value; chaining preserves types:

```typescript
const message: Promise<string> = fetchCount("/c")
  .then((n) => n * 2)
  .then((n) => `count: ${n}`);
```

> [!key] catch receives unknown
> With `strict`, the rejection reason is `unknown`. Narrow it before using
> its properties — rejections can be anything, not just Error.

## Combinators

```typescript
const [a, b] = await Promise.all([fetchA(), fetchB()]);
// a and b are individually typed; fails fast on first rejection

const first = await Promise.race([fetchA(), fetchB()]);

const results = await Promise.allSettled([fetchA(), fetchB()]);
for (const r of results) {
  if (r.status === "fulfilled") console.log(r.value);
  else console.log(r.reason);
}
```

- `Promise.all` — all succeed, or reject on the first failure.
- `Promise.allSettled` — never rejects; reports each outcome.
- `Promise.race` — settles with the first to finish.
- `Promise.any` — first fulfilled; rejects only if all fail.

## Typing allSettled

```typescript
const results: PromiseSettledResult<number>[] =
  await Promise.allSettled([fetchA(), fetchB()]);
```

`status` is a discriminant (`"fulfilled" | "rejected"`), so narrowing works.

> [!trap] Unhandled rejections crash Node
> A promise with no `.catch` or `try/catch` can terminate the process. Always
> handle the error path, even for "fire and forget" work.

## Promise typing tips

- Annotate async function returns as `Promise<T>` (or let inference do it).
- `Promise<void>` for side effects.
- Avoid `Promise<any>`; use `Promise<unknown>` and narrow.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does Promise<number> resolve to?"
    type: single
    choices: ["number", "string", "void", "unknown"]
    answer: [0]
    explanation: "The type parameter is the fulfilled value's type."
    difficulty: 1
  - id: q2
    prompt: "Which combinator never rejects and reports each outcome?"
    type: single
    choices: ["Promise.all", "Promise.race", "Promise.allSettled", "Promise.any"]
    answer: [2]
    explanation: "allSettled waits for every promise and reports fulfilled/rejected."
    difficulty: 2
  - id: q3
    prompt: "What type does .catch receive under strict mode?"
    type: single
    choices: ["Error", "unknown", "any", "string"]
    answer: [1]
    explanation: "Rejections can be any value, so the reason is unknown."
    difficulty: 2
  - id: q4
    prompt: "What happens on the first rejection in Promise.all?"
    type: single
    choices: ["It resolves with the error", "It rejects immediately", "It ignores it", "It retries"]
    answer: [1]
    explanation: "Promise.all fails fast on the first rejection."
    difficulty: 2
```