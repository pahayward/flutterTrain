---
id: 04-sync
title: Sync primitives
order: 4
section: 05-concurrency
language: golang
summary: WaitGroup, Mutex/RWMutex, Once, and when to use mutex vs channels.
tags: [sync, waitgroup, mutex, rwmutex, once, concurrency-control]
---

# Sync primitives

While Go encourages channel-based communication, the `sync` package provides
low-level primitives for cases where channels would be overkill or
impractical.

## WaitGroup

`sync.WaitGroup` lets you wait for a collection of goroutines to finish.

```go
import (
    "fmt"
    "sync"
)

var wg sync.WaitGroup
for i := 0; i < 3; i++ {
    wg.Add(1)
    go func(n int) {
        defer wg.Done()
        fmt.Println("worker", n)
    }(i)
}
wg.Wait()
fmt.Println("all done")
```

Call `wg.Add(n)` **before** launching goroutines, and `wg.Done()` (equivalent
to `Add(-1)`) inside each goroutine when it finishes. `wg.Wait()` blocks until
the counter reaches zero.

> [!trap]
> Calling `wg.Add` inside the goroutine (after launch) creates a race: `wg.Wait`
> might return before the first goroutine calls `Add`. Always increment before
> the `go` statement.

## Mutex

`sync.Mutex` protects shared state. Only one goroutine can hold the lock at a
time.

```go
import "sync"

var mu sync.Mutex
counter := 0
var wg sync.WaitGroup
for i := 0; i < 1000; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        mu.Lock()
        counter++
        mu.Unlock()
    }()
}
wg.Wait()
print("counter: ", counter, "\n")
```

> [!warning]
> Forgetting to unlock is easy. Prefer `defer mu.Unlock()` right after locking
> to ensure unlock happens even on panic.

## RWMutex

`sync.RWMutex` allows multiple concurrent readers **or** one exclusive writer.

```go
import "sync"

var rw sync.RWMutex
data := 0
var wg sync.WaitGroup
for i := 0; i < 5; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        rw.RLock()
        _ = data
        rw.RUnlock()
    }()
}
wg.Wait()
print("readers done\n")
```

Use `RLock()`/`RUnlock()` for reads, `Lock()`/`Unlock()` for writes. This
scales better than `Mutex` when reads vastly outnumber writes.

## Once

`sync.Once` ensures a function runs exactly once, even across goroutines.

```go
import "sync"

var once sync.Once
setup := func() { print("setup done\n") }
var wg sync.WaitGroup
for i := 0; i < 5; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        once.Do(setup)
    }()
}
wg.Wait()
```

Only one goroutine executes `setup`; the others block until it completes. This
is ideal for one-time initialization.

## When to use mutex vs channels

| Use channels when | Use mutex when |
|---|---|
| Passing ownership of data | Protecting a small critical section |
| Coordinating goroutines | Simple counters or flags |
| Pipeline / fan-out patterns | Multiple readers, one writer (RWMutex) |

> [!key]
> Channels communicate *intent*: "here is the data, you handle it." Mutexes
> say: "we're sharing this, take turns." Choose the one that makes the code's
> purpose clearer.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "When should `wg.Add(1)` be called relative to `go func()`?"
    type: single
    choices:
      - "Inside the goroutine, before doing work"
      - "After the goroutine finishes"
      - "Before the `go` statement"
      - "After `wg.Wait()`"
    answer: [2]
    explanation: "wg.Add must be called before launching the goroutine to prevent Wait from returning prematurely."
    difficulty: 1
  - id: q2
    prompt: "What is the difference between `Mutex` and `RWMutex`?"
    type: single
    choices:
      - "RWMutex allows concurrent readers and one writer"
      - "Mutex is faster than RWMutex for all workloads"
      - "RWMutex does not support locking"
      - "They are identical, RWMutex is just a rename"
    answer: [0]
    explanation: "RWMutex permits multiple simultaneous readers (RLock) but only one writer (Lock)."
    difficulty: 2
  - id: q3
    prompt: "What does `sync.Once.Do(f)` guarantee?"
    type: single
    choices:
      - "f is called once per goroutine"
      - "f is called exactly once across all goroutines"
      - "f is called at most once per second"
      - "f is called in a new goroutine"
    answer: [1]
    explanation: "Once.Do ensures f runs exactly once, even if called from multiple goroutines."
    difficulty: 1
  - id: q4
    prompt: "Which is a better choice for protecting a simple counter incremented by many goroutines?"
    type: single
    choices:
      - "A channel of ints"
      - "A sync.Mutex"
      - "A sync.Once"
      - "time.Sleep between increments"
    answer: [1]
    explanation: "A mutex provides straightforward mutual exclusion for a simple shared counter."
    difficulty: 2
```
