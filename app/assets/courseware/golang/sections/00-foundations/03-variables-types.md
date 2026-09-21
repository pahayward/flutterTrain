---
id: 03-variables-types
title: "Variables, types, zero values"
order: 3
section: 00-foundations
language: golang
summary: "var, :=, short declaration, basic types, zero values, multiple assignment"
tags: [variables, types, zero-values, declaration]
---

# Variables, types, zero values

Go is **statically typed** — every variable has a type known at compile time.
But Go is also pragmatic: it can **infer types** so you rarely need to spell
them out.

## Declaring variables

### `var` — explicit declaration

```go
var name string = "Alice"
var age int
```

When the initializer is present, the type annotation is optional:

```go
var name = "Alice" // type inferred as string
```

### `:=` — short declaration

The most common form. Infers the type and declares in one shot:

```go
name := "Alice"
age := 30
```

> [!key] `:=` is only for local variables
> Short declaration works inside functions. Package-level declarations must
> use `var`.

## Basic types

| Category | Types |
|---|---|
| Integer | `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `byte` |
| Float | `float32`, `float64` |
| Complex | `complex64`, `complex128` |
| Boolean | `bool` |
| String | `string` |
| Rune | `rune` (alias for `int32`, represents a Unicode code point) |

```go
import "fmt"

var i int = 42
var f float64 = 3.14
var b bool = true
var s string = "hello"
fmt.Println(i, f, b, s)
```

## Zero values

Every type in Go has a **zero value** — the value a variable gets when
declared without an initializer.

| Type | Zero value |
|---|---|
| `int` | `0` |
| `float64` | `0` |
| `bool` | `false` |
| `string` | `""` (empty string) |
| pointer, slice, map, channel, interface, func | `nil` |

```go
import "fmt"

var count int
var label string
var flag bool
fmt.Println("int:", count)
fmt.Println("string:", label)
fmt.Println("bool:", flag)
```

> [!trap] Zero values vs undefined
> In Go, variables are **never** undefined. If you declare `var x int`, it
> is `0` — not garbage. This eliminates entire classes of bugs.

## Multiple assignment

Go lets you assign several variables at once:

```go
a, b := 1, 2
a, b = b, a // swap without a temp variable
```

This is especially useful for function returns:

```go eval=no
val, err := doSomething()
```

> [!note] `doSomething` is a placeholder
> The pattern `val, err := doSomething()` shows the idiomatic Go way to
> handle function returns that can fail. You'll see this everywhere.

## Declaration scope

`:=` introduces a new variable in the **current block**. Reusing `:=` in the
same scope with the same variable name is an error. But at least one new
variable must appear on the left:

```go
x := 1
x, y := 2, 3 // ok: y is new
```

```go
import "fmt"

x, y := 10, 20
x, y = y, x // swap
fmt.Println("x:", x, "y:", y)

var a, b, c int
fmt.Println("zero triple:", a, b, c)
```

> [!note] `_` blank identifier
> Use `_` to ignore values you don't need: `val, _ := doSomething()`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the zero value of a `bool` variable in Go?"
    type: single
    choices:
      - "true"
      - "false"
      - "nil"
      - "0"
    answer: [1]
    explanation: "The zero value of `bool` is `false`. Every type has a defined zero value in Go."
    difficulty: 1
  - id: q2
    prompt: "What does `:=` do that `var` cannot?"
    type: single
    choices:
      - "Declare package-level variables"
      - "Declare and initialize a local variable with inferred type"
      - "Declare a constant"
      - "Declare a global constant with a type"
    answer: [1]
    explanation: "`:=` is a short declaration that combines `var`, type inference, and assignment. It only works for local variables inside functions."
    difficulty: 1
  - id: q3
    prompt: "Which of the following is a valid multiple assignment?"
    type: single
    choices:
      - "a, b := 1"
      - "a, b := 1, 2, 3"
      - "a, b := 1, 2"
      - "a := b := 1"
    answer: [2]
    explanation: "Multiple assignment requires matching numbers of values on each side: `a, b := 1, 2` assigns 1 to a and 2 to b."
    difficulty: 2
```
