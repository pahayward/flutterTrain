---
id: 03-interface-design
title: "Interfaces II: the Go philosophy"
order: 3
section: 04-methods-interfaces
language: golang
summary: Small interfaces, 'accept interfaces return structs', interface composition, any, and knowing when to skip interfaces entirely.
tags: [interface-design, philosophy, any, composition]
prereqs: [02-interfaces-basics]
---

# Interfaces II: the Go philosophy

> [!key]
> The design rules that make Go interfaces shine: keep them **small**, write functions to
> **accept interfaces and return concrete types**, build new interfaces by **embedding old ones**,
> and reach for them only where behavior is genuinely varied.

## Keep interfaces small

The most famous advice in Go's history is Rob Pike's proverb: *"The bigger the interface, the
weaker the abstraction."* Look at the interfaces the standard library survives on — nearly all of
them are tiny:

- `error` → `Error() string` — one method.
- `fmt.Stringer` → `String() string` — one method.
- `io.Reader` → `Read([]byte) (int, error)` — one method.
- `io.Writer` → `Write([]byte) (int, error)` — one method.
- `sort.Interface` → `Len() int`, `Less(i, j int) bool`, `Swap(i, j int)` — three methods, an
  extreme case.

A one-method interface is easy to satisfy, easy to fake in tests, and easy to implement for any
type you already have. A twenty-method interface is a contract almost nobody can meet and a wall
that blocks reuse. If you find yourself writing a God-interface, stop: it probably should be two
or three tiny interfaces that callers compose.

> [!tip]
> A common benchmark: if you can't name the single behavior an interface guarantees, you don't
> have an interface yet — you have a struct in disguise.

## Accept interfaces, return structs

The classic phrasing: *"Be conservative in what you send, liberal in what you accept."* In Go
practically: a function should **accept** thin interfaces (so many callers can feed it), and
**return** concrete types (so callers keep full access to methods, and the concrete type is
obvious).

This tiny renderer accepts anything that can receive bytes — a file, a buffer, a network
connection, even `os.Stdout` — while returning the concrete `*bytes.Buffer`:

```go title="accept-interface-return-struct.go"
import ("bytes"; "fmt"; "io")

build := func(dst io.Writer, names []string) error {
    for _, n := range names {
        if _, err := fmt.Fprintf(dst, "hi %s\n", n); err != nil {
            return err
        }
    }
    return nil
}

var buf bytes.Buffer
names := []string{"ana", "bo"}

err := build(&buf, names)   // concrete *bytes.Buffer satisfies io.Writer
if err != nil {
    fmt.Println("failed:", err)
}
fmt.Print(buf.String())
```

Prints `hi ana` and `hi bo`.

> [!note]
> The sandbox prevents passing compound literals directly into function calls (a yaegi parsing
> quirk), so assign a slice or struct to a variable first — `names := []string{...}` — then pass
> the variable.

### The honorable exceptions

Rules have exceptions, and Go's own library is where you learn them:

- `errors.New` and `fmt.Errorf` **return** the `error` interface — because the concrete type is
  deliberately unexported.
- `io.Reader`-style streams return `(n int, err error)` pairs — the error is part of their job
  description, not an option.

## Interfaces composed from others: embedding

Just as a struct can embed another struct, an **interface can embed other interfaces**, and the
set of methods is the union. `io.ReadWriter` is literally `io.Reader` + `io.Writer` — declared in
the standard library as:

```go eval=no
type ReadWriter interface {
    Reader
    Writer
}
```

A type that satisfies both embedded interfaces satisfies the composite automatically. No new
methods are invented — the composite is just a *name for a bigger set*. (The excerpt below uses
packages-internal names, so it won't run in the sandbox — it's for reading.)

```go title="embedded-interfaces.go"
import ("bytes"; "fmt"; "io")

type RW interface {
    io.Reader
    io.Writer
}

var buf bytes.Buffer
var rw RW = &buf                 // *bytes.Buffer has Read and Write
fmt.Fprintf(rw, "piped")         // talks to rw as an io.Writer
fmt.Println(buf.String())        // and data really arrived
```

> [!key]
> Embedded methods keep their **original** name and signature: if you embed `io.Reader` and then
> re-declare `Read` with a different signature, the interface has *two* Read methods — usually a
> compile error. Embedding is a union, not an override.

Composition like this is how terse, reusable contracts grow: small interfaces are glued together
where needed, and a consumer never has to see methods it doesn't care about.

## The empty interface: `any`, used with care

