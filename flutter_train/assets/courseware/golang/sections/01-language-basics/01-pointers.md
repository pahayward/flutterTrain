---
id: 01-pointers
title: "Pointers: & and *"
order: 1
section: 01-language-basics
language: golang
type: lesson
summary: "Address-of and dereference, why pointers exist, and pointers to structs."
tags: [pointer, dereference, address, memory, ampersand, struct]
prereqs: []
---

# Pointers: `&` and `*`

Almost every Go program leans on pointers. They are Go's way of saying "work
with the value that lives *over there* instead of copying it." This module
explains the two pointer operators, why pointers exist, and how they interact
with structs.

> [!key] **The two operators**
>
> - `&` (address-of) turns a variable into a pointer to that variable: `p := &x`.
> - `*` (dereference) goes *through* a pointer to read or write the value it
>   points at: `*p = 42`.

## What a pointer is

A pointer is just the **memory address** of a variable. Its type is spelled with
a star: `*int` is "pointer to int", `*string` is "pointer to string", `*Point`
is "pointer to a Point struct".

```go
import "fmt"
x := 21
p := &x
fmt.Println("x:", x)
fmt.Println("p points to address:", p)
fmt.Println("dereference *p ->", *p)
*p = 42
fmt.Println("after *p = 42, x is:", x)
```

`x` and the thing `p` points at are the **same storage**. Changing `*p`
changes `x`, because `p` does not copy `x` — it points to it.

> [!trap] **`*` means dereference on the right, type on the left**
>
> In `p := &x` the `&` creates a pointer. To *use* the pointed-at value you
> write `*p`. The two stars in `var p *int` and `*p = 3` do different jobs:
> the first declares "p is a pointer to int", the second writes through it.

## Why pointers exist

Go passes **copies** when you assign or call functions. Copying is safe and
cheap for small values, but it means the caller can never change the original.
Pointers exist because sometimes you want to:

- **Share and mutate** one value from many places (a counter, a config object).
- **Avoid copying** large structs, which would waste memory.
- **Represent "no value yet"** — a nil pointer is an explicit "nothing here".

The next example passes a struct pointer so a helper function can bump a
counter without copying it:

```go
import "fmt"
type Counter struct{ N int }
inc := func(c *Counter) {
	c.N++
}
c := Counter{N: 0}
inc(&c)
inc(&c)
inc(&c)
fmt.Println("count reached:", c.N)
```

Because `inc` receives a `*Counter`, the `c.N++` inside the function modifies
the *caller's* struct. If you passed `Counter` (not `*Counter`) it would modify
a copy and your count would stay `0`.

## Pointers to structs

Go lets you read and mutate struct fields through a pointer without an extra
dereference step: `pt.X = 10` works whether `pt` is a value or a `*Point`.

```go
import "fmt"
type Point struct{ X, Y int }
pt := Point{3, 4}
p := &pt
p.X = 10
fmt.Println("through pointer, pt is now:", pt.X, pt.Y)

a, b := 1, 2
swap := func(x, y *int) {
	*x, *y = *y, *x
}
swap(&a, &b)
fmt.Println("after swap a, b:", a, b)
```

> [!tip] **Convention: mutate large things through pointers**
>
> As you read more Go you will see `*Point`, `*Counter`, `*bytes.Buffer` —
> anything shared or expected to change. Functions that only *read* small
> values are written to receive plain values.

## The nil pointer

A pointer's zero value is `nil`, meaning "points at nothing." Dereferencing a
nil pointer causes a runtime panic, so check for nil before using it.

```go
import "fmt"
var p *int
fmt.Println("a nil pointer:", p)
if p == nil {
	fmt.Println("guard: p is nil, do not dereference")
}
```

> [!warning] **Never dereference nil**
>
> `var p *int; fmt.Println(*p)` would crash with a nil pointer dereference
> panic. Real programs guard pointer use with `if p != nil { ... }`.

## Summary

- `&x` gives you a pointer to `x`; `*p` reads or writes what `p` points to.
- Pointers share and mutate one value instead of copying it.
- Struct fields are reachable through pointers directly: `p.X`.
- The zero value of any pointer type is `nil`; dereferencing nil panics.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does the expression &x produce?"
    type: single
    choices:
      - "The value stored in x"
      - "A pointer to x (x's memory address)"
      - "A copy of x"
      - "The type of x"
    answer: [1]
    explanation: "&x is the address-of operator: it returns a pointer (*T) to the variable x."
    difficulty: 1

  - id: q2
    prompt: "After running these lines, what does the final fmt.Println print? x := 7; p := &x; *p = 12; fmt.Println(x)"
    type: single
    choices: ["7", "12", "&x", "an address"]
    answer: [1]
    explanation: "'*p = 12' writes through the pointer to the variable x, so x becomes 12."
    difficulty: 1

  - id: q3
    prompt: "type Point struct{ X, Y int }; pt := Point{1, 2}; q := &pt; q.Y = 9. What is pt.Y?"
    type: single
    choices: ["2", "9", "0", "&pt"]
    answer: [1]
    explanation: "Struct fields can be set through a pointer without dereferencing, so q.Y = 9 mutates the same struct that pt names."
    difficulty: 2

  - id: q4
    prompt: "What happens when you evaluate *p if p is a nil pointer?"
    type: single
    choices:
      - "Nothing; it yields the zero value"
      - "It returns nil"
      - "A runtime panic (nil pointer dereference)"
      - "It returns 0"
    answer: [2]
    explanation: "Dereferencing a nil pointer panics at runtime; guard with 'if p != nil' first."
    difficulty: 2
```