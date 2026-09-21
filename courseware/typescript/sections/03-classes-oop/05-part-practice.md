---
id: 05-part-practice
title: "Part 3 Practice"
order: 5
section: 03-classes-oop
language: typescript
summary: "Review and exam questions for Classes and OOP"
tags: [practice, exam, review]
---

# Part 3 Practice

## Section review

- **Classes** — typed fields, constructors, parameter properties.
- **Modifiers** — `public`, `protected`, `private`, `readonly`, and true
  runtime privacy with `#`.
- **Abstract and implements** — shared implementation vs pure contracts.
- **Getters/setters/static** — computed properties, validation, class-level
  members, factories.

```typescript
abstract class Repository<T extends { id: number }> {
  protected items: T[] = [];

  add(item: T): void {
    this.items.push(item);
  }

  find(id: number): T | undefined {
    return this.items.find((i) => i.id === id);
  }

  abstract save(): Promise<void>;
}

class MemoryRepository<T extends { id: number }> extends Repository<T> {
  async save(): Promise<void> {
    // in-memory: nothing to persist
  }
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which modifier creates a field from a constructor parameter?"
    type: single
    choices: ["static", "public/private/protected/readonly", "abstract", "async"]
    answer: [1]
    explanation: "A visibility/readonly modifier on a parameter declares a field."
    difficulty: 2
  - id: q2
    prompt: "What distinguishes an abstract method?"
    type: single
    choices:
      - "It has no body and must be implemented by subclasses"
      - "It is private"
      - "It is static"
      - "It runs once"
    answer: [0]
    explanation: "Abstract members declare a requirement without an implementation."
    difficulty: 1
  - id: q3
    prompt: "Where is a getter invoked?"
    type: single
    choices: ["Only in the constructor", "On property read", "On property write", "Never"]
    answer: [1]
    explanation: "Reading the property name calls the getter."
    difficulty: 1
  - id: q4
    prompt: "What does a class implement check?"
    type: single
    choices: ["Shape matches an interface", "Inherits code", "Is abstract", "Has statics"]
    answer: [0]
    explanation: "implements verifies the class satisfies the interface's members."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which is truly private at runtime?"
    type: single
    choices: ["private name", "protected name", "#name", "readonly name"]
    answer: [2]
    explanation: "ECMAScript # fields are enforced by the runtime; TS modifiers are erased."
    weight: 2
    section: 03-classes-oop
  - prompt: "Can an abstract class be instantiated?"
    type: single
    choices: ["Yes", "No", "Only with a factory", "Only if empty"]
    answer: [1]
    explanation: "Abstract classes must be extended before use."
    weight: 1
    section: 03-classes-oop
  - prompt: "What is a static member accessed through?"
    type: single
    choices: ["An instance", "The class name", "A getter", "A closure"]
    answer: [1]
    explanation: "Statics live on the class itself."
    weight: 1
    section: 03-classes-oop
  - prompt: "How many classes can a class extend?"
    type: single
    choices: ["One", "Two", "Any number", "Zero only"]
    answer: [0]
    explanation: "A class has a single base class but can implement many interfaces."
    weight: 2
    section: 03-classes-oop
  - prompt: "What should a setter be used for?"
    type: single
    choices: ["Validation on assignment", "Iteration", "Static init", "Inheritance"]
    answer: [0]
    explanation: "Setters run on every write and can validate or transform values."
    weight: 2
    section: 03-classes-oop
``````
