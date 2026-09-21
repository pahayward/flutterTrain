---
id: 05-pointers-vs-values
title: "Pointers vs values: a decision guide"
order: 5
section: 04-methods-interfaces
language: golang
summary: Choosing receivers, mutability and performance trade-offs, nil receivers, and the method-set gotcha.
tags: [pointers, receivers, method-set, nil]
prereqs: [01-methods, 02-interfaces-basics]
---

# Pointers vs values: a decision guide

> [!key]
> The receiver type — `T` or `*T` — is a design decision with three consequences: who can mutate
> the data, how much copying happens, and which interface method sets are unlocked.

## The core trade-offs

| | Value receiver `(t T)` | Pointer receiver `(t *T)` |
|---|---|---|
| Mutates the original? | No — works on a copy | Yes |
| Copies data | Copies the whole struct | Just the pointer |
| Large structs | Expensive copies | Cheap |
| Method set gained | Only `T` | `*T` **and** `T` methods |
| Works on non-addressable values | Yes | No |

The rules-of-thumb from the methods module, condensed:

- Mutates state → pointer.
- Struct is large or holds a mutex/slice/header → pointer.
- Small, immutable, read-only value (`Point`, `Color`, `Duration`) → value is fine.
- Unsure → pointer.

## Why value receivers live on copies

When you call a value-receiver method, the receiver is a **copy** of the argument. Mutating that
copy inside the method can't touch the caller's value. This is not a bug — it's the semantics:
value receivers promise "I will not change your data."

```go title="value-copy-is-a-copy.go"
import "fmt"

type Point struct{ X, Y int }

a := Point{1, 2}
b := a      // plain assignment also copies
b.X = 99
fmt.Println(a.X, b.X)
```

Prints `1 99`. Struct assignment is by value — so structs (and their receivers) are copies unless
you use a pointer.

## But beware: some values share state

Copying a struct whose fields are *references* copies the header, not the data. `bytes.Buffer`
holds a slice; copy the struct and both copies point at the same backing array. One "copy" can
write what the other sees:

```go title="shallow-copy-trap.go"
import ("bytes"; "fmt")

var orig bytes.Buffer
orig.WriteString("shared")
copy := orig                 // shallow copy: same backing storage
copy.WriteString("!")        // writes through the shared array
fmt.Println(orig.String(), copy.String())
```

Prints `shared shared!`. The moral: if a type owns mutable state (slices, maps, channels,
buffers), you usually want `*T`, not `T` — it's the difference between sharing a bank account and
photocopying the statement.

## Mutating through a pointer

Mutating through a pointer is explicit: you dereference to reach the real value. Method calls
make this convenient — calling `p.Shift(...)` on an addressable `p` auto-adds the `&`:

```go title="pointer-mutation.go"
import "fmt"

type Ledger struct{ Total int }

l := Ledger{}
lp := &l            // pointer to the original
lp.Total += 10      // field access through a pointer auto-dereferences
fmt.Println(l.Total)
```

```go eval=no
package main

import "fmt"

type Account struct{ balance int }

func (a *Account) Deposit(n int) { a.balance += n } // mutates the original
func (a Account) Balance() int   { return a.balance } // reads a copy (fine)

func main() {
    a := &Account{}
    a.Deposit(50)
    fmt.Println(a.Balance())
}
```

## Nil receivers: methods on nil must notice

A method with a pointer receiver can be called on a **nil pointer** without panicking — *as long
as the body doesn't dereference it*. That's occasionally useful (a tree with a nil node, a cache
with no backing store). Real Go:

```go eval=no
package main

import "fmt"

type Chain struct {
    Next *Chain
}

// Traverse handles a nil Chain gracefully.
func (c *Chain) Length() int {
    if c == nil {
        return 0
    }
    return 1 + c.Next.Length()
}

func main() {
    tail := &Chain{}                // Next == nil by default
    fmt.Println(tail.Length())      // 1
    var head *Chain
    fmt.Println(head.Length())      // 0 - nil receiver, method still runs
}
```

> [!trap]
> Wait: here `tail.Length()` calls `c.Next.Length()` where `c.Next` is nil — the method *doesn't*
> dereference first, it checks `c == nil`. But if a nil receiver reaches a *field* access or a
> method that does, you get a nil-pointer panic. Handle nil early, every time.

## The nil-pointer trap with interfaces

This is the most expensive bug in Go for newcomers, and it's a direct consequence of the
interface pair `(type, value)`:

- `var w io.Writer` → nil interface (no type).
- `var buf *bytes.Buffer = nil; var w io.Writer = buf` → **non-nil** interface holding a nil
  pointer.

