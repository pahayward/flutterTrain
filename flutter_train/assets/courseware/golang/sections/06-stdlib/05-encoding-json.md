---
id: 05-encoding-json
title: encoding/json
order: 5
section: 06-stdlib
language: golang
summary: Marshal/Unmarshal, struct tags, ignoring fields, maps, and treating JSON as a contract.
tags: [json, marshal, unmarshal, struct-tags, encoding]
---

# encoding/json

JSON is the lingua franca of APIs, config files, and data exchange. Go's
`encoding/json` turns structs into JSON and back — and the shape of your
struct **is** the shape of your data contract.

## The two workhorses

- `json.Marshal(v)` → `([]byte, error)` — struct/slice/map to JSON text.
- `json.Unmarshal(data, &dest)` → `error` — JSON text into a Go value.

```go
import (
	"encoding/json"
	"fmt"
)

type User struct {
	Name  string
	Age   int
	Email string
}

u := User{Name: "Grace", Age: 40, Email: "grace@example.com"}
data, err := json.Marshal(u)
if err != nil {
	fmt.Println("marshal error:", err)
} else {
	fmt.Println(string(data))
}
```

> [!key]
> Export **field names** (capital first letter) get JSON-ized by default:
> `Name` → `"Name"`, `Age` → `"Age"`. Unexported fields are silently omitted.

## Struct tags control the JSON shape

A struct tag after the field type renames keys, sets formats, and drops
fields. Three tags you'll use constantly:

- `` `json:"name"` `` — the JSON key name.
- `` `json:"name,omitempty"` `` — skip when the value is zero.
- `` `json:"-"` `` — never include this field.

```go
import (
	"encoding/json"
	"fmt"
)

type Metric struct {
	Name   string  `json:"name"`
	Value  float64 `json:"value"`
	Unit   string  `json:"unit"`
	Secret string  `json:"-"`
	Note   string  `json:"note,omitempty"`
}

m := Metric{Name: "latency", Value: 12.5, Unit: "ms", Secret: "never send"}
data, _ := json.Marshal(m)
fmt.Println(string(data))

m2 := Metric{Name: "ops", Value: 100, Unit: "rps", Secret: "hush", Note: "peak"}
data2, _ := json.Marshal(m2)
fmt.Println(string(data2))
```

> [!trap]
> `omitempty` drops only **zero values**: empty string, 0, nil, empty slice.
> It won't hide a meaningful 0 if 0 is a real answer — design your tags
> around that.

## Unmarshal: JSON back into a Go value

`Unmarshal` fills a value through the same tags, case-insensitively matching
keys to fields. Unknown keys in the input are ignored by default — which makes
your decoder tolerant of extra fields from the API.

```go
import (
	"encoding/json"
	"fmt"
)

type Product struct {
	Name  string  `json:"name"`
	Price float64 `json:"price"`
	Stock int     `json:"stock"`
}

input := `{"name":"keyboard","price":49.99,"stock":12,"sale":true}`
var p Product
err := json.Unmarshal([]byte(input), &p)
if err != nil {
	fmt.Println("unmarshal error:", err)
} else {
	fmt.Printf("%+v\n", p)
}
```

> [!note]
> The stray `"sale":true` key in the input is ignored — `Product` has no
> `Sale` field. If your API adds a field, old code keeps working.

## Maps and slices: JSON without a type

When the shape isn't known up front, unmarshal into a `map[string]any` (or
decode into `any`). Values become `string`, `float64`, `bool`, `[]any`, or
`map[string]any` — a small type system of its own. Works for lists too, where
you unmarshal into a `[]SomeType`.

```go
import (
	"encoding/json"
	"fmt"
)

blob := `{"city":"São Paulo","temp":28.5,"tags":["hot","humid"]}`
var m map[string]any
if err := json.Unmarshal([]byte(blob), &m); err != nil {
	fmt.Println("error:", err)
} else {
	fmt.Println("city:", m["city"])
	fmt.Println("temp:", m["temp"]) // note: float64

	tags := m["tags"].([]any)
	fmt.Println("first tag:", tags[0])
}
```

> [!warning]
> By default a JSON **number** unmarshals as `float64`, never `int`. Check
> `json.Decoder.UseNumber()` when you need exact integer or decimal handling.
> That number-as-float64 quirk surprises almost everyone once.

## Nested and lists: structs in structs

Real payloads nest: a user has an address, an order has a list of items.
Structs nest naturally, and a `[]Item` field round-trips to a JSON array.

```go
import (
	"encoding/json"
	"fmt"
)

type Address struct {
	City string `json:"city"`
	Zip  string `json:"zip"`
}

type Order struct {
	ID     int      `json:"id"`
	Items  []string `json:"items"`
	ShipTo Address  `json:"ship_to"`
}

order := Order{
	ID:     7,
	Items:  []string{"pen", "notebook"},
	ShipTo: Address{City: "Lisbon", Zip: "1000"},
}
data, _ := json.Marshal(order)
fmt.Println(string(data))

var back Order
_ = json.Unmarshal(data, &back)
fmt.Println("city back:", back.ShipTo.City, "| items:", back.Items)
```

> [!key]
> **JSON is a contract.** The struct tags are documentation and validation in
> one. Rename a tag and you change the wire format for every consumer — treat
> changes as breaking changes.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which call converts a Go struct to JSON bytes?"
    type: single
    choices:
      - "json.Unmarshal"
      - "json.Marshal"
      - "json.Encode"
      - "json.Stringify"
    answer: [1]
    explanation: "json.Marshal(v) returns ([]byte, error) holding the JSON-encoded value."
    difficulty: 1
  - id: q2
    prompt: "What does the tag `json:\"-,omitempty\"` do?"
    type: single
    choices:
      - "Omits the field when empty but includes the name otherwise"
      - "Always excludes the field from JSON"
      - "Renames the field so it cannot collide"
      - "Includes the field only when it is empty"
    answer: [1]
    explanation: "The '-' name means the field is never marshaled; omitempty is moot when the field is always excluded."
    difficulty: 2
  - id: q3
    prompt: "When unmarshaling into `map[string]any`, what type does a JSON number become?"
    type: single
    choices:
      - "int"
      - "float64"
      - "big.Int"
      - "string"
    answer: [1]
    explanation: "Default unmarshal incurs float64 for numbers; use json.Decoder.UseNumber() for exactness."
    difficulty: 2
  - id: q4
    prompt: "A struct has an unexported field `score int` and `json.Marshal` is called. What happens?"
    type: single
    choices:
      - "It is included as \"score\""
      - "It causes a compile error"
      - "It is silently omitted"
      - "The program panics"
    answer: [2]
    explanation: "Unexported fields are invisible to encoding/json and silently dropped from the output."
    difficulty: 1
```