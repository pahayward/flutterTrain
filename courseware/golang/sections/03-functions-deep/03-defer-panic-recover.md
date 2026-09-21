---
id: 03-defer-panic-recover
title: "defer, panic, recover"
order: 3
section: 03-functions-deep
language: golang
type: lesson
summary: "Defer LIFO stacking, argument evaluation, panic unwinding, recover, and Go's error philosophy."
tags: [defer, panic, recover, error-handling, LIFO, stack-unwinding]
---

# defer, panic, recover

Go uses `defer`, `panic`, and `recover` to manage cleanup, exceptional
conditions, and graceful shutdown. Understanding their precise semantics is
essential for writing correct resource-management code.

## defer: schedule a call for later

`defer` schedules a function call to run **after** the surrounding function
returns, but **before** the caller gets control. This is ideal for cleanup:

```go
import "fmt"

process := func() {
    fmt.Println("start")
    defer fmt.Println("deferred 1")
    defer fmt.Println("deferred 2")
    fmt.Println("end")
}
process()
```

Output is `start`, `end`, `deferred 2`, `deferred 1` — `defer` calls execute
in **LIFO** (last-in, first-out) order.

> [!key]
> `defer` is the Go replacement for `try/finally`. You open a file, then
> immediately `defer f.Close()` — no matter how the function exits, the close
> runs.

## LIFO stacking

Defers are pushed onto a stack when encountered and popped when the function
returns. This reverses the call order:

```go
import "fmt"

stack := func() {
    for i := 1; i <= 4; i++ {
        defer fmt.Print(i, " ")
    }
    fmt.Print("done ")
}
stack()
```

Output: `done 4 3 2 1 `. The last defer pushed (4) runs first, and `fmt.Print`
without `Println` avoids extra newlines.

## Argument evaluation timing

Arguments to a deferred call are evaluated **immediately** when `defer` is
executed, not when the deferred function runs:

```go
import "fmt"

x := 1
defer fmt.Println("x:", x)
x = 99
fmt.Println("x now:", x)
```

Output: `x now: 99`, then `x: 1`. The value `1` was captured at `defer` time.

> [!trap]
> This trips up many developers. `defer f(close())` evaluates `close()` right
> away. If you need a value from a later state, compute it inside the deferred
> function instead.

## Capturing for correctness

To read a value at return-time rather than defer-time, wrap it in a closure:

```go
import "fmt"

x := "hello"
defer func() {
    fmt.Println("at return, x:", x)
}()
x = "world"
fmt.Println("now, x:", x)
```

Output: `now, world`, then `at return, x: world`. The closure reads `x` when
it runs, not when `defer` was registered.

## panic: unwind the stack

`panic` stops normal execution and begins **unwinding** the stack. Each
deferred function runs in LIFO order as the stack unwinds. Here the panic
is deliberately recovered one function up the stack so the example can show
the unwind order and then continue normally:

```go
import "fmt"

inner := func() {
    defer fmt.Println("inner defer")
    panic("something broke")
}
outer := func() {
    defer func() {
        fmt.Println("recovered:", recover())
    }()
    defer fmt.Println("outer defer")
    inner()
    fmt.Println("outer continues") // never reached
}
outer()
fmt.Println("program continues")
```

Output order proves the mechanics: `inner defer` runs first (inner's own
defer), then—still unwinding—`outer defer`, then `recovered: something broke`
stops the unwinding. `"outer continues"` is never printed because `inner`
panicked, and the process continues after `recover`.

An **unhandled** panic prints its message and stack trace to the console and
crashes the program. Real output looks like this:

```text
inner defer
outer defer
panic: something broke

goroutine 1 [running]:
...
```

> [!warning]
> `panic` is for truly unrecoverable situations (nil pointer dereference,
> index out of range, programmer errors). For expected errors, use return
> values — not `panic`.

## recover: catch a panic

`recover` catches a panic and returns the value passed to `panic`. It only
works when called **directly** inside a deferred function:

```go
import "fmt"

safe := func() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("caught:", r)
        }
    }()
    panic("oops")
}
safe()
fmt.Println("program continues")
```

Output: `caught: oops`, `program continues`. Without `recover`, the panic
would terminate the program.

> [!key]
> `recover` only works inside a `defer`'d function. If you call `recover()`
> outside a deferred context, it returns `nil` and does nothing.

## Go's error-handling philosophy

Go deliberately avoids exceptions for normal errors. The convention is:

```go eval=no
// Return errors — don't panic
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}
```

Use `panic`/`recover` only as a last resort — for truly exceptional conditions
that a caller cannot reasonably handle. The `recover` pattern is most common
in HTTP servers to prevent a single request from crashing the whole process.

> [!tip]
> Prefer `if err != nil { return err }` for expected failures. Reserve
> `panic` for programmer mistakes, unreachable states, and top-level recovery
> in servers and goroutines.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In what order do deferred function calls execute?"
    type: single
    choices:
      - "FIFO — first defer registered runs first"
      - "LIFO — last defer registered runs first"
      - "Random order"
      - "Alphabetical order by function name"
    answer: [1]
    explanation: "Defers are pushed onto a stack and popped when the function returns. The last defer registered runs first (LIFO)."
    difficulty: 1

  - id: q2
    prompt: "What happens to the arguments of a deferred call?"
    type: single
    choices:
      - "They are evaluated when the deferred function runs"
      - "They are evaluated immediately when `defer` is encountered"
      - "They are passed by reference and always see the latest value"
      - "They are copied lazily on first access"
    answer: [1]
    explanation: "Arguments are evaluated eagerly at `defer` time. A closure must be used to capture a later value."
    difficulty: 2

  - id: q3
    prompt: "Where must `recover()` be called to catch a panic?"
    type: single
    choices:
      - "Anywhere in the same goroutine"
      - "Only in a function directly deferred by the panicking function"
      - "In the function that called `panic`"
      - "In a separate goroutine"
    answer: [1]
    explanation: "`recover` only works when called directly inside a function that is deferred. If called outside a deferred context, it returns nil."
    difficulty: 2

  - id: q4
    prompt: "What is the idiomatic way to handle expected errors in Go?"
    type: single
    choices:
      - "Use `panic` and let the caller `recover`"
      - "Return `(result, error)` and check `err != nil`"
      - "Use `try/catch` with a custom exception type"
      - "Log the error and call `os.Exit(1)`"
    answer: [1]
    explanation: "Go's convention is to return error values and check them explicitly. `panic`/`recover` is reserved for truly exceptional situations."
    difficulty: 1
```
