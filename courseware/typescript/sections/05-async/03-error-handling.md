---
id: 03-error-handling
title: "Error handling and typed errors"
order: 3
section: 05-async
language: typescript
summary: "try/catch with unknown, Result types, and exhaustive errors"
tags: [errors, try-catch, result, unknown]
---

# Error handling

JavaScript errors are untyped by nature. TypeScript's job is to make you
handle the `unknown` safely.

## try/catch with unknown

```typescript
async function load(): Promise<string> {
  try {
    return await fetchText("/api");
  } catch (err: unknown) {
    if (err instanceof Error) {
      console.error(err.message);
    } else {
      console.error("Unknown failure", err);
    }
    throw err;
  }
}
```

Under `strict`, the catch variable is `unknown`. Always narrow before use.

## A helper to normalize errors

```typescript
function toError(value: unknown): Error {
  if (value instanceof Error) return value;
  return new Error(String(value));
}
```

## Custom error classes

```typescript
class ValidationError extends Error {
  constructor(public readonly field: string, message: string) {
    super(message);
    this.name = "ValidationError";
  }
}

try {
  throw new ValidationError("email", "invalid");
} catch (e) {
  if (e instanceof ValidationError) {
    console.log(e.field);      // ✅ narrowed
  }
}
```

> [!key] Extend Error, not a plain object
> Throwing `{ message: "..." }` loses the stack and `instanceof`. Subclass
> `Error` so callers can narrow reliably.

## Result types — errors as values

Instead of throwing, return a discriminated union:

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parseJSON<T>(text: string): Result<T> {
  try {
    return { ok: true, value: JSON.parse(text) as T };
  } catch (e) {
    return { ok: false, error: toError(e) };
  }
}

const r = parseJSON<{ id: number }>(input);
if (r.ok) {
  console.log(r.value.id);
} else {
  console.error(r.error.message);
}
```

This makes the error path **visible in the type** and forces handling.

## Choosing a strategy

- **Throwing** — for exceptional, unrecoverable conditions.
- **Result** — for expected failures (validation, parsing, HTTP).
- **Never swallow** — an empty `catch {}` hides bugs.

> [!trap] Avoid catching and ignoring
> `try { ... } catch {}` silently drops errors. If you truly mean to ignore,
> comment why. Otherwise log or rethrow.

## Typing a validation boundary

```typescript
function assertNumber(x: unknown): asserts x is number {
  if (typeof x !== "number") throw new ValidationError("x", "not a number");
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the type of a catch variable under strict mode?"
    type: single
    choices: ["Error", "unknown", "any", "never"]
    answer: [1]
    explanation: "Anything can be thrown, so the caught value is unknown."
    difficulty: 1
  - id: q2
    prompt: "Why subclass Error for custom errors?"
    type: single
    choices:
      - "To keep instanceof and stack working"
      - "To make it faster"
      - "It is required"
      - "To avoid types"
    answer: [0]
    explanation: "Subclassing Error preserves instanceof narrowing and stack traces."
    difficulty: 2
  - id: q3
    prompt: "What is the benefit of a Result type?"
    type: single
    choices:
      - "The error path is part of the type and must be handled"
      - "It is faster"
      - "It removes errors"
      - "It uses any"
    answer: [0]
    explanation: "A discriminated Result forces callers to handle both branches."
    difficulty: 3
  - id: q4
    prompt: "Why is an empty catch {} risky?"
    type: single
    choices: ["It hides failures", "It is slow", "It throws", "It is a syntax error"]
    answer: [0]
    explanation: "Swallowing errors silently hides bugs; log or rethrow instead."
    difficulty: 2
```