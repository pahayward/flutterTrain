---
id: 04-interfaces-in-action
title: "Interfaces III: stdlib contracts"
order: 4
section: 04-methods-interfaces
language: golang
summary: The real-world contracts the standard library is built on — error, fmt.Stringer, io.Reader/Writer, sort.Interface.
tags: [stdlib, error, stringer, io, sort]
prereqs: [02-interfaces-basics, 03-interface-design]
---

# Interfaces III: stdlib contracts

> [!key]
> The standard library is a masterclass in interface design. Four contracts shape almost every Go
> program: `error`, `fmt.Stringer`, `io.Reader`/`io.Writer`, and `sort.Interface`. Learn how they
> think, and you learn how to write Go.

## `error`: the one-method contract

The `error` interface has exactly one method:

```go
type error interface {
    Error() string
}
```

It's the language's universal failure signal. Any type with that single method can be an error —
which is why `errors.New` (which returns `error`) can hand back a value whose concrete type is an
unexported internal string type. You never *need* the concrete type; you only need `Error()`.

Modern error handling builds chains: wrap an error with `%w` to keep the original reachable, then
ask questions with `errors.Is` and `errors.As` instead of comparing strings:

```go title="error-chains.go"
import ("errors"; "fmt")

base := errors.New("disk full")
wrapped := fmt.Errorf("save failed: %w", base)

fmt.Println(errors.Is(wrapped, base))          // true: the chain contains base
fmt.Println(errors.Unwrap(wrapped) == base)    // true: one link down
```

> [!note]
> The contract is *not* "a human-readable sentence". A good `Error()` message is lowercase,
> unpunctuated, and prefixable — `wrapped`, `wrapped2` — so it composes through layers.

## `fmt.Stringer`: how values describe themselves

```go
type Stringer interface {
    String() string
}
```

Any type with `String() string` controls how `fmt` renders it with `%v`, `%s` and `Println`.
The all-time example is `time.Duration`: you store nanoseconds, but printing it yields
`1m30s` — because `Duration` satisfies `Stringer`:

```go title="stringer-in-print.go"
import ("fmt"; "time")

d := 90 * time.Second
fmt.Println(d)          // fmt finds String() and uses it
fmt.Println(d.String()) // or call it yourself
```

> [!tip]
> Implement `String()` on the types you print often (amounts, IDs, statuses). One small method
> makes every `fmt.Println(thing)` in your codebase friendlier for free.

## `io.Reader` / `io.Writer`: streams as architectural ideas

These two single-method interfaces are the backbone of data plumbing in Go:

```go
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }
```

Their genius is what they *don't* say. Nothing about files, sockets, buffers, or HTTP. So code
written once against `io.Writer` works against literally any sink: memory, files, the network,
compression, encryption, logs. Producers feed readers; consumers drain writers; `io.Copy` and
friends glue them:

```go title="reading-streams.go"
import ("fmt"; "io"; "strings")

r := strings.NewReader("hello io") // *strings.Reader is an io.Reader
p := make([]byte, 5)
n, err := io.ReadFull(r, p)       // read exactly len(p) bytes
fmt.Println(n, err, string(p[:n]))
```

```go title="copy-between-streams.go"
import ("bytes"; "fmt"; "io"; "strings")

src := strings.NewReader("copy me")
var dst bytes.Buffer
n, _ := io.Copy(&dst, src)        // drain anything that Read()s into anything that Write()s
fmt.Println(n, dst.String())
```

> [!key]
> Reading `io.Reader` signatures trains you well: `Read` returns `(n, err)` and you must always
> handle `n > 0` *before* `err`. Streams are stateful, bounded contracts — no "give me the whole
> file" helper will save you from learning to loop.

### What this looks like with your own types

