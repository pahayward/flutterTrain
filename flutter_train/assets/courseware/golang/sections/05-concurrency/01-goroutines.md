---
id: 01-goroutines
title: Goroutines
order: 1
section: 05-concurrency
language: golang
summary: The go statement, lightweight threads, and the "don't communicate by sharing memory" philosophy.
tags: [goroutine, concurrency, go-statement, lightweight-thread]
---

# Goroutines

Go's headline feature is **built-in concurrency**. A *goroutine* is a function
that runs concurrently with other goroutines in the same address space. They
are managed by the Go runtime, not by the operating system, which makes them
extremely cheap — you can run millions of them.

## The `go` statement

Launching a goroutine is a one-word extension to a function call:

```go
import "fmt"

go fmt.Println("from goroutine")
fmt.Println("from main")
```

The `go` keyword starts the function in a new goroutine and returns
immediately. The main goroutine does **not** wait — it continues to the next
line. When `main` returns, the program exits and all other goroutines are
killed, even if they haven't finished.

> [!key]
> A goroutine is not a thread. It's a lightweight, multiplexed unit of
> execution. The Go runtime schedules thousands of goroutines across a small
> number of OS threads.

## Why goroutines are cheap

OS threads are heavy: each one allocates a megabyte or more of stack and
requires kernel-level context switches. Goroutines start with just a few
kilobytes of stack (which grows and shrinks as needed) and are scheduled in
user space.

This means:

- You can launch goroutines freely for small tasks.
- Concurrency is not something reserved for special subsystems — it's an
  everyday tool.

## Don't communicate by sharing memory; share memory by communicating

The Go proverb above is the philosophical backbone of Go concurrency. In
traditional concurrent programming, threads coordinate by locking shared data
structures. Go instead encourages passing values between goroutines via
**channels** (covered in the next module).

This doesn't mean mutexes are banned — it means the *default instinct* should
be: "pass the data, don't share it."

> [!warning]
> If two goroutines read and write the same variable without synchronization,
> you have a **data race**. The `go run -race` detector finds these. Always
> synchronize access to shared state.

## Practical example: launching multiple goroutines

```go
import "fmt"

for i := 1; i <= 3; i++ {
    go func(n int) {
        fmt.Println("hello", n)
    }(i)
}
// Block so goroutines have time to print
ch := make(chan bool)
go func() {
    fmt.Println("waiting done")
    ch <- true
}()
<-ch
```

Each goroutine prints "hello" with its number. The main goroutine blocks on a
channel receive (`<-ch`) to wait for the last goroutine — this is a basic
synchronization pattern.

> [!trap]
> **Closing order**: If you remove the channel receive at the end, `main`
> returns instantly and goroutines are killed. A common beginner mistake is to
> assume `main` waits for goroutines — it does not.

## Naming conventions

A goroutine is identified by its function name at launch. If you launch
`go worker(1)`, the goroutine is labeled `worker` in race-detector output and
stack traces. Name your goroutines meaningfully for debuggability.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does the `go` keyword do?"
    type: single
    choices:
      - "Calls a function synchronously on a new OS thread"
      - "Starts the function in a new goroutine and returns immediately"
      - "Pauses the current goroutine until the function completes"
      - "Declares a function as concurrent at compile time"
    answer: [1]
    explanation: "The go keyword launches the function as a goroutine and the calling goroutine continues without waiting."
    difficulty: 1
  - id: q2
    prompt: "What happens when `main()` returns in a Go program?"
    type: single
    choices:
      - "It waits for all goroutines to finish"
      - "It sends a signal to the Go runtime to schedule them"
      - "The program exits and all goroutines are killed"
      - "It panics if any goroutine is still running"
    answer: [2]
    explanation: "When main returns, the program terminates. There is no automatic wait for other goroutines."
    difficulty: 1
  - id: q3
    prompt: "Why are goroutines cheaper than OS threads?"
    type: single
    choices:
      - "They run on the GPU instead of the CPU"
      - "They start with only a few kilobytes of stack that can grow"
      - "They are compiled to machine code at runtime"
      - "They are scheduled by the OS kernel for maximum efficiency"
    answer: [1]
    explanation: "Goroutines start with a small (a few KB) stack that grows dynamically, unlike OS threads which typically allocate 1 MB+."
    difficulty: 2
  - id: q4
    prompt: "What does the Go proverb 'Don't communicate by sharing memory' suggest?"
    type: single
    choices:
      - "Never use mutexes in Go"
      - "Prefer passing data between goroutines via channels over mutating shared state"
      - "Goroutines cannot share variables"
      - "Memory should be allocated on the heap, not the stack"
    answer: [1]
    explanation: "The proverb encourages channel-based communication as the primary coordination mechanism, though mutexes are still available."
    difficulty: 2
```
