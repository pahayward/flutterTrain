---
id: 06-net-http
title: net/http client
order: 6
section: 06-stdlib
language: golang
summary: Making HTTP requests with http.Get/Do, methods, headers, status codes, and parsing responses.
tags: [net-http, http, client, requests, rest]
---

# net/http client

Almost every real Go program talks to another program over HTTP. The
`net/http` **client** side is built around three ideas: an HTTP method, a
URL, and a response with a status code and body. Once you can complete one
request and read its response, you can talk to a huge fraction of the world's
APIs.

## The request/response shape

A client round-trip produces:

- `resp.StatusCode` — e.g. `200`, `404`, `500`.
- `resp.Status` — e.g. `"200 OK"`.
- `resp.Header` — response headers as a map.
- `resp.Body` — an `io.ReadCloser`; read it and always close it.

```go
import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
)

ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hello %s", r.URL.Path)
}))
defer ts.Close()

resp, err := http.Get(ts.URL + "/world")
if err != nil {
	fmt.Println("request error:", err)
} else {
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	fmt.Println("status:", resp.Status)
	fmt.Println("code:  ", resp.StatusCode)
	fmt.Println("body:  ", string(body))
}
```

> [!note] Why httptest here
> These examples run entirely on-device against a local test server, so there
> is no external network access — exactly what the sandbox allows. The client
> code is identical to hitting a real API; only `ts.URL` stands in for
> `https://api.example.com`.

## Headers and other methods

`http.Get` is shorthand. For control (custom headers, methods, bodies) build
a `http.Request` and send it with `http.Client.Do` or `client.Get`:

```go
import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
)

ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "method=%s agent=%s", r.Method, r.Header.Get("User-Agent"))
}))
defer ts.Close()

req, err := http.NewRequest(http.MethodPost, ts.URL, nil)
if err != nil {
	fmt.Println("build error:", err)
} else {
	req.Header.Set("User-Agent", "edube-client/1.0")
	req.Header.Set("X-Trace", "abc")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("request error:", err)
	} else {
		defer resp.Body.Close()
		body, _ := io.ReadAll(resp.Body)
		fmt.Println("status:", resp.StatusCode)
		fmt.Println("echo:  ", string(body))
	}
}
```

## Checking status codes and testing errors

A 200 is not guaranteed. The reliable pattern: send, then **inspect** the
status before using the body, and respond accordingly.

```go
import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
)

ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/missing" {
		http.NotFound(w, r)
		return
	}
	fmt.Fprint(w, "found")
}))
defer ts.Close()

for _, path := range []string{"/present", "/missing"} {
	resp, err := http.Get(ts.URL + path)
	if err != nil {
		fmt.Println("error:", err)
		continue
	}
	code := resp.StatusCode
	if code >= 400 {
		// don't even bother reading the body — it's an error page
		fmt.Printf("%s → HTTP %d (failed request)\n", path, code)
		resp.Body.Close()
		continue
	}
	body, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	fmt.Printf("%s → %d: %s\n", path, code, string(body))
}
```

> [!trap]
> Always `Close()` the response body — even on error paths and even when you
> skip reading it. A leaked body keeps a connection open on the reusable
> client's pool and eventually exhausts file descriptors.

## Parsing JSON responses

HTTP + JSON is the standard pairing. Read the body, unmarshal it into a
struct, then use the data:

```go
import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
)

type APIResponse struct {
	Ok    bool     `json:"ok"`
	Items []string `json:"items"`
}

ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, `{"ok":true,"items":["a","b"]}`)
}))
defer ts.Close()

resp, err := http.Get(ts.URL)
if err != nil {
	fmt.Println("request error:", err)
} else {
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		fmt.Println("bad status:", resp.StatusCode)
	} else {
		body, _ := io.ReadAll(resp.Body)
		var parsed APIResponse
		if err := json.Unmarshal(body, &parsed); err != nil {
			fmt.Println("json error:", err)
		} else {
			fmt.Println("ok:", parsed.Ok)
			fmt.Println("items:", parsed.Items)
		}
	}
}
```

> [!key]
> A robust client flow: check error → check status code → read body → decode
> → use data. Every step can fail, and checking each one is what separates a
> reliable API client from a flaky one.

## Http client timeouts

In real apps, always set a timeout or a hung server will hang your client
forever. Configure the client once and reuse it:

```go eval=no
client := &http.Client{Timeout: 10 * time.Second}
resp, err := client.Get("https://api.example.com/v1/users")
```

> [!note] Why this is `eval=no`
> It requires real internet access and would block; on-device examples use
> `httptest` instead. The pattern to remember: one shared `http.Client` with a
> sensible `Timeout` for all requests.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which field on the response reports a 404?"
    type: single
    choices:
      - "resp.ErrCode"
      - "resp.StatusCode"
      - "resp.Error"
      - "resp.Is404"
    answer: [1]
    explanation: "resp.StatusCode holds the numeric HTTP status (404); resp.Status holds the text like '404 Not Found'."
    difficulty: 1
  - id: q2
    prompt: "Why must you always read-or-close resp.Body?"
    type: single
    choices:
      - "To avoid messages from the OS kernel"
      - "To return the connection to the pool instead of leaking it"
      - "Close is only needed for GET requests"
      - "It is optional in production code"
    answer: [1]
    explanation: "An unclosed Body leaks an open connection on the reusable client, eventually exhausting sockets/file descriptors."
    difficulty: 2
  - id: q3
    prompt: "How do you send a POST request with a custom header?"
    type: single
    choices:
      - "http.Get with a query string"
      - "Build an http.Request, set headers, send with client.Do"
      - "http.Post cannot have headers"
      - "Set the header on the response object"
    answer: [1]
    explanation: "http.NewRequest + req.Header.Set + client.Do gives full control over method, headers, and body."
    difficulty: 2
  - id: q4
    prompt: "Why set http.Client.Timeout?"
    type: single
    choices:
      - "It is required for HTTPS"
      - "A server that never responds would otherwise hang the client forever"
      - "It compresses the response automatically"
      - "It retries failed requests"
    answer: [1]
    explanation: "Without a timeout (default: none), a request can block the calling goroutine indefinitely against a hung server."
    difficulty: 1
```