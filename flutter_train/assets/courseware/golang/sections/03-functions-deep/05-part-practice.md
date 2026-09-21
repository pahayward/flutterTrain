---
id: 05-part-practice
title: "Part 3 Practice"
order: 5
section: 03-functions-deep
language: golang
type: lesson
summary: "Review of variadics, closures, defer/panic/recover, and generics with exam-style questions."
tags: [practice, review, exam, variadic, closure, defer, panic, recover, generics]
---

# Part 3 Practice

This part explored Go's function system in depth — from variadic parameters
and closures to error-recovery patterns and generics. Here is the full story
in one place.

## Section review

**Variadic functions** accept zero or more values via `...T`, which becomes
`[]T` inside the function. Spread a slice with `slice...` at the call site.
`append(a, b...)` is the canonical example.

**Closures** are function values that capture variables from their enclosing
scope **by reference**. Mutations to captured variables are shared. Closures
enable callbacks, higher-order composition, and stateful iterators.

**`defer`** schedules a call for return-time, executing in LIFO order.
Arguments are evaluated immediately. Use it for cleanup (closing files,
unlocking mutexes, releasing resources).

**`panic`** unwinds the stack, running each deferred function in LIFO order.
`recover` (only inside a `defer`'d function) catches a panic and returns its
value. Prefer error returns for expected failures; reserve `panic`/`recover`
for truly exceptional conditions and top-level server recovery.

**Generics** let you write type-safe, reusable code. Type parameters appear
in square brackets `[T constraint]`. Built-in constraints include `any` and
`comparable`. Union constraints like `int | float64` restrict the set of
allowed types.

## Combined example: variadics + closures

```go
import "fmt"

composeN := func(fns ...func(int) int) func(int) int {
    return func(x int) int {
        for _, fn := range fns {
            x = fn(x)
        }
        return x
    }
}
double := func(x int) int { return x * 2 }
inc := func(x int) int { return x + 1 }
quad := composeN(double, double)
pipeline := composeN(inc, quad)
fmt.Println("quad(3):", quad(3))
fmt.Println("pipeline(3):", pipeline(3))
```

`composeN` is **variadic** (accepts any number of `func(int) int` and returns
one) and returns a **closure** that captures the `fns` slice. `pipeline` is
`inc` then `quad`: `(3 + 1) * 2 * 2 = 16`.

The same shape generalizes across types with generics — shown here for study
(the sandbox's `yaegi` cannot run generics yet):

```go eval=no
import "fmt"

func filter[T any](s []T, keep func(T) bool) []T {
    result := []T{}
    for _, v := range s {
        if keep(v) {
            result = append(result, v)
        }
    }
    return result
}

evens := filter([]int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
    func(n int) bool { return n%2 == 0 })
fmt.Println("evens:", evens)
```

Why `eval=no`? The embedded interpreter does not support Go 1.18 generics, but
this is the real-world syntax that replaces dozens of hand-written loops.

## Combined example: defer + recover

```go
import "fmt"

safeDiv := func(a, b int) (result int, err error) {
    defer func() {
        if r := recover(); r != nil {
            err = fmt.Errorf("recovered: %v", r)
        }
    }()
    return a / b, nil
}
r, e := safeDiv(10, 0)
fmt.Println("result:", r, "err:", e)
```

`defer` + `recover` catches the divide-by-zero panic and converts it to an
error value, keeping the rest of the program alive.

> [!key]
> This pattern is the bridge between Go's error-return convention and the
> panic/recover mechanism — convert panics into errors at API boundaries.

## What's next?

Part 4 introduces **methods and interfaces** — how functions attach to types,
how interfaces enable polymorphism, and Go's design philosophy of small,
composable abstractions.

## ExamQuestions

```yaml
questions:
  - id: ex1
    prompt: "What is the type of a variadic `...string` parameter inside the function body?"
    type: single
    choices:
      - "`string`"
      - "`[]string`"
      - "`*string`"
      - "`[...]string`"
    answer: [1]
    explanation: "A variadic parameter becomes a slice (`[]string`) inside the function. The `...` syntax is only used at the declaration and call site."
    difficulty: 1
    weight: 3
    section: 03-functions-deep

  - id: ex2
    prompt: "Given this code, what is printed?"
    type: single
    choices:
      - "`0 1 2`"
      - "`3 3 3`"
      - "`2 1 0`"
      - "`0 2 4`"
    answer: [1]
    explanation: "All three closures capture the same variable `x`. By the time they execute, `x` holds the final loop value 3. Each closure sees the same `x`."
    difficulty: 3
    weight: 4
    section: 03-functions-deep

  - id: ex3
    prompt: "What does this print?"
    type: single
    choices:
      - "`deferred` then `main body`"
      - "`main body` then `deferred`"
      - "Only `main body` — `defer` is skipped on normal return"
      - "Runtime error — `defer` requires a `return`"
    answer: [1]
    explanation: "A deferred call always runs before the function returns. On normal return the deferred function executes after the body completes."
    difficulty: 1
    weight: 3
    section: 03-functions-deep

  - id: ex4
    prompt: "When must `recover()` be called to successfully catch a panic?"
    type: single
    choices:
      - "In the same goroutine, at any point after `panic`"
      - "In a function directly deferred by the panicking function"
      - "In a `defer`'d function anywhere in the call stack"
      - "In a separate goroutine using a channel"
    answer: [1]
    explanation: "`recover` only works when called directly inside a function that is deferred by the function that panicked. It returns nil in any other context."
    difficulty: 2
    weight: 4
    section: 03-functions-deep

  - id: ex5
    prompt: "What does the `comparable` constraint allow inside a generic function?"
    type: single
    choices:
      - "Arithmetic operations on the type parameter"
      - "Comparison with `==` and `!=`"
      - "Calling any method the type defines"
      - "Marshaling to JSON"
    answer: [1]
    explanation: "`comparable` guarantees the type supports `==` and `!=`. This is the constraint needed for map keys and equality checks."
    difficulty: 1
    weight: 3
    section: 03-functions-deep
```
