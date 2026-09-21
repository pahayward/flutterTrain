---
id: 04-project-structure
title: "Project structure & package design"
order: 4
section: 08-real-programs
language: golang
summary: "Layout, where files go, exported vs unexported API, avoiding over-abstraction, Conway's law angle"
tags: [layout, packages, api-design, structure]
---

# Project structure & package design

Go projects have a conventional layout. Following it makes your code navigable
for other Go developers — and for yourself six months from now.

## The standard layout

```
myproject/
├── cmd/
│   └── myapp/
│       └── main.go          # entry point
├── internal/
│   ├── auth/
│   │   └── auth.go          # private packages
│   └── db/
│       └── db.go
├── pkg/
│   └── util/
│       └── util.go          # public library packages
├── go.mod
├── go.sum
├── README.md
└── Makefile
```

> [!key] The two directories that matter most
> - `cmd/` — one subdirectory per executable (the `main` packages).
> - `internal/` — packages that cannot be imported by code outside this module.
>   The compiler enforces this.

## Where do files go?

The rule is simple: **group by behavior, not by layer.**

```
# Bad: group by technical role
handlers/
models/
services/
repositories/

# Good: group by domain
user/
order/
payment/
```

Each domain package owns its own types, handlers, and storage. This is the
"self-contained package" pattern — it scales better than splitting by layer.

> [!warning] Don't over-abstract
> A common Go anti-pattern is creating interfaces for every type. Only define
> interfaces where they're consumed, not where they're implemented. If only one
> function uses `UserStore`, define the interface in that function's package.

## Exported vs unexported

Capitalization is your visibility modifier:

| Name | Visible outside package? |
|------|--------------------------|
| `User` | Yes — exported |
| `user` | No — unexported |
| `GetName` | Yes — exported |
| `getName` | No — unexported |

Unexported identifiers are used all the time *within* their package — that's not
a crime, it's the design:

```go
import "fmt"

// This is what an unexported helper + exported caller looks like.
lowercasePrefix := func(name string) string {
    return "usr-" + name
}

LookupName := func(id int, given string) string {
    return lowercasePrefix(given) // same package: allowed
}

fmt.Println(LookupName(42, "Ada"))
```

> [!tip] Keep the API surface small
> Export only what other packages need. A small exported API is easier to
> maintain, document, and test. Unexported functions give you freedom to refactor
> internally without breaking callers.

## package names matter

Package names should be short, lowercase, single words. They describe what the
package provides, not where it lives:

```
# Bad
import "github.com/org/myproject/pkg/util/helper/strings"

# Good
import "github.com/org/myproject/internal/strings"
```

A caller writes `strings.Split(...)` — the package name becomes part of the
sentence. Make it read naturally.

## Conway's Law and package design

Conway's Law says organizations ship designs that mirror their communication
structure. This applies to Go packages too:

- If your team has a **payments squad**, they probably own `internal/payment/`.
- If the **platform team** handles infra, `internal/config/` and `internal/db/`
  might live in their repo.

The lesson: **design packages around the people who will change them**, not just
around technical boundaries. When the payments team can work entirely inside
`internal/payment/` without touching other packages, your structure is healthy.

> [!note] Small teams → small packages
> If a package needs more than 3-4 files, consider splitting it. If a package
> has only one tiny file, it might belong somewhere else. Aim for cohesion.

## Avoiding over-engineering

Start simple. Don't create a `pkg/` directory until you actually have a reusable
library. Don't add an `internal/` boundary until you need one.

```
# Viable for a small CLI tool:
mytool/
├── main.go
├── parser.go
├── formatter.go
├── go.mod
└── README.md
```

> [!trap] Don't copy big-company layouts blindly
> The cmd/internal/pkg pattern works for large projects. A five-file CLI tool
> doesn't need five directories. Structure should serve the project, not the
> other way around.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does the `internal/` directory enforce in Go?"
    type: single
    choices:
      - "Packages inside cannot be tested"
      - "Only the root module can import packages inside it"
      - "Files are encrypted at rest"
      - "The compiler generates documentation automatically"
    answer: [1]
    explanation: "Go's compiler prevents code outside the parent module from importing internal packages."
    difficulty: 1
  - id: q2
    prompt: "What is the Go convention for package names?"
    type: single
    choices:
      - "PascalCase like Java packages"
      - "Short, lowercase, single words"
      - "Always match the repository name exactly"
      - "Prefix with the company domain"
    answer: [1]
    explanation: "Package names should be short, lowercase, single words — e.g. json, httputil, user."
    difficulty: 1
  - id: q3
    prompt: "Where should Go interfaces generally be defined?"
    type: single
    choices:
      - "In the package that implements them"
      - "In a global interfaces.go file"
      - "In the package that consumes them"
      - "In every package that touches the type"
    answer: [2]
    explanation: "Go convention: define interfaces where they're used (consumer-side), not where they're implemented."
    difficulty: 2
  - id: q4
    prompt: "According to Conway's Law applied to package design, packages should be organized around:"
    type: single
    choices:
      - "Technical layers (handlers, models, repos)"
      - "The people or teams who change them"
      - "Database tables"
      - "API endpoints"
    answer: [1]
    explanation: "Organizing packages around team boundaries minimizes cross-team conflicts and merge contention."
    difficulty: 2
```
