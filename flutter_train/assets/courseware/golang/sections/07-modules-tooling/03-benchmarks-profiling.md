---
id: 03-benchmarks-profiling
title: Benchmarks and profiling
order: 3
section: 07-modules-tooling
language: golang
summary: testing.B, benchmark output (ns/op, B/op), -bench flags, pprof basics.
tags: [benchmark, testing.B, pprof, profiling, performance]
---

# Benchmarks and profiling

"Optimize what you measured, never what you guessed." Go gives you the measuring tape built in: benchmarks via `testing.B`, and CPU/memory profiles driven by `pprof`.

## Writing a benchmark

A benchmark lives in a `_test.go` file and looks like a test with a different name and type:

```go eval=no title="title_test.go"
func BenchmarkTitle(b *testing.B) {
	for i := 0; i < b.N; i++ {
		title("go zero to hero")
	}
}
```

The loop over `b.N` is the whole trick. `b.N` is not fixed: the harness **calibrates** it, increasing the iteration count until timing is stable and precise.

```bash eval=no
go test -run=^$ -bench=. -benchmem ./...
```

The `-run=^$` says "no tests please, only benchmarks"; `-bench=.` matches every benchmark; `-benchmem` also reports allocations.

Example output:

```bash eval=no
BenchmarkTitle-8              58263             20623 ns/op            128 B/op           8 allocs/op
ok   example.com/logger        1.321s
```

| Piece | Meaning |
|---|---|
| `BenchmarkTitle-8` | benchmark name; `-8` = GOMAXPROCS (CPUs) it ran under |
| `58263` | iterations the harness finally used for one measurement |
| `20623 ns/op` | average nanoseconds per iteration (lower = faster) |
| `128 B/op` | bytes allocated per iteration |
| `8 allocs/op` | heap allocations per iteration |

> [!trap]
> A benchmark that discards its result can be optimized away entirely — `go test` may conclude the work is unused. Keep a side effect: assign to a package-level sink (the old `var sink` trick) or return the value. Real Go compilers do bring this back; don't let dead code make your 0 ns/op fantasy.

## A micro-benchmark you can run here

No `go test` binary exists on the device, so this is a hand-rolled timing loop with the same shape — calibrate nothing, just run the function many times and print ns/op:

```go
import "fmt"
import "strings"
import "time"

// The function under test: "go zero to hero" -> "Go Zero To Hero".
title := func(s string) string {
	words := strings.Fields(s)
	for i, w := range words {
		words[i] = strings.ToUpper(w[:1]) + w[1:]
	}
	return strings.Join(words, " ")
}

const reps = 1000

start := time.Now()
for i := 0; i < reps; i++ {
	title("go zero to hero")
}
elapsed := time.Since(start)

fmt.Printf("total %v, %.0f ns/op\n", elapsed, float64(elapsed.Nanoseconds())/reps)
```

## Comparing two implementations

Benchmarks shine when two approaches race. Here a loop and a math formula both sum `1..n`:

```go
import "fmt"
import "time"

loopSum := func(n int) int {
	total := 0
	for i := 1; i <= n; i++ {
		total += i
	}
	return total
}

formulaSum := func(n int) int { return n * (n + 1) / 2 }

measure := func(f func(int) int, reps int) int64 {
	start := time.Now()
	for r := 0; r < reps; r++ {
		_ = f(5000) // keep the result "used" so the call isn't skipped
	}
	return time.Since(start).Nanoseconds()
}

loop := measure(loopSum, 30)
formula := measure(formulaSum, 30)
if formula == 0 {
	formula = 1 // avoid dividing by zero on ultra-fast runs
}

fmt.Println("loop    :", loop, "ns total")
fmt.Println("formula :", formula, "ns total")
fmt.Printf("formula is %.0fx faster here\n", float64(loop)/float64(formula))
```

