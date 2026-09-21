---
id: 02-interfaces-basics
title: "Interfaces I: structural typing"
order: 2
section: 04-methods-interfaces
language: golang
summary: Declaring interfaces, implicit satisfaction without 'implements', and how values flow into interface variables.
tags: [interfaces, structural-typing, duck-typing, interface-value]
prereqs: [01-methods]
---

# Interfaces I: structural typing

> [!key]
> An **interface** is a set of method names. Any type whose method set contains those methods
> **automatically** satisfies it — no `implements`, no explicit opt-in.

## What problem do interfaces solve?

Most OOP languages build polymorphism on *declared* relationships: a class **extends** a base
class or implements an interface, and the compiler checks the declaration. Go refuses that model.
Why? Because it forces the *author of a type* to know, in advance, every abstract contract that
might ever want to use it.

Go flips the responsibility: the **consumer** declares the interface, and the compiler checks
compatibility structurally — by comparing method sets. If your type happens to have a method
called `Read([]byte) (int, error)`, it is an `io.Reader`, whether you planned it or not. This is
*structural typing* (often called duck typing at compile time): "if it walks like a duck and
quacks like a duck, it's a duck."

That single decision is why the Go standard library can mix and match so freely: `*os.File`,
`bytes.Buffer`, `strings.Reader`, `net.Conn`, `gzip.Reader` all satisfy `io.Reader` without any
of them knowing about each other.

## Declaring an interface

An interface declaration lists method signatures:

```go
type Speaker interface {
    Speak() string
}
```

To satisfy it you need exactly one method: `Speak() string`. Nothing else. Extra methods don't
hurt — interfaces describe a *subset* of behavior.

## Implementing without 'implements'

Because there's no keyword, the only proof of implementation is the method set itself. Here the
standard library satisfies an interface *we* invented. `errors.New` returns a value whose method
set includes `Error() string`, so it drops into our `Reporter` interface instantly:

```go title="implicit-satisfaction.go"
import ("errors"; "fmt")

type Reporter interface{ Error() string }

first := errors.New("first error")
wrapped := fmt.Errorf("second: %w", first)

var r Reporter = wrapped   // no 'implements' anywhere
fmt.Println(r.Error())
```

> [!note]
> `errors.New` and `fmt.Errorf` both return the standard `error` interface — a value is "born" as
> an interface. The structural point is that its concrete type (*errorString / *wrapError) carries
> an `Error() string` method, which is all our `Reporter` demands.

## One interface, many concrete types

The real power: assign *different* concrete types to the *same* interface variable, and call the
same method on whichever one it currently holds. `*strings.Builder` and `time.Duration` are
unrelated — yet both have a `String() string` method, so both are `Stringer`s:

```go title="polymorphism.go"
import ("fmt"; "strings"; "time")

type Formatter interface{ String() string }

var sb strings.Builder
sb.WriteString("built")
d := time.Hour

var f1 Formatter = &sb   // *strings.Builder has String()
var f2 Formatter = d     // time.Duration has String()

fmt.Println(f1.String(), f2.String())
```

At run time the interface variable stores the concrete type alongside the value. Calls on `f1` and
`f2` dispatch to the *actual* type each holds.

> [!tip]
> This is polymorphism without inheritance: the types don't share a parent, they share a
> behavior. New concrete types slot into existing interfaces the moment their method sets line up.

## An interface value is a pair: (type, value)

Think of an interface variable as a small box holding **two** pieces of information: the dynamic
*type* of what's inside, and the *value* itself.

- An empty interface *variable* is `nil` (no type, no value).
- Assigning a value puts both in the box: type + value.
- Assigning a **typed nil pointer** puts a *type* in the box but a *nil value* — and the
  interface is no longer `== nil`. This is the classic "nil interface is not nil" trap.

```go title="nil-interface-trap.go"
import ("bytes"; "fmt"; "io")

var buf *bytes.Buffer
var w io.Writer = buf    // box holds (*bytes.Buffer, nil)

fmt.Println(w == nil)    // false! the box knows its type
var x io.Writer
fmt.Println(x == nil)    // true - empty box
```

