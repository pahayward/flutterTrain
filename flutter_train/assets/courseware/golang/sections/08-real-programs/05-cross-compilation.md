---
id: 05-cross-compilation
title: "Cross-compilation: from laptop to everywhere"
order: 5
section: 08-real-programs
language: golang
summary: "GOOS/GOARCH, CGO_ENABLED=0, static builds, building for all platforms, WASM, gomobile deep dive"
tags: [cross-compilation, goos, goarch, wasm, gomobile, android]
---

# Cross-compilation: from laptop to everywhere

One of Go's superpowers is dead-simple cross-compilation. No cross-compiler
toolchain to install — just set two environment variables.

## The GOOS/GOARCH table

Every Go binary targets a **platform** defined by two values:

| Variable | What it means | Examples |
|----------|---------------|---------|
| `GOOS` | Operating system | `linux`, `darwin`, `windows`, `android`, `js` |
| `GOARCH` | CPU architecture | `amd64`, `arm64`, `arm`, `wasm` |

Build commands look like this:

```bash eval=no
# Linux binary for x86-64
GOOS=linux GOARCH=amd64 go build -o myapp-linux-amd64

# macOS binary for Apple Silicon
GOOS=darwin GOARCH=arm64 go build -o myapp-darwin-arm64

# Windows binary
GOOS=windows GOARCH=amd64 go build -o myapp.exe

# Android binary (ARM64)
GOOS=android GOARCH=arm64 go build -o myapp-android
```

> [!key] No cross-compiler needed
> Unlike C/C++, Go's cross-compilation requires zero extra tools. The Go
> toolchain itself contains all the necessary compilers and linkers.

You can inspect your current target and any runtime constants the compiler
bakes in:

```go
import (
    "fmt"
    "runtime"
)

fmt.Println("GOOS:", runtime.GOOS)
fmt.Println("GOARCH:", runtime.GOARCH)
fmt.Println("Compiler:", runtime.Compiler)
```

## Common targets

Here are the platforms you'll most likely encounter:

```bash eval=no
# Server deployments
GOOS=linux   GOARCH=amd64   # most cloud VMs
GOOS=linux   GOARCH=arm64   # AWS Graviton, Raspberry Pi 4+
GOOS=linux   GOARCH=arm     # older Raspberry Pi, embedded

# Desktop
GOOS=darwin  GOARCH=arm64   # Apple Silicon Mac (M1+)
GOOS=darwin  GOARCH=amd64   # Intel Mac
GOOS=windows GOARCH=amd64   # Windows x86-64

# Mobile
GOOS=android GOARCH=arm64   # Android devices
GOOS=android GOARCH=arm     # older Android devices

# Web
GOOS=js      GOARCH=wasm    # WebAssembly for browsers
```

> [!tip] Use `go tool dist list` to see every supported target
> This command prints all valid GOOS/GOARCH combinations your Go installation
> supports.

## Static builds: CGO_ENABLED=0

By default, Go can use CGO for features like DNS resolution and SQLite. For a
truly static binary with **no shared library dependencies**:

```bash eval=no
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o myapp-static
file myapp-static
# myapp-static: ELF 64-bit LSB executable, ... statically linked
```

When `CGO_ENABLED=0`:
- No C compiler is needed
- The binary is fully static — runs on any Linux system
- Some stdlib features that use C (`net`, `os/user`) fall back to pure-Go
  implementations

> [!warning] Set CGO_ENABLED=0 when cross-compiling
> Some toolchains try to use cgo by default. If you forget, cross-compilation
> fails with "cc: not found". Setting `CGO_ENABLED=0` explicitly is a good
> habit.

## Building for Windows from Linux

A common CI/CD scenario — build Windows binaries on a Linux build server:

```bash eval=no
# Cross-compile for Windows
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o myapp.exe

# Cross-compile for macOS
CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -o myapp-darwin
```

Both produce ready-to-run binaries. No Wine, no macOS VM needed.

## Building for WebAssembly

Go can compile to WASM, allowing Go code to run in browsers:

```bash eval=no
# Build a WASM binary
GOOS=js GOARCH=wasm go build -o myapp.wasm

# Copy the JS support file
cp "$(go env GOROOT)/lib/wasm/wasm_exec.js" .
```

The `wasm_exec.js` glue code initializes the Go runtime inside a browser's
WebAssembly VM. Your Go code runs alongside JavaScript.

> [!note] WASM limitations
> The Go WASM runtime is large (~10MB). It works for compute-heavy tasks but
> isn't ideal for small utilities. For lightweight browser needs, consider a
> dedicated JS/TS approach.

## Deep dive: Can Go run on Android?

This is a question every mobile-aware Go developer asks. The answer is **yes**,
and there are several approaches.

### 1. gomobile: standalone apps

`gomobile` is the official tool for building Go apps that run directly on
Android (and iOS) without any Java/Kotlin code:

```bash eval=no
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Build an Android APK directly from Go
gomobile build -target=android -o myapp.apk ./cmd/myapp
```

This produces a full Android APK. Your Go code IS the app — no Android SDK
required beyond what gomobile bundles.

### 2. gomobile bind: Go libraries for Android

