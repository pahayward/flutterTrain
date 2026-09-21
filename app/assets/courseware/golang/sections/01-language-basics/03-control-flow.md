---
id: 03-control-flow
title: "Control flow: if, for, switch"
order: 3
section: 01-language-basics
language: golang
type: lesson
summary: "if with init statements, the for statement in all its forms, and switch statements and expressions."
tags: [control-flow, if, for, switch, range, break, continue]
prereqs: [02-functions]
---

# Control flow: `if`, `for`, `switch`

Go keeps control flow deliberately small: one loop keyword (`for`), conditionals
with a useful init pattern, and a `switch` that is both a statement and an
expression.

## `if` with an init statement

An `if` may run a short statement before the condition. That statement's scope
ends when the branch ends, which keeps the code tight.

```go
import "fmt"
xs := []int{3, 1, 4, 1, 5}
if first := xs[0]; first > 2 {
	fmt.Println("starts big:", first)
}
sum := 0
for i := 0; i < 10; i++ {
	sum += i
}
fmt.Println("sum of 0..9:", sum)
```

Note the two-part form: `if first := xs[0]; first > 2 {` — the `;` separates the
init statement from the condition.

> [!tip] **if + else with no parens**
>
> Go has `if x > 0 { ... } else { ... }` with no parentheses. The indentation
> and brace placement are what the compiler (and gofmt) force.

## `for`: three shapes, one keyword

Go has **no** `while` and no `do` loop. Every loop is a `for`:

- **Classic**: `for init; condition; post { ... }`
- **While-style**: `for condition { ... }`
- **Infinite**: `for { ... }` (exit with `break`)
- **Range**: `for i, v := range xs { ... }` (see below)

```go
import "fmt"
// classic
total := 0
for i := 1; i <= 4; i++ {
	total += i
}
fmt.Println("classic total:", total)

// while-style
n := 5
for n > 0 {
	n--
}
fmt.Println("while-style n:", n)

// infinite with break
count := 0
for {
	if count >= 3 {
		break
	}
	count++
}
fmt.Println("infinite-with-break count:", count)
```

## `range` + break/continue

`range` is the idiomatic way to walk a slice, array, map, or string. `break`
exits the innermost loop immediately; `continue` skips to the next iteration.

```go
import "fmt"
word := "golang"
for i, r := range word {
	if r == 'o' {
		continue
	}
	if i >= 4 {
		break
	}
	fmt.Printf("%d:%c ", i, r)
}
fmt.Println()
```

That prints `0:g 2:l 3:a`. Trace it: the `o` at index 1 is skipped by
`continue`, and the loop `break`s at `i == 4` before printing the `n`.

> [!trap] **break/continue act on the innermost loop**
>
> `break` inside nested loops stops only the loop you are in, not the outer
> loop. Breaking an outer loop needs a labeled break, which you will meet in
> later parts.

## `switch` as a statement

A switch statement picks one of several cases. Go automatically `break`s after
each case — no `fallthrough` unless you want it.

```go
import "fmt"
season := func(m int) string {
	switch m {
	case 12, 1, 2:
		return "winter"
	case 3, 4, 5:
		return "spring"
	case 6, 7, 8:
		return "summer"
	case 9, 10, 11:
		return "fall"
	}
	return "?"
}
fmt.Println("month 2 is", season(2), "| month 4 is", season(4))

grade := ""
score := 82
switch {
case score >= 90:
	grade = "A"
case score >= 70:
	grade = "B"
default:
	grade = "F"
}
fmt.Println("score", score, "-> grade", grade)
```

The first switch picks a case by matching the value of `m` — several months can
share a case (`12, 1, 2`). The second is a **tagless** switch where each case
is a boolean condition evaluated top-down, `case score >= 90:` and so on.

## `switch` as an expression

Since Go 1.17 nothing special is needed — `switch` is a statement, but you can
wrap case bodies in a function literal to turn the whole thing into an
expression result. The example above already does this with `season`: the
switch lives inside the literal and the value is returned.

```go
import "fmt"
txt := func(n int) string {
	switch n {
	case 0:
		return "zero"
	case 1:
		return "one"
	case 2:
		return "two"
	default:
		return "many"
	}
}
fmt.Println(txt(0), txt(2), txt(9))
```

> [!tip] **Switch is easier to read than long if-chains**
>
> When you compare one value against several cases, `switch` expresses the
> intent more clearly than a chain of `else if`, and it reads the same on a
> phone screen.

## One more: `range` over a slice with `continue`

A final compact recap tying `range`, `continue`, and slice building together:

```go
import "fmt"
evens := []int{}
for _, v := range []int{1, 2, 3, 4, 5, 6} {
	if v%2 != 0 {
		continue
	}
	evens = append(evens, v)
}
fmt.Println("evens:", evens)
```

## Summary

- `if` accepts an init statement before the condition.
- `for` covers classic, while-style, infinite, and range loops.
- `break` exits the innermost loop; `continue` skips one iteration.
- `switch` auto-breaks, supports multiple values per case, and a tagless
  boolean form.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In 'if x := f(); x > 0 { ... }', what is the scope of x?"
    type: single
    choices:
      - "The whole program"
      - "Just the if/else block"
      - "Only the condition line"
      - "Until the end of the enclosing function"
    answer: [1]
    explanation: "An init statement's scope is the whole if statement, including the else branch."
    difficulty: 2

  - id: q2
    prompt: "Which loop below is equivalent to Go's while-loop style?"
    type: single
    choices:
      - "for {}"
      - "for cond {}"
      - "for init; cond; post {}"
      - "while cond {}"
    answer: [1]
    explanation: "Go has no 'while' keyword; 'for cond {}' is the while-style form."
    difficulty: 1

  - id: q3
    prompt: "Consider 'for i := 0; i < 10; i++ { if i == 4 { continue }; print(i) }'. Which numbers print?"
    type: single
    choices:
      - "0 1 2 3 4 5 6 7 8 9"
      - "0 1 2 3 5 6 7 8 9"
      - "0 1 2 3 4 6 7 8 9"
      - "5 6 7 8 9"
    answer: [1]
    explanation: "continue skips the current iteration, so 4 is never printed; every other number is."
    difficulty: 2

  - id: q4
    prompt: "What does a switch statement do after a case block finishes?"
    type: single
    choices:
      - "Falls through to the next case automatically"
      - "Breaks out of the switch automatically"
      - "Repeats the switch"
      - "Returns from the function"
    answer: [1]
    explanation: "Go cases break automatically; you must write 'fallthrough' to continue into the next case."
    difficulty: 1
```