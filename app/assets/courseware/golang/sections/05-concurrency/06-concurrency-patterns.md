---
id: 06-concurrency-patterns
title: Concurrency patterns
order: 6
section: 05-concurrency
language: golang
summary: Worker pool, pipeline, fan-out/fan-in, and concurrency vs parallelism.
tags: [worker-pool, pipeline, fan-out, fan-in, concurrency-patterns, parallelism]
---

# Concurrency patterns

Go's goroutines and channels enable powerful patterns. This module covers three
classics: worker pool, pipeline, and fan-out/fan-in — plus the crucial
distinction between concurrency and parallelism.

## Concurrency vs parallelism

**Concurrency** is about *dealing with* multiple things at once — structuring
your program to handle multiple tasks. **Parallelism** is about *doing*
multiple things at once — executing them simultaneously on multiple cores.

Go's runtime schedules goroutines across available cores, giving you
parallelism for free. But the patterns below are valuable even on a single
core: they let you structure logic so tasks can overlap in time.

> [!key]
> Concurrency is a design tool; parallelism is an execution strategy. You
> write concurrent code regardless of how many cores you have.

## Worker pool

A fixed number of goroutines (workers) pull jobs from a shared channel:

```go
import "sync"

jobs := make(chan int, 5)
results := make(chan int, 5)
var wg sync.WaitGroup
for w := 0; w < 3; w++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        for j := range jobs {
            results <- j * j
        }
    }(w)
}
for i := 0; i < 5; i++ {
    jobs <- i
}
close(jobs)
go func() {
    wg.Wait()
    close(results)
}()
sum := 0
for r := range results {
    sum += r
}
print("sum of squares: ", sum, "\n")
```

Three workers process five jobs. The shared `jobs` channel distributes work,
and a `WaitGroup` coordinates shutdown.

> [!trap]
> If you forget to close the results channel, the range loop hangs. If you
> close jobs too early (before all sends complete), workers miss jobs. Send
> all jobs first, then close.

## Pipeline

Each stage is a goroutine; data flows through them in series:

```go
naturals := make(chan int, 5)
squares := make(chan int, 5)
go func() {
    for i := 1; i <= 5; i++ {
        naturals <- i
    }
    close(naturals)
}()
go func() {
    for v := range naturals {
        squares <- v * v
    }
    close(squares)
}()
for v := range squares {
    print(v, " ")
}
print("\n")
```

Stage 1 produces numbers, stage 2 squares them, the main goroutine consumes.
Each stage runs concurrently.

## Fan-out / fan-in

Fan-out: multiple goroutines read from the same channel. Fan-in: multiple
channels merge into one.

```go
import "sync"

in := make(chan int, 10)
out := make(chan int, 10)
for i := 0; i < 10; i++ {
    in <- i
}
close(in)
var wg sync.WaitGroup
for w := 0; w < 3; w++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        for v := range in {
            out <- v * 2
        }
    }()
}
go func() {
    wg.Wait()
    close(out)
}()
results := 0
for v := range out {
    results += v
}
print("fan-in sum: ", results, "\n")
```

Three workers share the input; results merge back through a single channel.

> [!tip]
> Fan-out/fan-in scales CPU-bound work across cores. The workers don't need
> locks because they communicate through channels.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In a worker pool, what controls how many jobs run concurrently?"
    type: single
    choices:
      - "The number of jobs sent"
      - "The size of the results buffer"
      - "The number of worker goroutines launched"
      - "The OS thread count"
    answer: [2]
    explanation: "Each worker goroutine handles one job at a time. The number of workers determines concurrency level."
    difficulty: 1
  - id: q2
    prompt: "What is a pipeline in Go concurrency?"
    type: single
    choices:
      - "A sequence of goroutines where each reads from one channel and writes to another"
      - "A buffered channel with many readers"
      - "A single goroutine processing data in stages"
      - "A mutex protecting a shared queue"
    answer: [0]
    explanation: "A pipeline connects goroutines in a chain: each stage receives, processes, and passes data downstream."
    difficulty: 2
  - id: q3
    prompt: "In fan-out/fan-in, what does 'fan-in' refer to?"
    type: single
    choices:
      - "Multiple goroutines reading from one channel"
      - "Merging multiple channel outputs into one channel"
      - "Copying data to multiple goroutines"
      - "Scaling down from parallel to serial"
    answer: [1]
    explanation: "Fan-in merges outputs from multiple goroutines into a single channel for downstream consumption."
    difficulty: 2
  - id: q4
    prompt: "Which best describes the difference between concurrency and parallelism?"
    type: single
    choices:
      - "They are the same thing"
      - "Concurrency is about structure; parallelism is about simultaneous execution"
      - "Parallelism requires goroutines; concurrency requires threads"
      - "Concurrency only works on multi-core CPUs"
    answer: [1]
    explanation: "Concurrency is the design of handling multiple tasks; parallelism is executing them simultaneously."
    difficulty: 1
```
