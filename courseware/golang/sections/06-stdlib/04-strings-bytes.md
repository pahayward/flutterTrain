---
id: 04-strings-bytes
title: strings, strconv, bytes
order: 4
section: 06-stdlib
language: golang
summary: String helpers, converting and parsing numbers, building strings, and strings.Builder.
tags: [strings, strconv, bytes, builder, parsing]
---

# strings, strconv, bytes

Strings appear in every program, and Go keeps the helpers in three focused
packages:

- `strings` — search, split, join, case, and trimming on `string`.
- `strconv` — convert between strings and numbers.
- `bytes` — like `strings`, but for `[]byte`, plus a growable buffer.

## Search and edit helpers (`strings`)

The meat of everyday string work:

- `strings.Contains(s, sub)` → bool
- `strings.HasPrefix(s, p)`, `strings.HasSuffix(s, p)` → bool
- `strings.Split(s, sep)` → `[]string`
- `strings.Join(parts, sep)` → `string`
- `strings.TrimSpace(s)`, `strings.ToUpper(s)`, `strings.ToLower(s)`
- `strings.ReplaceAll(s, old, new)`
- `strings.Index(s, sub)` → first position or `-1`

```go
import (
	"fmt"
	"strings"
)

s := "  Go, Rust, Go is everywhere  "
fmt.Println("trimmed:   [", strings.TrimSpace(s), "]")
fmt.Println("upper:     ", strings.ToUpper(strings.TrimSpace(s)))
fmt.Println("has Go:    ", strings.Contains(s, "Go"))

parts := strings.Split(strings.TrimSpace(s), ", ")
fmt.Println("parts:     ", parts)
fmt.Println("joined:    ", strings.Join(parts, " | "))
fmt.Println("replace:   ", strings.ReplaceAll(s, "Go", "Zig"))
fmt.Println("index of Rust:", strings.Index(s, "Rust"))
```

> [!key]
> `strings.Split` + `strings.Join` is the reverse pair that shows up in config
> parsing, CSV-ish inputs, and path handling. Learn the pair together.

## Strings are runes and bytes

A Go string is a read-only `[]byte`. Indexing gives you **bytes**, so walking
a string with `for i := range s` iterates byte positions, while a range loop
iterates runes. When you need per-character logic, range over the string:

```go
import "fmt"

s := "héllo"
fmt.Println("byte length:", len(s))
for i, r := range s {
	fmt.Printf("index %d → rune %q\n", i, r)
}
```

## Parsing and formatting numbers (`strconv`)

`strconv` is the bridge between text and numbers:

- `strconv.Atoi(s)` → `(int, error)` — the common "string to int".
- `strconv.ParseFloat(s, 64)` → `(float64, error)`.
- `strconv.Itoa(n)` → `string` — int to string.
- `strconv.FormatFloat(f, 'g', -1, 64)` → `string`.
- `strconv.ParseBool(s)` → `(bool, error)`.

```go
import (
	"fmt"
	"strconv"
)

age, err := strconv.Atoi("29")
fmt.Println("age:", age, "err:", err)

pi, err := strconv.ParseFloat("3.14159", 64)
fmt.Println("pi:", pi, "err:", err)

if e, err := strconv.Atoi("twelve"); err != nil {
	fmt.Println("bad parse → error:", err)
} else {
	fmt.Println(e)
}

fmt.Println("back to string:", strconv.Itoa(age))
ok, _ := strconv.ParseBool("true")
fmt.Println("bool parsed:", ok)
```

> [!trap]
> Every parse function returns `(value, error)`. Ignoring `err` and using the
> zero value silently is a classic source of "why is my count 0" bugs. Check
> the error.

## Building strings efficiently: strings.Builder

Appending with `+=` in a loop repeatedly allocates new strings. For anything
non-trivial, use `strings.Builder`, which grows a buffer internally:

```go
import (
	"fmt"
	"strings"
)

var b strings.Builder
for i := 1; i <= 5; i++ {
	fmt.Fprintf(&b, "item %d\n", i)
}
fmt.Print(b.String())
fmt.Println("builder length:", b.Len())
```

> [!tip]
> `strings.Builder` implements `io.Writer`, so you can hand it to anything
> that writes — including `fmt.Fprintf`, as above.

## Encoding without the string layer: `bytes`

`bytes` mirrors `strings` for `[]byte` and also provides `bytes.Buffer` — a
growable, in-memory byte sink that implements both `io.Reader` and
`io.Writer`. Use buffers when transforming binary-ish data (JSON, images,
compressed blobs) rather than juggling immutable strings.

```go
import (
	"bytes"
	"fmt"
)

var buf bytes.Buffer
buf.WriteString("alpha")
buf.WriteByte('-')
buf.WriteString("beta")

fmt.Println("buffer:", buf.String())
fmt.Println("upper: ", bytes.ToUpper(buf.Bytes()))
fmt.Println("split: ", bytes.Split(buf.Bytes(), []byte("-")))
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which call converts the string \"123\" into an int safely?"
    type: single
    choices:
      - "strconv.Atoi(\"123\")"
      - "string(\"123\")"
      - "int(\"123\")"
      - "strconv.Itoa(\"123\")"
    answer: [0]
    explanation: "strconv.Atoi parses a decimal string to (int, error). Itoa goes the other direction and takes an int."
    difficulty: 1
  - id: q2
    prompt: "What is the reverse operation of `strings.Split(s, \",\")`?"
    type: single
    choices:
      - "strings.Join(parts, \",\")"
      - "strings.ReplaceAll(s, \",\", \"\")"
      - "strings.Trim(s, \",\")"
      - "strings.Fields(s)"
    answer: [0]
    explanation: "Split breaks a string into parts; Join reassembles a []string into one string with the given separator."
    difficulty: 1
  - id: q3
    prompt: "Why should you prefer strings.Builder over `s += more` in a loop?"
    type: single
    choices:
      - "Builder strings are immutable"
      - "Appending with += repeatedly allocates; Builder grows one buffer"
      - "+= only works on []byte"
      - "They are identical in performance"
    answer: [1]
    explanation: "Each += allocates a brand-new string. Builder keeps one growable buffer, which is far cheaper in loops."
    difficulty: 2
  - id: q4
    prompt: "What does `len(\"café\")` return?"
    type: single
    choices:
      - "4"
      - "5"
      - "6"
      - "3"
    answer: [1]
    explanation: "len counts bytes, not runes; 'é' is 2 bytes in UTF-8, so café is 4 + 1 bytes = 5."
    difficulty: 3
```