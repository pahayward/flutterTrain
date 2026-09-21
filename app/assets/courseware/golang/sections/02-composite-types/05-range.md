---
id: 05-range
title: Range
order: 5
section: 02-composite-types
language: golang
summary: "The range keyword over arrays, slices, maps, and strings; index-value forms; underscore."
tags: [range, iteration, index, value, underscore, strings]
---

# Range

The `range` keyword iterates over elements of arrays, slices, maps, and
strings. It's the standard way to loop over collections in Go.

## Range over slices and arrays

`range` yields the **index** and **value** at each step:

```go
colors := []string{"red", "green", "blue"}

for i, c := range colors {
    print(i, "=", c, " ")
}
print("\n")
```

Use `_` when you don't need one of the values:

```go
nums := []int{10, 20, 30, 40}

// Only need values, not index
for _, n := range nums {
    print(n, " ")
}
print("\n")
```

> [!tip]
> In Go, every variable must be used. The underscore `_` discards values you
> don't need. Omitting both index and value is not allowed — at least `_` is
> required.

## Range over strings

Range over a string iterates over **runes** (Unicode code points), not bytes:

```go
text := "Go语言"
for i, r := range text {
    print(i, "=", string(r), " ")
}
print("\n")
```

> [!key]
> The index `i` is the byte offset, not the rune index. For `"Go语言"`,
> `i=0` is `'G'`, `i=2` is `'语'` (since `'G'` and `'o'` are 1 byte each).
> If you need the rune index, use `utf8.RuneCountInString`.

## Range over maps

Range over a map yields **key** and **value**:

```go
scores := map[string]int{
    "Alice": 95,
    "Bob":   87,
    "Carol": 92,
}

for name, score := range scores {
    print(name, ": ", score, "\n")
}
```

> [!warning]
> Map iteration order is randomized. The output above may appear in any order.
> Don't depend on it.

## Range with only a variable (no index)

You can capture just the value (dropping the index) or just the index
(dropping the value):

```go
s := []string{"hello", "world"}

// Only index
for i := range s {
    print("index ", i, "\n")
}
```

## Modifying through the index

Since `range` gives you the index, you can modify elements in-place:

```go
data := []int{1, 2, 3, 4, 5}

for i := range data {
    data[i] *= 10
}

for _, v := range data {
    print(v, " ")
}
print("\n")
```

> [!trap]
> You **cannot** modify the value variable returned by range — it's a copy:
> `for _, v := range data { v = 0 }` does nothing to `data`.
> Use the index form to modify in place.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does `for i, v := range s` yield when `s` is a `[]int`?"
    type: single
    choices:
      - "Only the value at each index"
      - "Only the index"
      - "The index and a copy of the value"
      - "A pointer to the value"
    answer: [2]
    explanation: "Range yields the index and a copy of the value. Modifying `v` does not affect the original slice."
    difficulty: 1
  - id: q2
    prompt: "Why does `for _, v := range \"Go语言\"` produce unexpected byte indices?"
    type: single
    choices:
      - "The string is encoded in UTF-16"
      - "The index is the byte offset, and multi-byte runes shift subsequent indices"
      - "Range always starts at index 1"
      - "It's a bug in the Go runtime"
    answer: [1]
    explanation: "Range over strings yields byte offsets as indices. Multi-byte Unicode characters cause non-consecutive indices."
    difficulty: 2
  - id: q3
    prompt: "How do you discard the index when ranging over a slice?"
    type: single
    choices:
      - "Omit it entirely: `for v := range s`"
      - "Use underscore: `for _, v := range s`"
      - "Use nil: `for nil, v := range s`"
      - "Use dash: `for - , v := range s`"
    answer: [1]
    explanation: "The underscore `_` is Go's blank identifier. It discards the index while keeping the value binding."
    difficulty: 1
  - id: q4
    prompt: "Which of these modifies the original slice?"
    type: single
    choices:
      - "`for _, v := range s { v = 0 }`"
      - "`for i := range s { s[i] = 0 }`"
      - "`for i, _ := range s { v := 0 }`"
      - "`range s = []int{0, 0, 0}`"
    answer: [1]
    explanation: "Only the index form `s[i] = 0` writes through to the original array. The value variable `v` is a copy."
    difficulty: 2
```
