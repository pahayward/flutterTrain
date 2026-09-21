---
id: 01-arrays
title: Arrays
order: 1
section: 02-composite-types
language: golang
summary: "Fixed-length collections, value semantics, and the range keyword."
tags: [array, fixed-length, value-type, range]
---

# Arrays

An **array** in Go is a fixed-length, ordered sequence of elements of a
single type. Once created, its length can never change.

## Declaring arrays

```go
var scores [5]int                 // five zeros
names := [3]string{"Ada", "Linus", "Ken"}
langs := [...]string{"Go", "Rust"} // length inferred = 2

print(scores[0], " ", names[1], " ", langs[0], "\n")
```

> [!key]
> The `[...]` syntax tells the compiler to count the elements for you.
> You still get a fixed-length array — the length is just implicit.

## Value semantics

Arrays in Go are **value types**. Assigning one array to another copies every
element:

```go
a := [3]int{10, 20, 30}
b := a
b[0] = 99

print("a:", a[0], " b:", b[0], "\n")
```

Modifying `b` does **not** change `a`. This differs from slices (covered next),
which share underlying memory.

> [!trap]
> Passing large arrays to functions copies the entire array. If you need
> shared access, use a slice instead.

## Comparing arrays

Two arrays are equal if they have the **same length** and **identical elements**
at every index. Arrays of different lengths are never equal — the compiler
rejects the comparison.

```go
x := [2]int{1, 2}
y := [2]int{1, 2}
z := [3]int{1, 2, 3}

print(x == y, "\n")
// x == z  // compile error: different lengths
```

## Iterating with range

The `range` keyword iterates over array elements. It yields the index and the
value:

```go
fruits := [3]string{"apple", "banana", "cherry"}

for i, v := range fruits {
    print(i, ": ", v, "\n")
}
```

Use `_` to ignore the index when you only need the value:

```go
nums := [4]int{2, 4, 6, 8}

for _, n := range nums {
    print(n * 3, "\n")
}
```

> [!tip]
> In practice, slices are far more common than arrays in Go. Arrays appear
> mainly as building blocks for maps and slices, or when a fixed size is
> genuinely required (e.g., buffers, hash keys).

## When to use arrays

Arrays are rarely used directly because their fixed size is inflexible. Most Go
code uses **slices** instead. You'll encounter arrays:

- As the underlying storage for slices.
- As map keys (arrays can be keys; slices cannot).
- When an exact, known size is needed (e.g., `[32]byte` for a buffer).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the length of `langs := [...]string{\"Go\", \"Rust\"}`?"
    type: single
    choices:
      - "0 — the compiler doesn't know the length"
      - "1"
      - "2"
      - "It's a slice, not an array"
    answer: [2]
    explanation: "The `[...]` syntax tells the compiler to infer the length from the initializer. Two elements means length 2."
    difficulty: 1
  - id: q2
    prompt: "What happens when you assign one array to another in Go?"
    type: single
    choices:
      - "Both variables reference the same underlying data"
      - "A complete copy of every element is made"
      - "Only the pointer is copied"
      - "It causes a compile error"
    answer: [1]
    explanation: "Arrays are value types. Assignment copies all elements, so modifying the copy does not affect the original."
    difficulty: 1
  - id: q3
    prompt: "Can you compare an `[2]int` with an `[3]int` using `==`?"
    type: single
    choices:
      - "Yes, they are compared element by element"
      - "Yes, the shorter array is zero-padded"
      - "No, arrays of different lengths are not comparable"
      - "Only if both are empty"
    answer: [2]
    explanation: "Arrays with different lengths have different types in Go. The compiler rejects `==` between them."
    difficulty: 2
  - id: q4
    prompt: "Which syntax lets the compiler infer the array length?"
    type: single
    choices:
      - "`var arr []int`"
      - "`arr := [...]int{1, 2, 3}`"
      - "`arr := [3:]int{1, 2, 3}`"
      - "`arr := new([3]int)`"
    answer: [1]
    explanation: "`[...]` is the Go syntax for length inference. The compiler counts the elements in the literal."
    difficulty: 1
```
