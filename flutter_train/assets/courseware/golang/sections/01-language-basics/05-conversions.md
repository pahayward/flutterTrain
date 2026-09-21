---
id: 05-conversions
title: "Type conversions and safety"
order: 5
section: 01-language-basics
language: golang
type: lesson
summary: "Explicit conversions, typed vs untyped constants, int/float, and string/byte conversions."
tags: [conversion, constants, typed, untyped, int, float, byte, string]
prereqs: [04-strings-runes]
---

# Type conversions and safety

Go is strict: it will **never** silently change the type of a value. This is a
feature — implicit conversions are where whole classes of bugs come from in
other languages. When you really want a different type, you say so with an
explicit **conversion**: `T(x)`.

> [!key] **The rule of thumb**
>
> `T(x)` converts the *value* `x` to type `T`. Nothing happens by magic, and
> the compiler complains the moment you mix incompatible types without a
> conversion.

## Explicit conversion between numeric types

`int` and `float64` are different types. `3 + 0.5` does not compile; you must
convert. Converting a float to int **truncates** toward zero (drops the
fraction) — it does not round.

```go
import "fmt"
pi := 3.999
n := int(pi)
fmt.Println("int(3.999) truncates to:", n)

a := 10
b := 3
f := float64(a) / float64(b)
fmt.Println("float division:", f)

num := 65
r := rune(num)
fmt.Printf("rune(65) prints as: %c\n", r)
```

> [!trap] **float -> int truncates, it never rounds**
>
> `int(pi)` for `pi := 3.999` yields 3, not 4. If you need rounding, round
> *before* converting (e.g. `math.Round`) — for now, just know that the
> fractional part is dropped.

## Overflow can wrap

Converting a big value into a smaller type does not stop at the boundary — it
wraps around modulo the target size. Always check your range.

```go
import "fmt"
big := 300
small := int8(big)
fmt.Println("int8(300) wraps to:", small)

var u uint8 = 255
u++
fmt.Println("uint8 255 + 1 wraps to:", u)
```

## Typed vs untyped constants

This is one of Go's elegant ideas. An **untyped constant** like `3` has no
fixed type until it is used, so it adapts to whatever type you assign it to. A
**typed** value never adapts.

```go
import "fmt"
const k = 3
var x float64 = k
var y int = k
var z int64 = int64(k)
fmt.Println("untyped const fits float64, int, int64:", x, y, z)

typed := 7
// var w float64 = typed   // compile error: typed int cannot hide in float64
var w float64 = float64(typed)
fmt.Println("typed value needs an explicit conversion:", w)
```

The commented line is illegal Go — it is shown only to make the contrast clear;
a *typed* variable `typed := 7` will not silently be used where a `float64` is
required.

> [!note] **Where this bites**
>
> `const a = 2; const b = 0.5; a*b` works (both untyped). But two *variables*
> of type `int` and `float64` cannot be multiplied together without a
> conversion.

## String ↔ `[]byte` and runes

Strings convert cleanly to byte slices and back. Each byte keeps its UTF-8
value; you can inspect or intercept bytes, then rebuild the string. Runes
convert to single-character strings with `string(r)`.

```go
import "fmt"
s := "Go!"
b := []byte(s)
fmt.Println("bytes:", b)
b[1] = 66
fmt.Println("edited string:", string(b))

back := string([]byte{104, 101, 108, 108, 111})
fmt.Println("rebuilt:", back)

r := '☃'
fmt.Println("runes to strings:", string(r) == "☃", len(string(r)))
```

## Conversion safety checklist

- Incompatible types → compile error; use `T(x)` explicitly.
- float → int truncates toward zero.
- Small types wrap on overflow (e.g. `int8(300)`).
- Untyped constants adapt; typed values require explicit conversion.
- `[]byte(s)` / `string(b)` round-trip exactly; string slicing still needs
  rune care (see Strings and runes).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "f := 9.75; n := int(f). What is n?"
    type: single
    choices: ["9.75", "10", "9", "a compile error"]
    answer: [2]
    explanation: "Converting a typed float to int truncates toward zero, dropping .75, so n is 9."
    difficulty: 1

  - id: q2
    prompt: "Which line compiles without an explicit conversion?"
    type: single
    choices:
      - "var f float64 = 3"
      - "var f float64 = typedInt (where typedInt := 3)"
      - "var f float64 = int64(3)"
      - "var f int = 3.5"
    answer: [0]
    explanation: "'3' is an untyped constant and adapts to float64. A typed int variable or int64 value needs an explicit conversion."
    difficulty: 3

  - id: q3
    prompt: "big := 300; small := int8(big). What is the result?"
    type: single
    choices:
      - "small == 300"
      - "The value wraps modulo 256 instead of staying 300"
      - "The program panics"
      - "It rounds to 300"
    answer: [1]
    explanation: "Converting into an 8-bit range wraps the value modulo 256 rather than clipping: int8(300) becomes 44."
    difficulty: 2

  - id: q4
    prompt: "Given b := []byte(\"Go\"), what does string(b) return?"
    type: single
    choices:
      - "\"Go\""
      - "a []byte again"
      - "the byte sequence 71 111"
      - "a compile error"
    answer: [0]
    explanation: "[]byte(s) and string(b) are exact inverses, so converting b back yields the original string Go."
    difficulty: 1
```