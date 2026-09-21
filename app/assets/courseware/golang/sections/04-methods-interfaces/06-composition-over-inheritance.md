---
id: 06-composition-over-inheritance
title: Composition over inheritance — the Go way
order: 6
section: 04-methods-interfaces
language: golang
summary: Struct embedding, promoted fields and methods, interface embedding, and modeling 'has-a' without classes.
tags: [composition, embedding, has-a, inheritance]
prereqs: [01-methods, 03-interface-design]
---

# Composition over inheritance — the Go way

> [!key]
> Go deliberately has **no classes, no inheritance, and no method overriding**. Instead it has
> *embedding*: drop one type inside another and its fields and methods are **promoted** to the
> outer type. The design word is **has-a**, not *is-a*.

## Why no classes?

Inheritance is elegant on paper and fragile in the wild. Deep class trees couple a child to every
ancestor: a new method on a base class silently changes the meaning of a subclass; overriding
creates subtle behavior drift; and "is-a" is often a lie ("Yes, a Car *is* a Vehicle — but also a
*Dashboard* and an *Engine* owner and a *Loan* signer"). Go's authors decided that **structuring a
program around what a thing *has*** survives rearrangement better than what a thing *descends
from*.

- There is no `extends`, no `super`, no virtual dispatch on receivers.
- Embedding is *not* inheritance-with-a-new-name — if a promoted behavior isn't right, you can't
  "override" it; you *replace* the component or add your own field to shadow it.
- Interfaces (already visited) supply the polymorphism side: many types, one contract.

## Embedding and promoted fields

Embedding is just an anonymous, typeless field. Every field of the embedded type is **promoted**
one level up, so `it.ID` finds the field even though it physically lives in `Base`:

```go title="promoted-fields.go"
import "fmt"

type Base struct{ ID int }
type Item struct {
    Base        // anonymous field: type name is the field name
    Note string
}

it := Item{Base: Base{ID: 9}, Note: "first"}
fmt.Println(it.ID, it.Note)      // promoted: it.ID is it.Base.ID
fmt.Println(it.Base.ID, it.Note) // explicit path is always valid
```

Prints `9 first` in both lines. `it.ID` is a *shortcut* — the field still lives at `it.Base.ID`.

## Promoted methods: instant "has-a" behavior

Methods of an embedded type are promoted too. Embed `bytes.Buffer` inside a logging sink and you
inherit `WriteString`, `Len`, `String` — whole batteries of behavior without copying any code:

```go title="promoted-methods.go"
import ("bytes"; "fmt")

type MyBuf struct{ bytes.Buffer }   // MyBuf has everything Buffer does

mb := MyBuf{}
mb.WriteString("hello")             // promoted method
fmt.Println(mb.Len(), mb.String())  // 5 hello
```

> [!key]
> Value embedding (`type MyBuf struct{ bytes.Buffer }`) vs pointer embedding
> (`struct{ *bytes.Buffer }`): the ptr form lets the component live elsewhere and be shared; the
> value form owns it outright. Prefer value embedding for owned state.

## The canonical use: mutex-by-embedding

The most famous embedding in Go is `sync.Mutex` inside a struct. It's literally "this type *has* a
lock" — and the promotion gives you `c.Lock()`/`c.Unlock()` for free:

```go title="mutex-embedding.go"
import ("fmt"; "sync")

type Cache struct {
    sync.Mutex
    entries map[string]int
}

c := Cache{entries: map[string]int{}}
c.Lock()
c.entries["hits"]++      // guard the mutation
c.Unlock()
fmt.Println(c.entries)
```

> [!warning]
> Embedding `sync.Mutex` is idiomatic *when the struct is the lock owner*. If you embed it merely
> to expose `Lock()` on a third-party type, you leak your internal locking discipline to every
> caller. `sync.Mutex` docs: the zero value is a usable unlocked mutex, but copy the struct and
> you copy the mutex — copy-once discipline matters.

## Promotion has limits: name shadowing

If the outer struct declares a field or method with the same name as a promoted one, the outer
**shadows** it. This is not override — the embedded field still exists and is reachable by its full
path:

```go title="shadowing.go"
import "fmt"

type Base struct{ Name string }
type Wrap struct {
    Base
    Name string   // shadows the promoted Base.Name
}

w := Wrap{Name: "outer"}
w.Base.Name = "inner"
fmt.Println(w.Name, w.Base.Name)
```

Prints `outer inner`. Shadowing gives you a place to "fix" a promoted behavior — but read it as a
code smell: if you shadow a promoted method you can't override, and the usual fix is *changing your
component*, exactly what composition invites you to do.

## Modeling trees without inheritance

How do you build taxonomies, then? **Has-a + interfaces**, not extends. "Shape" becomes a small
interface; each shape *owns* its data and implements the contract; and shared helpers live in
embedded components instead of ancestor classes:

```go eval=no
package main

import "fmt"

type Shape interface{ Area() float64 }

type rect struct{ W, H float64 }

func (r rect) Area() float64 { return r.W * r.H }

// A Button has a rect (its geometry) and a label. No rectangle 'base class'.
type Button struct {
    rect          // has-a: geometry via embedding
    Label   string
    Visible bool
}

func (b Button) Render() string {
    return fmt.Sprintf("button %q %dx%d visible=%v", b.Label, b.W, b.H, b.Visible)
}

func main() {
    b := Button{rect: rect{W: 20, H: 10}, Label: "ok", Visible: true}
    fmt.Println(b.Render())      // promoted W, H from the embedded rect
    var s Shape = b.rect          // the component itself satisfies the contract
    fmt.Printf("%.0f\n", s.Area())
}
```

Compare with the class-tree version: a `Renderer`, a `Rectangleable`, method override bikesheds —
Go simply makes the relationships one level deep and explicit.

## When to embed vs use a named field

| Goal | Choice |
|---|---|
| Reuse behavior wholesale, want its methods promoted | Embed (`struct{ bytes.Buffer }`) |
| Document an owned part, hide its methods | Named field (`Buf bytes.Buffer`) |
| Interface method union | Embed interfaces (`type RW interface { io.Reader; io.Writer }`) |
| Guard against leaking a component's API | Named, unexported field |

> [!tip]
> Interfaces embed the same way structs do — `io.ReadWriter` is `io.Reader` + `io.Writer`
> literally. Whether for structs or interfaces, embedding is the composition primitive; there is
> no third option, because there is no `extends` in the language.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "type Item struct { Base; Note string } and Base has field ID. Which accesses are valid?"
    type: single
    choices:
      - "Only it.Base.ID."
      - "Only it.ID."
      - "Both it.ID (promoted) and it.Base.ID (explicit path)."
      - "Neither: embedding is syntactic sugar for inheritance."
    answer: [2]
    explanation: "Embedding promotes Base.ID to Item, and the typed path it.Base.ID always remains valid. Embedding is not inheritance."
    difficulty: 2
  - id: q2
    prompt: "Why does Go omit classes and inheritance?"
    type: single
    choices:
      - "The authors judged deep 'is-a' hierarchies fragile, coupling children to ancestors; has-a composition and interfaces provide the flexibility."
      - "The Go compiler cannot support virtual methods."
      - "Inheritance is slower in all cases."
      - "Classes were planned but removed in 1.0."
    answer: [0]
    explanation: "Deliberate design: replace hierarchy with embedding ('has-a') and interchangeable behavior via small interfaces."
    difficulty: 2
  - id: q3
    prompt: "An outer struct field named Score shadows a promoted field Score from an embedded type. What is the effect?"
    type: single
    choices:
      - "The embedded field is destroyed."
      - "The outer field wins for outward access; the embedded one is still reachable by its full path."
      - "The compiler refuses to allow both."
      - "Method calls are routed to the embedded type instead."
    answer: [1]
    explanation: "Shadowing hides the promoted name at the outer level (read w.Score as outer), while w.Emb.Score remains reachable. It is not overridable."
    difficulty: 3
  - id: q4
    prompt: "type Logger struct { *bytes.Buffer }. What does this embedding make Logger?"
    type: single
    choices:
      - "A subclass of bytes.Buffer."
      - "A type holding a pointer to a buffer, with Buffer's methods promoted."
      - "A type that discards all Buffer methods by hiding them."
      - "Invalid Go: pointers cannot be embedded."
    answer: [1]
    explanation: "Pointer embedding (an anonymous field of type *bytes.Buffer) promotes the buffer's methods and can share one buffer across instances."
    difficulty: 2
  - id: q5
    prompt: "How do you gain polymorphic behavior across unrelated concrete types without inheritance?"
    type: single
    choices:
      - "By declaring them subclasses of a common base."
      - "By giving each the required method set so they satisfy a small interface, and swapping them through that interface."
      - "By embedding one in the other and calling super."
      - "It is impossible in Go."
    answer: [1]
    explanation: "Structural interfaces give polymorphism: unrelated types with the right methods are interchangeable through the interface."
    difficulty: 2
```