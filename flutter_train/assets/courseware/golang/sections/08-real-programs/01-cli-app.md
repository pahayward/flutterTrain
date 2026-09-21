---
id: 01-cli-app
title: "Building a CLI tool"
order: 1
section: 08-real-programs
language: golang
summary: "flags package, os.Args, exit codes, reading stdin, small real tool walkthrough"
tags: [cli, flags, stdin, exit-codes]
---

# Building a CLI tool

Go is one of the best languages for command-line tools. The standard library
gives you everything you need: argument parsing, stdin/stdout, exit codes — all
built in.

## os.Args: the raw arguments

`os.Args` is a `[]string` holding the program name plus every argument passed on
the command line.

```go
import "fmt"
import "os"

for i, arg := range os.Args {
    fmt.Println(i, arg)
}
```

When you run `./tool hello world`, you get:

```
0 ./tool
1 hello
2 world
```

> [!note] Index 0 is the program name
> Always skip `os.Args[0]` when processing user arguments — it's the binary
> itself, not something the user typed.

## The flags package

Manually parsing `os.Args` gets messy fast. The `flag` package handles
positional arguments, `-flag value` pairs, and `--flag=value` syntax
automatically. Use `FlagSet` for isolated parsing:

```go
import "flag"
import "fmt"

fs := flag.NewFlagSet("greet", flag.ContinueOnError)
name := fs.String("name", "world", "greeting target")
count := fs.Int("repeat", 1, "number of greetings")
fs.Parse([]string{"-name", "Go", "-repeat", "2"})

for i := 0; i < *count; i++ {
    fmt.Println("Hello,", *name)
}
```

Running `./greet -name Go -repeat 2` outputs:

```
Hello, Go
Hello, Go
```

> [!tip] flag.Parse() must come first
> Call `fs.Parse()` before reading any flag values. Flags are parsed from the
> argument slice; positional (non-flag) arguments are left in `fs.Args()`.

## Reading non-flag arguments

After `Parse()`, anything that isn't a flag lands in `fs.Args()`:

```go
import "flag"
import "fmt"

fs := flag.NewFlagSet("ls", flag.ContinueOnError)
verbose := fs.Bool("v", false, "verbose output")
fs.Parse([]string{"-v", "a.txt", "b.txt", "c.txt"})

files := fs.Args()
if *verbose {
    fmt.Println("Processing", len(files), "files")
}
for _, f := range files {
    fmt.Println("File:", f)
}
```

Running `./ls -v a.txt b.txt c.txt` outputs:

```
Processing 3 files
File: a.txt
File: b.txt
File: c.txt
```

## Exit codes

Convention matters for CLI tools. Use `os.Exit` to communicate success or
failure to the shell:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse / bad arguments |

```go eval=no
import "fmt"
import "os"

if len(os.Args) < 2 {
    fmt.Println("usage: tool <name>")
    os.Exit(2) // bad arguments
}
```

> [!warning] Exit codes are invisible but important
> Scripts and CI pipelines check `$?` after running your tool. A non-zero exit
> code signals failure. This block is `eval=no` because `os.Exit` kills the
> interpreter process.

## Reading from stdin

Many Unix tools read from stdin when no file is given. Go's `bufio.Scanner`
makes this easy. In a real program you'd use `os.Stdin`:

```go eval=no
import "bufio"
import "fmt"
import "os"
import "strings"

scanner := bufio.NewScanner(os.Stdin)
count := 0
for scanner.Scan() {
    line := scanner.Text()
    if strings.TrimSpace(line) != "" {
        count++
    }
}
fmt.Println("Non-empty lines:", count)
```

Reading from `os.Stdin` would block waiting for keyboard input, so here we
demonstrate the same `Scanner` loop with an in-memory reader:

```go
import "bufio"
import "fmt"
import "strings"

input := "hello world\nsecond line\n\n"
scanner := bufio.NewScanner(strings.NewReader(input))
count := 0
for scanner.Scan() {
    line := scanner.Text()
    if strings.TrimSpace(line) != "" {
        count++
    }
}
fmt.Println("Non-empty lines:", count)
```

> [!key] The Unix philosophy in Go
> A good CLI tool reads from stdin, writes to stdout, and uses exit codes for
> status. This lets you compose tools with pipes: `cat data.txt | ./tool | sort`.

## Putting it together: a word counter

Here's a small but real tool that combines flags, stdin reading, and a report.
The only swap for the sandbox is the input source:

```go
import (
    "bufio"
    "flag"
    "fmt"
    "strings"
)

fs := flag.NewFlagSet("wc", flag.ContinueOnError)
upper := fs.Bool("upper", false, "output in uppercase")
fs.Parse([]string{"-upper"})

input := "go is a compiled language\nstatic binaries are nice\n"
total := 0
scanner := bufio.NewScanner(strings.NewReader(input))
for scanner.Scan() {
    total += len(strings.Fields(scanner.Text()))
}

msg := fmt.Sprintf("Total words: %d", total)
if *upper {
    msg = strings.ToUpper(msg)
}
fmt.Println(msg)
```

> [!trap] Don't forget the os import
> The word counter reads from `os.Stdin`, which requires `import "os"`. In a
> standalone program this is obvious; in a code block it's easy to miss.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is `os.Args[0]`?"
    type: single
    choices:
      - "The first user-provided argument"
      - "The name or path of the program itself"
      - "An empty string if no arguments are given"
      - "The value of the first flag"
    answer: [1]
    explanation: "os.Args[0] is always the program name or path. User arguments start at index 1."
    difficulty: 1
  - id: q2
    prompt: "Which function parses command-line flags in Go?"
    type: single
    choices:
      - "flag.Parse()"
      - "flag.Read()"
      - "os.ParseArgs()"
      - "flag.Load()"
    answer: [0]
    explanation: "flag.Parse() reads os.Args and populates the registered flag variables."
    difficulty: 1
  - id: q3
    prompt: "After flag.Parse(), where are non-flag positional arguments found?"
    type: single
    choices:
      - "os.Args"
      - "flag.Args()"
      - "flag.Rest()"
      - "os.Positional()"
    answer: [1]
    explanation: "flag.Args() returns a slice of the remaining non-flag arguments."
    difficulty: 2
  - id: q4
    prompt: "What exit code conventionally signals success?"
    type: single
    choices:
      - "1"
      - "0"
      - "-1"
      - "255"
    answer: [1]
    explanation: "Exit code 0 means success in Unix convention. Non-zero indicates various error conditions."
    difficulty: 1
```