`any` (`interface{}`) declares no methods, so every type satisfies it. It's the escape hatch for
"a value of some unknown kind" — think JSON documents, message payloads, or generic containers.
But with the freedom comes blindness: to *do* anything with an `any`, you must inspect it, usually
with a type switch:

```go title="any-type-switch.go"
import "fmt"

classify := func(v any) string {
    switch t := v.(type) {
    case int:
        return "int"
    case string:
        return "string"
    default:
        return fmt.Sprintf("other (%T)", t)
    }
}

fmt.Println(classify(3), classify("hi"), classify(2.5))
```

Prints `int string other (float64)`.

> [!warning]
> `any` in a function signature erases the contract. `func F(v any)` tells the caller *nothing*
> about what's valid. Prefer a small typed interface wherever you can; reserve `any` for genuinely
> mixed data that must be decoded and switched on anyway.

## When NOT to use interfaces

Interfaces are a tool for *variety*, not a decoration. The most common design mistake in Go is the
interface that currently has exactly one implementation — introduced "just in case":

```go eval=no
type Flusher interface { Flush() }
// ... one type has Flush, and nothing else will ever implement Flusher
```

There are no abstract bases to future-proof in Go. Interfaces are justified when you truly have
multiple implementations (swap-in test doubles, storage backends, writer targets), or when you
must *exclude* unrelated details, like the receiver of a value. Otherwise:

- **Use the concrete type** — it's clearer, lighter, and easy to call.
- Add the interface **when a second real use appears**, not before. Deleting a premature
  interface is always possible; the reverse accumulation is what rots code.
- Ask: "would this function behave differently for at least two realistic inputs?" If the answer
  is no, no interface is needed.

> [!tip]
> Watch the stdlib: `os.Open` returns `*os.File`, not `io.ReadCloser`. The programs *receiving*
> files declare their `io.Reader`. That asymmetry — concrete on the way out, interface on the way
> in — is the philosophy in one sentence.

## Rules of thumb

- One method is a feature, not a deficiency.
- Define interfaces where they're *used* (consumer-side), so implementers stay uncluttered.
- Compose small interfaces rather than declaring giant ones.
- Return concrete types; accept interfaces.
- Reserve `any` for genuinely heterogeneous data.
- No second real implementation yet? No interface.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why does the proverb say 'the bigger the interface, the weaker the abstraction'?"
    type: single
    choices:
      - "Bigger interfaces hold more memory."
      - "A large method set is harder for new types to satisfy, so the interface blocks reuse instead of enabling it."
      - "The compiler can no longer check method sets for large interfaces."
      - "Large interfaces reject all pointer receivers."
    answer: [1]
    explanation: "Every method is an entry cost for implementers; small interfaces like error, io.Reader and io.Writer maximize implementers and reuse."
    difficulty: 2
  - id: q2
    prompt: "Which best reflects 'accept interfaces, return structs'?"
    type: single
    choices:
      - "Functions should return interfaces and take concrete types."
      - "Functions should accept small interfaces and return concrete types — flexibility on input, clarity on output."
      - "Both inputs and outputs should always be interfaces."
      - "Both inputs and outputs should always be concrete."
    answer: [1]
    explanation: "Input interfaces widen the set of callers; concrete returns keep the full method set available and the output type obvious."
    difficulty: 2
  - id: q3
    prompt: "type R interface { io.Reader }; type W interface { io.Writer }; type RW interface { R; W }. Which types satisfy RW?"
    type: single
    choices:
      - "Only types explicitly marked as RW."
      - "RW is invalid because interfaces cannot embed interfaces."
      - "Any type whose method set includes both Read and Write."
      - "Only types declared inside package io."
    answer: [2]
    explanation: "Embedding interfaces unions their method sets, so structural satisfaction by both Read and Write is all that matters."
    difficulty: 2
  - id: q4
    prompt: "Which is the clearest justification for introducing an interface?"
    type: single
    choices:
      - "The type is trendy and might be needed someday."
      - "At least two realistic implementations exist, or a fake is needed for tests."
      - "The function has only one argument."
      - "The type is exported from a package."
    answer: [1]
    explanation: "Interfaces pay off when behavior genuinely varies — multiple implementations or test doubles. A single concrete implementation does not justify one."
    difficulty: 2
  - id: q5
    prompt: "What is the practical role of any (interface{})?"
    type: single
    choices:
      - "A guarantee that the value is a primitive like int or string."
      - "A placeholder for a value of unknown type, which must usually be switched on or asserted to be used."
      - "A faster alternative to concrete types."
      - "A way to declare structs without fields."
    answer: [1]
    explanation: "any has zero methods, so its dynamic type must be discovered by assertion or type switch before meaningful use."
    difficulty: 1
```