Prints `false` then `true`.

> [!trap]
> An interface holding a nil pointer is not a nil interface. Code like `if w == nil` will happily
> call `w.Write` and then crash inside a nil receiver. Guard with a typed check, or never store a
> possibly-nil pointer into an interface you'll test for nil.

## Empty interface `any`

An interface with **zero methods** says "I know nothing about this value." Every type satisfies
it — including `int`, `string`, and pointers. `any` is the modern alias for `interface{}` and is
used where a value has unknown or mixed nature (JSON blobs, generic containers, logging):

```go title="empty-interface.go"
import "fmt"

var v any = 42
fmt.Println(v)
v = "now a string"
fmt.Println(v)
```

To use the value, assert its type back out with the comma-ok form:

```go title="type-assertion.go"
import "fmt"

var v any = 42
n, ok := v.(int)
fmt.Println(n, ok)
```

`ok` is `false` if the type doesn't match — it never panics.

> [!key]
> The empty interface is a **dead end** in a different sense: it tells readers nothing about a
> function's contract. Prefer specific interfaces (small, meaningful method sets) over `any`
> everywhere except genuinely heterogeneous data.

## What an interface says — and what it doesn't

When a function takes `io.Reader`, it announces only "give me something I can Read() from". It does
**not** promise the value is a file, a buffer, or a socket — and that's precisely the point. Anyone
can provide any value with the method set; caller and implementation stay decoupled.

> [!warning]
> Satisfaction is checked at compile time against the **method set** — and the method-set gotcha
> from the previous module applies: if `Read` is defined on `*T`, then `*T` satisfies `io.Reader`
> but a stored-by-value `T` does not. When an assignment won't compile, you are almost always
> looking at a pointer-receiver method.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How does a type declare that it implements an interface?"
    type: single
    choices:
      - "With the keyword 'implements', as in 'type Foo implements Bar'."
      - "By listing the interface in the type declaration."
      - "Automatically, by having all the interface's methods in its method set."
      - "By extending a base class that already implements it."
    answer: [2]
    explanation: "Go is structurally typed: satisfaction is implicit, based purely on the method set, so there is no 'implements' keyword."
    difficulty: 1
  - id: q2
    prompt: "type Writer interface { Write([]byte) (int, error) } and type X has method func (x *X) Write(...). Which of these compile?"
    type: single
    choices:
      - "var w Writer = X{}"
      - "var w Writer = &X{}"
      - "Both compile."
      - "Neither compiles."
    answer: [1]
    explanation: "Write has a pointer receiver, so *X has the method but X (value) does not — the value does not satisfy Writer."
    difficulty: 3
  - id: q3
    prompt: "What is stored inside a non-nil interface variable such as var s Speaker = d?"
    type: single
    choices:
      - "Only a copy of d's methods."
      - "The concrete type of d and d's value."
      - "A pointer to the interface declaration."
      - "Only a string describing d's type."
    answer: [1]
    explanation: "An interface value is a two-part box: the dynamic (concrete) type and the value, enabling dispatch when a method is called."
    difficulty: 2
  - id: q4
    prompt: "func (p *Person) Greet() string. var p *Person (nil). var s Speaker = p. What is s == nil?"
    type: single
    choices:
      - "true"
      - "false — the box holds a typed nil pointer, so s is not the nil interface"
      - "It panics."
      - "The code does not compile."
    answer: [1]
    explanation: "Assigning a nil pointer stores its type too; s == nil is false even though the pointer inside is nil."
    difficulty: 3
  - id: q5
    prompt: "Which value satisfies the empty interface 'any'?"
    type: single
    choices:
      - "Only pointers and structs."
      - "Only values of interface type."
      - "Every type: any has zero methods, so nothing is required."
      - "Only declared types with at least one method."
    answer: [2]
    explanation: "any/interface{} declares no methods, so every Go type qualifies automatically."
    difficulty: 1
```