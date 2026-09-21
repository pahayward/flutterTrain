---
id: 05-context
title: "context"
order: 5
section: 05-concurrency
language: golang
summary: context.Context, cancellation, deadlines, values, and common patterns.
tags: [context, cancellation, deadline, timeout, values, propagation]
---

# context

The `context` package provides a standard way to carry deadlines, cancellation
signals, and request-scoped values across goroutines. It's the backbone of
coordinated shutdown in Go servers and libraries.

## What is context.Context?

`context.Context` is an interface, but you never implement it yourself. The
package provides constructors:

| Constructor | Purpose |
|---|---|
| `context.Background()` | Root context; never cancelled, no deadline |
| `context.TODO()` | Placeholder when you're unsure |
| `context.WithCancel(parent)` | Returns a cancellable child |
| `context.WithTimeout(parent, d)` | Cancels automatically after `d` |
| `context.WithDeadline(parent, t)` | Cancels at absolute time `t` |
| `context.WithValue(parent, k, v)` | Carries a key-value pair |

> [!key]
> Every context is a child of another. Cancellation propagates downward: when
> the parent is cancelled, all children are too.

## Cancellation

```go
import (
    "context"
    "time"
)

ctx, cancel := context.WithCancel(context.Background())
go func() {
    <-ctx.Done()
    print("cancelled: ", ctx.Err().Error(), "\n")
}()
cancel()
time.Sleep(10 * time.Millisecond)
```

`cancel()` closes the context's `Done()` channel. All goroutines listening on
`ctx.Done()` can react immediately.

> [!trap]
> You **must** call `cancel()` when you're done with a cancellable context, even
> if the child has already been cancelled. Forgetting leaks resources. Use
> `defer cancel()`.

## Timeouts

```go
import (
    "context"
    "time"
)

ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
defer cancel()
select {
case <-time.After(200 * time.Millisecond):
    print("slow work done\n")
case <-ctx.Done():
    print("timeout: ", ctx.Err().Error(), "\n")
}
```

The context times out after 100ms. The "slow work" would take 200ms, so the
timeout wins.

## Carrying values

```go
import "context"

type ctxKey string

ctx := context.WithValue(context.Background(), ctxKey("user"), "alice")
v, ok := ctx.Value(ctxKey("user")).(string)
if ok {
    print("user: ", v, "\n")
}
```

Use typed keys (your own exported type) to avoid collisions. Values are
request-scoped — not a substitute for function parameters.

> [!warning]
> Context values are for request-scoped data (trace IDs, auth tokens), not for
> passing application configuration. Keep the value map small.

## Practical example: timeout propagation

```go
import (
    "context"
    "time"
)

work := func(ctx context.Context) {
    select {
    case <-time.After(200 * time.Millisecond):
        print("work done\n")
    case <-ctx.Done():
        print("work cancelled: ", ctx.Err().Error(), "\n")
    }
}

ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
defer cancel()
work(ctx)
```

The caller sets a 50ms timeout; the worker respects it without knowing the
duration.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why must you call `cancel()` even when the context has already expired?"
    type: single
    choices:
      - "To allow garbage collection of resources held by the context"
      - "To reset the timeout for the next use"
      - "To re-enable the Done channel"
      - "It's optional but recommended"
    answer: [0]
    explanation: "Calling cancel releases internal resources (timers, goroutines). Failing to call it causes memory leaks."
    difficulty: 2
  - id: q2
    prompt: "Which method returns a channel that is closed when the context is cancelled?"
    type: single
    choices:
      - "ctx.Error()"
      - "ctx.Value()"
      - "ctx.Done()"
      - "ctx.Cancel()"
    answer: [2]
    explanation: "ctx.Done() returns a <-chan struct{} that is closed when the context's work is done."
    difficulty: 1
  - id: q3
    prompt: "What is `context.Background()` used for?"
    type: single
    choices:
      - "It creates a context that auto-cancels after 30 seconds"
      - "It returns the top-level, never-cancelled root context"
      - "It returns the last active context"
      - "It clears all context values"
    answer: [1]
    explanation: "context.Background() returns an empty, non-cancellable context used as the root of a context tree."
    difficulty: 1
  - id: q4
    prompt: "When `context.WithTimeout` fires, what does `ctx.Err()` return?"
    type: single
    choices:
      - "nil"
      - "context.Canceled"
      - "context.DeadlineExceeded"
      - "context.Timeout"
    answer: [2]
    explanation: "ctx.Err() returns DeadlineExceeded when the context's timeout or deadline has passed."
    difficulty: 2
```
