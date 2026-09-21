---
id: 02-functions
title: "Functions"
order: 2
section: 01-language-basics
language: golang
type: lesson
summary: "Declaring functions, parameters, multiple return values, and named returns."
tags: [function, return, parameters, signature, func]
prereqs: [01-pointers]
---

# Functions

A **function** is a named, reusable block of code that takes inputs
(**parameters**) and produces outputs (**return values**). Functions are the
heart of structured Go programs.

> [!note] **About the examples in this app**
>
> The on-device sandbox wraps every snippet in a `func main(){...}` shell, so
> the runnable examples here use *function literals* (anonymous functions
> assigned to variables) — those run anywhere a statement can. The declaration
> syntax you write in a real `.go` file is shown at the end of this module.

## The declaration syntax

A named function is declared at the top level of a package:

```go eval=no
func add(a, b int) int {
	return a + b
}

func main() {
	fmt.Println(add(2, 3))
}
```

Why `eval=no`? The embedded sandbox cannot use package-level `func`
declarations (it wraps every snippet inside `func main()`), but this is the
syntax you will type in every real Go file.

> [!key] **Reading a signature**
>
> `func add(a, b int) int` — name `add`, parameters `a` and `b` (both `int`),
> one return value of type `int`. Consecutive parameters sharing a type can
> be written once: `a, b int`.

## Parameters and return values

Function literals behave exactly like named functions — same parameters, same
returns — they are just declared where they are used:

```go
import "fmt"
sumAndCount := func(xs []int) (int, int) {
	total, n := 0, 0
	for _, v := range xs {
		total += v
		n++
	}
	return total, n
}
total, n := sumAndCount([]int{10, 20, 30})
fmt.Println("sum:", total, "count:", n)
```

Notice the return type `(int, int)`: a **parenthesized list** of return types.
The function returns *two* values, and the caller unpacks both at once:
`total, n := ...`.

## Multiple return values

Returning several values is idiomatic Go. A very common pattern is
"result plus a boolean or error."

```go
import "fmt"
divide := func(a, b int) (quotient int, ok bool) {
	if b == 0 {
		return 0, false
	}
	quotient = a / b
	ok = true
	return
}
q, good := divide(10, 3)
fmt.Println("10/3:", q, "ok:", good)
q2, good2 := divide(1, 0)
fmt.Println("1/0:", q2, "ok:", good2)
```

## Named returns

A return list can **name** its results. Named results behave like local
variables, and a bare `return` sends back their current values. This is handy
when the function has several exit points.

```go
import "fmt"
divmod := func(n, d int) (quot, rem int) {
	quot = n / d
	rem = n % d
	return
}
q, r := divmod(17, 5)
fmt.Println("17 / 5:", q, "remainder", r)
```

> [!trap] **Bare `return` with named results is code-smell if unclear**
>
> `return` alone works because the results `quot` and `rem` are named. Beginners
> misread it, so many style guides say: name results when it makes the function
> clearer, otherwise return explicit values.

## Pointers as parameters

Function parameters are copies unless the type is a pointer. If a function
must change the caller's variable, pass a `*T`.

```go
import "fmt"
reset := func(p *int) {
	*p = 0
}
addOne := func(v int) int {
	return v + 1
}
n := 99
reset(&n)
m := addOne(n)
fmt.Println("after reset, n:", n)
fmt.Println("addOne copied n, n is unchanged, m is:", m)
```

With `addOne(v int)` the parameter is a **copy**, so `n` keeps its value.
Only the pointer-based `reset(&n)` reaches over and changes `n` itself.

## Summary

- `func name(params) returns { ... }` declares a function.
- Multiple returns are written `(int, bool)` and unpacked with `:=`.
- Named results allow a clean bare `return`.
- Pass `&x` (a pointer) when a function must modify `x`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which signature returns exactly two int values?"
    type: single
    choices:
      - "func f(a, b int) int"
      - "func f(a, b int) (int, int)"
      - "func f(a int, b int) (int)"
      - "func f(a int, b int)"
    answer: [1]
    explanation: "A parenthesized list of return types, (int, int), means two int values are returned."
    difficulty: 1

  - id: q2
    prompt: "func f(x int) (double int) { double = x * 2; return } — what does f(5) return?"
    type: single
    choices: ["5", "10", "x * 2", "nothing (declaration error)"]
    answer: [1]
    explanation: "The bare return returns the named result 'double', which holds x*2 = 10."
    difficulty: 2

  - id: q3
    prompt: "How do you receive two results from a function call returning (int, bool)?"
    type: single
    choices:
      - "v := f()"
      - "v, ok := f()"
      - "v := ok := f()"
      - "return f() twice"
    answer: [1]
    explanation: "Multiple return values are unpacked with one '=' or ':=' per result: 'v, ok := f()'."
    difficulty: 1

  - id: q4
    prompt: "func bump(v int) { v = v + 1 }; n := 5; bump(n). What is n afterwards?"
    type: single
    choices: ["6", "5", "0", "a pointer to 6"]
    answer: [1]
    explanation: "Parameters are copies, so bump modifies its local copy; n stays 5. To change n you would pass &n."
    difficulty: 3
```