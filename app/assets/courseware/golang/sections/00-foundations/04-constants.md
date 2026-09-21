---
id: 04-constants
title: "Constants and iota"
order: 4
section: 00-foundations
language: golang
summary: "const, typed/untyped constants, iota pattern"
tags: [constants, iota, typed-constants]
---

# Constants and iota

Constants in Go are values determined at **compile time**. They can't be
changed after declaration, and the compiler can inline them directly into
generated code.

## Declaring constants

```go
const Pi = 3.14159
const MaxRetries = 3
```

Use `const` the same way you'd use `var`, but the value must be assignable
at compile time — no function calls, no runtime computation.

### Typed vs untyped constants

```go
const Speed = 100          // untyped — can be used with any compatible type
const Limit int = 50       // typed — explicitly int
```

> [!key] Untyped constants are flexible
> An untyped constant like `100` can be used as an `int`, `float64`, or even
> assigned to a custom type — the compiler picks the right one.

### Typed constants prevent mistakes

```go eval=no
const Timeout float64 = 30.0
var x int = Timeout // compile error: can't assign float64 to int
```

> [!note] Why this block is non-runnable
> This snippet deliberately contains a type mismatch that would fail
> compilation. It illustrates that typed constants enforce type safety at
> compile time.

## The `iota` pattern

`iota` is a special identifier that **auto-increments** inside a `const` block.
It's the idiomatic way to create enums and flag sets.

```go
const (
    Sunday = iota   // 0
    Monday          // 1
    Tuesday         // 2
    Wednesday       // 3
    Thursday        // 4
    Friday          // 5
    Saturday        // 6
)
```

Each line after the first inherits the `iota` expression and increments by 1.
You can use expressions with `iota`:

```go
const (
    _  = iota             // skip 0
    KB = 1 << (10 * iota) // 1 << 10 = 1024
    MB                    // 1 << 20 = 1048576
    GB                    // 1 << 30
)
```

```go
import "fmt"

const (
    Red = iota
    Green
    Blue
)
fmt.Println("Red:", Red)
fmt.Println("Green:", Green)
fmt.Println("Blue:", Blue)
```

```go
import "fmt"

const (
    _  = iota
    KB = 1 << (10 * iota)
    MB
    GB
)
fmt.Println("KB:", KB)
fmt.Println("MB:", MB)
fmt.Println("GB:", GB)
```

> [!tip] Use `iota` for anything sequential
> Bit flags, enum values, error codes — if the values form a natural sequence,
> `iota` keeps them in sync and prevents manual numbering errors.

> [!trap] `iota` resets per block
> Each `const (...)` block starts `iota` at 0 again. Don't rely on continuity
> across separate `const` blocks.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the value of `iota` on the second line inside a `const` block?"
    type: single
    choices:
      - "0"
      - "1"
      - "2"
      - "Undefined"
    answer: [1]
    explanation: "`iota` starts at 0 on the first line and increments by 1 on each subsequent line, so the second line is 1."
    difficulty: 1
  - id: q2
    prompt: "Can a constant in Go hold the result of a function call?"
    type: single
    choices:
      - "Yes, if the function is pure"
      - "Yes, if the function returns a constant"
      - "No — constants must be assignable at compile time"
      - "Only if the function is in the same package"
    answer: [2]
    explanation: "Constants must be compile-time expressions. Function calls are evaluated at runtime, so they can't be used in `const` declarations."
    difficulty: 1
  - id: q3
    prompt: "What is the output of this code?\n```go\nconst (\n    A = iota\n    B\n    C\n)\nfmt.Println(C)\n```"
    type: single
    choices:
      - "0"
      - "1"
      - "2"
      - "3"
    answer: [2]
    explanation: "iota starts at 0 for A, 1 for B, and 2 for C."
    difficulty: 2
  - id: q4
    prompt: "Which is the idiomatic way to define a set of error codes 1, 2, 3 in Go?"
    type: single
    choices:
      - "`const (A = 1; B = 2; C = 3)`"
      - "`const (A = iota + 1; B; C)`"
      - "`var (A = 1; B = 2; C = 3)`"
      - "`let A = 1, B = 2, C = 3`"
    answer: [1]
    explanation: "`iota + 1` starts the sequence at 1 and auto-increments, which is the idiomatic Go pattern for 1-based enums."
    difficulty: 2
```
