---
id: 01-go-mod
title: Modules
order: 1
section: 07-modules-tooling
language: golang
summary: go.mod/go.sum, module paths, go get, versions, replace, vendor, workspaces.
tags: [modules, go.mod, go.sum, go-get, vendor, workspace]
---

# Modules

A Go **module** is a set of packages that are released and versioned together. Since Go 1.16 modules are the default, so every real project lives in one. Modules are how your code declares, pins, downloads, and shares its dependencies in a reproducible way.

## go.mod — the manifest

The heart of every module is `go.mod`, a small plain-text file at the module root:

```go eval=no title="go.mod"
module github.com/acme/logger

go 1.22

require github.com/google/uuid v1.6.0
```

- `module` — the module path: the unique, importable identity of your project.
- `go` — the language version the code is written and tested against.
- `require` — a dependency and the exact version your program needs.

> [!key]
> The `go.mod` file travels with your project and is committed to version control. Its sibling `go.sum` is committed too — but only `go.mod` is hand-edited.

This `go.mod` says the root package of the module is imported as `logger` (the last path element) while its full import path stays `github.com/acme/logger`.

> [!trap]
> Editing `go.mod` by hand is allowed, but the tools (`go mod tidy`, `go get`) normally own it — a comment like `// indirect` means a dependency is needed only transitively and is kept in sync for you. Leave it alone.

## Module paths

A module path is unique, lowercase, and usually points at where code will be hosted:

- `github.com/user/repo` — the most common style.
- `example.com/team/project` — any domain you control.
- `golang.org/x/tools` — the Go team's own extended tools.

When you publish an app on the Google Play store... sorry, wrong ecosystem — publishing Go modules uses a VCS tag (below). The important rule: the path should be a place *you* own so nobody can squat it.

```go
import "fmt"
import "strings"

modulePath := "github.com/acme/logger"
parts := strings.Split(modulePath, "/")
rootPkg := parts[len(parts)-1]

fmt.Printf("module: %s\n", modulePath)
fmt.Printf("root package import name: %q\n", rootPkg)
```

> [!warning]
> Later major versions split your identity: a `v2+` module must add a `/v2` suffix to its path (`github.com/acme/logger/v2`). This lets two major versions of the same library coexist in one build. It's a common "why won't this import?" trap.

## go.sum — supply-chain receipts

`go.sum` stores **cryptographic hashes (SHA-256)** of every module file your build downloads, along with a copy of what the original author signed. Before compiling, Go verifies downloads against these hashes.

> [!note]
> The GO**SUMDB** (checksum database) validates a version the first time you see it; `go.sum` then locks it in for everyone on your team. Together they stop a compromised or tampered module from silently blending into your build.

To add a dependency with the tools:

```bash eval=no
go get github.com/google/uuid@v1.6.0   # add or update a requirement
go mod tidy                            # reconcile go.mod + go.sum with the code
go mod download                        # fetch modules into the module cache
```

`go mod tidy` is the safety net: it adds missing requirements, removes unused ones, and repairs `go.sum`. Run it often.

## Versions and semantic versioning

Go versions follow **semantic versioning**: `vMAJOR.MINOR.PATCH`, optionally with pre-release suffixes like `v1.2.3-beta.1`. The `@version` selector understands them (`@latest`, `@v1.2.x`, `@upgrade`).

The same rules the tooling uses are easy to reproduce:

```go
import "fmt"
import "strconv"
import "strings"

compare := func(a, b string) int {
	pa := strings.Split(strings.TrimPrefix(a, "v"), ".")
	pb := strings.Split(strings.TrimPrefix(b, "v"), ".")
	for i := 0; i < 3; i++ {
		x, _ := strconv.Atoi(pa[i])
		y, _ := strconv.Atoi(pb[i])
		if x > y {
			return 1
		}
		if x < y {
			return -1
		}
	}
	return 0
}

for _, pair := range [][2]string{
	{"v1.2.0", "v1.10.0"},
	{"v1.2.0", "v1.2.0"},
	{"v2.5.1", "v2.5.0"},
} {
	fmt.Printf("%s vs %s -> %d\n", pair[0], pair[1], compare(pair[0], pair[1]))
}
```

> [!trap]
> String comparison would sort `"v1.2.0"` after `"v1.10.0"` — wrong. Version tools compare numerically field by field, which is exactly why the example reports `-1` (1.2 is *older* than 1.10).

