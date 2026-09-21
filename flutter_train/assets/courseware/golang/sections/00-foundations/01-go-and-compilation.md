---
id: 01-go-and-compilation
title: "How Go works: the compilation model"
order: 1
section: 00-foundations
language: golang
summary: "Compile → link → binary, goroutine scheduler, static linking, ecosystem"
tags: [compilation, binary, goroutines, static-linking]
---

# How Go works: the compilation model

Go is a **compiled** language. You write source code, a compiler turns it into a
native binary, and that binary runs without an interpreter or virtual machine.

## Compile → link → binary

When you run `go build`, the Go toolchain does two things in sequence:

1. **Compilation** — each `.go` file is compiled into an object file containing
   machine code and metadata.
2. **Linking** — object files and any required library code are combined into a
   single **static binary**.

The result is one executable file with **no runtime dependencies**. No shared
libraries, no virtual machine, no installation step on the target machine.

> [!key] Static linking means easy deployment
> A Go binary built on Linux x86 can be copied to another Linux x86 machine and
> run immediately — no `apt install`, no Docker, no version manager needed.

## Go vs Python vs C

| Feature | Go | Python | C |
|---|---|---|---|
| Execution | Compiled → native binary | Interpreted (bytecode) | Compiled → native binary |
| Runtime dependency | None | Python interpreter | C runtime / libc |
| Garbage collected | Yes | Yes | No |
| Concurrency model | Goroutines (built-in) | GIL / threads | pthreads |
| Typical build speed | Fast | N/A | Slow |

> [!tip] Go's speed sweet spot
> Go compiles as fast as a scripting language feels, but produces binaries as
> fast as C. That combination is rare.

## Goroutine scheduler

Go includes a **runtime** that manages goroutines — lightweight green threads
scheduling across OS threads. You don't need to manually manage threads or
thread pools.

```
Goroutine 1 ──┐
Goroutine 2 ──┤
Goroutine 3 ──┼──→ Go Scheduler ──→ OS Thread 1
               │                      OS Thread 2
               │                      OS Thread 3
```

The scheduler multiplexes thousands (or millions) of goroutines onto a small
number of OS threads. This is why `go func()` is practically free — a goroutine
starts at just a few KB of stack.

## Ecosystem and design goals

Go was designed at Google with these priorities:

- **Fast compilation** — large codebases compile in seconds.
- **Simple concurrency** — goroutines + channels, not complex thread APIs.
- **Static binaries** — deploy anywhere with zero dependencies.
- **Readable code** — one standard format (`gofmt`), explicit error handling.
- **Practical tooling** — built-in formatter, tester, profiler, doc generator.

> [!note] Go's philosophy
> "Don't communicate by sharing memory; share memory by communicating."
> This channels-over-locks principle shapes every Go program.

## A quick taste

```go eval=no
package main

import "fmt"

func main() {
    msg := "Go compiles to a native binary"
    fmt.Println(msg)
}
```

In yaegi we can run the same logic without the `package`/`import` wrapper:

```go
import "fmt"

msg := "Go compiles to a native binary"
fmt.Println(msg)
```

```go eval=no
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Println("CPUs available:", runtime.NumCPU())
    fmt.Println("Goroutines use lightweight threads")
}
```

And a simplified version that works on-device:

```go
import "fmt"

n := 2 + 3
fmt.Println("Go links everything into one binary:", n)
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What happens when you run `go build` on a Go source file?"
    type: single
    choices:
      - "It produces bytecode for a virtual machine"
      - "It compiles and links into a static native binary"
      - "It interprets the file line by line"
      - "It transpiles Go to C source code"
    answer: [1]
    explanation: "Go compiles source to object files, then links them into a single static binary with no external dependencies."
    difficulty: 1
  - id: q2
    prompt: "Why are Go binaries easier to deploy than Python scripts?"
    type: single
    choices:
      - "Go binaries are smaller in file size"
      - "Go binaries are statically linked with no runtime dependency"
      - "Go binaries include an embedded Python interpreter"
      - "Go binaries auto-install dependencies on first run"
    answer: [1]
    explanation: "Static linking bundles everything the binary needs — no interpreter or shared library must be present on the target machine."
    difficulty: 1
  - id: q3
    prompt: "What does Go's goroutine scheduler do?"
    type: single
    choices:
      - "Compiles goroutines into OS threads at build time"
      - "Multiplexes many goroutines onto a small number of OS threads at runtime"
      - "Prevents goroutines from running in parallel"
      - "Assigns each goroutine its own dedicated OS thread"
    answer: [1]
    explanation: "The scheduler runs at runtime and maps lightweight goroutines onto OS threads, allowing millions of goroutines with minimal overhead."
    difficulty: 2
```
