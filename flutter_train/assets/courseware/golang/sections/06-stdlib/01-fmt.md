---
id: 01-fmt
title: "fmt: printing verbs"
order: 1
section: 06-stdlib
language: golang
summary: The fmt package verbs, Sprintf/Errorf, width and precision, and Stringer interaction.
tags: [fmt, printf, formatting, verbs, stringer]
---

# fmt: printing verbs

Almost every Go program prints something, and `fmt` is the package that does
it. Beyond `Println`, `fmt` gives you **format verbs** that control exactly how
a value appears on screen. Learn these once and you will read and write Go
output fluently.

## The core verbs

A verb always starts with `%`. The three you will use most:

| Verb | Meaning | Example output for `42.5` or `"Go"` |
|---|---|---|
| `%v` | default representation (value) | `42.5` / `Go` |
| `%T` | type of the value | `float64` / `string` |
| `%d` | base-10 integer | `42` |
| `%s` | string | `Go` |
| `%q` | quoted string (safe to paste) | `"Go"` |
| `%x` | lowercase hexadecimal | `2a` |
| `%f` | decimal float | `42.500000` |
| `%t` | boolean | `true` |

> [!key]
> `%v` prints "whatever makes sense", `%T` prints the *type*, and the typed
> verbs (`%d`, `%s`, `%x`, ...) print a *specific* representation. When you
> need exact output, use the typed verb — never assume `%v`'s shape.

```go
import "fmt"

n := 42
name := "Go"
pi := 3.14159

fmt.Printf("n=%d name=%s pi=%f\n", n, name, pi)
fmt.Printf("defaults: %v | %v | %v\n", n, name, pi)
fmt.Printf("types:    %T | %T | %T\n", n, name, pi)
fmt.Printf("quoted:   %q\n", name)
fmt.Printf("hex:      %x\n", n)
fmt.Printf("bool:     %t\n", true)
```

> [!note]
> The runner wraps each snippet in `func main()`, so plain statements like
> `n := 42` are exactly what you write; `import` lines are hoisted for you.

## Width and precision

After `%` you can add a number (minimum width) and a `.N` (precision):

- `%5d` → integer padded to at least 5 characters wide.
- `%.2f` → float with exactly 2 decimals.
- `%8.3f` → width 8, precision 3.
- `%-5d` → the `-` left-aligns within the width.

```go
import "fmt"

fmt.Printf("|%5d|\n", 42)    // right-aligned, width 5
fmt.Printf("|%-5d|\n", 42)    // left-aligned, width 5
fmt.Printf("|%05d|\n", 42)    // zero-padded
fmt.Printf("|%.2f|\n", 3.14159)
fmt.Printf("|%8.3f|\n", 3.14159)
```

> [!tip]
> The width starts a "minimum" — it pads, never truncates normal values. For a
> max cap, put the precision before the verb: `%.3s` shows at most 3
> characters of a string.

## Sprintf and Errorf — formatted strings

`Printf` writes to stdout, but you often want the string itself:

- `fmt.Sprintf(format, args...)` returns a formatted string.
- `fmt.Errorf(format, args...)` returns an `error` value with the formatted message.

`Errorf` is everywhere in Go — it's the idiomatic way to build useful error
messages that carry context.

```go
import "fmt"

greeting := fmt.Sprintf("Hello, %s! You have %d new messages.", "Ada", 7)
fmt.Println(greeting)

distance := 384400.0
report := fmt.Sprintf("Moon distance: %.0f km", distance)
fmt.Println(report)

err := fmt.Errorf("value %d out of range", 999)
fmt.Println("error:", err)
```

> [!warning]
> `Printf` does **not** append a newline; `Println` does. A classic bug is
> `fmt.Printf("hello")` and wondering why the next prompt is glued to the end.

## Stringer: `fmt` respects your types

If a type implements the `String()` method (the `fmt.Stringer` interface), `fmt`
uses it for `%v` and `%s`. This is one of the friendliest conversions in Go —
you control how your own type displays. Some stdlib types already do this; you
can see `fmt` preferring `String()` in action with `time.Duration` (it prints
as `1m30s`) and `time.Time`:

```go
import (
	"fmt"
	"time"
)

d := 90 * time.Second
t := time.Date(2026, time.September, 17, 14, 30, 0, 0, time.UTC)
fmt.Println("duration:", d)         // String() gives 1m30s, not raw ns
fmt.Println("time via %v:", t)      // String() gives the default layout
```

Here is the full pattern for your own types — a `String()` method that makes
`%v`, `%s`, and `Println` all use your format:

```go eval=no
import "fmt"

type Celsius float64

func (c Celsius) String() string {
	return fmt.Sprintf("%.1f°C", float64(c))
}

// main...
b := Celsius(36.6)
fmt.Println("body temp:", b) // calls String()
```

> [!note] Why this block is `eval=no`
> The on-device runner wraps every snippet inside `func main()`, and Go does
> not allow method declarations inside a function body. The pattern above is
> exactly how you'd write it in a real project; the runnable examples show the
> same ideas with statements only.

> [!trap]
> Never call `fmt` on the same type *inside* its own `String()` using the
> identical verb that would print the type again — that recurses forever.

## The escaping escape hatch

When `%v` and friends aren't enough, remember Go's built-in **alternates**:

- `%+v` shows struct field names.
- `%#v` shows a Go-syntax representation of the value (great for debugging).

```go
import "fmt"

type Point struct {
	X, Y int
	label string
}

p := Point{3, 4, "origin-adjacent"}
fmt.Printf("%v\n", p)
fmt.Printf("%+v\n", p)
fmt.Printf("%#v\n", p)
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which verb prints the *type* of a value?"
    type: single
    choices:
      - "%t"
      - "%v"
      - "%T"
      - "%d"
    answer: [2]
    explanation: "The uppercase %T prints the type of the argument (e.g. float64, string); %t is for booleans."
    difficulty: 1
  - id: q2
    prompt: "What does `fmt.Printf(\"%6.2f\", 3.14159)` print?"
    type: single
    choices:
      - "  3.14"
      - "3.14159"
      - "  3.14159"
      - "3.14"
    answer: [0]
    explanation: "%.2f gives exactly 2 decimals, and width 6 pads on the left, so the output is '  3.14' (width 6)."
    difficulty: 2
  - id: q3
    prompt: "What is the difference between Printf and Sprintf?"
    type: single
    choices:
      - "Printf prints to stdout; Sprintf returns the formatted string"
      - "Sprintf prints to a file; Printf prints to stdout"
      - "Printf adds a newline; Sprintf does not"
      - "They are identical"
    answer: [0]
    explanation: "Sprintf only formats and returns the string; Printf writes it to standard output."
    difficulty: 1
  - id: q4
    prompt: "Your type has a method `func (p PanicPoint) String() string`. What happens with `%v` and `%s`?"
    type: single
    choices:
      - "fmt panics at compile time"
      - "fmt calls the field names instead"
      - "fmt uses String() to render the value"
      - "You must wrap the value in string() first"
    answer: [2]
    explanation: "fmt.Stringer is honored by %v and %s: the String() method controls the representation."
    difficulty: 2
```