## replace — overriding a dependency

Sometimes upstream is broken, unmaintained, or you need a private fork. The `replace` directive reroutes a module:

```go eval=no title="go.mod snippet"
require github.com/acme/db v1.2.0

replace github.com/acme/db => github.com/me/db-fork v1.2.0
```

The build then uses your fork everywhere `github.com/acme/db` is imported. It also works with a local folder on disk, which is the classic way to develop two modules side by side:

```go
import "fmt"

replaces := map[string]string{
	"github.com/acme/db": "github.com/me/db-fork v0.1.0",
}

resolve := func(mod string) string {
	if fork, ok := replaces[mod]; ok {
		return "replace " + mod + " => " + fork
	}
	return "use upstream " + mod
}

fmt.Println(resolve("github.com/acme/db"))
fmt.Println(resolve("github.com/acme/api"))
```

> [!warning]
> `replace` is a local build decision — it should generally **not** be committed when the replacement points at a temporary fork. Vendoring, however, is a team-wide decision and *is* committed (below).

## vendor — snapshotting dependencies

`go mod vendor` copies all dependency source into a `vendor/` directory committed to your repo. Builds then compile that snapshot with **no network access** — ideal for CI, air-gapped environments, and reproducible hermetic builds.

```bash eval=no
go mod vendor        # create vendor/ from go.mod + go.sum
go build -mod=vendor ./...
```

> [!tip]
> Modern Go switches to vendored mode automatically when a `vendor/` directory exists and matches `go.mod`. Keep `vendor/modules.txt` — it records exactly which versions are vendored.

## Workspaces — many modules, one build

When you develop across two modules at once (your app + a library you're also editing), juggling `replace` lines gets old. A **workspace** in `go.work` groups several local modules:

```bash eval=no
go work init ./app ./lib    # creates go.work listing both modules
go work sync                # keep dependent modules aligned
```

Now `go build ./...` inside the workspace uses your local `./lib` without any `replace` rules. When a module is selected at multiple versions, Go applies **Minimal Version Selection (MVS)**: it quietly picks the highest version each module requires and adds it to the build graph.

```go
import "fmt"

// MVS in miniature: app needs util v1.2.0, helper needs v1.5.0.
// The build uses the maximum of the two.
required := []string{"v1.2.0", "v1.5.0"}
selected := "v0.0.0"

for _, v := range required {
	if v > selected {
		selected = v
	}
}

fmt.Println("app requires:  ", required[0])
fmt.Println("helper requires:", required[1])
fmt.Println("MVS selects:    ", selected)
```

> [!note]
> `go.work` files are usually **not** committed (they describe your local dev setup), while `go.mod`, `go.sum`, and `vendor/` are.

## Summary

- `go.mod` declares identity and requirements; `go.sum` locks hashes; both are committed.
- Versions are semver; `v2+` modules need a `/v2` path suffix.
- `replace` overrides a module (fork or local disk); `vendor/` snapshots everything for hermetic builds; workspaces handle multi-module development.
- Let the tools edit these files: `go get`, `go mod tidy`, `go mod vendor`, `go work`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which file stores cryptographic checksums of every downloaded module to guard against supply-chain tampering?"
    type: single
    choices:
      - "go.mod"
      - "go.sum"
      - "vendor/modules.txt"
      - "go.work"
    answer: [1]
    explanation: "go.sum records SHA-256 hashes of module files and verifies downloads against them; go.mod declares versions, it holds no hashes."
    difficulty: 1
  - id: q2
    prompt: "A dependency has a bug. Which directive points the build at a personal fork instead of the upstream module?"
    type: single
    choices:
      - "require"
      - "replace"
      - "exclude"
      - "toolchain"
    answer: [1]
    explanation: "replace (e.g. replace old => new version, or => ../local-dir) reroutes an import path to another module or a local directory."
    difficulty: 1
  - id: q3
    prompt: "The module path is \"github.com/acme/logger/v2\". Why does it carry the /v2 suffix?"
    type: single
    choices:
      - "It is a fast two-second build."
      - "Major version 2 is a separate module and must use a distinct path so both major versions can coexist."
      - "It signals the module was rewritten in Go 2."
      - "It is only a convention for forks, never required."
    answer: [1]
    explanation: "Go requires major version suffixes (v2, v3, ...) in module paths so two major versions are separate modules that can live in one build graph."
    difficulty: 2
```