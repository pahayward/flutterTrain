---
id: 03-maps
title: Maps
order: 3
section: 02-composite-types
language: golang
summary: "Key-value collections, make, literals, lookup, comma-ok, delete, iteration."
tags: [map, hash-table, key-value, lookup, delete, comma-ok]
---

# Maps

A **map** in Go is an unordered collection of key-value pairs. It's Go's hash
table implementation.

## Creating maps

Use `make` or a literal:

```go
ages := make(map[string]int)
ages["Alice"] = 30
ages["Bob"] = 25

scores := map[string]int{
    "Go":   100,
    "Rust": 95,
}

print("Alice:", ages["Alice"], "\n")
print("Go:", scores["Go"], "\n")
```

> [!key]
> Map keys must be **comparable** types — strings, integers, booleans,
> arrays, and pointers. Slices, maps, and structs containing slices/maps
> cannot be map keys.

## Lookup and comma-ok

Accessing a missing key returns the **zero value** for the value type. The
two-value form tells you whether the key exists:

```go
m := map[string]int{"a": 1, "b": 2}

val, ok := m["c"]
print("value:", val, " found:", ok, "\n")

val2, ok2 := m["a"]
print("value:", val2, " found:", ok2, "\n")
```

> [!trap]
> A zero value from a lookup might be a valid value. Use comma-ok to
> distinguish "key not present" from "key present with zero value."

## Adding and updating entries

```go
inventory := map[string]int{
    "apples":  5,
    "oranges": 3,
}

inventory["apples"] += 2
inventory["bananas"] = 10

print("apples:", inventory["apples"], "\n")
print("bananas:", inventory["bananas"], "\n")
```

## Deleting entries

Use the built-in `delete` function:

```go
m := map[string]int{"x": 1, "y": 2, "z": 3}
delete(m, "y")

_, ok := m["y"]
print("y exists:", ok, "\n")
print("z:", m["z"], "\n")
```

## Iteration order

Map iteration order in Go is **randomized**. The language specification does
not guarantee order between runs or even between iterations in the same run.

```go
m := map[string]int{"a": 1, "b": 2, "c": 3}

for k, v := range m {
    print(k, "=", v, " ")
}
print("\n")
```

> [!warning]
> Never write code that depends on map iteration order. If you need
> deterministic order, collect the keys, sort them, and iterate the sorted
> list.

## Nil maps

A map declared without `make` is `nil`. Reading from a nil map returns the
zero value (no panic), but **writing** to a nil map panics at runtime.

```go
var m map[string]int
print("nil map read:", m["key"], "\n")
print("nil map len:", len(m), "\n")
```

> [!trap]
> A nil map behaves like an empty map for reads, but any `m[k] = v` write
> causes a runtime panic. Always initialize with `make` or a literal before
> writing.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does accessing a missing key in a map return?"
    type: single
    choices:
      - "A runtime panic"
      - "An error value"
      - "The zero value for the value type"
      - "nil, regardless of the value type"
    answer: [2]
    explanation: "Go maps return the zero value (e.g., 0 for int, \"\" for string) when a key is not found. Use comma-ok to detect missing keys."
    difficulty: 1
  - id: q2
    prompt: "What is the two-value map lookup `val, ok := m[key]` called?"
    type: single
    choices:
      - "Try-catch"
      - "Comma-ok idiom"
      - "Optional chaining"
      - "Guard clause"
    answer: [1]
    explanation: "The comma-ok idiom returns the value and a boolean indicating whether the key exists in the map."
    difficulty: 1
  - id: q3
    prompt: "What happens when you write to a nil map?"
    type: single
    choices:
      - "The map is automatically initialized"
      - "The write is silently ignored"
      - "A runtime panic occurs"
      - "A compile error is raised"
    answer: [2]
    explanation: "Writing to a nil map panics at runtime. Always use `make` or a literal to initialize maps before writing."
    difficulty: 2
  - id: q4
    prompt: "Which of these can be a map key in Go?"
    type: single
    choices:
      - "`[]int{1, 2}` (a slice)"
      - "`[2]string{\"a\", \"b\"}` (an array)"
      - "`map[string]int` (a nested map)"
      - "`struct{ Data []int }` (struct with a slice field)"
    answer: [1]
    explanation: "Only comparable types can be map keys. Arrays are comparable; slices, maps, and structs with non-comparable fields are not."
    difficulty: 2
```
