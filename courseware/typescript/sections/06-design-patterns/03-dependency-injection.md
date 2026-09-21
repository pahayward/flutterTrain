---
id: 03-dependency-injection
title: "Dependency injection and inversion"
order: 3
section: 06-design-patterns
language: typescript
summary: "Program to interfaces; inject dependencies for testability"
tags: [dependency-injection, interfaces, testability, solid]
---

# Dependency injection

**Dependency injection (DI)** means a component receives what it needs from
the outside instead of creating it itself. Types make the seams explicit.

## The problem: hard-wired dependencies

```typescript
class UserService {
  private db = new PostgresDatabase();   // ❌ tightly coupled

  async getUser(id: number) {
    return this.db.query("SELECT * FROM users WHERE id = $1", [id]);
  }
}
```

Tests now need a real Postgres. The class cannot be reused with another
store.

## Define an interface (the seam)

```typescript
interface UserRepository {
  findById(id: number): Promise<User | null>;
}

interface Logger {
  info(msg: string): void;
}
```

## Inject via the constructor

```typescript
class UserService {
  constructor(
    private readonly repo: UserRepository,
    private readonly logger: Logger,
  ) {}

  async getUser(id: number): Promise<User | null> {
    this.logger.info(`getUser ${id}`);
    return this.repo.findById(id);
  }
}
```

Now the service depends on **abstractions**, not implementations.

## Production vs test

```typescript
class PostgresUserRepository implements UserRepository {
  async findById(id: number) {
    /* real query */
    return null;
  }
}

const service = new UserService(
  new PostgresUserRepository(),
  console,
);
```

```typescript
const fakeRepo: UserRepository = {
  findById: async (id) => ({ id, name: "Test" }),
};

const service = new UserService(fakeRepo, { info: () => {} });
```

> [!key] Structural typing makes fakes easy
> A plain object matching the interface is a valid dependency. No mocking
> framework required for simple cases.

## Inversion of control

The high-level module (UserService) defines what it needs; low-level modules
implement it. Control of *which* implementation is inverted to the caller —
the **D** in SOLID.

> [!trap] Do not over-abstract
> Interfaces for every class add indirection. Introduce a seam where you need
> to swap implementations or test in isolation, not everywhere.

## A tiny container (optional)

```typescript
type Factory<T> = (c: Container) => T;

class Container {
  private factories = new Map<string, Factory<unknown>>();

  register<T>(key: string, factory: Factory<T>): void {
    this.factories.set(key, factory as Factory<unknown>);
  }

  resolve<T>(key: string): T {
    const factory = this.factories.get(key);
    if (!factory) throw new Error(`Not registered: ${key}`);
    return factory(this) as T;
  }
}
```

Most apps do not need a DI framework — constructor injection plus interfaces
goes a long way.

## Benefits

- **Testability** — swap real services for fakes.
- **Decoupling** — swap databases, HTTP clients, clocks.
- **Clarity** — the constructor documents dependencies.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does dependency injection mean?"
    type: single
    choices:
      - "Receiving dependencies from outside instead of creating them"
      - "Creating dependencies internally"
      - "Using global variables"
      - "Avoiding interfaces"
    answer: [0]
    explanation: "Dependencies are passed in, not constructed inside the class."
    difficulty: 1
  - id: q2
    prompt: "What should a service depend on for testability?"
    type: single
    choices: ["Concrete classes", "Interfaces/abstractions", "Globals", "Singletons"]
    answer: [1]
    explanation: "Depending on interfaces lets you swap in fakes."
    difficulty: 2
  - id: q3
    prompt: "Why can a plain object serve as a dependency?"
    type: single
    choices: ["Structural typing", "Inheritance", "Generics", "Enums"]
    answer: [0]
    explanation: "If it matches the interface shape, it is assignable."
    difficulty: 2
  - id: q4
    prompt: "When should you introduce a DI seam?"
    type: single
    choices:
      - "Where you need to swap implementations or test in isolation"
      - "For every class"
      - "Only for databases"
      - "Never"
    answer: [0]
    explanation: "Add abstraction where flexibility or testing requires it."
    difficulty: 3
```