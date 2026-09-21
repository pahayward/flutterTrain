---
id: 05-tooling
title: "Tooling: gofmt, go vet, go doc"
order: 5
section: 00-foundations
language: golang
summary: "Why format-vs-fight, running the tools, go help"
tags: [gofmt, go-vet, go-doc, tooling]
---

# Tooling: gofmt, go vet, go doc

Go ships with a powerful set of built-in tools. No IDE plugins, no config
files — just run them from the terminal.

## Why `gofmt`? Format, don't fight

Every other language has style wars — tabs vs spaces, brace placement, line
length. Go solved this with `gofmt`: a tool that formats **all** Go code to
one canonical style.

- Every Go project looks the same.
- Code reviews focus on logic, not formatting.
- Zero time spent on style debates.

> [!key] `gofmt` is non-negotiable
> The Go community expects `gofmt`'d code. Submitting unformatted code in a
> Go project is considered unprofessional.

### Running `gofmt`

```bash
# Format a file in place
gofmt -w main.go

# Format all Go files in the current directory
gofmt -w .

# Show what would change without modifying (dry run)
gofmt -d main.go
```

## `go vet` — static analysis

`go vet` catches common mistakes that the compiler doesn't flag:

- Incorrect format string arguments (`fmt.Sprintf("%s", 42)` with wrong types)
- Unreachable code
- Suspicious assignments
- Missing printf arguments

```bash
go vet ./...
```

> [!trap] Don't ignore `go vet` warnings
> `go vet` catches real bugs. Treat its output as errors, not suggestions.

### `go doc` — instant documentation

No internet needed. Read docs for any standard library package or your own
code:

```bash
# Package docs
go doc fmt

# Specific function
go doc fmt.Println

# Your own project (from the project root)
go doc ./...
```

## The full toolchain at a glance

| Tool | Purpose |
|---|---|
| `go build` | Compile to binary |
| `go run` | Compile and run |
| `go test` | Run tests |
| `go fmt` | Alias for `gofmt -l -w` |
| `go vet` | Static analysis |
| `go doc` | Documentation |
| `go mod` | Module management |
| `go get` | Add/update dependencies |
| `go list` | List packages |
| `go env` | Show Go environment |

> [!tip] `go fmt` vs `gofmt`
> `go fmt` is a thin wrapper around `gofmt`. They produce identical output.
> Use whichever you prefer — most people use `go fmt` for convenience.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the primary purpose of `gofmt`?"
    type: single
    choices:
      - "Optimize code for speed"
      - "Format all Go code to a canonical style"
      - "Check for security vulnerabilities"
      - "Compile Go to machine code"
    answer: [1]
    explanation: "`gofmt` enforces a single formatting style across all Go code, eliminating style debates."
    difficulty: 1
  - id: q2
    prompt: "Which tool catches bugs like incorrect `fmt` format strings?"
    type: single
    choices:
      - "gofmt"
      - "go doc"
      - "go vet"
      - "go mod"
    answer: [2]
    explanation: "`go vet` performs static analysis and catches suspicious code patterns including format string mismatches."
    difficulty: 1
  - id: q3
    prompt: "How do you view documentation for the `strings` package without internet?"
    type: single
    choices:
      - "strings --help"
      - "go doc strings"
      - "strings docs"
      - "go help strings"
    answer: [1]
    explanation: "`go doc strings` reads documentation from the local Go installation — no internet required."
    difficulty: 1
```
