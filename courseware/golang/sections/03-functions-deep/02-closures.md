---
id: 02-closures
title: "Closures and first-class functions"
order: 2
section: 03-functions-deep
language: golang
type: lesson
summary: "Function values, closure capture semantics, callbacks, and higher-order composition."
tags: [closure, function-value, callback, higher-order, first-class]
---

# Closures and first-class functions

In Go, functions are **first-class values** — you can assign them to
variables, pass them as arguments, and return them from other functions. A
**closure** is a function value that references variables declared outside its
own body; those variables "close over" the function and persist as long as the
function exists.

> [!note] **About the examples in this app**
>
> The on-device sandbox wraps every snippet in `func main(){...}`. Function
> literals assigned to variables run perfectly here. Top-level `func` names
> (shown in `eval=no` blocks) require a real `.go` file.

## Function values

A function literal `func(x int) int { ... }` can be assigned to a variable,
passed around, and called later:

```go
double := func(x int) int {
    return x * 2
}
triple := func(x int) int {
    return x * 3
}
print("double 5:", double(5), "\n")
print("triple 5:", triple(5), "\n")
```

> [!key]
> `double` and `triple` are **function values** — variables whose type is
> `func(int) int`. You can reassign them, store them in slices, and pass them
> to other functions.

## Closures capture by reference

A closure captures the **variable itself**, not a snapshot of its value.
Later mutations to that variable are visible inside the closure:

```go
counter := 0
inc := func() {
    counter++
}
inc()
inc()
inc()
print("counter:", counter, "\n")
```

Every call to `inc()` reads and writes the same `counter` variable in the
enclosing scope. The variable lives as long as at least one closure references
it.

> [!trap]
> Captured variables are shared by reference. If a loop body captures the loop
> variable, all closures see the **same** variable — this catches many
> beginners out. Give each iteration its own copy if you need independent values.

## Closures as callbacks

Functions can accept other functions as parameters. This is the foundation of
event-driven and filter/map/reduce patterns:

```go
apply := func(f func(int) int, x int) int {
    return f(x)
}
result := apply(func(x int) int {
    return x * x
}, 7)
print("7 squared:", result, "\n")
```

The anonymous `func(x int) int { return x * x }` is created inline and
immediately passed to `apply`. Go inlines small closures efficiently.

## Higher-order composition

You can build new functions from existing ones — a technique called
**composition**:

```go
addSuffix := func(suffix string) func(string) string {
    return func(s string) string {
        return s + suffix
    }
}
addExcl := addSuffix("!")
addQ := addSuffix("?")
print(addExcl("hello"), "\n")
print(addQ("really"), "\n")
```

`addSuffix` is a higher-order function — it **returns** a closure. Each
returned closure remembers the `suffix` it was created with, even after
`addSuffix` has returned.

## Building a pipeline

Closures let you compose small, focused transformations into a pipeline:

```go
pipeline := func(fns ...func(int) int) func(int) int {
    return func(x int) int {
        for _, fn := range fns {
            x = fn(x)
        }
        return x
    }
}
double := func(x int) int { return x * 2 }
addTen := func(x int) int { return x + 10 }
negate := func(x int) int { return -x }

run := pipeline(double, addTen, negate)
print("pipeline(5):", run(5), "\n")
```

`pipeline` composes functions left-to-right: 5 → double (10) → addTen (20)
→ negate (-20).

> [!tip]
> This style mirrors functional programming patterns. Go is not a functional
> language, but closures make these patterns natural and efficient.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does a closure capture: the variable's value at creation time, or the variable itself?"
    type: single
    choices:
      - "The value at the moment the closure is created"
      - "The variable itself — mutations after creation are visible"
      - "A deep copy of the variable"
      - "Nothing — closures cannot reference outer variables"
    answer: [1]
    explanation: "Closures capture variables by reference. Later changes to the variable are visible when the closure runs."
    difficulty: 1

  - id: q2
    prompt: "What is a function that accepts or returns another function called?"
    type: single
    choices:
      - "A variadic function"
      - "A closure function"
      - "A higher-order function"
      - "A recursive function"
    answer: [2]
    explanation: "Higher-order functions take or return function values. This is the standard term in Go and functional programming."
    difficulty: 1

  - id: q3
    prompt: "Given this code, what does `outer()` print?"
    type: single
    choices:
      - "0, 0, 0"
      - "1, 2, 3"
      - "3, 3, 3"
      - "Compilation error — cannot return a closure"
    answer: [2]
    explanation: "Each returned function captures the same `x`. By the time they run, `x` holds 3 (the final loop value). All three closures see 3."
    difficulty: 3

  - id: q4
    prompt: "How do you give each loop iteration its own independent captured variable?"
    type: single
    choices:
      - "Declare the loop variable outside the loop"
      - "Use `go` to launch each iteration in a goroutine"
      - "Copy the loop variable into a fresh local inside the loop body"
      - "Use `defer` to defer the capture"
    answer: [2]
    explanation: "Creating a new variable inside the loop body (e.g. `v := i`) makes a fresh copy per iteration. Each closure captures its own `v`."
    difficulty: 2
```
