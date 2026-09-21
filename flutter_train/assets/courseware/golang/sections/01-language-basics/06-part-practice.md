---
id: 06-part-practice
title: "Part 1 Practice"
order: 6
section: 01-language-basics
language: golang
type: lesson
summary: "Review of pointers, functions, control flow, strings/runes, and conversions with exam practice."
tags: [review, practice, exam, pointers, functions, control-flow, strings, conversions]
prereqs: [01-pointers, 02-functions, 03-control-flow, 04-strings-runes, 05-conversions]
---

# Part 1 Practice

You have covered the five pillars of Go's language basics. This module ties
them together, then gives you exam-style questions.

## Section review

**Pointers** — `&x` takes the address of `x`; `*p` reads or writes through a
pointer. Pointers share and mutate one value instead of copying it, and struct
fields are reachable through pointers directly (`p.X`). A nil pointer must not
be dereferenced.

**Functions** — `func name(params) returnTypes { ... }`. Parameters are copies;
pass a pointer to modify the caller's value. Functions return one or many
values, parenthesized for multiple, and named results allow a bare `return`.

**Control flow** — `if` may carry an init statement (`if x := f(); x > 0 {`).
There is only `for`: classic, while-style, infinite, and `range`. `break` exits
the innermost loop; `continue` skips an iteration. `switch` auto-breaks and
supports a tagless boolean form.

**Strings and runes** — a string is UTF-8 bytes. `len()` counts bytes, `s[i]`
is a byte, and only `range` (or `[]rune(s)`) gives you characters. Byte slicing
can split a rune.

**Conversions** — Go converts only explicitly, via `T(x)`. float-to-int
truncates, small types can wrap, untyped constants adapt while typed values
do not, and `[]byte(s)` / `string(b)` round-trip exactly.

## Two quick recap examples

```go
import "fmt"
type Account struct {
	Bal int
}
deposit := func(a *Account, amount int) {
	a.Bal += amount
}
acc := Account{Bal: 100}
deposit(&acc, 25)
fmt.Println("balance:", acc.Bal)
```

```go
import "fmt"
text := "héllo"
letters := []rune(text)
first := string(letters[1])
f := 3.99
n := int(f)
fmt.Println("rune:", first, "| byte len:", len(text), "| 3.99 as int:", n)
```

In the first block, `deposit` gets a pointer, so the balance actually changed.
In the second, `len(text)` is 6 (two bytes for `é`), while `letters[1]` is a
whole `é`, and `int(f)` truncates 3.99 to 3.

## ExamQuestions

```yaml
bank:
  - prompt: "type T struct{ N int }; v := T{N: 5}; p := &v; p.N = 12. What is v.N?"
    type: single
    choices: ["5", "12", "0", "&v"]
    answer: [1]
    explanation: "Struct fields are assignable through a pointer, so p.N = 12 mutates v and v.N becomes 12."
    difficulty: 2
    weight: 4
    section: 01-language-basics

  - prompt: "func f(a, b int) (int, int) { return b, a }. How do you capture both results?"
    type: single
    choices:
      - "x, y := f(1, 2)"
      - "x := f(1, 2)"
      - "x = y = f(1, 2)"
      - "f(1, 2) -> (x, y)"
    answer: [0]
    explanation: "Multiple return values are unpacked with a single short declaration listing one variable per result."
    difficulty: 1
    weight: 4
    section: 01-language-basics

  - prompt: "In 'for i := 0; i < 5; i++ { if i == 2 { continue }; print(i) }', which numbers print?"
    type: single
    choices: ["0 1 2 3 4", "0 1 3 4", "1 2 3 4", "0 1 2"]
    answer: [1]
    explanation: "continue skips the rest of the iteration whenever i == 2, so only 2 is omitted from the sequence 0..4."
    difficulty: 2
    weight: 4
    section: 01-language-basics

  - prompt: "s := \"aér\". Which statement is true about this string?"
    type: multi
    choices:
      - "len(s) is 3"
      - "len(s) is 4"
      - "len([]rune(s)) is 3"
      - "s[1] is a byte, not a rune"
    answer: [1, 2, 3]
    explanation: "'é' uses two bytes, so the 3-character string holds 4 bytes; []rune gives 3 runes, and s[i] indexes bytes."
    difficulty: 3
    weight: 4
    section: 01-language-basics
```