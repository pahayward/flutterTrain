---
id: 02-first-program
title: "Your first program: build, run, install"
order: 2
section: 00-foundations
language: golang
summary: "package main, func main, go build/run/install, module basics"
tags: [hello-world, package-main, go-run, go-build, go-install]
---

# Your first program: build, run, install

Every Go program starts in `package main` with a `func main()`. That's the
entry point the compiler looks for.

## Anatomy of a minimal program

```go eval=no
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```

On-device we run just the body:

```go
print("Hello, Go!\n")
```

- `package main` — declares an executable (not a library).
- `import "fmt"` — pulls in the standard formatting/printing package.
- `func main()` — the entry point; runs when the binary starts.

> [!key] Library vs executable
> Any package that is **not** `main` is a library. Only `package main` produces
> a runnable binary.

## Three ways to run it

### `go run` — compile and run in one step

```bash
go run hello.go
```

Compiles to a temporary binary, runs it, discards the binary. Perfect for
quick scripts and development.

### `go build` — compile to a binary

```bash
go build -o hello hello.go
```

Produces a persistent executable called `hello` (or `hello.exe` on Windows).
You can distribute it, copy it, deploy it.

### `go install` — compile and put in PATH

```bash
go install
```

Builds the binary and places it in `$GOPATH/bin` (usually `~/go/bin`).
This makes the command available system-wide.

> [!trap] `go install` vs `go build`
> `go build` puts the binary in your **current directory**.
> `go install` puts it in `$GOPATH/bin`. Don't confuse the two when
> scripting.

## Module basics

Modern Go uses **modules** to manage dependencies and project structure.

```bash
# Start a new module
go mod init example.com/hello
```

This creates a `go.mod` file tracking the module path and Go version. You
don't need `go mod init` for single-file scripts, but any real project should
have one.

```bash
# Add dependencies automatically
go mod tidy
```

`go mod tidy` scans your imports and adds missing dependencies to `go.mod`.

## Working example: building and running

```go eval=no
package main

import (
    "fmt"
    "os"
)

func main() {
    name := "Go developer"
    if len(os.Args) > 1 {
        name = os.Args[1]
    }
    fmt.Println("Welcome,", name)
}
```

```go eval=no
package main

import (
    "fmt"
    "strings"
)

func main() {
    phrase := "hello, world"
    fmt.Println(strings.ToUpper(phrase))
}
```

On-device the `strings.ToUpper` example runs like this:

```go
import "fmt"
import "strings"

phrase := "hello, world"
fmt.Println(strings.ToUpper(phrase))
```

> [!tip] Use `go run` during development
> Save time by using `go run` for quick iteration. Only `go build` when you
> need a distributable binary.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What must the main package of a Go executable declare?"
    type: single
    choices:
      - "A `func init()` only"
      - "A `func main()` function"
      - "A `func Start()` function"
      - "An `init` variable"
    answer: [1]
    explanation: "An executable Go program requires `func main()` inside `package main` as the entry point."
    difficulty: 1
  - id: q2
    prompt: "What is the difference between `go build` and `go install`?"
    type: single
    choices:
      - "`go build` discards the binary; `go install` keeps it"
      - "`go build` puts the binary in the current directory; `go install` puts it in `$GOPATH/bin`"
      - "`go install` skips compilation; `go build` compiles"
      - "They are identical in behavior"
    answer: [1]
    explanation: "`go build` creates the binary locally; `go install` builds and copies it to `$GOPATH/bin` for global access."
    difficulty: 1
  - id: q3
    prompt: "Which command creates a new Go module with a `go.mod` file?"
    type: single
    choices:
      - "go new module"
      - "go init module"
      - "go mod init"
      - "go create mod"
    answer: [2]
    explanation: "`go mod init <path>` initializes a module and creates the `go.mod` file."
    difficulty: 1
```
