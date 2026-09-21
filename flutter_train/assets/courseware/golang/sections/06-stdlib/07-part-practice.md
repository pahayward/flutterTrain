---
id: 07-part-practice
title: Part 6 Practice
order: 7
section: 06-stdlib
language: golang
summary: Review of the Part 6 standard library modules plus exam-style practice questions.
tags: [stdlib, review, practice, exam]
type: lesson
---

# Part 6 Practice

You now hold the everyday toolbox of the Go standard library. This module
recaps each topic with a runnable "kitchen sink" review, then closes with five
exam-style questions that combine the material the way the simulator will.

## Section review

### fmt
Format verbs (`%v`, `%T`, `%d`, `%s`, `%q`, `%x`), width/precision
(`%6.2f`), `Sprintf` for strings, `Errorf` for errors, and `Stringer` for
custom display. `Printf` never adds a newline.

### io
Two interfaces rule the world: `io.Reader` (`.Read(p []byte)`) and
`io.Writer` (`.Write(p []byte)`). `strings.NewReader` wraps in-memory data as
a stream, `io.Copy` pumps one into another, and `os.ReadFile` / `os.WriteFile`
cover whole-file work.

### time
`time.Time` (a moment) vs `time.Duration` (a span, in nanoseconds). Formats
use the reference layout `Mon Jan 2 15:04:05 MST 2006` — so dates are
`"2006-01-02"`. Timers fire once; tickers fire repeatedly.

### strings, strconv, bytes
`strings.Split`/`Join`/`Contains`/`TrimSpace`, `strconv.Atoi`/`Itoa`/
`ParseFloat`, and `strings.Builder` for efficient concatenation. `bytes`
mirrors it all for `[]byte`.

### encoding/json
`json.Marshal` (struct → JSON), `json.Unmarshal` (JSON → struct), struct tags
rename (`json:"name"`), drop (`json:"-"`), and skip empty
(`json:",omitempty"`). JSON is a contract.

### net/http client
`http.Get` for quick GETs; build an `http.Request` with headers and send via
`client.Do` for control. Check the error, check `StatusCode`, then read the
body. Set a client `Timeout`.

## Kitchen-sink review: a small pipeline

Here everything works together: build a message, encode it as JSON, pretend
it traveled over a local HTTP server, decode the response, and format the
result — all with stdlib only, on-device.

```go
import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
)

type Order struct {
	ID    int      `json:"id"`
	Items []string `json:"items"`
}

readAll := func(r io.Reader) string {
	var sb strings.Builder
	buf := make([]byte, 32)
	for {
		n, err := r.Read(buf)
		if n > 0 {
			sb.Write(buf[:n])
		}
		if err != nil {
			break
		}
	}
	return sb.String()
}

parseOrders := func(src io.Reader) ([]Order, error) {
	var orders []Order
	if err := json.Unmarshal([]byte(readAll(src)), &orders); err != nil {
		return nil, err
	}
	return orders, nil
}

server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, `[{"id":1,"items":["pencil"]},{"id":2,"items":["pen","ink"]}]`)
}))
defer server.Close()

resp, err := http.Get(server.URL)
if err != nil {
	fmt.Println("request error:", err)
} else {
	defer resp.Body.Close()
	orders, err := parseOrders(resp.Body)
	if err != nil {
		fmt.Println("parse error:", err)
	} else {
		for _, o := range orders {
			fmt.Printf("#%d → %d item(s): %s\n", o.ID, len(o.Items), strings.Join(o.Items, ", "))
		}
	}
}
```

## What to remember for the exam

- **Preferences, not trivia.** The exam rewards knowing *which tool* for
  *which job*: `Atoi` for parsing ints, `Ticker` for repeating work, `Marshal`
  for JSON out, `io.Copy` for streams.
- **The two big contracts.** Reader/Writer understanding unlocks file, buffer,
  HTTP, and string APIs at once.
- **Errors are returned.** Scan, parse, and HTTP all signal failure through
  returned `error` values — check them.
- **Tags shape JSON.** Struct tags are the contract between your Go types and
  the wire format.

> [!tip]
> Before the practice exam, re-run the runnable examples in this section on
> your phone. Hands-on repetition of the small patterns beats memorizing
> signatures.

## ExamQuestions

```yaml
bank:
  - question: "You need to emit exactly two decimal digits of a float. Which verb?"
    type: single
    choices:
      - "%d"
      - "%x"
      - "%.2f"
      - "%v"
    answer: [2]
    explanation: "%.2f prints a float with precision 2 — exactly two digits after the decimal point."
    weight: 3
    section: 06-stdlib
  - question: "Which pair converts \"42\" ↔ int 42 in Go?"
    type: single
    choices:
      - "strconv.Itoa / strconv.Atoi"
      - "int() / string()"
      - "json.Marshal / json.Unmarshal"
      - "fmt.Sprint / fmt.Scan"
    answer: [0]
    explanation: "Itoa converts int → string and Atoi parses string → int; both live in strconv."
    weight: 3
    section: 06-stdlib
  - question: "A JSON payload has a key your struct doesn't declare. What does json.Unmarshal do by default?"
    type: single
    choices:
      - "Fails with a parse error"
      - "Ignoring extra keys in the input, it fills matching fields only"
      - "Adds the unknown key as a new field"
      - "Panics"
    answer: [1]
    explanation: "Unknown keys are silently ignored, so forward-compatible payloads decode fine."
    weight: 4
    section: 06-stdlib
  - question: "Which type satisfies io.Writer and lets you receive the assembled text with .String()?"
    type: single
    choices:
      - "strings.Reader"
      - "bytes.Reader"
      - "strings.Builder"
      - "strconv.Number"
    answer: [2]
    explanation: "strings.Builder accumulates writes (it implements io.Writer) and exposes String(); the Reader types are for reading."
    weight: 3
    section: 06-stdlib
  - question: "You want a background job that logs every 30 seconds forever. Which tool fits best?"
    type: single
    choices:
      - "time.Now"
      - "time.NewTimer"
      - "time.NewTicker"
      - "time.Sleep only, in a goroutine"
    answer: [2]
    explanation: "A Ticker fires repeatedly at a fixed interval — the natural fit for periodic background work. A Timer fires once."
    weight: 4
    section: 06-stdlib
```