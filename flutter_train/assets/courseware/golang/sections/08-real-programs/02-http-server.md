---
id: 02-http-server
title: "Writing an HTTP server"
order: 2
section: 08-real-programs
language: golang
summary: "net/http handlers, HandleFunc, mux, middleware pattern, JSON responses, graceful shutdown"
tags: [http, server, handler, json, middleware]
---

# Writing an HTTP server

Go's standard library ships a production-quality HTTP server. No frameworks
needed — just `net/http`.

## Hello, HTTP

The smallest possible server:

```go eval=no
import "fmt"
import "net/http"

http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello from Go!")
})
fmt.Println("Server listening on :8080")
http.ListenAndServe(":8080", nil)
```

> [!warning] Blocking call
> `http.ListenAndServe` blocks forever — it never returns, so it can't run in
> this sandbox. On a real machine you'd compile and run it. Almost every example
> in this module is therefore `eval=no`; the runnable ones show the *logic* of
> servers without actually listening on a socket.

## Routing with ServeMux

Go 1.22 added pattern-based routing to `http.ServeMux`. Earlier versions
relied on prefix matching only:

```go eval=no
import "fmt"
import "net/http"

mux := http.NewServeMux()

mux.HandleFunc("GET /users", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "List users")
})

mux.HandleFunc("GET /users/{id}", func(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    fmt.Fprintf(w, "User %s\n", id)
})

http.ListenAndServe(":8080", mux)
```

> [!key] Method-based routing
> The `"GET /users"` pattern only matches GET requests. This eliminates the need
> for manual `r.Method` checks that older Go code required.

## Handler functions

Any function matching `func(http.ResponseWriter, *http.Request)` is a handler.
Use `http.HandlerFunc` to adapt a plain function. Here's the shaping logic,
runnable without a socket:

```go
import "fmt"

// MakeHandler builds a closure that acts like a net/http handler,
// returning the body text it would send to the client.
makeHandler := func(name string) func() string {
    return func() string {
        return "Hello, " + name + "!"
    }
}

hello := makeHandler("World")
gopher := makeHandler("Gopher")
fmt.Println(hello())
fmt.Println(gopher())
```

In a real server you register these instead:

```go eval=no
import "fmt"
import "net/http"

makeHandler := func(name string) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, %s!", name)
    }
}

http.HandleFunc("/hello", makeHandler("World"))
http.HandleFunc("/gopher", makeHandler("Gopher"))
http.ListenAndServe(":8080", nil)
```

## JSON responses

REST APIs return JSON. Use `encoding/json` to marshal data and set the right
content type:

```go
import (
    "encoding/json"
    "fmt"
)

type User struct {
    Name  string `json:"name"`
    Email string `json:"email"`
    Admin bool   `json:"admin"`
}

u := User{Name: "Alice", Email: "alice@example.com", Admin: true}
data, _ := json.MarshalIndent(u, "", "  ")
fmt.Println(string(data))
```

Output:

```
{
  "name": "Alice",
  "email": "alice@example.com",
  "admin": true
}
```

A handler that returns JSON:

```go eval=no
import (
    "encoding/json"
    "net/http"
)

type User struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}

http.HandleFunc("/api/user", func(w http.ResponseWriter, r *http.Request) {
    u := User{Name: "Alice", Email: "alice@example.com"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(u)
})
http.ListenAndServe(":8080", nil)
```

## The middleware pattern

Middleware wraps handlers to add cross-cutting concerns: logging, authentication,
CORS headers. It's just function composition:

```go
import (
    "fmt"
    "strings"
)

// A stand-in for http.HandlerFunc that carries a request string.
type Handler func(string) string

withLogging := func(next Handler) Handler {
    return func(input string) string {
        fmt.Println("[LOG] request:", input)
        result := next(input)
        fmt.Println("[LOG] response:", result)
        return result
    }
}

withAuth := func(next Handler) Handler {
    return func(input string) string {
        if !strings.Contains(input, "token=valid") {
            return "401 Unauthorized"
        }
        return next(input)
    }
}

hello := func(req string) string {
    return "Hello, World!"
}

protected := withAuth(withLogging(hello))
fmt.Println(protected("path=/hello token=valid"))
fmt.Println(protected("path=/hello"))
```

Output:

```
[LOG] request: path=/hello token=valid
[LOG] response: Hello, World!
Hello, World!
401 Unauthorized
```

> [!note] Middleware is composable
> Each layer is a function that takes a handler and returns a new handler. Stack
> them in any order — logging, auth, rate limiting, recovery.

## Graceful shutdown

Don't just kill your server — finish serving in-flight requests first. Go's
`http.Server` supports this via `Shutdown()`:

```go eval=no
import (
    "context"
    "fmt"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
)

srv := &http.Server{Addr: ":8080"}

go func() {
    if err := srv.ListenAndServe(); err != http.ErrServerClosed {
        fmt.Println("Server error:", err)
    }
}()

quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
<-quit

ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
srv.Shutdown(ctx)
fmt.Println("Server stopped gracefully")
```

> [!tip] Always shut down gracefully in production
> A hard kill mid-request leaves clients with broken connections. `Shutdown()`
> stops accepting new connections and waits for existing ones to finish.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What function signature does http.HandleFunc expect?"
    type: single
    choices:
      - "func(r *http.Request) http.Response"
      - "func(http.ResponseWriter, *http.Request)"
      - "func(w io.Writer, r []byte)"
      - "func(string) string"
    answer: [1]
    explanation: "Handlers must accept a ResponseWriter and a pointer to Request."
    difficulty: 1
  - id: q2
    prompt: "What does r.PathValue(\"id\") return in Go 1.22+?"
    type: single
    choices:
      - "The query string"
      - "The request body"
      - "The matched path parameter from the URL pattern"
      - "The client IP address"
    answer: [2]
    explanation: "PathValue extracts parameters matched by {id} in the route pattern."
    difficulty: 2
  - id: q3
    prompt: "How do you set the Content-Type header for a JSON response?"
    type: single
    choices:
      - "json.SetHeader(w, \"application/json\")"
      - "w.Header().Set(\"Content-Type\", \"application/json\")"
      - "r.Header.Set(\"Content-Type\", \"application/json\")"
      - "http.ContentType = \"json\""
    answer: [1]
    explanation: "w.Header().Set() modifies the response headers before writing the body."
    difficulty: 2
  - id: q4
    prompt: "What is the purpose of graceful shutdown?"
    type: single
    choices:
      - "To start the server faster"
      - "To compress responses before sending"
      - "To finish serving in-flight requests before the process exits"
      - "To automatically restart the server on crash"
    answer: [2]
    explanation: "Graceful shutdown stops accepting new connections while letting existing requests complete."
    difficulty: 1
```
