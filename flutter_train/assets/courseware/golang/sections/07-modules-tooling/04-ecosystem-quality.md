---
id: 04-ecosystem-quality
title: Ecosystem & code quality
order: 4
section: 07-modules-tooling
language: golang
summary: gofmt, go vet, staticcheck/golangci-lint, gold standards, and Go's documentation culture.
tags: [gofmt, go-vet, staticcheck, golangci-lint, docs, quality]
---

# Ecosystem & code quality

A language is only as good as its habits. Go's ecosystem made three tools nearly mandatory — one formatter and two analyzers — and built a documentation culture the rest of the industry borrows from.

## gofmt — one style to rule them all

`gofmt` (invoked as `go fmt`) rewrites source into the canonical Go formatting: consistent tabs, aligned fields, no trailing whitespace. There is exactly one way to format Go, so **arguments about formatting vanish**.

```bash eval=no
gofmt -w file.go       # rewrite the file in place
go fmt ./...           # format the whole module
gofmt -d file.go       # print the diff without touching the file
```

> [!key]
> `gofmt` is idempotent and safe, which is why it runs in pre-commit hooks and CI (`gofmt -l .` lists files that need formatting). It never changes *meaning*, only layout. `goimports` adds the bonus of managing import blocks.

This toy recreates what gofmt does to struct fields — aligning names into a column:

```go
import "fmt"

type field struct{ name, kind string }

fields := []field{
	{"id", "string"},
	{"count", "int"},
	{"name", "string"},
}

width := 0
for _, f := range fields {
	if len(f.name) > width {
		width = len(f.name)
	}
}

fmt.Println("gofmt aligns fields into columns:")
for _, f := range fields {
	fmt.Printf("\t%-*s %s\n", width, f.name+":", f.kind)
}
```

> [!trap]
> After a big refactor, run `go fmt ./...` before reviewing the diff — otherwise every reviewer fights whitespace noise and real changes get lost. Editors like `gopls` reformat on save by default.

## go vet — the built-in checker

`go vet` analyzes your code for **suspicious or plain-wrong constructions** that still compile: wrong `Printf` verbs, unreachable code, incorrect `fmt` calls, shadowed variables, bogus struct tags, and more.

```bash eval=no
go vet ./...
```

It is fast, opinionated, and always startable — run it in CI on every push, not just before release. Warnings are strong clues of real bugs.

```go
import "fmt"
import "strings"

// Some exported API surface of a hypothetical package.
api := []struct{ name, doc string }{
	{"Sum", "Sum returns the total of a slice."},
	{"Average", ""}, // no doc comment — a style violation
}

fmt.Println("doc-comment audit (the kind of check linters add):")
for _, s := range api {
	// Good doc comments start with the name they document.
	if strings.HasPrefix(s.doc, s.name) {
		fmt.Println("  ok   :", s.name)
	} else {
		fmt.Println("  LINT :", s.name, "is exported but has no (or a badly named) doc comment")
	}
}
```

> [!note]
> The doc-comment rule above is enforced by **linters** (golint, staticcheck, golangci-lint), not by `go vet` itself. vet focuses on correctness bugs; linters add style and maintainability rules. Together they form a lint pyramid: `gofmt` → `vet` → linters.

## staticcheck and golangci-lint

Two widely used third-party lint suites live one level above vet:

```bash eval=no
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./...

go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
golangci-lint run
```

- **staticcheck** — a curated, high-signal set of analyses (misused struct tags, useless code, bad error handling).
- **golangci-lint** — a *runner* that aggregates dozens of linters (including staticcheck, govet rules, gofmt checks, revive, gosec) under one command and one config file.

> [!tip]
> Add golangci-lint to CI, fail the build on new issues, and let it grow alongside the codebase. A single config file (`golangci.yml`) decides which linters are on.

## Gold standards of the ecosystem

Beyond tools, well-regarded Go projects share habits:

- **Ships formatted**: `go fmt` output — no style debates in review.
- **Lint-clean before merge**: vet + staticcheck/golangci-lint pass in CI.
- **Compiles without warnings and with tests**: `go test ./...` in the same CI step.
- **Small, focused functions** with obvious names; the code reads like a spec.
- **Coverage that is real**: tests assert behaviour, not just "ran".
- **Follows official guidance**: `Effective Go`, the `golang.org/wiki/CodeReviewComments` checklist, and the [Go Proverbs](https://go-proverbs.github.io).

> [!warning]
> "Gold standard" is not about being perfect on day one — it's about **momentum**: each commit is one tiny step of formatting, linting, testing, and documenting. Code that follows these habits is dramatically cheaper for the next reader (often future-you).

## Documentation culture

Excellent Go docs follow a simple, enforceable rule: **every exported name gets a doc comment that begins with the name.**

```go eval=no title="sum.go"
// Sum returns the total of the integers in vals.
// The name starts the sentence: this is the Go convention.
func Sum(vals ...int) int { ... }
```

```go eval=no title="sum_test.go"
func ExampleSum() {
	fmt.Println(Sum(1, 2, 3))
	// Output: 6
}
```

> [!key]
> `ExampleSum` is not just a human-readable example — it is an **executable test**. `go test` runs the function and compares real output against the `// Output:` comment. Documentation that lies fails CI. That is the heart of Go's docs culture: the documentation is tested, formatted, and linted like any other code.

```bash eval=no
go test -run Example ./...   # run the examples as tests
```

Package-level doc comments become the page at `pkg.go.dev`, so `// Package` summaries read like a short marketing blurb for how to use the whole API.

## Summary

- `gofmt`/`go fmt` — one canonical, idempotent style; run it everywhere, always.
- `go vet` — built-in static analysis for construction errors; run it in CI.
- `staticcheck`/`golangci-lint` — stricter, aggregated lint suites with high signal.
- Gold standards: formatted, lint-clean, tested, doc-commented code in small focused pieces.
- Doc comments begin with the name; `Example` functions triple as docs, tests, and demos.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which tool rewrites Go source into the single canonical format and never changes its meaning?"
    type: single
    choices:
      - "gofmt / go fmt"
      - "go vet"
      - "staticcheck"
      - "go mod tidy"
    answer: [0]
    explanation: "gofmt is the official, idempotent formatter; vet and staticcheck analyze, tidy manages dependencies."
    difficulty: 1
  - id: q2
    prompt: "Which statement best describes what go vet does?"
    type: single
    choices:
      - "It reformats code to the canonical style."
      - "It flags suspicious or incorrect code that still compiles, such as wrong Printf verbs or unreachable code."
      - "It downloads missing dependencies."
      - "It runs your tests and reports failures."
    answer: [1]
    explanation: "go vet is a built-in static analyzer for construction errors that the compiler allows; test running belongs to go test."
    difficulty: 1
  - id: q3
    prompt: "How does golangci-lint relate to staticcheck?"
    type: single
    choices:
      - "It replaces the go compiler."
      - "It is a runner that aggregates many linters, including staticcheck, under one command and config."
      - "It is the same program renamed."
      - "It only works inside vendored modules."
    answer: [1]
    explanation: "golangci-lint orchestrates a suite of linters (staticcheck, govet, revive, gosec, etc.) with a single config file and exit code."
    difficulty: 2
```