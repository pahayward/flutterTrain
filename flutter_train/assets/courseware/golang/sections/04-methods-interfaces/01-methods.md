---
id: 01-methods
title: Methods
order: 1
section: 04-methods-interfaces
language: golang
summary: What a method is, how receivers bind behavior to types, and the value vs pointer receiver trade-offs.
tags: [methods, receivers, method-set]
prereqs: []
---

# Methods

> [!key]
> A **method** is a function with a special leading parameter — the **receiver** — that binds the
> function to a named type. In Go you don't call `Speak(d)`, you call `d.Speak()`.

## What problem do methods solve?

Functions are great, but real programs are full of values that carry state: a `bytes.Buffer`
holding buffered bytes, a `time.Duration` holding nanoseconds, a customer record holding a name
and balance. If every operation on that value is a free function, you end up with a zoo of names —
`writeToBuffer(buf, data)`, `bufferLen(buf)`, `bufferToString(buf)`. The "thing" is split apart
from its operations.

Methods bundle the **operations with the type**, so the call site reads naturally: `buf.Write(data)`,
`buf.Len()`, `buf.String()`. The type announces "here is everything you can do with me." That is
the same motivation behind classes in other languages — minus inheritance, which Go deliberately
leaves out (you'll see why in the composition module).

## Over 5 minutes: calling methods in the sandbox

The app's Go sandbox runs inside a `func main() {}` body, so it can show you real method calls made
by the standard library. `bytes.Buffer` is a named type with several methods — `WriteString`,
`Len`, and `String`:

```go title="buffer-methods.go"
import ("bytes"; "fmt")

var buf bytes.Buffer        // a value of the named type bytes.Buffer
buf.WriteString("Go ")      // method call: receiver is buf
buf.WriteString("methods")  // WriteString takes a pointer receiver
fmt.Println(buf.Len())      // int method, value returned
fmt.Println(buf.String())   // renders the buffered bytes as a string
```

Run it: `14` then `Go methods`.

> [!note]
> The sandbox writes code inside `func main()`, so methods **on new types you declare yourself**
> can't be defined on-device (Go only allows methods at package level). You'll see real
> method *declarations* in the read-only examples below — those run in any real Go project —
> while the runnable sandbox examples show the same ideas using standard-library types.

## The anatomy of a method declaration

Here is a complete, runnable-in-Go program (read-only here):

```go eval=no
package main

import "fmt"

type Bank struct {
    balance int
}

// Deposit has a pointer receiver: it must change the balance.
func (b *Bank) Deposit(amount int) {
    b.balance += amount
}

// Balance has a value receiver: it only reads the struct.
func (b Bank) Balance() int {
    return b.balance
}

func main() {
    acct := &Bank{}
    acct.Deposit(100)
    fmt.Println(acct.Balance())
}
```

`func (b *Bank) Deposit(...)` reads as: "a function named `Deposit`, attached to the type
`*Bank`". The receiver `b` inside the body is just a local variable — a name you choose — that
holds the value the method was called on.

## Why methods differ from functions

- **Same name, different type.** Two unrelated types can both have a `String` method. There's no
  collision because the receiver is part of the identity. With free functions you'd need
  `bufferToString` vs `durationToString`.
- **No overloading.** Within *one* type, you cannot define two methods with the same name. If you
  need a different behavior, pick a different name (`Bytes()` vs `String()`).
- **The type announces its contract.** A value of type `time.Duration` *is* the set of its
  methods. Anyone reading `d.String()` knows exactly what they get.

`time.Duration` is the classic example of a method that exists on a tiny scalar type. The value
stores nanoseconds; the method renders it human-readably:

```go title="duration-stringer.go"
import ("fmt"; "time")

d := 90 * time.Second          // time.Duration: nanoseconds underneath
fmt.Println(d.String())        // explicit call
fmt.Println(d)                 // fmt calls String automatically
```

Prints `1m30s` twice.

A method can also be detached from its receiver as a **method value** — you capture the receiver
up front, then call it later:

```go title="method-value.go"
import ("bytes"; "fmt")

var buf bytes.Buffer
buf.WriteString("hi")
snap := buf.String    // method value: binds buf to String
fmt.Println(snap())   // same result as buf.String()
```

## Value receivers vs pointer receivers

The receiver type decides whether the method can modify the value it is called on:

| Receiver | Can mutate the original? | Copies on call? | Typical use |
|---|---|---|---|
| `func (b Bank) ...` | No — operates on a copy | Copies the whole value (structs) | reads, pure logic, small types |
| `func (b *Bank) ...` | Yes — operates on the original | No copy, just a pointer | writes, large structs, anything holding mutable state |

```go eval=no
package main

import "fmt"

type Counter struct{ n int }

func (c Counter) Value() int { return c.n }      // reads: value receiver
func (c *Counter) Inc()      { c.n++ }           // writes: pointer receiver
func (c Counter) Bump()      { c.n++ }           // lost! n++ hits a copy

func main() {
    c := Counter{}
    c.Bump()
    fmt.Println(c.Value())   // 0 - the increment was thrown away

    c.Inc()
    fmt.Println(c.Value())   // 1 - pointer receiver reached the real value
}
```

> [!trap]
> A value receiver takes a **copy**. If the method mutates the receiver, the change is lost the
> moment the method returns. When a method can change state, or the type contains a mutex or a
> slice header you want to control, use a pointer receiver.

## Auto-address: value receiver vs pointer receiver calls

The receiver doesn't have to match the calling value. If a variable is *addressable*, Go will
silently add the `&` so you can call `c.Inc()` on `c Counter` even though the receiver is
`*Counter`:

```go eval=no
package main

import "fmt"

type Point struct{ X, Y int }
func (p *Point) Shift(dx, dy int) { p.X += dx; p.Y += dy }

func main() {
    p := Point{1, 2}
    p.Shift(3, 4)     // OK: Go uses &p automatically
    fmt.Println(p.X, p.Y)
}
```

The reverse does **not** happen: a value-receiver method can sometimes apply to a pointer via
`(*v).Method()`, but a pointer-receiver method needs something addressable. Non-addressable
expressions like `Point{1,2}.Shift(3,4)` or function call results cannot be auto-addressed.

## Method sets: which receivers come along?

The **method set** of a type is the collection of methods callable on it.

- `T` (value) has methods with receivers `T` only.
- `*T` (pointer) has methods with receivers `T` *and* `*T`.

This asymmetry is the single most important gotcha when interfaces come into play — you'll meet it
head-on in the interface modules. Keep the table:

> [!key]
> `*T`'s method set ⊇ `T`'s method set. If a method has a pointer receiver, then only `*T`
> (or an addressable `T`) can promise to implement an interface requiring that method.

## Choosing a receiver — quick guidance

- **Mutates state** → pointer.
- **Large struct** (say, a multi-hundred-byte record or one with mutex/slice fields) → pointer.
- **Read-only, small, immutable value** (a Point, a Duration, a Color) → value is fine and
  faster in some paths.
- **Not sure** → pointer. It's the safer default for anything you pass around and change.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Select the correct method declaration for attaching Favorite to the type Dog."
    type: single
    choices:
      - "func Dog.Favorite(string)"
      - "func (d Dog) Favorite(food string)"
      - "func Favorite(d Dog, food string)"
      - "func (d, food) Favorite(Dog string)"
    answer: [1]
    explanation: "A method lists the receiver in parentheses before the method name: func (d Dog) Favorite(food string)."
    difficulty: 1
  - id: q2
    prompt: "A method has a value receiver and increments a field of the receiver. What happens to the original value?"
    type: single
    choices:
      - "The original is changed because the receiver shares memory."
      - "The original is unchanged: the method worked on a copy."
      - "The program does not compile."
      - "Only the first increment is kept."
    answer: [1]
    explanation: "A value receiver copies the value into the method; field changes vanish when the method returns."
    difficulty: 2
  - id: q3
    prompt: "Which of these calls is valid given func (p *Point) Shift(dx, dy int) and the local variable p := Point{1, 2}?"
    type: single
    choices:
      - "p.Shift(1, 1) — Go auto-takes the address of the addressable p."
      - "p.Shift(1, 1) — this is a compile error."
      - "Shift(p, 1, 1)"
      - "(&p).Shift is required; no other form works."
    answer: [0]
    explanation: "Addressable variables are auto-addressed, so p.Shift(1, 1) is equivalent to (&p).Shift(1, 1)."
    difficulty: 2
  - id: q4
    prompt: "Why do methods and free functions differ most importantly in Go?"
    type: single
    choices:
      - "Methods are always faster than functions."
      - "Methods bind operations to a named type and get the receiver as part of their identity, so unrelated types can share method names."
      - "Free functions cannot return values."
      - "Methods cannot be called outside a package."
    answer: [1]
    explanation: "Receiver binding is the defining trait: the type is part of the method's identity, enabling String(), Len(), etc. on unrelated types."
    difficulty: 1
  - id: q5
    prompt: "Which statement about method sets is correct?"
    type: single
    choices:
      - "T and *T always have identical method sets."
      - "*T includes T's value-receiver methods plus *T's pointer-receiver methods."
      - "Only T, never *T, can satisfy an interface."
      - "Pointer-receiver methods are also added to T's method set automatically."
    answer: [1]
    explanation: "The pointer type's method set is a superset: value-receiver methods also count on *T, while pointer-receiver methods count only on *T (or addressable T values)."
    difficulty: 3
```