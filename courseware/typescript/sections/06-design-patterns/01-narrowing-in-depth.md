---
id: 01-narrowing-in-depth
title: "Discriminated unions in practice"
order: 1
section: 06-design-patterns
language: typescript
summary: "Modeling state and results so invalid states are unrepresentable"
tags: [discriminated-unions, state-machine, exhaustive]
---

# Discriminated unions in practice

A **discriminated union** tags each variant with a shared literal field. The
tag drives narrowing and makes illegal states impossible to represent.

## The pattern

```typescript
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: string[] }
  | { status: "error"; message: string };
```

Only `success` has `data`, only `error` has `message`. There is no
"success with no data" or "loading with an error".

## Rendering state

```typescript
function render(state: State): string {
  switch (state.status) {
    case "idle": return "Ready";
    case "loading": return "Loading…";
    case "success": return state.data.join(", ");
    case "error": return `Error: ${state.message}`;
  }
}
```

The compiler checks exhaustiveness — add a variant and every `switch` that
misses it errors.

## Making it impossible to forget a case

```typescript
function assertNever(x: never): never {
  throw new Error(`Unhandled: ${JSON.stringify(x)}`);
}

function render(state: State): string {
  switch (state.status) {
    case "idle": return "Ready";
    case "loading": return "Loading…";
    case "success": return state.data.join(", ");
    case "error": return `Error: ${state.message}`;
    default: return assertNever(state);   // compile error if a case is missed
  }
}
```

> [!key] The tag must be a literal type
> `status: string` will not discriminate — each variant needs distinct
> **literal** values (`"idle" | "loading" | ...`).

## Better than booleans

```typescript
// ❌ allows invalid combinations
interface BadState {
  isLoading: boolean;
  isError: boolean;
  data?: string[];
}

// ✅ one field, exact states
type GoodState = State;
```

Boolean flags multiply into impossible combinations. A discriminated union
enumerates exactly the valid states.

## Reducers and actions

The same pattern models Redux-style actions:

```typescript
type Action =
  | { type: "add"; text: string }
  | { type: "toggle"; id: number }
  | { type: "clear" };

function reducer(todos: string[], action: Action): string[] {
  switch (action.type) {
    case "add": return [...todos, action.text];
    case "toggle": return todos;
    case "clear": return [];
  }
}
```

> [!trap] Avoid optional fields as discriminants
> `data?: T` makes `undefined` a legal value and weakens narrowing. Prefer a
> required literal tag plus variant-specific fields.

## Real-world uses

- UI/async state (idle/loading/success/error).
- API results (`Result<T, E>`).
- Redux actions and reducers.
- ASTs and parser nodes.
- Form validation states.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What must a discriminant field be?"
    type: single
    choices: ["A literal type per variant", "A boolean", "optional", "any"]
    answer: [0]
    explanation: "Each variant needs a distinct literal tag for narrowing."
    difficulty: 2
  - id: q2
    prompt: "Why prefer a discriminated union over boolean flags?"
    type: single
    choices:
      - "It prevents impossible state combinations"
      - "It is faster"
      - "It uses less memory"
      - "It avoids switch"
    answer: [0]
    explanation: "The union enumerates only valid states; flags can combine invalidly."
    difficulty: 2
  - id: q3
    prompt: "What does assertNever(state: never) provide?"
    type: single
    choices: ["A runtime check", "A compile-time exhaustiveness check", "A cast", "A default"]
    answer: [1]
    explanation: "Passing an unhandled variant to a never parameter is a compile error."
    difficulty: 3
  - id: q4
    prompt: "Which is a classic discriminated-union use?"
    type: single
    choices: ["Async UI state", "A single number", "A constant", "A loop counter"]
    answer: [0]
    explanation: "idle/loading/success/error is a natural discriminated union."
    difficulty: 1
```