Read-only example, because it defines methods (sandbox can't — but any real project can):

```go eval=no
package main

import (
    "fmt"
    "io"
)

// tokenReader yields one token string per Read call.
type tokenReader []string

func (t *tokenReader) Read(p []byte) (int, error) {
    if len(*t) == 0 {
        return 0, io.EOF
    }
    s := (*t)[0]
    *t = (*t)[1:]
    n := copy(p, s)
    return n, nil
}

func main() {
    tr := &tokenReader{"go", "io", "rocks"}
    out := make([]byte, 0, 16)
    buf := make([]byte, 3)
    for {
        n, err := tr.Read(buf)
        out = append(out, buf[:n]...)
        if err != nil { break }
    }
    fmt.Println(string(out))
}
```

Because it implements `Read`, the type plugs into `io.ReadFull`, `io.Copy`, `bufio.Scanner` — the
whole ecosystem.

## `sort.Interface`: three methods buy you sorting

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

`sort.Sort` can order *anything* with `Len`, `Less`, `Swap` — it doesn't need to know your data's
shape. The stdlib provides helper defined types like `sort.IntSlice` and `sort.StringSlice` that
already implement it, so sorting (even reversed) becomes declarative:

```go title="sorting.go"
import ("fmt"; "sort")

si := sort.IntSlice{3, 1, 2}
sort.Sort(sort.Reverse(si))     // Reverse wraps a sort.Interface
fmt.Println(si)                 // [3 2 1]
```

And the modern convenience `sort.Slice` skips the interface by taking a `Less` closure — the same
idea, expressed inline:

```go title="sort-by-closure.go"
import ("fmt"; "sort")

nums := []int{4, 1, 3}
sort.Slice(nums, func(i, j int) bool { return nums[i] > nums[j] })
fmt.Println(nums)               // [4 3 1]
```

For your own structs you implement the three methods once (read-only example — methods need
package scope):

```go eval=no
package main

import ("fmt"; "sort")

type Student struct{ Name string; Score int }
type ByScore []Student

func (s ByScore) Len() int           { return len(s) }
func (s ByScore) Less(i, j int) bool { return s[i].Score < s[j].Score }
func (s ByScore) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }

func main() {
    class := ByScore{{"ada", 88}, {"lin", 95}, {"ken", 70}}
    sort.Sort(class)
    for _, st := range class {
        fmt.Printf("%s:%d\n", st.Name, st.Score)
    }
}
```

> [!note]
> In this block `%s:%d\n` inside `fmt.Printf` needs a full program; it's kept read-only here.
> The pattern above is the total surface you need to sort slices of any struct.

## The architecture lesson

Read the four contracts again: each is **one idea, one (or three) methods**, and consumers treat
the world as a pool of interchangeable implementers. When you design an interface, ask "does my
contract do what `error` does — name a single behavior so precisely that a stranger's type can
satisfy it without ever hearing about mine?"

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which method must a type provide to be usable as an error?"
    type: single
    choices:
      - "Message() string"
      - "Error() string"
      - "String() error"
      - "Err() error"
    answer: [1]
    explanation: "error is satisfied by exactly one method: Error() string."
    difficulty: 1
  - id: q2
    prompt: "time.Duration prints as 1m30s with fmt.Println(d) even though it stores nanoseconds. Why?"
    type: single
    choices:
      - "Duration's format is hardcoded in fmt."
      - "Duration implements String() string, so fmt calls it via the Stringer interface."
      - "Duration stores both forms and fmt chooses the pretty one."
      - "fmt.PrefixedEncode special-cases all numeric types."
    answer: [1]
    explanation: "fmt checks for the Stringer interface (String() string) and uses it to render values; Duration has exactly that method."
    difficulty: 2
  - id: q3
    prompt: "What does io.Reader's contract guarantee about Read?"
    type: single
    choices:
      - "It returns all requested bytes or fails."
      - "It returns (n, err) where n may be less than requested and errors must be handled; io.EOF signals end of stream."
      - "It always copies the entire remaining stream."
      - "It may never return zero bytes."
    answer: [1]
    explanation: "Read is bounded and incremental: n can be 0..len(p), callers loop, and io.EOF (or another error) ends the stream."
    difficulty: 2
  - id: q4
    prompt: "A type has Len, Less, and Swap for []struct entries. Which interface does it satisfy?"
    type: single
    choices:
      - "io.Writer"
      - "fmt.Stringer"
      - "sort.Interface"
      - "error"
    answer: [2]
    explanation: "sort.Interface is exactly Len() int, Less(i,j int) bool, Swap(i,j int) — the trio sort.Sort consumes."
    difficulty: 2
  - id: q5
    prompt: "Why does errors.Is(wrapped, base) matter more than comparing error strings?"
    type: single
    choices:
      - "String comparison is slower."
      - "Wrapping with %w preserves the original error in the chain, so Is can find it reliably without parsing text."
      - "errors.Is only works on nil errors."
      - "It's the only way to access the concrete error type."
    answer: [1]
    explanation: "Message text is unstable and can be reworded; the wrapped chain keeps the original error object reachable for equality-based checks."
    difficulty: 2
```