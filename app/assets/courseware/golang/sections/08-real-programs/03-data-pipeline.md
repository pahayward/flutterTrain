---
id: 03-data-pipeline
title: "Reading and writing data"
order: 3
section: 08-real-programs
language: golang
summary: "Round-trip CSV/JSON, streaming with io, error handling through a pipeline"
tags: [csv, json, io, pipeline, encoding]
---

# Reading and writing data

Real programs process data: read a CSV, transform it, write JSON. Go's `io`
interfaces make these pipelines composable and efficient.

## Reading JSON

`encoding/json` decodes JSON into Go structs or generic maps:

```go
import (
    "encoding/json"
    "fmt"
)

input := `{"name": "Go", "year": 2009, "paradigm": "multi"}`

var lang struct {
    Name     string `json:"name"`
    Year     int    `json:"year"`
    Paradigm string `json:"paradigm"`
}

json.Unmarshal([]byte(input), &lang)
fmt.Printf("%s was created in %d (%s)\n", lang.Name, lang.Year, lang.Paradigm)
```

> [!key] Pointer receivers matter
> `json.Unmarshal` needs a pointer to your struct so it can modify the fields.
> Passing a value copy silently does nothing.

## Writing JSON

Marshal structs back to JSON — useful for API responses and file output:

```go
import (
    "encoding/json"
    "fmt"
)

type Book struct {
    Title  string   `json:"title"`
    Author string   `json:"author"`
    Tags   []string `json:"tags,omitempty"`
}

books := []Book{
    {Title: "The Go Programming Language", Author: "Donovan & Kernighan", Tags: []string{"reference", "classic"}},
    {Title: "Go in Action", Author: "Kennedy, Ketelsen & St. Martin"},
}

data, _ := json.MarshalIndent(books, "", "  ")
fmt.Println(string(data))
```

> [!note] omitempty skips zero values
> The `omitempty` tag means the field is excluded from JSON output when it's
> zero (`""`, `0`, `nil`, `false`). This keeps responses clean.

## Reading CSV

`encoding/csv` reads CSV row by row — memory efficient for large files:

```go
import (
    "encoding/csv"
    "fmt"
    "strings"
)

data := `name,age,city
Alice,30,London
Bob,25,Paris
Charlie,35,Berlin`

reader := csv.NewReader(strings.NewReader(data))
records, _ := reader.ReadAll()

for i, row := range records {
    if i == 0 {
        continue // skip header
    }
    fmt.Printf("%s is %s years old, lives in %s\n", row[0], row[1], row[2])
}
```

## Writing CSV

Build output programmatically and write it back:

```go
import (
    "encoding/csv"
    "fmt"
    "strings"
)

var out strings.Builder
writer := csv.NewWriter(&out)
writer.Write([]string{"language", "year", "compiled"})
writer.Write([]string{"Go", "2009", "yes"})
writer.Write([]string{"Rust", "2010", "yes"})
writer.Write([]string{"Python", "1991", "no"})
writer.Flush()

fmt.Println(out.String())
```

Output:

```
language,year,compiled
Go,2009,yes
Rust,2010,yes
Python,1991,no
```

## Streaming with io.Reader and io.Writer

Go's `io` package provides interfaces that make data processing composable.
Any type that implements `Read(p []byte) (n int, err error)` is an `io.Reader`:

```go
import (
    "fmt"
    "io"
    "strings"
)

// strings.NewReader implements io.Reader
r := strings.NewReader("Hello, streaming world!")

buf := make([]byte, 8)
for {
    n, err := r.Read(buf)
    if n > 0 {
        fmt.Printf("Read %d bytes: %s\n", n, buf[:n])
    }
    if err == io.EOF {
        break
    }
}
```

> [!tip] io.Copy for simple pipelines
> `io.Copy(dst, src)` reads from `src` and writes to `dst` in a loop — the
> simplest way to pipe data between two streams.

## A data pipeline pattern

Chain transformations using goroutines and channels:

```go
import (
    "fmt"
    "strings"
)

// Each stage is a function over channels. `...<-chan` is "producer",
// `<-chan` is "consumer". Go functions are values, so stages compose.
generate := func(words ...string) <-chan string {
    out := make(chan string)
    go func() {
        for _, w := range words {
            out <- w
        }
        close(out)
    }()
    return out
}

filter := func(in <-chan string) <-chan string {
    out := make(chan string)
    go func() {
        for w := range in {
            if strings.HasPrefix(w, "g") || strings.HasPrefix(w, "G") {
                out <- w
            }
        }
        close(out)
    }()
    return out
}

words := []string{"Go", "gopher", "Python", "golang", "Java", "Gin"}
pipeline := filter(generate(words...))

for w := range pipeline {
    fmt.Println("Match:", w)
}
```

## Error handling in pipelines

Always propagate errors through the chain. A common pattern is to use an error
channel alongside the data channel:

```go
import (
    "fmt"
    "strconv"
)

parseNumbers := func(sources []string) (<-chan int, <-chan error) {
    out := make(chan int)
    errs := make(chan error, len(sources)) // buffered: producer never blocks

    go func() {
        defer close(out)
        defer close(errs)
        for _, s := range sources {
            n, err := strconv.Atoi(s)
            if err != nil {
                errs <- fmt.Errorf("parse %q: corrupted", s)
                continue
            }
            out <- n
        }
    }()

    return out, errs
}

data := []string{"1", "2", "oops", "4"}
nums, errs := parseNumbers(data)

for n := range nums {
    fmt.Println("Got:", n)
}
for err := range errs {
    fmt.Println("parse failed:", err)
}
```

> [!note] Buffered error channels
> The `errs` channel is buffered so the goroutine never blocks writing an error
> while nobody is reading yet. Without a buffer, a slow consumer could deadlock
> the pipeline.

> [!trap] Always drain all channels
> When a pipeline has both data and error channels, make sure you read from both
> until both are closed. Otherwise goroutines leak.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Why must you pass a pointer to json.Unmarshal?"
    type: single
    choices:
      - "It's required by Go syntax for all functions"
      - "Unmarshal needs to modify the struct's fields directly"
      - "Pointers are faster than values for JSON decoding"
      - "JSON can only be decoded into pointer types"
    answer: [1]
    explanation: "Unmarshal writes into your struct — a value argument would be a copy that gets discarded."
    difficulty: 1
  - id: q2
    prompt: "What does the `omitempty` JSON tag do?"
    type: single
    choices:
      - "Makes the field required in input"
      - "Includes the field even when empty"
      - "Excludes the field from output when it has a zero value"
      - "Renames the field to lowercase"
    answer: [2]
    explanation: "omitempty tells the encoder to skip the field if its value is the zero value for its type."
    difficulty: 2
  - id: q3
    prompt: "Which interface must a type implement to be an io.Reader?"
    type: single
    choices:
      - "Read(buf []byte) (int, error)"
      - "Read() ([]byte, error)"
      - "IO() []byte"
      - "Stream(w io.Writer) int"
    answer: [0]
    explanation: "io.Reader requires a Read method that fills a byte slice and returns bytes read plus an error."
    difficulty: 2
  - id: q4
    prompt: "What happens if you only read from the data channel in a dual-channel pipeline?"
    type: single
    choices:
      - "The pipeline runs faster"
      - "The program panics immediately"
      - "The error channel's goroutine blocks and leaks"
      - "Errors are silently discarded"
    answer: [2]
    explanation: "If nobody reads from the error channel, the goroutine writing to it blocks forever, causing a goroutine leak."
    difficulty: 3
```