> [!warning]
> A single synthetic micro-race proves nothing about your whole program — the formula wins in this toy on this interpreter, but real factors like cache behavior, allocation, and caller context decide production speed. Use micro-benchmarks to *hypothesis-check*, then confirm with a profile of the real workload.

## Benchmark flags worth knowing

```bash eval=no
go test -bench=BenchmarkTitle -benchtime=3s ./...   # run each for ~3s
go test -bench=. -count=5 ./...                     # 5 samples for variance
go test -bench=. -benchmem ./...                    # B/op + allocs/op
```

`b.ReportAllocs()` inside the benchmark body forces allocation reporting too, and `b.SetBytes(n)` expresses throughput (`x ns/op` becomes `MB/s`) for benchmarks over byte streams.

> [!tip]
> Run `-count` several times and compare before/after fixes across the *same* environment. One nanosecond "wins" between random runs is noise — look for consistent trends, like 2x or 10x.

## pprof — profiling the real program

pprof samples what the program actually does while it runs:

```bash eval=no
go test -run=^$ -bench=. -cpuprofile cpu.out ./...  # CPU samples while benchmarking
go test -run=^$ -bench=. -memprofile mem.out ./...
go tool pprof cpu.out                               # interactive shell
```

Inside the pprof shell:

```bash eval=no
top                  # the functions consuming the most time
list Sum             # time per line inside Sum
web                  # open a call-graph (flame graph style)
```

- CPU profile tells you **where time goes** (hot loops, waiting, allocations' cost).
- Memory profile tells you **what survives** — `-memprofile` with `-memprofilerate=1` samples all allocations, catching accidental retention.

> [!note]
> The golden workflow: (1) benchmark to reproduce the slowness, (2) profile to find the hot spot — "premature optimization is the root of all evil" — (3) fix *that*, (4) rerun the benchmark to prove the win, (5) repeat. Change one variable per round.

## Summary

- Benchmarks run in `_test.go`, loop over `b.N`, and print `ns/op`, `B/op`, `allocs/op`.
- Read output carefully: `-8` is CPU count, `58263` is iterations, `20623 ns/op` is the timing.
- Don't let results be optimized away; keep side effects alive in the loop.
- For real-world insight, `-cpuprofile` + `go tool pprof` shows exactly where time goes.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What should the loop inside a benchmark use as its bound?"
    type: single
    choices:
      - "A fixed constant such as 1000."
      - "b.N, which the testing harness calibrates for stable timing."
      - "runtime.NumCPU()."
      - "len(os.Args)."
    answer: [1]
    explanation: "b.N is chosen automatically: the harness grows the iteration count until one measurement is statistically stable."
    difficulty: 1
  - id: q2
    prompt: "In the benchmark line \"BenchmarkTitle-8\", what does the suffix -8 mean?"
    type: single
    choices:
      - "The benchmark ran 8 times."
      - "Go version 1.8."
      - "The number of CPUs (GOMAXPROCS) the run used."
      - "8 goroutines per iteration."
    answer: [2]
    explanation: "The number after the dash is GOMAXPROCS, so you can spot timing differences caused by parallelism."
    difficulty: 2
  - id: q3
    prompt: "Which flag makes benchmarks also report bytes and allocations per operation?"
    type: single
    choices:
      - "-benchmem"
      - "-count"
      - "-benchtime"
      - "-race"
    answer: [0]
    explanation: "-benchmem adds B/op (bytes) and allocs/op (allocations) columns to the ns/op output."
    difficulty: 1
  - id: q4
    prompt: "Your app is slow but you don't know why. What is the most reliable first move?"
    type: single
    choices:
      - "Add more goroutines to spread the work."
      - "Rewrite every function using shortcuts you remember."
      - "Measure: write a benchmark or profile, find the real hot spot, then fix it and re-measure."
      - "Disable go vet so builds are faster."
    answer: [2]
    explanation: "Guessing without measurement produces speculative complexity. Measure first, fix the measured hot spot, and prove the change with the same benchmark."
    difficulty: 2
```