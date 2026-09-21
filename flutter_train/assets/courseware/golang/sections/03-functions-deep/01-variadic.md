---
id: 01-variadic
title: "Variadic functions and slices"
order: 1
section: 03-functions-deep
language: golang
type: lesson
summary: "Using ... T parameters, spreading slices, and append's variadic form."
tags: [variadic, append, ellipsis, variadic-function, slice]
---

# Variadic functions and slices

A **variadic** function accepts a variable number of arguments. The `...`
syntax in the parameter list is Go's way of saying "zero or more of these."

> [!note] **About the examples in this app**
>
> The on-device sandbox wraps every snippet in a `func main(){...}` shell, so
> the runnable examples here use *function literals* (anonymous functions
> assigned to variables) — those run anywhere a statement can. The declaration
> syntax you write in a real `.go` file is shown in `eval=no` blocks.

## Declaring a variadic parameter

Inside a function body, `args` has type `[]int` — it is a slice. You can
iterate it, take its length, and index it just like any other slice:

```go
sum := func(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}
print("sum:", sum(1, 2, 3, 4, 5), "\n")
```

In a real `.go` file the declaration looks like this:

```go eval=no
func sum(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}
```

> [!key]
> `...int` in a parameter list means "zero or more ints." Inside the function
> the parameter `nums` is a `[]int`. Outside the function you call it as
> `sum(1, 2, 3)` — no slice literal required.

## Mixing variadic and fixed parameters

A variadic parameter must be the **last** one. You can have fixed parameters
before it:

```go
import "fmt"
greet := func(tag string, names ...string) {
    for _, n := range names {
        fmt.Println(tag, n)
    }
}
greet("Hi", "Alice", "Bob", "Charlie")
```

```go eval=no
import "fmt"

func greet(tag string, names ...string) {
    for _, n := range names {
        fmt.Println(tag, n)
    }
}
```

> [!trap]
> The variadic parameter must be the final one. `func f(nums ...int, end string)`
> is a compile error — Go has no concept of a "trailing fixed" parameter.

## Spreading a slice with `...`

You already have a `[]int` and want to call a variadic function. Append `...`
to the slice to **spread** its elements as individual arguments:

```go
sum := func(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}
batch := []int{10, 20, 30}
print("spread sum:", sum(batch...), "\n")
```

Without the `...` you would be passing the slice as a single argument, which
would only work if the parameter type matches `[]int` exactly.

> [!tip]
> `slice...` spreads the slice. It works anywhere a variadic call-site is
> expected, including `append`, `fmt.Println`, and your own functions.

## append's variadic form

`append` is itself variadic — it takes an initial slice followed by any
number of elements to add:

```go
a := []int{1, 2, 3}
b := []int{4, 5}
a = append(a, b...)
print("a:", a, "\n")
```

`append(a, b...)` appends every element of `b` to `a`. The `...` is mandatory
here — without it you would need `append(a, b[0], b[1])`.

> [!warning]
> `append` returns a new slice header (it may reallocate the backing array).
> Always capture the result: `a = append(a, items...)`.

## Zero variadic arguments

A variadic function can be called with **zero** arguments for the variadic
portion — the parameter is simply an empty slice:

```go
sum := func(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}
print("zero args:", sum(), "\n")
print("one arg:", sum(42), "\n")
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What type does a variadic `...int` parameter have inside the function?"
    type: single
    choices:
      - "`int`"
      - "`[]int`"
      - "`*int`"
      - "`[...]int`"
    answer: [1]
    explanation: "Inside the function, a `...int` parameter is a `[]int` slice. The `...` syntax is only used at the call site and in the declaration."
    difficulty: 1

  - id: q2
    prompt: "Given `func f(a int, s ...string)`, which call is valid?"
    type: single
    choices:
      - "`f(\"hello\")`"
      - "`f(1, \"a\", \"b\")`"
      - "`f(\"a\", 1)`"
      - "`f(1)`"
    answer: [1]
    explanation: "`f` requires an `int` first, then zero or more strings. `f(1, \"a\", \"b\")` satisfies both. `f(\"hello\")` passes a string where an int is expected."
    difficulty: 1

  - id: q3
    prompt: "What does `append(a, b...)` do when `b` is a `[]int`?"
    type: single
    choices:
      - "Appends `b` as a single element to `a`"
      - "Appends every element of `b` to `a`"
      - "Creates a new slice containing only `b`"
      - "Copies `b` into `a` starting at index 0"
    answer: [1]
    explanation: "`b...` spreads the slice, so `append` receives each element of `b` individually, adding them all to `a`."
    difficulty: 2

  - id: q4
    prompt: "Why is `s = append(s, items...)` preferred over `append(s, items)`?"
    type: single
    choices:
      - "`append(s, items)` is a syntax error"
      - "`append(s, items)` appends the slice `items` as a single nested element"
      - "They are identical in behaviour"
      - "`append` ignores the second argument entirely"
    answer: [1]
    explanation: "Without `...`, `items` is passed as one value. The variadic signature `append([]T, ...T)` expects individual `T` values, so a `[]int` would become a `[][]int` nesting."
    difficulty: 3
```
