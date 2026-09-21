---
id: 03-json
title: JSON data transfer
order: 3
section: 04-network
language: python
summary: JSON syntax and types, the json module (dumps/loads), and the Python-to-JSON mapping.
tags: [json, serialization, rest, dumps, loads, payload]
---

# JSON data transfer

**JSON (JavaScript Object Notation)** is the de-facto format for data exchanged
over the network — web APIs, REST endpoints, config files, logs. Nearly every
service you call with a socket returns JSON. PCPP-32-101 4.3 expects you to
read, write, and transform JSON with Python's `json` module.

## JSON syntax and structure

JSON is a text format with two container types:

- **object** — an unordered set of `"key": value` pairs in curly braces:
  `{"name": "Ada", "level": 2}`
- **array** — an ordered list of values in square brackets:
  `["python", "socket", "json"]`

Objects and arrays nest freely, so a whole document is a tree/root object that
contains everything else.

## JSON data types

JSON has exactly six value types:

| JSON | Example | Looks like Python |
|---|---|---|
| object | `{...}` | `dict` |
| array | `[...]` | `list` |
| string | `"hi\n\t"` | `str` (double quotes only!) |
| number | `3`, `-2.5`, `1e4` | `int` / `float` |
| boolean | `true`, `false` | `True` / `False` |
| null | `null` | `None` |

> [!trap]
> JSON is case-sensitive and *slightly* different from Python: booleans are
> lowercase `true`/`false` (not `True`/`False`), `null` not `None`, strings
> must use **double** quotes, and there are no single quotes or trailing commas.

## The Python ↔ JSON mapping

The `json` module serializes **JSON-compatible** Python values exactly like this:

| Python | JSON |
|---|---|
| `dict` | object |
| `list`, `tuple` | array |
| `str` | string |
| `int`, `float` | number |
| `True` / `False` | `true` / `false` |
| `None` | `null` |

`tuple` silently becomes an array — JSON has no direct tuple concept. When you
load JSON back, objects come back as `dict` and arrays as `list`; you never get
the original tuple.

## dumps and loads

- `json.dumps(obj)` — Python object → JSON **string**.
- `json.loads(text)` — JSON **string** → Python object.
- `json.dump(obj, file)` / `json.load(file)` — same, but to/from a file
  object opened with `encoding="utf-8"`.

```python
import json

data = {
    "name": "Ada",
    "skills": ["python", "sockets", "rest"],
    "age": 36,
    "active": True,
    "score": None,
}

text = json.dumps(data, indent=2, ensure_ascii=False)
print("type:", type(text).__name__)
print(text[:60], "...")

back = json.loads(text)
print("round trip ok:", back == data)
print(type(back["skills"]).__name__)
```

Note the kinds of things you can print to prove the round trip worked.

## Pretty printing and formatting flags

- `indent=N` — pretty-print with N-space indentation (default is one line).
- `sort_keys=True` — output keys alphabetically; great for stable files.
- `ensure_ascii=False` — keep non-ASCII characters literal instead of
  `\uXXXX` escapes. Useful for non-English text.
- `separators=(',', ':')` — compact form, often used for wire transfer.

```python
import json

payload = {"host": "127.0.0.1", "ports": [80, 443]}

compact = json.dumps(payload, separators=(",", ":"))
pretty = json.dumps(payload, indent=2, sort_keys=True)

print("compact:", compact)
print("sorted keys:", json.loads(pretty).keys())
print("pretty 2nd line:", pretty.splitlines()[2])
```

## Working with files

`json.dump` / `json.load` make file round-trips trivial. Files holding text
should be opened with an explicit UTF-8 encoding:

```python
import json
import os
import tempfile

path = os.path.join(tempfile.gettempdir(), "settings.json")
settings = {"host": "127.0.0.1", "retries": 3, "secure": True}

with open(path, "w", encoding="utf-8") as fh:
    json.dump(settings, fh, indent=2)

with open(path, encoding="utf-8") as fh:
    loaded = json.load(fh)

print("file round trip ok:", loaded == settings)
print("value:", loaded["host"])
```

> [!note]
> On-device you can only write into the app's scratch/temp directory — that is
> exactly what `tempfile.gettempdir()` targets, so this example is safe.

## Serializing non-JSON objects

`dumps` refuses unknown types (`set`, custom classes, `complex`). Fix it by
passing a `default` function that turns the object into something JSON-native:

```python
import json

class Task:
    def __init__(self, name, done):
        self.name = name
        self.done = done

def to_dict(obj):
    if isinstance(obj, Task):
        return {"name": obj.name, "done": obj.done}
    raise TypeError(f"cannot serialize {type(obj).__name__}")

task = Task("tidy up", True)
print(json.dumps(task, default=to_dict))
```

The reverse direction (`loads` → your class) has no magic: decode to a `dict`
and build your object from it yourself.

## Common traps

- **Using single quotes or trailing commas** — JSON rejects both. Validate with
  `json.loads`.
- **Expecting tuples to survive** — they come back as lists.
- **Forgetting `ensure_ascii=False`** — non-ASCII becomes `\u....` by default.
- **Passing `True`/`None` but reading `true`/`null`** — remember the mapping
  table above.
- **Assuming dict key order is preserved for you** — it usually is in CPython,
  but never rely on it unless you also control the reader.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which Python call converts a dict into a JSON string?"
    type: single
    choices:
      - "json.loads(data)"
      - "json.load(data)"
      - "json.dumps(data)"
      - "json.stringify(data)"
    answer: [2]
    explanation: "json.dumps serializes a Python object into a JSON string; loads/load handle the reverse direction."
    difficulty: 1
  - id: q2
    prompt: "How is the JSON boolean value written, and what Python value does it map to?"
    type: single
    choices:
      - "True, mapping directly to Python True"
      - "true, mapping to Python True"
      - "TRUE, mapping to Python True"
      - "true, mapping to the integer 1"
    answer: [1]
    explanation: "JSON booleans are lowercase true/false and map to Python True/False."
    difficulty: 1
  - id: q3
    prompt: "After json.loads() decodes a JSON object, what Python type do you receive?"
    type: single
    choices:
      - "custom class instance"
      - "tuple"
      - "dict"
      - "namedtuple"
    answer: [2]
    explanation: "JSON objects decode to plain dicts (arrays decode to lists). The module has no knowledge of your own Python classes."
    difficulty: 1
  - id: q4
    prompt: "What is the effect of json.dumps(obj, indent=2, sort_keys=True)?"
    type: single
    choices:
      - "Output is minified and keys are shuffled randomly"
      - "Output is pretty-printed with 2-space indentation and keys are sorted alphabetically"
      - "Output is wrapped in an XML tag"
      - "Output is encoded to binary bytes"
    answer: [1]
    explanation: "indent=N pretty-prints the JSON tree; sort_keys=True writes keys in alphabetical order."
    difficulty: 2
  - id: q5
    prompt: "Which of the following Python values can json.dumps() serialize directly without a custom default function?"
    type: multi
    choices:
      - "a dict"
      - "a common set"
      - "a list of floats"
      - "a custom class instance"
    answer: [0, 2]
    explanation: "Plain dicts and lists of JSON-native scalars serialize fine. Sets and arbitrary class instances need a default= converter first."
    difficulty: 2
```