---
id: 02-slices
title: Slices
order: 2
section: 02-composite-types
language: golang
summary: "Dynamic views into arrays, append, sub-slices, copy, len/cap, slice tricks."
tags: [slice, append, capacity, sub-slice, make, copy]
---

# Slices

A **slice** is a dynamically-sized, flexible view into an underlying array. Most
Go code uses slices where arrays were once required.

## What a slice is

A slice has three parts:

- A **pointer** to the first accessible element of an underlying array.
- A **length** (`len`) — how many elements the slice currently contains.
- A **capacity** (`cap`) — how many elements the slice can hold before the
  underlying array must be reallocated.

```go
s := []int{10, 20, 30}
print("len:", len(s), " cap:", cap(s), "\n")
```

> [!key]
> A slice is **not** an array. It's a small struct (pointer, length, capacity)
> that points into an array. This is why slices are passed by reference-like
> semantics — mutations affect the underlying array.

## Creating slices

There are several ways:

```go
fromLiteral := []int{1, 2, 3, 4}

fromMake := make([]int, 5)        // len=5, cap=5, all zeros
fromMake2 := make([]int, 0, 10)   // len=0, cap=10

print("literal len:", len(fromLiteral), "\n")
print("make len:", len(fromMake), " cap:", cap(fromMake), "\n")
print("prealloc len:", len(fromMake2), " cap:", cap(fromMake2), "\n")
```

> [!tip]
> `make([]T, length, capacity)` lets you pre-allocate capacity. This avoids
> repeated reallocations when you know roughly how many elements you'll need.

## Appending elements

The `append` function grows a slice as needed:

```go
var s []int
for i := 1; i <= 5; i++ {
    s = append(s, i*10)
}
print("len:", len(s), " cap:", cap(s), "\n")
for _, v := range s {
    print(v, " ")
}
print("\n")
```

> [!warning]
> `append` may return a **new** slice header if the underlying array needs to
> grow. Always capture the result: `s = append(s, x)`.

## Sub-slices share memory

Slicing a slice creates a new slice header that shares the same underlying
array:

```go
original := []int{10, 20, 30, 40, 50}
sub := original[1:3]

sub[0] = 99

print("original:", original[1], "\n")
print("sub:", sub[0], "\n")
```

Changing `sub[0]` also changes `original[1]` because both point to the same
element in memory.

> [!trap]
> Sub-slices share memory with the original. If you don't want that, use
> `copy()` to make an independent copy.

## The copy function

`copy` duplicates elements from a source slice into a destination:

```go
src := []int{1, 2, 3, 4, 5}
dst := make([]int, 3)
n := copy(dst, src)

print("copied:", n, "\n")
for _, v := range dst {
    print(v, " ")
}
print("\n")
```

Only `min(len(dst), len(src))` elements are copied — the extra elements in
`src` are silently ignored.

## Slice tricks

Go's slice expressions give you useful patterns:

```go
data := []int{0, 1, 2, 3, 4, 5}

// Drop first element (reslice, keeps capacity)
tail := data[1:]
print("tail:", tail[0], " len:", len(tail), "\n")

// Drop last element
head := data[:len(data)-1]
print("head last:", head[len(head)-1], "\n")

// Copy to avoid aliasing
fresh := make([]int, len(tail))
copy(fresh, tail)
fresh[0] = 999
print("original tail still:", tail[0], "\n")
```

> [!note]
> Reslicing is zero-cost (no allocation), but remember the aliasing trap.
> Use `copy` when you need independence.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does `make([]int, 5, 10)` create?"
    type: single
    choices:
      - "A slice of length 10 and capacity 5"
      - "A slice of length 5 and capacity 10"
      - "An array of 10 elements with first 5 initialized"
      - "A nil slice"
    answer: [1]
    explanation: "`make([]int, 5, 10)` creates a slice with len=5 and cap=10. All 5 elements are zero-valued."
    difficulty: 1
  - id: q2
    prompt: "What happens when you slice a slice?"
    type: single
    choices:
      - "A new underlying array is allocated"
      - "A new slice header is created that shares the same underlying array"
      - "The original slice is modified"
      - "A deep copy is made automatically"
    answer: [1]
    explanation: "Slicing creates a new header pointing into the same array. Elements are shared — mutations in one affect the other."
    difficulty: 2
  - id: q3
    prompt: "Why must you capture the result of `append`?"
    type: single
    choices:
      - "append modifies the slice in place"
      - "append may allocate a new backing array and return a new slice header"
      - "append returns only the new elements"
      - "The compiler requires it for memory safety"
    answer: [1]
    explanation: "When the slice's capacity is exhausted, append allocates a new array and returns a new header pointing to it. The old variable would still reference the old array."
    difficulty: 2
  - id: q4
    prompt: "How do you prevent sub-slice aliasing?"
    type: single
    choices:
      - "Use `len()` to isolate the sub-slice"
      - "Use `copy()` to duplicate into a new slice"
      - "Use `append()` with a nil destination"
      - "Assign to a new variable with `:=`"
    answer: [1]
    explanation: "`copy` duplicates elements into a fresh backing array, breaking the shared-memory link."
    difficulty: 2
```
