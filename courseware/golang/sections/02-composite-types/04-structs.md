---
id: 04-structs
title: Structs
order: 4
section: 02-composite-types
language: golang
summary: "Named types with fields, literals, field access, value semantics, anonymous structs."
tags: [struct, field, named-type, anonymous-struct, value-type]
---

# Structs

A **struct** is a composite type that groups named fields of different types
into a single value. Structs are the backbone of data modeling in Go.

## Defining a struct type

```go
type Point struct {
    X float64
    Y float64
}

p := Point{X: 3.0, Y: 4.0}
print("x:", p.X, " y:", p.Y, "\n")
```

## Struct literals

Go offers two forms:

```go
type Person struct {
    Name string
    Age  int
}

// Named fields — clear and safe
p1 := Person{Name: "Ada", Age: 36}

// Positional — order matters, less readable
p2 := Person{"Linus", 50}

print(p1.Name, " ", p1.Age, "\n")
print(p2.Name, " ", p2.Age, "\n")
```

> [!tip]
> Always prefer named-field literals (`Person{Name: "Ada", Age: 36}`).
> Positional literals break silently if you reorder or add fields later.

## Field access

Dot notation accesses fields. Fields are **capitalized** to be exported
(visible outside the package); lowercase fields are package-private.

```go
type Rect struct {
    Width  float64
    Height float64
}

r := Rect{Width: 5.0, Height: 3.0}
area := r.Width * r.Height
print("area:", area, "\n")
```

## Structs as values

Like arrays, structs are **value types**. Assignment copies all fields:

```go
type Color struct {
    R, G, B int
}

c1 := Color{R: 255, G: 128, B: 0}
c2 := c1
c2.R = 0

print("c1.R:", c1.R, " c2.R:", c2.R, "\n")
```

Modifying `c2` does not affect `c1`. To share data, use pointers to structs:

```go
type Color2 struct {
    R, G, B int
}

c3 := &Color2{R: 100, G: 100, B: 100}
c4 := c3
c4.R = 0
print("c3.R:", (*c3).R, "\n")
```

> [!note]
> In standard Go, `c3.R` and `(*c3).R` are equivalent — the compiler
> auto-dereferences struct pointers. Some interpreters require the explicit
> `(*c3).R` form, so prefer it when writing portable snippets.

## Zero value

Every field in a struct gets its type's zero value when omitted:

```go
type Config struct {
    Host    string
    Port    int
    Debug   bool
}

cfg := Config{}
print("host:", cfg.Host, " port:", cfg.Port, " debug:", cfg.Debug, "\n")
```

## Anonymous structs

Sometimes you need a quick, one-off grouping without a named type:

```go
point := struct {
    X, Y int
}{X: 10, Y: 20}

print("x:", point.X, " y:", point.Y, "\n")
```

Anonymous structs are useful for small, localized data structures and in tests.

> [!warning]
> Anonymous structs cannot be compared with `==` even if they have identical
> field layouts. Use a named type if you need comparison.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the zero value of a `string` field in a struct?"
    type: single
    choices:
      - "`nil`"
      - "`\"0\"`"
      - "`\"\"` (empty string)"
      - "undefined"
    answer: [2]
    explanation: "Every Go type has a zero value. For strings it is the empty string `\"\"`, not nil."
    difficulty: 1
  - id: q2
    prompt: "Why are named-field struct literals preferred over positional ones?"
    type: single
    choices:
      - "They run faster"
      - "They are less verbose"
      - "They are resilient to field reordering and additions"
      - "Positional literals are not allowed in Go"
    answer: [2]
    explanation: "Positional literals depend on field order. Adding or reordering fields silently breaks the code. Named fields are self-documenting and safe."
    difficulty: 1
  - id: q3
    prompt: "What happens when you assign one struct to another?"
    type: single
    choices:
      - "Both variables share the same fields"
      - "A complete copy of all fields is made"
      - "Only exported fields are copied"
      - "A compile error occurs"
    answer: [1]
    explanation: "Structs are value types. Assignment copies every field. Use a pointer to share data."
    difficulty: 2
  - id: q4
    prompt: "What is an anonymous struct?"
    type: single
    choices:
      - "A struct with no exported fields"
      - "A struct defined inline without a named type"
      - "A struct initialized with nil values"
      - "A struct embedded in another struct"
    answer: [1]
    explanation: "An anonymous struct is defined and instantiated in one expression: `s := struct{ X int }{X: 1}`. It has no reusable type name."
    difficulty: 2
```
