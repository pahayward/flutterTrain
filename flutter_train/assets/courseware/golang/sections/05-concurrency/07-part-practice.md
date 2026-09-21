---
id: 07-part-practice
title: "Part 5 Practice"
order: 7
section: 05-concurrency
language: golang
summary: Compact review of Go concurrency plus a 5-question exam bank for Part 5.
tags: [review, practice, exam, concurrency, goroutine, channel, context]
---

# Part 5 Practice

A compact recap of goroutines, channels, select, sync primitives, context, and
concurrency patterns.

## Section review

**Goroutines (5.1)**

- `go f()` starts `f` in a new goroutine; returns immediately.
- Goroutines are lightweight (small stack, grows/shrinks), scheduled in user
  space by the Go runtime.
- `main` returning kills all goroutines. Use channels or `sync.WaitGroup` to
  wait.

**Channels (5.2)**

- `make(chan T)` unbuffered (rendezvous), `make(chan T, n)` buffered.
- `<-ch` receive, `ch <- v` send. `v, ok := <-ch` checks if open.
- `close(ch)` from sender side only; `range ch` reads until drained+closed.
- Send-only: `chan<- T`. Receive-only: `<-chan T`.

**select (5.3)**

- Waits on multiple channel operations simultaneously.
- Ready case chosen at random. `default` makes it non-blocking.
- `time.After(d)` returns a channel for timeouts.

**Sync primitives (5.4)**

- `WaitGroup`: `Add` before launch, `Done` inside goroutine, `Wait` blocks.
- `Mutex`: `Lock`/`Unlock` around critical section. Use `defer Unlock`.
- `RWMutex`: concurrent readers, exclusive writer.
- `Once.Do(f)`: `f` runs exactly once across all goroutines.

**Context (5.5)**

- Carries cancellation, deadlines, and values across goroutines.
- `WithCancel`, `WithTimeout`, `WithDeadline` — always `defer cancel()`.
- `ctx.Done()` channel; `ctx.Err()` reports cause.

**Patterns (5.6)**

- Worker pool: fixed goroutines pull from shared jobs channel.
- Pipeline: goroutines chain via channels.
- Fan-out/fan-in: multiple workers share input; results merge.

```go
import (
    "context"
    "sync"
    "time"
)

ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
defer cancel()

jobs := make(chan int, 10)
results := make(chan int, 10)
var wg sync.WaitGroup

for w := 0; w < 3; w++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        for j := range jobs {
            select {
            case <-ctx.Done():
                return
            case results <- j * 2:
            }
        }
    }()
}

for i := 1; i <= 6; i++ {
    jobs <- i
}
close(jobs)

go func() {
    wg.Wait()
    close(results)
}()

total := 0
for r := range results {
    total += r
}
print("total: ", total, "\n")
```

## ExamQuestions

```yaml
bank:
  - prompt: "Which keyword starts a goroutine?"
    type: single
    choices: ["go", "async", "spawn", "thread"]
    answer: [0]
    explanation: "The `go` keyword launches a function as a goroutine."
    weight: 2
    section: 05-concurrency
  - prompt: "What does a send on an unbuffered channel do when no receiver is waiting?"
    type: single
    choices:
      - "Drops the value"
      - "Buffers one value"
      - "Blocks the sender"
      - "Panics"
    answer: [2]
    explanation: "Unbuffered channel sends block until a goroutine is ready to receive."
    weight: 3
    section: 05-concurrency
  - prompt: "Which sync primitive ensures a function runs exactly once?"
    type: single
    choices: ["sync.Mutex", "sync.WaitGroup", "sync.Once", "sync.Map"]
    answer: [2]
    explanation: "sync.Once.Do(f) guarantees f executes only once, even with concurrent callers."
    weight: 2
    section: 05-concurrency
  - prompt: "Why is `defer cancel()` important after creating a cancellable context?"
    type: single
    choices:
      - "It triggers the cancellation immediately"
      - "It releases internal resources to prevent leaks"
      - "It resets the context for reuse"
      - "It's optional — the runtime handles cleanup"
    answer: [1]
    explanation: "Even if the context is already cancelled, calling cancel releases held resources (timers, goroutines)."
    weight: 3
    section: 05-concurrency
  - prompt: "In a Go worker pool pattern, what limits the number of concurrent jobs being processed?"
    type: single
    choices:
      - "The buffer size of the results channel"
      - "The number of worker goroutines"
      - "The number of jobs sent to the channel"
      - "The OS scheduler"
    answer: [1]
    explanation: "Each worker goroutine handles one job at a time, so the worker count determines concurrency."
    weight: 2
    section: 05-concurrency
```
