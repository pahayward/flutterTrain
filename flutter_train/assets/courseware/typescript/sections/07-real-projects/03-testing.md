---
id: 03-testing
title: "Testing TypeScript"
order: 3
section: 07-real-projects
language: typescript
summary: "Vitest/Jest, typed mocks, and testing types"
tags: [testing, vitest, jest, types]
---

# Testing TypeScript

Tests run the compiled/transpiled JS, but TypeScript types make tests safer
and catch mistakes in test code too.

## Setup with Vitest

```bash
npm install --save-dev vitest
```

```json
{ "scripts": { "test": "vitest run", "test:watch": "vitest" } }
```

```typescript
// math.test.ts
import { describe, it, expect } from "vitest";
import { add } from "./math";

describe("add", () => {
  it("adds numbers", () => {
    expect(add(1, 2)).toBe(3);
  });
});
```

## Typed test data

Fixtures are typed, so a change to `User` flags every stale test:

```typescript
const user: User = { id: userId(1), name: "Ada" };

function makeUser(overrides: Partial<User> = {}): User {
  return { id: userId(1), name: "Ada", ...overrides };
}
```

`Partial<User>` lets tests override only what matters.

## Typed mocks

For dependency injection, a fake that satisfies the interface:

```typescript
interface Clock { now(): Date }

const fakeClock: Clock = { now: () => new Date(0) };
```

The compiler ensures the fake matches the contract. No `as any` needed.

> [!key] Prefer structural fakes over deep mocks
> A small object implementing the interface is clearer and type-checked,
> unlike mock frameworks that produce `any`.

## Testing async code

```typescript
it("resolves the count", async () => {
  await expect(getCount()).resolves.toBe(42);
});

it("rejects on bad input", async () => {
  await expect(fetchUser(-1)).rejects.toThrow();
});
```

## Testing types themselves

Use `expectTypeOf` (Vitest) or `tsd` to assert types:

```typescript
import { expectTypeOf } from "vitest";

expectTypeOf(first([1, 2, 3])).toEqualTypeOf<number | undefined>();
```

These fail the build if the inferred type drifts.

## What to test

- Pure logic (reducers, parsers, formatting) — high value.
- Boundaries (parsing unknown input) — high value.
- Components/UI — behavior, not implementation details.

> [!trap] Do not test implementation details
> Tests coupled to private methods break on refactors. Test public behavior
> and outputs; keep the interface the contract.

## Coverage and CI

```json
{
  "scripts": {
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "ci": "npm run typecheck && npm run test"
  }
}
```

Run both type-checking and tests in CI — they catch different classes of
bugs.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does Partial<User> help with in tests?"
    type: single
    choices: ["Overriding only needed fields in fixtures", "Runtime validation", "Mocking", "Coverage"]
    answer: [0]
    explanation: "Partial makes fixture fields optional so tests set only what matters."
    difficulty: 2
  - id: q2
    prompt: "What is a typed fake?"
    type: single
    choices:
      - "An object implementing an interface, checked by the compiler"
      - "An any-based mock"
      - "A snapshot"
      - "A stub file"
    answer: [0]
    explanation: "A fake matching the interface is verified structurally."
    difficulty: 2
  - id: q3
    prompt: "How do you assert an async function resolves to 42?"
    type: single
    choices: ["await expect(fn()).resolves.toBe(42)", "expect(fn()).toBe(42)", "fn().then", "await fn()"]
    answer: [0]
    explanation: "resolves/rejects assert on promise outcomes."
    difficulty: 2
  - id: q4
    prompt: "Why run tsc --noEmit alongside tests?"
    type: single
    choices:
      - "They catch different bugs (types vs behavior)"
      - "Tests do not run otherwise"
      - "It speeds up tests"
      - "It adds coverage"
    answer: [0]
    explanation: "Type checking and behavior tests are complementary."
    difficulty: 3
```