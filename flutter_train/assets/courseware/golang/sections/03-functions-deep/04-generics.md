---
id: 04-generics
title: "Generics"
order: 4
section: 03-functions-deep
language: golang
type: lesson
summary: "Type parameters, constraints, comparable, and type sets."
tags: [generics, type-parameter, constraint, comparable, type-set, any]
---

# Generics

Go 1.18 introduced **generics** (also called type parameters), allowing you
to write functions and types that work over a range of types while preserving
type safety. Instead of writing the same logic for `int`, `float64`, `string`,
etc., you write it once with a type parameter.

> [!note] **About the examples in this app**
>
> The on-device sandbox's `yaegi` interpreter precedes Go 1.18 generics, so
> the actual generic syntax below is tagged `eval=no` and shown for study only.
> The **runnable** examples demonstrate the problem generics solve and the
> concepts the constraints rely on.

## The problem generics solve

Before generics, you wrote nearly identical functions for each type:

```go
maxInt := func(a, b int) int {
    if a > b {
        return a
    }
    return b
}
maxFloat := func(a, b float64) float64 {
    if a > b {
        return a
    }
    return b
}
print("maxInt:", maxInt(3, 7), "\n")
print("maxFloat:", maxFloat(2.5, 1.8), "\n")
```

Duplicated logic, one copy per type. Generics collapse both into a single
definition with a **type parameter**.

> [!key]
> A **type parameter** is a placeholder for a concrete type, written in square
> brackets: `func Name[T constraint](...)`. Go infers `T` from the call-site
> arguments — no need to spell it out.

## The generic form (declaration in a real .go file)

In a real `.go` file the generic function looks like this — one definition,
many types:

```go eval=no
func max[T int | float64](a, b T) T {
    if a > b {
        return a
    }
    return b
}

max(3, 7)      // T inferred as int
max(2.5, 1.8)  // T inferred as float64
```

Why `eval=no`? The embedded `yaegi` interpreter cannot execute generics, but
this is the syntax you will type in every real Go project. Read it carefully.

> [!warning]
> `[T int | float64]` declares type parameter `T` constrained to `int` or
> `float64`. Go infers `T` from the arguments at each call site.

## What is a constraint?

A **constraint** is an interface that defines the set of types a type parameter
may take. Two built-in constraints matter more than any other:

- `any` — any type (the empty interface `interface{}` in disguise)
- `comparable` — any type that supports `==` and `!=`

### `comparable`

```go eval=no
func contains[T comparable](s []T, v T) bool {
    for _, item := range s {
        if item == v {
            return true
        }
    }
    return false
}
```

Without the `comparable` constraint, the `==` check would not compile for
types that do not support equality. In modern Go, the standard library marks
most generic containers with exactly this constraint.

> [!key]
> `comparable` is what makes generic containers possible: they rely on `==`
> to find elements. Map keys must be comparable for the same reason.

### `any` and runtime dispatch

`any` places no restriction on the type, so the function cannot use operators
or methods directly. When you need to branch on the concrete type, a **type
switch** does the dispatch at runtime. This is the pre-generics pattern that
type sets replaced — and the runnable blueprint behind generic constraints:

```go
import "fmt"

classify := func(v any) string {
    switch t := v.(type) {
    case int:
        return fmt.Sprintf("int %d", t)
    case float64:
        return fmt.Sprintf("float64 %v", t)
    case string:
        return fmt.Sprintf("string %q", t)
    default:
        return "unknown"
    }
}
fmt.Println(classify(42))
fmt.Println(classify(1.5))
fmt.Println(classify("hi"))
```

`classify` works at runtime over an open set of types. A generic function
instead checks the constraint **at compile time** — the set is fixed and
checked before the program ever runs.

## Type sets: union of types

Constraints can restrict a type parameter to a specific **union** of types
with `|`. This moves the dispatch decision from runtime (type switch) to
compile time:

```go eval=no
func describe[T int | string | bool](v T) {
    fmt.Printf("value: %v, type: %T\n", v, v)
}

describe(42)
describe("hello")
describe(true)
```

`T` is restricted to exactly those three types — passing a `float64` or a
struct is a compile-time error. The function is type-safe for every allowed
type, with no type assertions anywhere.

> [!note]
> Use narrow unions for small, well-known sets of types. For broader
> behaviours (anything with a `Len()` method), prefer an interface with a
> method set instead.

## Generic types

Type parameters also work on **structs** and named types:

```go eval=no
type Pair[T any] struct {
    First  T
    Second T
}

p := Pair[string]{First: "hello", Second: "world"}
q := Pair[int]{First: 10, Second: 20}
```

`Pair[string]` and `Pair[int]` are distinct types with concrete field types.
This eliminates the `interface{}` fields, type assertions, and casting that
pre-generics Go required. The compiler checks `p.First` is a `string` — not a
runtime `.(string)` jump.

## Summary of the pattern

- Write `func Name[T constraint](...)` to create a generic function.
- Use `any` when no restriction is needed; `comparable` when you must compare
  with `==`.
- Use unions like `int | float64` when the type set is small and known.
- Generic structs use the same `[T]` syntax at the type name.
- The on-device sandbox's `yaegi` cannot run generics yet, so these examples
  are tagged `eval=no`; the runnable type-switch above shows the runtime
  equivalent that generic constraints replace.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Where does a type parameter appear in a function declaration?"
    type: single
    choices:
      - "In parentheses with the regular parameters"
      - "In square brackets after the function name"
      - "In the return type only"
      - "As a comment above the function"
    answer: [1]
    explanation: "Type parameters go in square brackets: `func F[T any](x T) T`."
    difficulty: 1

  - id: q2
    prompt: "What does the `comparable` constraint allow inside a generic function?"
    type: single
    choices:
      - "Use the `+` operator on any type"
      - "Use `==` and `!=` on the type parameter's values"
      - "Call any method on the type parameter"
      - "Serialize the value to JSON"
    answer: [1]
    explanation: "`comparable` guarantees the type supports equality operators, so `==` and `!=` checks compile for any permitted type. It does not permit arithmetic or arbitrary methods."
    difficulty: 2

  - id: q3
    prompt: "Given `func f[T int | string](v T)`, what happens if you call `f(3.14)`?"
    type: single
    choices:
      - "It panics at runtime because 3.14 is a float64"
      - "It fails at compile time — float64 is not in the constraint's type set"
      - "It implicitly converts 3.14 to int"
      - "It works because any numeric type satisfies int | string"
    answer: [1]
    explanation: "The type set `int | string` does not include float64, so the compiler rejects the call before the program runs. Type sets are checked at compile time, unlike runtime type switches."
    difficulty: 2

  - id: q4
    prompt: "What does the `any` constraint represent?"
    type: single
    choices:
      - "Any type that implements a specific interface"
      - "Any type at all — the empty interface"
      - "Any numeric type"
      - "Any type with a `String()` method"
    answer: [1]
    explanation: "`any` is an alias for the empty interface `interface{}`. It places no restriction on the type parameter."
    difficulty: 1
```