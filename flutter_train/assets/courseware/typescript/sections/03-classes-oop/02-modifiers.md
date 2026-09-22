---
id: 02-modifiers
title: "Access modifiers and readonly"
order: 2
section: 03-classes-oop
language: typescript
summary: "public, private, protected, readonly, and #private fields"
tags: [modifiers, private, protected, readonly]
---

# Access modifiers

Modifiers control who can see a member. They exist at compile time and shape
your API.

## The three levels

```typescript
class Account {
  public owner: string;        // anyone
  protected balance: number;   // this class and subclasses
  private pin: number;         // this class only

  constructor(owner: string, balance: number, pin: number) {
    this.owner = owner;
    this.balance = balance;
    this.pin = pin;
  }
}

const a = new Account("Ada", 100, 1234);
a.owner;      // ✅
a.balance;    // ❌ protected
a.pin;        // ❌ private
```

## protected vs private

- `private` — only the declaring class.
- `protected` — declaring class **and** subclasses.

```typescript
class Savings extends Account {
  addInterest() {
    this.balance *= 1.05;      // ✅ protected accessible in subclass
    // this.pin;                ❌ private
  }
}
```

## readonly

```typescript
class Point {
  constructor(readonly x: number, readonly y: number) {}
}

const p = new Point(1, 2);
// p.x = 3;   ❌
```

`readonly` means assignment is allowed only in the constructor (or field
initializer).

## True runtime privacy with #

ECMAScript private fields are enforced by the runtime:

```typescript
class Vault {
  #code = "0000";

  unlock(input: string): boolean {
    return input === this.#code;
  }
}

const v = new Vault();
// v.#code;   ❌ SyntaxError — not accessible outside
```

> [!key] private (TS) vs #private (JS)
> `private` is erased and only checked by the compiler. `#code` exists at
> runtime and is genuinely inaccessible outside the class. Choose `#` when
> encapsulation must be real.

## Parameter property modifiers

```typescript
class User {
  constructor(
    public readonly id: number,
    private email: string,
    protected role: string = "user",
  ) {}
}
```

One line declares, assigns, and sets visibility.

> [!trap] Protected is not a security boundary
> Like private, `protected` disappears at runtime. It documents intent and
> catches mistakes; it does not stop a determined caller.

## Modifiers and structural typing

Private/protected members affect compatibility: two classes with a `private`
member are only compatible if that member comes from the same declaration.
Structural typing applies mostly to public members.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which modifier allows subclasses but not outside access?"
    type: single
    choices: ["public", "protected", "private", "readonly"]
    answer: [1]
    explanation: "protected is visible in the class and its subclasses."
    difficulty: 1
  - id: q2
    prompt: "When can a readonly field be assigned?"
    type: single
    choices:
      - "Never"
      - "Only in the constructor or initializer"
      - "Anytime inside the class"
      - "Only via a setter"
    answer: [1]
    explanation: "readonly allows assignment at declaration/construction only."
    difficulty: 2
  - id: q3
    prompt: "What is the advantage of #field over private?"
    type: single
    choices:
      - "It is faster"
      - "It is truly private at runtime"
      - "It can be readonly"
      - "It is optional"
    answer: [1]
    explanation: "# fields are enforced by the JavaScript runtime, not just the checker."
    difficulty: 2
  - id: q4
    prompt: "Do access modifiers provide runtime security?"
    type: single
    choices:
      - "Yes, always"
      - "No, they are compile-time only (except #)"
      - "Only protected"
      - "Only public"
    answer: [1]
    explanation: "TS modifiers are erased; only # private fields persist at runtime."
    difficulty: 2
```