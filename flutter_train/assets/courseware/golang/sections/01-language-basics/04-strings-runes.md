---
id: 04-strings-runes
title: "Strings and runes"
order: 4
section: 01-language-basics
language: golang
type: lesson
summary: "UTF-8, the rune type, byte indexing, slicing, and the classic length traps."
tags: [string, rune, byte, utf8, unicode, slice]
prereqs: [01-pointers]
---

# Strings and runes

Go strings are **sequences of bytes** that hold UTF-8 encoded text. That one
fact explains almost every surprise beginners hit: `len` says something you do
not expect, `s[0]` is not "the first character", and slicing can cut a
character in half.

> [!key] **Vocabulary**
>
> - **Byte** — one 8-bit unit. A string is a `[]byte`-like read-only blob.
> - **Rune** — one Unicode code point, stored as an `int32`.
> - **UTF-8** — the variable-length encoding Go uses: ASCII characters take 1
>   byte; `é` takes 2; CJK characters like `世` take 3.

## `len()` counts bytes, not characters

```go
import "fmt"
s := "café"
fmt.Println("byte length:", len(s))
fmt.Println("first byte:", s[0], "(ASCII 'c')")
fmt.Println("third byte:", s[3], "(first byte of é)")
rs := []rune(s)
fmt.Println("rune count:", len(rs))
```

`café` looks like 4 characters, but `len(s)` reports **5** because `é` occupies
2 bytes. Converting to `[]rune` first gives the true character count (4).

> [!trap] **The length trap**
>
> `len("café")` is 5, not 4. Any `for i := 0; i < len(s); i++` loop walks
> *bytes*, so it can step through the middle of a multi-byte rune and print
> garbage.

## `range` iterates runes for you

The `range` form of a loop decodes UTF-8, giving you the byte offset *and* the
rune at each step. This is the safe way to walk characters.

```go
import "fmt"
s := "héllo"
for i, r := range s {
	fmt.Printf("%d:%c ", i, r)
}
fmt.Println()
```

Output: `0:h 1:é 3:l 4:l 5:o`. Notice the jump from `1` to `3`: `é` occupies
bytes 1 and 2, so the next rune starts at offset 3. You get the correct
character but the byte-based index.

## Byte indexing and slicing

`s[i]` yields a **byte** (`uint8`), never a rune. `s[a:b]` slices bytes too —
slicing can cut a rune in half, giving an invalid UTF-8 sequence that renders
as the replacement character `�`.

```go
import "fmt"
s := "世界hello"
b := []byte(s)
fmt.Println("bytes 3..5 decode as:", string(b[3:6]))
fmt.Println("rune 0 as default:", string([]rune(s)[0]))
```

`世` and `界` each use 3 bytes, so `b[3:6]` grabs exactly the second character
`界`. Slicing bytes *between* rune boundaries is what breaks the encoding.

> [!warning] **Slice runes, don't guess byte offsets**
>
> Prefer converting to `[]rune` before slicing up Unicode text:
> `string([]rune(s)[1:3])`. Byte slices are fine for format checks on ASCII
> and for APIs that want raw bytes (hashing, etc.).

## Building strings from runes

A rune literal like `'雪'` is a `rune`; `string(r)` converts one rune back to a
string. Concatenating is fine, but many appends should use a `strings.Builder`
(Part 6) for performance.

```go
import "fmt"
r := 9731
fmt.Println("U+2603 as text:", string(rune(r)))
word := "Go"
parts := []rune{102, 117, 110}
word += string(parts[0]) + string(parts[1]) + string(parts[2])
fmt.Println("built:", word)
```

> [!tip] **Print vs fmt for runes**
>
> `print(r)` would print the code point number; use `fmt.Printf("%c", r)` or
> `string(r)` when you want the visible character.

## Summary

- A string is UTF-8 bytes; `len(s)` counts bytes.
- `s[i]` is a byte; `range` yields byte offsets plus correctly decoded runes.
- `[]rune(s)` gives characters; slicing byte slices can split a rune.
- `string(r)` turns a rune into a one-rune string.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "s := \"café\"; how many bytes does len(s) return?"
    type: single
    choices: ["4", "5", "6", "8"]
    answer: [1]
    explanation: "'é' is two bytes in UTF-8, so the 4 visible characters take 5 bytes."
    difficulty: 2

  - id: q2
    prompt: "When you index a string with s[0], what do you get?"
    type: single
    choices:
      - "The first character (rune)"
      - "A one-character string"
      - "The first byte as a uint8 value"
      - "The string's length"
    answer: [2]
    explanation: "String indexing gives bytes (uint8), not runes. To get characters use range or []rune(s)."
    difficulty: 2

  - id: q3
    prompt: "What does 'for i, r := range s' give you at each step?"
    type: single
    choices:
      - "Character count and character index"
      - "Byte offset and decoded rune"
      - "Byte offset and raw byte"
      - "Rune and byte value"
    answer: [1]
    explanation: "Range over a string yields the byte index where the rune starts plus the decoded rune itself."
    difficulty: 2

  - id: q4
    prompt: "Which is the safest way to take the first two characters of a string?"
    type: single
    choices:
      - "s[0:2]"
      - "s[:2]"
      - "string([]rune(s)[:2])"
      - "s[0] + s[1]"
    answer: [2]
    explanation: "s[0:2] slices raw bytes and can split a multibyte rune; converting to []rune first guarantees whole characters."
    difficulty: 3
```