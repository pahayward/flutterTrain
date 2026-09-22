---
id: 05-capstone
title: "Capstone: a type-safe app"
order: 5
section: 07-real-projects
language: typescript
summary: "Put it all together: model, parse, serve, test"
tags: [capstone, project, integration]
---

# Capstone: a type-safe app

Let's assemble the whole course into a small, type-safe app: fetch users,
parse the response, model state, and render it — with errors as values.

## 1. Domain types

```typescript
type Brand<T, B> = T & { readonly __brand: B };
type UserId = Brand<number, "UserId">;

interface User {
  id: UserId;
  name: string;
  active: boolean;
}
```

## 2. Result type for expected failures

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

## 3. Parse at the boundary

```typescript
function parseUser(input: unknown): Result<User> {
  if (typeof input !== "object" || input === null) {
    return { ok: false, error: new Error("Not an object") };
  }
  const { id, name, active } = input as Record<string, unknown>;
  if (typeof id !== "number" || typeof name !== "string" || typeof active !== "boolean") {
    return { ok: false, error: new Error("Bad user shape") };
  }
  return { ok: true, value: { id: id as UserId, name, active } };
}
```

## 4. Repository interface (the seam)

```typescript
interface UserRepository {
  list(): Promise<Result<User[]>>;
}
```

## 5. Real implementation

```typescript
class HttpUserRepository implements UserRepository {
  constructor(private readonly baseUrl: string) {}

  async list(): Promise<Result<User[]>> {
    try {
      const res = await fetch(`${this.baseUrl}/users`);
      if (!res.ok) {
        return { ok: false, error: new Error(`HTTP ${res.status}`) };
      }
      const raw: unknown = await res.json();
      if (!Array.isArray(raw)) {
        return { ok: false, error: new Error("Expected array") };
      }
      const users: User[] = [];
      for (const item of raw) {
        const parsed = parseUser(item);
        if (!parsed.ok) return parsed;
        users.push(parsed.value);
      }
      return { ok: true, value: users };
    } catch (e) {
      return { ok: false, error: e instanceof Error ? e : new Error(String(e)) };
    }
  }
}
```

## 6. UI state as a discriminated union

```typescript
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "ready"; users: User[] }
  | { status: "error"; message: string };
```

## 7. The service ties it together

```typescript
class UserService {
  constructor(private readonly repo: UserRepository) {}

  async load(): Promise<State> {
    const result = await this.repo.list();
    if (result.ok) {
      return { status: "ready", users: result.value };
    }
    return { status: "error", message: result.error.message };
  }
}
```

## 8. Test with a fake

```typescript
const fakeRepo: UserRepository = {
  list: async () => ({ ok: true, value: [{ id: 1 as UserId, name: "Ada", active: true }] }),
};

const service = new UserService(fakeRepo);
const state = await service.load();
// state.status === "ready"
```

## 9. Wire it up

```typescript
const repo = new HttpUserRepository("https://api.example.com");
const service = new UserService(repo);

const state = await service.load();
switch (state.status) {
  case "ready": console.log(state.users.length); break;
  case "error": console.error(state.message); break;
  default: break;
}
```

> [!key] The course in one file
> Branded ids, `Result`, parse-don't-validate, a repository seam,
> discriminated UI state, and exhaustive handling — this is production
> TypeScript.

## Where to go next

- Add a runtime validator (Zod) to replace the hand-written parser.
- Add tests for each `parseUser` branch.
- Turn on `strict`, `noUncheckedIndexedAccess`, and `exactOptionalPropertyTypes`.
- Keep `tsc --noEmit` in CI.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why return Result<User[]> from the repository instead of throwing?"
    type: single
    choices:
      - "It makes the error path part of the type and forces handling"
      - "It is faster"
      - "It avoids async"
      - "It removes errors"
    answer: [0]
    explanation: "Result encodes expected failures so callers must handle them."
    difficulty: 3
  - id: q2
    prompt: "What does parseUser guarantee after it succeeds?"
    type: single
    choices:
      - "The value matches the User type"
      - "The network is fast"
      - "The id is positive"
      - "Nothing"
    answer: [0]
    explanation: "Parsing converts unknown input into a trusted User value."
    difficulty: 2
  - id: q3
    prompt: "Why use a UserRepository interface in the capstone?"
    type: single
    choices: ["To swap real and fake implementations", "To speed up fetch", "To avoid Result", "To add statics"]
    answer: [0]
    explanation: "The interface is a seam enabling test doubles and alternative backends."
    difficulty: 2
  - id: q4
    prompt: "How does the switch on State stay safe as variants grow?"
    type: single
    choices:
      - "Exhaustiveness checking flags unhandled variants"
      - "It silently ignores them"
      - "It uses any"
      - "It catches at runtime"
    answer: [0]
    explanation: "A discriminated union plus exhaustiveness turns missing cases into errors."
    difficulty: 3
```