More commonly, you embed Go as a **library** inside an Android app:

```bash eval=no
# Generate Java/JNI bindings from a Go package
gomobile bind -target=android -o mylib.aar ./pkg/mylib
```

This produces an `.aar` file (Android Archive) that Java/Kotlin code can
import. The Go functions become Java methods via JNI. This is how Go powers
performance-critical sections of native Android apps.

### 3. The embedded approach: yaegi in Android

This is exactly how **this study app** works:

```
Android app (Kotlin UI)
└── Go engine binary   ← gomobile bind
    └── yaegi interpreter
        └── your Go snippets parsed + evaluated at runtime
```

The app uses `gomobile bind` to embed the **yaegi interpreter** — a pure-Go
interpreter that can parse and execute Go source code at runtime. When you tap
"Run" on a code example in this app:

1. The Go source text is sent to the yaegi interpreter
2. yaegi parses it, evaluates it, and captures `print`/`fmt.Println` output
3. The output is displayed in the app's code viewer

> [!key] Why yaegi?
> yaegi is a Go-to-Go interpreter — it understands Go syntax natively. No
> transpilation, no compilation step. It evaluates Go code directly inside a
> Go binary, which itself runs on Android via gomobile. It's Go all the way
> down.

The yaegi engine builds a fresh `package main` around each snippet, hoisting
imports and wrapping the body in `func main()`. Any snippet runs identically
on your phone and on a server:

```go
import "fmt"

for i := 1; i <= 3; i++ {
    fmt.Println("goroutine-friendly iteration", i)
}
```

> [!note] Why the engine does this
> By inserting `package main` + `func main(){}` automatically, every example is
> a complete runnable program — exactly what a phone-sized interpreter needs.

### 4. WebAssembly on Android

Another option: compile Go to WASM and run it in a WebView:

```bash eval=no
# Build Go as WASM
GOOS=js GOARCH=wasm go build -o engine.wasm

# Load in Android WebView
# <script src="wasm_exec.js"></script>
# <script>
#   const go = new Go();
#   WebAssembly.instantiateStreaming(fetch("engine.wasm"), go.importObject)
# </script>
```

This trades native performance for platform independence — the same WASM binary
works on Android, iOS, and desktop browsers.

> [!note] Trade-offs of each approach

| Approach | Pros | Cons |
|----------|------|------|
| gomobile (full app) | Pure Go, no Java needed | Large binary, limited Android UI |
| gomobile bind | Best of both worlds | Requires JNI bridge layer |
| yaegi + gomobile | Dynamic Go evaluation at runtime | Interpreter overhead, not all stdlib works |
| WASM + WebView | Cross-platform, runs in browser | Slower, large download, limited file access |

## Building a complete binary

Let's tie it together with a minimal program that reports its platform, then
build it for everywhere:

```go
import "fmt"

host := map[string]string{"os": "your-device", "lang": "Go"}
fmt.Println("binary targets:", host["os"], "compiled in", host["lang"])
```

```bash eval=no
# Build for every major platform from your laptop
CGO_ENABLED=0 GOOS=linux   GOARCH=amd64 go build -o app-linux
CGO_ENABLED=0 GOOS=darwin  GOARCH=arm64 go build -o app-mac
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o app.exe
CGO_ENABLED=0 GOOS=js      GOARCH=wasm  go build -o app.wasm

ls -lh app-linux app-mac app.exe app.wasm
```

> [!tip] Automate with a Makefile or script
> Cross-compiling for five targets manually gets old. Put the build commands in
> a `Makefile` or `build.sh` and run it in CI.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which two environment variables control Go cross-compilation targets?"
    type: single
    choices:
      - "CC and CXX"
      - "GOOS and GOARCH"
      - "GOPATH and GOROOT"
      - "BUILD_TARGET and BUILD_ARCH"
    answer: [1]
    explanation: "GOOS specifies the target OS and GOARCH specifies the CPU architecture."
    difficulty: 1
  - id: q2
    prompt: "What does CGO_ENABLED=0 produce?"
    type: single
    choices:
      - "A dynamically-linked binary"
      - "A binary that requires a C compiler"
      - "A fully static binary with no shared library dependencies"
      - "A smaller but less compatible binary"
    answer: [2]
    explanation: "Setting CGO_ENABLED=0 disables cgo and produces a fully static binary."
    difficulty: 2
  - id: q3
    prompt: "How does the yaegi interpreter enable Go code execution inside this Android study app?"
    type: single
    choices:
      - "It compiles Go to Java bytecode"
      - "It transpiles Go to JavaScript first"
      - "It parses and evaluates Go source code directly at runtime"
      - "It uses an Android NDK cross-compiler"
    answer: [2]
    explanation: "yaegi is a pure-Go interpreter that evaluates Go source code in-process, embedded via gomobile bind."
    difficulty: 2
  - id: q4
    prompt: "What does `go tool dist list` show?"
    type: single
    choices:
      - "All installed Go packages"
      - "All installed Go versions"
      - "All supported GOOS/GOARCH cross-compilation targets"
      - "All files in the current project"
    answer: [2]
    explanation: "It lists every valid OS/architecture pair that the Go toolchain can build for."
    difficulty: 1
```
