---
id: 06-part-practice
title: "Part 8 Practice"
order: 6
section: 08-real-programs
language: golang
summary: "Review + exam questions for writing real Go programs"
tags: [practice, exam, review]
---

# Part 8 Practice

## Section review

In this section you learned how to build real Go programs:

- **CLI tools** — use the `flag` package for argument parsing, `bufio.Scanner`
  for stdin, and exit codes to signal success or failure.
- **HTTP servers** — `net/http` gives you handlers, routing, JSON responses,
  middleware composition, and graceful shutdown — all in the standard library.
- **Data pipelines** — `encoding/json` and `encoding/csv` for structured data;
  `io.Reader`/`io.Writer` interfaces for composable streaming; error channels
  for propagating failures.
- **Project structure** — `cmd/` for entry points, `internal/` for private
  packages, exported names via capitalization, design packages around team
  boundaries.
- **Cross-compilation** — `GOOS` + `GOARCH` for any target, `CGO_ENABLED=0`
  for static builds, gomobile for Android/iOS, yaegi for embedded Go
  interpretation.

> [!key] The big picture
> Go's standard library is remarkably complete. Most programs need no external
> dependencies. Start with the stdlib — add packages only when the stdlib
> genuinely falls short.

> [!trap] Sandbox rules to remember
> The embedded yaegi engine wraps every snippet in `func main()` and hoists its
> imports. Blocks that block forever (`ListenAndServe`), need `os.Exit`, or read
> the live keyboard (`os.Stdin`) are tagged `eval=no` in these lessons.

## ExamQuestions

```yaml
bank:
  - question: "`os.Args[0]` in a Go CLI program is:"
    type: single
    choices:
      - "The first user-provided argument"
      - "The program name or path"
      - "An empty string"
      - "The value of the -v flag"
    answer: [1]
    explanation: "os.Args[0] is always the binary's name or path; user arguments start at index 1."
    weight: 4
    section: 08-real-programs
  - question: "What does `http.HandleFunc` do?"
    type: single
    choices:
      - "It creates an HTTP client"
      - "It registers a handler function for a URL pattern"
      - "It sends an HTTP request"
      - "It starts a TCP listener"
    answer: [1]
    explanation: "HandleFunc registers a function to handle HTTP requests matching a given URL pattern."
    weight: 4
    section: 08-real-programs
  - question: "Which type must implement `Read(p []byte) (int, error)`?"
    type: single
    choices:
      - "io.Reader"
      - "io.Writer"
      - "io.Closer"
      - "json.Marshaler"
    answer: [0]
    explanation: "io.Reader requires a Read method that fills a byte slice and returns bytes read plus an error."
    weight: 4
    section: 08-real-programs
  - question: "Which environment variables control Go cross-compilation targets?"
    type: single
    choices:
      - "CC and CXX"
      - "GOOS and GOARCH"
      - "GOPATH and GOROOT"
      - "TARGET_OS and TARGET_ARCH"
    answer: [1]
    explanation: "GOOS sets the target OS and GOARCH sets the CPU architecture for cross-compilation."
    weight: 4
    section: 08-real-programs
```
