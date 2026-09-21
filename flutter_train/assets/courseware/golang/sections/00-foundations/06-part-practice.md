---
id: 06-part-practice
title: "Part 0 Practice"
order: 6
section: 00-foundations
language: golang
summary: "Section review and exam questions for the Foundations part"
tags: [practice, exam, review]
---

# Part 0 Practice

## Section review

You've covered the fundamentals of how Go works:

- **Compilation model** — Go compiles source to object files, links them into
  static binaries. No runtime dependencies, no interpreter needed.
- **First program** — `package main` + `func main()` is all you need.
  Use `go run`, `go build`, or `go install` to execute code.
- **Variables and types** — Statically typed with type inference. `:=` for
  local declarations, `var` for explicit. Every type has a zero value.
- **Constants** — Compile-time values with `const`. Use `iota` for sequential
  enums and flag sets.
- **Tooling** — `gofmt` formats code, `go vet` catches bugs, `go doc` reads
  docs. All built-in, all zero-config.

```go
import "fmt"

const greeting = "Go foundations review"
var count int
count = 42
fmt.Println(greeting, "- count:", count)
```

```go
import "fmt"

const (
    Debug = iota
    Info
    Warn
    Error
)
level := Info
switch level {
case Debug:
    fmt.Println("debug")
case Info:
    fmt.Println("info")
case Warn:
    fmt.Println("warn")
case Error:
    fmt.Println("error")
}
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the zero value of a string in Go?"
    type: single
    choices:
      - "nil"
      - "\"\" (empty string)"
      - "0"
      - "\"undefined\""
    answer: [1]
    explanation: "The zero value of `string` is the empty string \"\", not `nil` or `0`."
    difficulty: 1
  - id: q2
    prompt: "Which command compiles a Go file and places the binary in $GOPATH/bin?"
    type: single
    choices:
      - "go build"
      - "go run"
      - "go install"
      - "go fmt"
    answer: [2]
    explanation: "`go install` builds and copies the binary to $GOPATH/bin for global access."
    difficulty: 1
  - id: q3
    prompt: "What does `iota` represent inside a `const` block?"
    type: single
    choices:
      - "A runtime counter"
      - "A compile-time auto-incrementing integer"
      - "A type conversion function"
      - "A package-level variable"
    answer: [1]
    explanation: "`iota` is a compile-time constant that auto-increments starting from 0 within each `const` block."
    difficulty: 2
  - id: q4
    prompt: "What does `go vet` check for?"
    type: single
    choices:
      - "Code formatting consistency"
      - "Suspicious code patterns and common mistakes"
      - "Missing documentation comments"
      - "Unused imports only"
    answer: [1]
    explanation: "`go vet` performs static analysis to find suspicious code patterns, format string errors, unreachable code, and other common bugs."
    difficulty: 2
```

## ExamQuestions

```yaml
bank:
  - prompt: "What does `go build` produce?"
    type: single
    choices:
      - "Bytecode for a VM"
      - "A static native binary"
      - "An interpreted script"
      - "A shared library"
    answer: [1]
    explanation: "`go build` compiles and links into a static native binary with no runtime dependencies."
    weight: 2
    section: 00-foundations
  - prompt: "What is the entry point for a Go executable?"
    type: single
    choices:
      - "func init() in any package"
      - "func main() in package main"
      - "func Start() in package main"
      - "func run() in package app"
    answer: [1]
    explanation: "An executable Go program requires `func main()` inside `package main`."
    weight: 3
    section: 00-foundations
  - prompt: "What is the zero value of a boolean in Go?"
    type: single
    choices:
      - "true"
      - "nil"
      - "0"
      - "false"
    answer: [3]
    explanation: "The zero value of `bool` is `false`. Go guarantees all variables start with a defined zero value."
    weight: 2
    section: 00-foundations
  - prompt: "Which line correctly declares and initializes two variables using short declaration?"
    type: single
    choices:
      - "var a, b = 1, 2"
      - "a, b := 1, 2"
      - "a := 1; b := 2"
      - "let a, b = 1, 2"
    answer: [1]
    explanation: "`a, b := 1, 2` is the idiomatic short declaration for multiple local variables."
    weight: 3
    section: 00-foundations
```
