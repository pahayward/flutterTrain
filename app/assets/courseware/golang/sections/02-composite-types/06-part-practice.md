---
id: 06-part-practice
title: Part 2 Practice
order: 6
section: 02-composite-types
language: golang
summary: "Review of arrays, slices, maps, structs, and range with exam-style questions."
tags: [practice, review, exam, arrays, slices, maps, structs, range]
---

# Part 2 Practice

This part covered Go's composite types — the building blocks of every real
program. Here's the whole story in one place.

## Section review

**Arrays** are fixed-length value types. Literals include `[3]int{...}` and
`[...]int{...}`. Assigning copies all elements, and arrays with different
lengths are different types.

**Slices** are dynamic views over arrays: a pointer, a length, and a capacity.
`make([]int, len, cap)` pre-allocates, `append` grows, `copy` duplicates, and
sub-slices share memory unless you copy. `s = append(s, x)` is the discipline.

**Maps** are hash tables. `make(map[K]V)` and `map[K]V{...}` create them. Use
the comma-ok form `v, ok := m[k]` for safe lookups, `delete(m, k)` to remove,
and never rely on iteration order. Writing to a nil map panics.

**Structs** group heterogeneous fields into one value. Use named-field
literals, dot access, and remember structs are copied by value. Anonymous
structs work for one-off data.

**Range** iterates slices, arrays, maps, and strings. It yields index+value for
slices (byte offset + rune for strings) and key+value for maps. `_` discards
what you don't need, and only the index form can modify the collection.

## Combined examples

```go
type Student struct {
    Name  string
    Score int
}

students := []Student{
    {Name: "Alice", Score: 95},
    {Name: "Bob", Score: 87},
}

best := students[0]
for _, s := range students {
    if s.Score > best.Score {
        best = s
    }
}
print("best:", best.Name, "\n")
```

```go
m := map[string][]int{
    "odd":  {1, 3, 5},
    "even": {2, 4, 6},
}

total := 0
for _, list := range m {
    for _, n := range list {
        total += n
    }
}
print("total of all numbers:", total, "\n")
```

> [!key]
> Recall the traps: sub-slices share memory; `append` may return a new
> header; map lookup needs comma-ok; struct assignment copies; range value
> variables are immutable copies.

## What's next?

Part 3 moves from data structures to **functions**: parameters by value versus
pointer, variadics, named returns, and closures — the tools that operate on
these composite types.

## ExamQuestions

```yaml
questions:
  - id: ex1
    prompt: "Which form of Go's `for` loop prints the value of every element of `arr := [4]int{1,2,3,4}`?"
    type: single
    choices:
      - "`for _, v := range arr { print(v) }`"
      - "`for v := arr { print(v) }`"
      - "`for i, v := range arr { print(i) }`"
      - "`for v in arr { print(v) }`"
    answer: [0]
    explanation: "Range over an array yields index and value; `_` discards the index and `v` receives the value. There is no Python-style `in` form in Go."
    difficulty: 1
    weight: 3
    section: 02-composite-types
  - id: ex2
    prompt: "Sub-slices like `b := a[1:3]` share memory with the original slice. How do you get an independent copy?"
    type: single
    choices:
      - "Use `copy`: allocate a new slice and copy elements into it"
      - "Use `append`: `b = append(a[1:3], 0); b = b[:2]`"
      - "Use swap: `a, a[1:3] = a[1:3], a`"
      - "Use `range`: rebuild from `len(a[1:3])`"
    answer: [0]
    explanation: "The only independent copy comes from `copy(b, a[1:3])` after allocating `b`, or a fresh `append([]int(nil), a[1:3]...)`. Slicing alone always aliases."
    difficulty: 2
    weight: 4
    section: 02-composite-types
  - id: ex3
    prompt: "Why is `v, ok := m[\"key\"]` preferred over a plain `v := m[\"key\"]` lookup?"
    type: single
    choices:
      - "The comma-ok form returns a pointer to the value"
      - "The comma-ok form distinguishes a zero value from a missing key"
      - "The comma-ok form sorts the map"
      - "The plain form panics on missing keys"
    answer: [1]
    explanation: "A missing key returns the zero value. Comma-ok adds a boolean so you can tell 'zero value stored' from 'key absent'."
    difficulty: 1
    weight: 3
    section: 02-composite-types
  - id: ex4
    prompt: "What happens when you write to a nil map `var m map[string]int; m[\"x\"] = 1`?"
    type: single
    choices:
      - "The map is initialized automatically and the write succeeds"
      - "The write is silently ignored and m stays empty"
      - "A runtime panic occurs because a nil map cannot store values"
      - "The program returns an error value"
    answer: [2]
    explanation: "Reads and `len` are safe on nil maps, but a write causes a runtime panic. Always initialize with `make` or a literal before writing."
    difficulty: 2
    weight: 4
    section: 02-composite-types
```