```go title="typed-nil.go"
import ("bytes"; "fmt"; "io")

var buf *bytes.Buffer
var w io.Writer = buf        // (type *bytes.Buffer, value nil) - box is not empty
fmt.Println(w == nil)        // false
var x io.Writer
fmt.Println(x == nil)        // true
```

> [!warning]
> `if w != nil { w.Write(...) }` passes the guard but panics — the pointer inside is nil. When a
> type can legitimately be nil and will be stored in an interface, check it *before* storing, or
> check the concrete type with a type switch.

## The method-set gotcha (revisited with sharp teeth)

Interface satisfaction cares about **whose** method set has the methods:

- `T`'s method set: methods with value receivers only.
- `*T`'s method set: methods with value receivers **plus** pointer receivers.

So a pointer-receiver method bars the *value* `T` from an interface that needs it — even though
calling the method on an addressable `T` works fine:

```go eval=no
package main

import "fmt"

type Robot struct{ battery int }

func (r *Robot) Charge()        { r.battery += 10 }
func (r *Robot) Battery() int   { return r.battery }

type Powered interface {
    Charge()
    Battery() int
}

func main() {
    r1 := &Robot{}                 // *Robot has all methods -> satisfies
    var p Powered = r1
    p.Charge()
    fmt.Println(p.Battery())

    // r2 := Robot{}                 // value: Charge/Battery are pointer-receiver only
    // var p2 Powered = r2            // COMPILE ERROR: *Robot methods not in Robot's set
    // _ = p2
}
```

> [!key]
> If you define a method with a pointer receiver, the value you store in an interface must *also*
> be a pointer (or an addressable variable auto-addressed at the call site). When an interface
> assignment fails, check for pointer receivers first.

The standard library demonstrates the pattern you'll copy most: `*bytes.Buffer` (pointer) is an
`io.Writer`, `io.Reader`, and `fmt.Stringer` all at once. Almost every mutable, stateful type in
Go lives behind its pointer.

## Decision guide

1. Would keeping the value changed matter? → pointer.
2. Is the struct big (say ≥ 64 bytes) or holding a mutex/slice? → pointer.
3. Is the value immutable and tiny? → value is idiomatic.
4. Do you want both `T` and `*T` to satisfy an interface? → value receivers only — but then
   mutation is impossible, so think again.

> [!tip]
> Consistency beats cleverness: use the **same** receiver style across all methods of a type.
> Mixed styles compile, but they make the method set and interface satisfaction infuriating to
> reason about.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What best describes a value receiver (r T) M() when M mutates r?"
    type: single
    choices:
      - "The mutation is lost because r is a copy of the caller's value."
      - "The mutation reaches the original through a shared pointer."
      - "Go panics at compile time."
      - "Only the first field change survives."
    answer: [0]
    explanation: "A value receiver copies the receiver into the method; any mutation expires when the method returns."
    difficulty: 1
  - id: q2
    prompt: "A struct holds a slice and you copy the struct with :=. What do the two copies share?"
    type: single
    choices:
      - "Nothing: the copies are fully independent."
      - "Only the length and capacity headers."
      - "The backing array behind the slice (the header copies, the data is shared)."
      - "The stack memory of the original."
    answer: [2]
    explanation: "Assignments copy slice headers; both headers reference the same backing array, so writes by one 'copy' can appear in the other."
    difficulty: 3
  - id: q3
    prompt: "All methods of T use pointer receivers. Which values satisfy an interface requiring one of those methods?"
    type: single
    choices:
      - "T itself."
      - "*T only."
      - "Both T and *T."
      - "Neither."
    answer: [1]
    explanation: "Pointer-receiver methods belong only to *T's method set, so only *T satisfies the interface."
    difficulty: 3
  - id: q4
    prompt: "Calling a method on a nil pointer receiver (c *Chain) that begins with if c == nil { return 0 } — what happens?"
    type: single
    choices:
      - "Panics before the method body runs."
      - "The method runs and returns 0 without dereferencing."
      - "It always returns nil."
      - "The compiler rejects it."
    answer: [1]
    explanation: "Methods on nil pointers only panic if the body dereferences; a nil check at the top is safe and idiomatic."
    difficulty: 2
  - id: q5
    prompt: "var buf *bytes.Buffer (nil); var w io.Writer = buf. What is w == nil?"
    type: single
    choices:
      - "true"
      - "false — the interface holds both a concrete type and a nil value"
      - "It panics."
      - "It does not compile."
    answer: [1]
    explanation: "Assigning any value — even a nil pointer — fills the interface's (type, value) pair, so the interface itself is non-nil."
    difficulty: 2
```