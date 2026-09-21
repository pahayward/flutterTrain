---
id: 05-part-practice
title: "Part 5 Practice"
order: 5
section: 05-async
language: typescript
summary: "Review and exam questions for Async and the Real World"
tags: [practice, exam, review]
---

# Part 5 Practice

## Section review

- **Promises** — `Promise<T>`, then/catch/finally, `all`/`allSettled`/`race`/`any`.
- **async/await** — async returns a promise, `await` unwraps, sequential vs
  concurrent, forEach pitfall.
- **Errors** — catch is `unknown`, custom Error subclasses, Result types.
- **DOM/Node** — `lib` settings, `@types/node`, narrowing elements, avoiding
  global clashes.

```typescript
type Result<T> = { ok: true; value: T } | { ok: false; error: Error };

async function fetchUser(id: number): Promise<Result<{ id: number }>> {
  try {
    const res = await fetch(`/users/${id}`);
    if (!res.ok) return { ok: false, error: new Error(res.statusText) };
    return { ok: true, value: await res.json() };
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e : new Error(String(e)) };
  }
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which combinator fails fast on the first rejection?"
    type: single
    choices: ["allSettled", "all", "any", "race"]
    answer: [1]
    explanation: "Promise.all rejects as soon as one input rejects."
    difficulty: 2
  - id: q2
    prompt: "What does await do to a Promise<T>?"
    type: single
    choices: ["Returns T", "Returns Promise<T>", "Returns void", "Throws"]
    answer: [0]
    explanation: "await yields the fulfilled value of type T."
    difficulty: 1
  - id: q3
    prompt: "How do you make independent awaits run concurrently?"
    type: single
    choices: ["Sequential awaits", "Promise.all with the started promises", "forEach", "Nested try"]
    answer: [1]
    explanation: "Start the promises, then Promise.all them to overlap work."
    difficulty: 2
  - id: q4
    prompt: "What should catch(e) do first under strict?"
    type: single
    choices: ["Use e.message", "Narrow e (e.g. instanceof Error)", "Ignore e", "Cast to any"]
    answer: [1]
    explanation: "The caught value is unknown, so narrow before accessing members."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "What is the type of an async function that returns number?"
    type: single
    choices: ["number", "Promise<number>", "void", "unknown"]
    answer: [1]
    explanation: "async functions always return a Promise of the returned type."
    weight: 1
    section: 05-async
  - prompt: "Which combinator never rejects?"
    type: single
    choices: ["Promise.all", "Promise.allSettled", "Promise.race", "Promise.any"]
    answer: [1]
    explanation: "allSettled reports each outcome without rejecting."
    weight: 2
    section: 05-async
  - prompt: "What type is a catch variable under strict mode?"
    type: single
    choices: ["Error", "unknown", "any", "never"]
    answer: [1]
    explanation: "Any value can be thrown, so it is unknown."
    weight: 2
    section: 05-async
  - prompt: "Why is forEach with an async callback a bug?"
    type: single
    choices: ["It ignores returned promises", "async is invalid there", "It throws", "It blocks"]
    answer: [0]
    explanation: "forEach does not await; use for...of or Promise.all(map)."
    weight: 3
    section: 05-async
  - prompt: "Which lib provides browser globals?"
    type: single
    choices: ["DOM", "ES2022", "node", "worker"]
    answer: [0]
    explanation: "The DOM lib types browser globals like document and window."
    weight: 1
    section: 05-async
``````
