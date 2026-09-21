---
id: 07-part-practice
title: Part 4 Practice
order: 7
section: 04-methods-interfaces
language: golang
summary: Review of methods, interfaces, and composition — plus the exam bank for Part 4.
tags: [review, practice, exam]
prereqs: [01-methods, 02-interfaces-basics, 03-interface-design, 04-interfaces-in-action, 05-pointers-vs-values, 06-composition-over-inheritance]
---

# Part 4 Practice: Methods & Interfaces

## Section review

You now own the two ideas that define Go's flavor of object-oriented design.

**Methods** are functions bound to a named type through a receiver. They differ from functions by
binding behavior to the type and making the receiver part of the method's identity — unrelated
types can each have `String()`, `Read()`, or `Charge()`. The receiver decides mutability: value
receivers operate on copies, pointer receivers on the original. And the receiver decides the
**method set**: `*T` carries `T`'s methods plus pointer-receiver ones, which is the root cause of
most interface-satisfaction surprises.

**Interfaces** are sets of method names, satisfied *structurally* and *implicitly* — no
`implements` keyword exists. Small interfaces win (`error`, `io.Reader`, `io.Writer`,
`fmt.Stringer`, `sort.Interface`); compose them by embedding instead of growing them; accept
interfaces in your functions and return concrete types; reserve `any` for genuinely mixed data;
and say no to interfaces with a single implementation. An interface value is a `(type, value)`
pair — which is why a nil pointer stored in an interface is still not `== nil`.

**Composition** replaces inheritance: embed structs to promote fields and methods ("has-a"), embed
interfaces to union contracts, and model variety with interchangeable implementers rather than an
extends-tree.

### Warm-up: decode this program

```go title="review.go"
import ("fmt"; "time")

type Labeler interface{ Label() string }

render := func(v any) string {
    if s, ok := v.(Labeler); ok {
        return s.Label()
    }
    return "?"
}

d := 42 * time.Second
fmt.Println(render(d))
```

What type asserts, how interfaces pair with `any`, and where `Stringer` fits: run it and make sure
each line of your reasoning matches. Then try the exam items below.

## ExamQuestions

```yaml
questions:
  - id: p4q1
    prompt: "A value receiver (r Robot) Speak() string is the only method of Robot, defined at package scope. Which statement about Robot's method call on a non-addressable expression is TRUE?"
    type: single
    choices:
      - "Robot{}.Speak() fails whenever the receiver list includes more than one parameter."
      - "Value-receiver methods can be called on non-addressable values; assigning a value-receiver method to an interface also works for the value type."
      - "Value-receiver methods require a pointer and auto-address the value."
      - "Value-receiver methods are never callable on struct literals."
    answer: [1]
    explanation: "The T method set carries value-receiver methods, so T itself satisfies an interface requiring them; only pointer-receiver methods need addressability."
    difficulty: 3
    weight: 4
    section: 04-methods-interfaces
  - id: p4q2
    prompt: "Which two conditions make a type satisfy an interface without writing 'implements'?"
    type: multi
    choices:
      - "Its method set includes every method of the interface."
      - "It is declared inside the same package as the interface."
      - "The method signatures (names, parameters, results) match exactly."
      - "It embeds the interface by value."
    answer: [0, 2]
    explanation: "Structural typing requires exact method names and signatures; extra methods are allowed and location/package is irrelevant."
    difficulty: 2
    weight: 3
    section: 04-methods-interfaces
  - id: p4q3
    prompt: "func F(out io.Writer) error { _, err := fmt.Fprintln(out, \"hi\"); return err }. Which call sites are valid?"
    type: multi
    choices:
      - "F(&bytes.Buffer{})"
      - "F(os.Stdout)"
      - "F(fmt.Stringer{})"
      - "F(myWriter) where myWriter has only method Write([]byte)(int, error)"
    answer: [0, 1, 3]
    explanation: "Any io.Writer works: *bytes.Buffer, os.Stdout, or any type with a matching Write (pointer receivers included). fmt.Stringer has no Write, so it fails."
    difficulty: 3
    weight: 4
    section: 04-methods-interfaces
  - id: p4q4
    prompt: "You model 'every notification has a recipient and a message, but delivery varies (email, SMS)'. Best Go design?"
    type: single
    choices:
      - "A Notification base struct plus a subclass per channel."
      - "A Notification struct with a recipient embed and a small Deliverer interface satisfied by email and SMS senders."
      - "One Notification struct with a switch on a string channel type."
      - "An interface for Notification with no structs at all."
    answer: [1]
    explanation: "Shared data lives in one struct ('has-a') while varied behavior is captured by a small interface the channels implement — composition over inheritance."
    difficulty: 2
    weight: 3
    section: 04-methods-interfaces
  - id: p4q5
    prompt: "var w io.Writer = (*bytes.Buffer)(nil). Which are true?"
    type: multi
    choices:
      - "w == nil"
      - "w != nil"
      - "Calling w.Write panics because the concrete pointer is nil."
      - "Calling w.Write is perfectly safe."
    answer: [1, 2]
    explanation: "The interface holds (type, value) = (*bytes.Buffer, nil): w != nil, but the nil pointer dereferences on Write and panics."
    difficulty: 3
    weight: 4
    section: 04-methods-interfaces
```