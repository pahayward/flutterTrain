---
id: 02-channels
title: Channels
order: 2
section: 05-concurrency
language: golang
summary: Unbuffered vs buffered channels, send/receive, close, range, and channels as function arguments.
tags: [channel, unbuffered, buffered, close, range, send, receive]
---

# Channels

Channels are the pipes that connect concurrent goroutines. You can send values
into a channel from one goroutine and receive them in another. Channels enforce
communication: only one goroutine accesses a value at a time through any given
channel.

## Creating channels

```go
ch := make(chan int)       // unbuffered channel of int
buf := make(chan int, 3)   // buffered channel, capacity 3
_ = ch
_ = buf
```

## Unbuffered vs buffered

- **Unbuffered** (`make(chan T)`): A send blocks until another goroutine is
  ready to receive, and vice versa. This forces synchronization.
- **Buffered** (`make(chan T, n)`): A send blocks only when the buffer is full.
  A receive blocks only when the buffer is empty.

> [!key]
> Unbuffered channels act as *rendezvous points* — sender and receiver must
> both be ready. Buffered channels decouple timing as long as the buffer isn't
> full/empty.

## Send and receive

```go eval=no
ch <- value   // send
v := <-ch     // receive
v, ok := <-ch // receive + check if channel is open
```

Syntax reminder — a real channel needs to exist first (see below for a running
version). Here they are in action:

```go
ch := make(chan int, 1)
ch <- 7
close(ch)
v := <-ch
v2, ok := <-ch // channel is closed, ok is false now
print("v:", v, " v2:", v2, " ok:", ok, "\n")
```

## Closing a channel

```go eval=no
close(ch) // illustration: ch must exist and only the sender closes it
```

A closed channel delivers no new values but still yields buffered ones. After
draining, receives on a closed channel return the zero value immediately (the
`ok` flag in the example above is `false` once the channel is closed and
drained).

> [!trap]
> **Sending on a closed channel panics.** Always close a channel from the
> sender's side, never from the receiver's side. If multiple goroutines send,
> use a WaitGroup to coordinate close.

## Ranging over a channel

```go
ch := make(chan int, 3)
ch <- 1
ch <- 2
ch <- 3
close(ch)
for v := range ch {
    print(v, " ")
}
print("\n")
```

The `for-range` loop on a channel reads values until the channel is closed and
drained.

## Channels as function arguments

Channels are passed by reference (they are already reference types, but the
channel value is a pointer-like header). You typically accept a channel as a
parameter to clarify the goroutine's role:

```go
producer := func(out chan int) {
    out <- 42
}
consumer := func(in chan int) {
    v := <-in
    print(v, "\n")
}
ch := make(chan int, 1)
producer(ch)
consumer(ch)
```

Use `chan<- T` (send-only) and `<-chan T` (receive-only) types on parameters
to document intent and prevent misuse.

## Practical example: unbuffered channel

```go
ch := make(chan string)
go func() {
    ch <- "hello from goroutine"
}()
msg := <-ch
print(msg, "\n")
```

The sender blocks until the main goroutine receives — perfect synchronization
without any locks.

## Practical example: buffered channel with range

```go
ch := make(chan int, 3)
ch <- 10
ch <- 20
ch <- 30
close(ch)
sum := 0
for v := range ch {
    sum += v
}
print("sum: ", sum, "\n")
```

All three values are buffered before close. The range loop drains them all.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens when you send on an unbuffered channel with no receiver?"
    type: single
    choices:
      - "The value is silently dropped"
      - "The value is buffered automatically"
      - "The sender goroutine blocks until a receiver is ready"
      - "The program panics"
    answer: [2]
    explanation: "An unbuffered channel send blocks until another goroutine performs a receive."
    difficulty: 1
  - id: q2
    prompt: "What is a buffered channel with capacity 0 (unbuffered) equivalent to?"
    type: single
    choices:
      - "A sync.Mutex"
      - "A rendezvous point between sender and receiver"
      - "A queue that stores one value"
      - "A signal-only channel"
    answer: [1]
    explanation: "Unbuffered channels synchronize sender and receiver — both must be ready at the same time."
    difficulty: 2
  - id: q3
    prompt: "Which statement about closing channels is correct?"
    type: single
    choices:
      - "Any goroutine can safely close a channel"
      - "Only the sender should close a channel"
      - "Closing a channel releases its memory immediately"
      - "A closed channel cannot be read from"
    answer: [1]
    explanation: "Sending on a closed channel panics. The convention is to close from the sender side only."
    difficulty: 2
  - id: q4
    prompt: "What does `for v := range ch` do when `ch` is closed and empty?"
    type: single
    choices:
      - "It blocks forever"
      - "It panics"
      - "The loop exits"
      - "It receives the zero value repeatedly"
    answer: [2]
    explanation: "Range over a channel exits after the channel is closed and all buffered values are drained."
    difficulty: 2
```
