---
id: 01-project-structure
title: "Structuring a real project"
order: 1
section: 07-real-projects
language: typescript
summary: "Folders, feature slices, shared types, and where to put what"
tags: [structure, architecture, folders]
---

# Structuring a real project

As projects grow, structure determines how easily you can change them. A few
patterns scale well.

## A feature-oriented layout

```
src/
  features/
    users/
      user.types.ts
      user.repository.ts
      user.service.ts
      user.test.ts
    orders/
      order.types.ts
      order.service.ts
  shared/
    types.ts
    result.ts
    http.ts
  app/
    main.ts
  index.ts
```

Group by **feature**, not by technical type. Everything about users lives
together.

> [!key] Feature folders beat layer folders at scale
> `controllers/ models/ services/` scatters one feature across the tree.
> `features/users/` keeps related code discoverable and deletable.

## Where types live

- **Domain types** — beside the feature that owns them
  (`user.types.ts`).
- **Shared primitives** — `shared/types.ts` (e.g. `Result`, `Id`).
- **API/DTO types** — near the client that fetches them.

```typescript
// shared/result.ts
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

## Public APIs via barrels

```typescript
// features/users/index.ts
export type { User } from "./user.types";
export { UserService } from "./user.service";
```

Other features import from `features/users`, not deep paths — you can
reorganize internals freely.

## Dependency direction

Keep dependencies pointing **inward** toward domain types:

```
app → features → shared
```

Features may depend on shared; shared must not import features. This avoids
cycles and keeps the core reusable.

> [!trap] Watch for import cycles
> Circular imports cause confusing `undefined` at module init. Barrel files
> make cycles easy to create. Keep the dependency graph acyclic and check it
> in CI (madge, dependency-cruiser).

## Naming conventions

- Files: `kebab-case.ts` or `PascalCase.tsx` for components.
- Types/interfaces: `PascalCase`.
- Values/functions: `camelCase`.
- Constants: `SCREAMING_SNAKE_CASE`.
- Type files: `*.types.ts`; tests: `*.test.ts`.

## Scripts and config

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "test": "vitest run",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit"
  }
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why group code by feature rather than by layer?"
    type: single
    choices:
      - "Related code stays together and is easier to change"
      - "It compiles faster"
      - "It uses fewer files"
      - "It avoids types"
    answer: [0]
    explanation: "Feature folders keep a slice's code cohesive and discoverable."
    difficulty: 2
  - id: q2
    prompt: "Which direction should dependencies point?"
    type: single
    choices: ["app → features → shared", "shared → features → app", "features → app", "randomly"]
    answer: [0]
    explanation: "Depend inward toward shared/domain; shared must not import features."
    difficulty: 3
  - id: q3
    prompt: "What is a barrel file used for?"
    type: single
    choices: ["Re-exporting a folder's public API", "Bundling JS", "Testing", "Linting"]
    answer: [0]
    explanation: "An index.ts re-exports so consumers use a stable path."
    difficulty: 1
  - id: q4
    prompt: "What problem do import cycles cause?"
    type: single
    choices: ["undefined values at module init", "Faster builds", "Type errors only", "None"]
    answer: [0]
    explanation: "Cycles can leave bindings undefined during initialization."
    difficulty: 3
```