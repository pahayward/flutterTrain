---
id: 05-part-practice
title: Part 7 Practice
order: 5
section: 07-modules-tooling
language: golang
summary: Review of modules, testing, benchmarks, and ecosystem quality; exam-bank questions.
tags: [review, practice, exam]
---

# Part 7 Practice

## Section review

Part 7 turned "shape" (language, stdlib, concurrency) into **process**. The four skills together make you productive in any real Go codebase:

**1. Modules** — every project is a module. `go.mod` declares identity (`module path`) and pinned requirements; `go.sum` locks cryptographic hashes. Let the tools edit them: `go get`, `go mod tidy`, `go mod download`. `replace` reroutes a dependency to a fork or a local directory; `vendor/` snapshots all sources for hermetic builds; `go.work` groups local modules during development. Versions are semver, and `v2+` modules carry a `/v2` path suffix so major versions coexist.

**2. Testing** — `go test` plus the `testing` package is all you need. Tests are `func TestXxx(t *testing.T)` in `*_test.go` files next to the code. Table-driven tests keep data separate from logic. `t.Errorf` reports and continues; `t.Fatalf` stops the current test. `-cover` reports statement coverage so you can find gaps.

**3. Benchmarks & profiling** — benchmarks loop over `b.N`, calibrated by the harness; output is `ns/op`, plus `B/op` and `allocs/op` with `-benchmem`. Fix dead-code elision by keeping results used. `-cpuprofile`/`-memprofile` hand a profile to `go tool pprof` (`top`, `list`, `web`) so optimization targets measured hot spots, never guesses.

**4. Ecosystem & quality** — the lint pyramid: `gofmt` for the one true style, `go vet` for construction errors, and `staticcheck`/`golangci-lint` for deeper suites — all in CI. Gold-standard habits: exported names with doc comments starting with the name, tested `Example` functions that double as executable docs, small focused functions, and continuous momentum over perfection.

A last taste that shows how modules, a `replace`-style resolution, and test-style checks combine into one small program:

```go
import "fmt"

replaces := map[string]string{
	"github.com/acme/db": "github.com/me/db-fork v0.1.0",
}

resolve := func(mod string) string {
	if fork, ok := replaces[mod]; ok {
		return "replace -> " + fork
	}
	return "upstream " + mod
}

check := func(got, want string) bool {
	if got == want {
		fmt.Println("PASS", got)
		return true
	}
	fmt.Printf("FAIL got %q, want %q\n", got, want)
	return false
}

ok := check(resolve("github.com/acme/db"), "replace -> github.com/me/db-fork v0.1.0")
ok = check(resolve("github.com/acme/api"), "upstream github.com/acme/api") && ok

fmt.Println("all checks passed:", ok)
```

Before the exam, make sure you can answer all four of these cold — they sample each module of Part 7.

## ExamQuestions

```yaml
bank:
  - prompt: "go get fetched a package but go.mod was not updated. Which command reconciles go.mod and go.sum with the code?"
    question: "go get fetched a package but go.mod was not updated. Which command reconciles go.mod and go.sum with the code?"
    type: single
    choices:
      - "go run"
      - "go mod tidy"
      - "go build -tags all"
      - "go vet"
    answer: [1]
    explanation: "go mod tidy adds missing requirements, removes unused ones, and repairs go.sum; go run and go build only compile."
    weight: 4
    difficulty: 1
    section: 07-modules-tooling
  - prompt: "Which file records cryptographic checksums of module files so downloads are verified against what other developers used?"
    question: "Which file records cryptographic checksums of module files so downloads are verified against what other developers used?"
    type: single
    choices:
      - "go.mod"
      - "go.sum"
      - "go.work"
      - "modules.txt"
    answer: [1]
    explanation: "go.sum stores SHA-256 hashes of every downloaded module file; builds verify downloaded content against them."
    weight: 3
    difficulty: 1
    section: 07-modules-tooling
  - prompt: "A benchmark loop must use b.N instead of a hard-coded iteration count because the harness..."
    question: "A benchmark loop must use b.N instead of a hard-coded iteration count because the harness..."
    type: single
    choices:
      - "counts b.N bytes per operation for reporting."
      - "calibrates b.N to a value that yields stable, precise timing."
      - "wants b.N to equal the number of CPUs."
      - "uses b.N only when -benchmem is passed."
    answer: [1]
    explanation: "The testing framework grows b.N until one measurement is statistically reliable, which is why all benchmarks loop over b.N."
    weight: 3
    difficulty: 2
    section: 07-modules-tooling
  - prompt: "What do go vet and staticcheck have in common?"
    question: "What do go vet and staticcheck have in common?"
    type: single
    choices:
      - "Both reformat source code into the official style."
      - "Both are static analysis tools that flag suspicious code without running it."
      - "Both compile C code used by cgo."
      - "Both manage module versions."
    answer: [1]
    explanation: "vet is the built-in analyzer and staticcheck a curated suite; both inspect source statically for bugs, unlike formatters (gofmt) or the module toolchain (go get/go mod)."
    weight: 3
    difficulty: 2
    section: 07-modules-tooling
```