---
id: 02-testing
title: Testing
order: 2
section: 07-modules-tooling
language: golang
summary: The testing package, Test functions, table-driven tests, subtests, t.Errorf vs t.Fatal, coverage.
tags: [testing, go-test, table-driven, subtests, coverage]
---

# Testing

Testing in Go is built into the toolchain: **no third-party framework required**, just the `testing` package and the `go test` command.

## The rules of adding tests

- A test file lives next to the code it tests and ends in `_test.go` (`math.go`'s tests go in `math_test.go`).
- A test is an exported function named `TestXxx(t *testing.T)`.
- `go test ./...` runs every test in the current module.

```bash eval=no
go test ./...              # run all tests in the module
go test -run TestAdd ./... # run only tests matching TestAdd
go test -v ./...           # verbose: print every test name
```

A minimal real test cannot run in the embedded interpreter (there is no `go test` runner there), so it is shown for reference:

```go eval=no title="add_test.go"
package main

import "testing"

func TestAdd(t *testing.T) {
	got := add(2, 3)
	if got != 5 {
		t.Errorf("add(2, 3) = %d, want 5", got)
	}
}
```

> [!key]
> The signature is sacred: the function must start with `Test` and accept exactly one parameter of type `*testing.T`. The test helper is passed as a **pointer** because it records failures that live on your test's behalf.

## Table-driven tests (the Go idiom)

Instead of copying a test function for every input, put inputs *and expected outputs* in a table and loop:

```go
import "fmt"

add := func(a, b int) int { return a + b }

type testCase struct {
	name string
	a, b int
	want int
}

cases := []testCase{
	{"positive", 2, 3, 5},
	{"negative", -1, 1, 0},
	{"zero", 0, 0, 1}, // deliberate wrong expectation to show FAIL
	{"big", 1000, 999, 1999},
}

failed := 0
for _, tc := range cases {
	got := add(tc.a, tc.b)
	status := "PASS"
	if got != tc.want {
		status = "FAIL"
		failed++
	}
	fmt.Printf("%-4s %s: add(%d,%d) = %d (want %d)\n",
		status, tc.name, tc.a, tc.b, got, tc.want)
}
fmt.Printf("%d/%d cases passed\n", len(cases)-failed, len(cases))
```

This is **the** canonical Go pattern. Adding a new edge case never means writing a new function — it means adding one row to the table.

> [!key]
> Each row usually carries a `name`, the inputs, and a `want` field. The body is identical for every row: run, compare, report. A failing row names itself, so you can tell exactly which input broke.

## Subtests: tests inside tests

Subtests let one `TestXxx` run related scenarios with richer reporting and independent execution — `t.Run(name, func(t *testing.T) { ... })`. A failure in one subtest does not stop the others.

```go
import "fmt"

mul := func(a, b int) int { return a * b }

type sub struct {
	name     string
	a, b     int
	want     int
}

subtests := []sub{
	{"positive", 2, 3, 6},
	{"zero", 7, 0, 0},
	{"negative", -2, 3, -6},
}

// Runs in the same spirit as t.Run: each case is independent.
for _, st := range subtests {
	got := mul(st.a, st.b)
	if got != st.want {
		fmt.Printf("FAIL %s: got %d, want %d\n", st.name, got, st.want)
		continue // the other subtests still run
	}
	fmt.Printf("PASS %s\n", st.name)
}
```

> [!note]
> In real code, `t.Run` names appear in verbose output like `TestMul/negative`, and subtests can be filtered individually (`go test -run 'TestMul/negative'`). Parallel subtests with `t.Parallel()` run concurrently once their sequential siblings finish.

## t.Errorf vs t.Fatal

Both record a failure, but they differ in **flow**:

- `t.Errorf` — records the failure and **continues** the test.
- `t.Fatalf` — records the failure and **stops the current test** immediately (it calls `runtime.Goexit`).

```go
import "fmt"

// t.Errorf flavor: record the failure, keep checking everything else.
errorf := func(failed *bool, msg string) {
	*failed = true
	fmt.Println("  recorded:", msg)
}

failed := false
for _, n := range []int{1, 2, 3} {
	if n%2 == 0 {
		errorf(&failed, fmt.Sprintf("expected odd, got %d", n))
	}
	fmt.Println("  still running, n =", n)
}
fmt.Println("test finished; failed:", failed)

fmt.Println()

// t.Fatalf flavor: abort this test as soon as the condition fails.
check := func(cond bool, msg string) bool {
	if !cond {
		fmt.Println("  FATAL:", msg)
		return false
	}
	return true
}
for i := 1; i <= 3; i++ {
	if !check(i != 2, fmt.Sprintf("value %d unexpected", i)) {
		break // in go test, t.Fatalf would stop the whole test here
	}
	fmt.Println("  checked", i)
}
```

> [!tip]
> Use `Errorf` when a bad row shouldn't hide its siblings (table rows, subtests). Use `t.Fatalf` when continuing is impossible or meaningless — e.g., you could not set up a fixture the rest of the test needs.

## Coverage

Coverage answers *"how much of my code did the tests execute?"*

```bash eval=no
go test -cover ./...
go test -coverprofile=cover.out ./...   # write an HTML-friendly report
go tool cover -html=cover.out           # open graphical report
```

- Go reports **statement coverage**: % of executable statements run by the tests.
- Coverage measures *what you exercised*, not *that it is correct* — 100% coverage with weak assertions is still weak.

> [!trap]
> A common beginner trap: chasing 100% coverage on error paths by deleting asserts. High coverage is a by-product of good tests, not the goal. Strive for solid cases per function, then let `-cover` point at the gaps.

## Summary

- Tests live in `*_test.go` files; `go test ./...` runs them.
- `func TestXxx(t *testing.T)` is the unit of testing, with **table-driven** inputs as the Go idiom.
- `t.Errorf` keeps going; `t.Fatalf` stops the current test.
- Subtests (`t.Run`) group and isolate cases; `-cover` reports statement coverage.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the main benefit of a table-driven test?"
    type: single
    choices:
      - "It runs the test cases in parallel automatically."
      - "It separates test data from test logic, so edge cases are one-row additions."
      - "It guarantees 100% statement coverage."
      - "It removes the need for expected values."
    answer: [1]
    explanation: "A table of input/expected pairs with one shared loop body makes new cases a single row, no new test functions."
    difficulty: 1
  - id: q2
    prompt: "Which statement best describes t.Fatalf?"
    type: single
    choices:
      - "It records a failure and continues executing the remaining checks."
      - "It stops the current test function immediately after reporting."
      - "It stops the entire go test binary, including other packages."
      - "It panics the test and prints a stack trace."
    answer: [1]
    explanation: "t.Fatalf reports and then calls runtime.Goexit, ending that test's goroutine; sibling tests and other packages still run."
    difficulty: 2
  - id: q3
    prompt: "Which is a valid Go test function signature?"
    type: single
    choices:
      - "func TestAdd() { ... }"
      - "func TestAdd(t *testing.T) { ... }"
      - "func TestAdd(t *Tester) { ... }"
      - "func test_add(t *testing.T) { ... }"
    answer: [1]
    explanation: "A test must start with Test and accept exactly one *testing.T parameter; lower-case names are never run by go test."
    difficulty: 1
  - id: q4
    prompt: "What does \"go test -cover ./...\" report?"
    type: single
    choices:
      - "The number of test functions written per package."
      - "The percentage of statements executed by the tests, per package."
      - "Which tests failed and why."
      - "The lines of code changed since the last commit."
    answer: [1]
    explanation: "Coverage is the fraction of executable statements the tests ran. It shows what was exercised, not whether the assertions were strong."
    difficulty: 1
```