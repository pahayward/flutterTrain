---
id: 03-select
title: "select"
order: 3
section: 05-concurrency
language: golang
summary: Waiting on many channels, default, time.After, and non-blocking sends/receives.
tags: [select, time-after, non-blocking, default, multiplexing]
---

# select

The `select` statement lets a goroutine wait on multiple channel operations
simultaneously. Think of it as a `switch` for channels.

## Basic syntax

```go
ch1 := make(chan string, 1)
ch2 := make(chan string, 1)
ch1 <- "ping"
var msg string
var msg2 string
select {
case msg = <-ch1:
    print("from ch1:", msg, "\n")
case msg2 = <-ch2:
    print("from ch2:", msg2, "\n")
default:
    print("neither ready\n")
}
```

Go evaluates all channel operations; if one is ready, it executes the
corresponding case. If multiple are ready, one is chosen **at random**. If
none are ready, the `default` case runs (if present) — otherwise the goroutine
blocks.

> [!key]
> `select` with no `default` case blocks until one case is ready. With
> `default`, it becomes **non-blocking**: it tries each case and falls through
> immediately.

## Waiting on many channels

A common pattern is to listen for data from multiple sources:

```go
ch1 := make(chan string, 1)
ch2 := make(chan string, 1)
ch1 <- "alpha"
ch2 <- "beta"
var got string
for i := 0; i < 2; i++ {
    select {
    case got = <-ch1:
        print("got: ", got, "\n")
    case got = <-ch2:
        print("got: ", got, "\n")
    }
}
```

> [!trap]
> If **both** channels are ready, Go picks one **randomly**. You cannot predict
> which case executes first — that's by design for fairness.

## `time.After` for timeouts

```go
import "time"

ch := make(chan string)
var v string
select {
case v = <-ch:
    print("received:", v, "\n")
case <-time.After(100 * time.Millisecond):
    print("timed out\n")
}
```

`time.After(d)` returns a channel that sends a value after duration `d`. If
nothing arrives on `ch` within 100ms, the timeout case wins.

## Non-blocking send and receive

Combine `select` with `default` for non-blocking operations:

```go
ch := make(chan int)
select {
case ch <- 42:
    print("sent\n")
default:
    print("channel not ready, skipped\n")
}
var v int
select {
case v = <-ch:
    print("received:", v, "\n")
default:
    print("nothing to receive\n")
}
```

This is useful for polling: try a channel operation and do something else if it
would block.

## Practical example: simple heartbeat

```go
import "time"

heartbeat := make(chan string, 1)
go func() {
    for i := 0; i < 3; i++ {
        heartbeat <- "beat"
    }
}()
var v string
for i := 0; i < 3; i++ {
    select {
    case v = <-heartbeat:
        print(v, "\n")
    case <-time.After(500 * time.Millisecond):
        print("timeout!\n")
    }
}
```

Each beat arrives quickly; the timeout never triggers. This pattern scales to
health checks, ping/pong protocols, and more.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens if multiple `select` cases are ready simultaneously?"
    type: single
    choices:
      - "The first case in the list is always chosen"
      - "All ready cases execute sequentially"
      - "One is chosen at random"
      - "The program panics"
    answer: [2]
    explanation: "Go randomly selects among ready cases to ensure fairness."
    difficulty: 1
  - id: q2
    prompt: "What is the purpose of `default` in a `select` statement?"
    type: single
    choices:
      - "It catches errors"
      - "It makes the select non-blocking"
      - "It closes all channels in the select"
      - "It restarts the select loop"
    answer: [1]
    explanation: "With a default case, if no channel operation is ready, the default executes immediately instead of blocking."
    difficulty: 1
  - id: q3
    prompt: "Which function returns a channel that sends a value after a delay?"
    type: single
    choices:
      - "time.Sleep"
      - "time.Tick"
      - "time.After"
      - "time.NewTimer"
    answer: [2]
    explanation: "time.After(d) returns a channel that receives the current time after duration d."
    difficulty: 1
  - id: q4
    prompt: "A `select` with no `default` case and no ready channel will:"
    type: single
    choices:
      - "Return the zero value"
      - "Execute a random case"
      - "Block until one case becomes ready"
      - "Panic with a deadlock"
    answer: [2]
    explanation: "Without default, select blocks until at least one case's channel operation is ready."
    difficulty: 2
```
