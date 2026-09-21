---
id: 04-xml
title: XML data transfer
order: 4
section: 04-network
language: python
summary: XML syntax, elements and attributes, DTD basics, the XML tree model, and ElementTree parsing.
tags: [xml, elementtree, parsing, dtd, attribute, tree]
---

# XML data transfer

**XML (eXtensible Markup Language)** is a text format for structured data:
configurations, RSS feeds, SOAP web services, SVG, and countless file formats.
PCPP-32-101 4.3 focuses on reading XML as a *tree* with Python's standard
`xml.etree.ElementTree` module.

## XML syntax

An XML document is a plain-text document containing **elements** (tags),
**attributes**, and **text**:

```text
<library>
  <book id="b1">
    <title>Python</title>
    <year>2024</year>
  </book>
</library>
```

- One single **root** element (`<library>`) wraps everything.
- Tags come in pairs: `<title>...</title>`. A tag with no content may be
  self-closing: `<br/>` or `<img src="x.png"/>`.
- **Attributes** live inside the opening tag: `id="b1"`. Their values are
  always quoted.
- Text between tags is the element's text content (`Python` above).

## XML is a tree

Because elements nest inside elements, an XML document is naturally a **tree**:

```text
library (root)
└── book (id="b1")
    ├── title      -> text "Python"
    └── year       -> text "2024"
└── book (id="b2")
    └── ...
```

ElementTree builds exactly this tree in memory. A node is an **Element** with:

- `.tag` — the element's name (`book`).
- `.attrib` — its attributes as a `dict` (`{"id": "b1"}`).
- `.text` / `.tail` — the text inside the element / after it.
- children — iterable sub-elements.

> [!key]
> Know the tree vocabulary: the *root* element is the top node; a *parent*
> contains *children*; a node with no children is a *leaf*. `.findall()`,
> `.find()`, and `.iter()` navigate it.

## What makes a document well-formed

For tools to parse XML, the document must be **well-formed**:

- exactly one root element;
- every opening tag has a matching closing tag (or is self-closing);
- tags are properly nested (no overlapping);
- attribute values are quoted;
- `&`, `<`, and `>` inside text are escaped as `&amp;`, `&lt;`, `&gt;`
  (or from CDATA sections).

A parser will raise `xml.etree.ElementTree.ParseError` on malformed input:

```python
import xml.etree.ElementTree as ET

try:
    ET.fromstring("<a><b></a>")  # b is closed by the wrong tag
except ET.ParseError as err:
    print("malformed XML rejected:", err)
```

## DTD — validation rules, briefly

A **DTD (Document Type Definition)** describes the *allowed* structure of a
document class: which elements may exist, what order they appear in, and what
attributes they take. With a DTD you can **validate** a document (check it
conforms), not merely parse it.

```text
<!ELEMENT library (book+)>
<!ELEMENT book (title, year)>
<!ATTLIST book id CDATA #REQUIRED>
```

This says: `library` contains one or more `book`s; every `book` holds `title`
then `year`; every `book` requires an `id` attribute. ElementTree **does not**
perform DTD validation — it is a structural parser only.

> [!note]
> For the exam, you should recognise the *purpose* of a DTD (document
> validation) and the fact that ElementTree does not enforce it, not remember
> every DTD keyword.

## Parsing XML with ElementTree

Two entry points:

- `ET.fromstring(text)` — parse a string directly.
- `ET.parse(path)` — parse a file; returns an `ElementTree`, whose root is
  `.getroot()`.

```python
import xml.etree.ElementTree as ET

xml_text = """
<library>
  <book id="b1"><title>Python</title><year>2024</year></book>
  <book id="b2"><title>Networking</title><year>2023</year></book>
</library>
"""

root = ET.fromstring(xml_text)
print("root tag:", root.tag)
for book in root.findall("book"):
    title = book.find("title").text
    year = book.find("year").text
    print(f"  id={book.get('id')} title={title} year={year}")
```

Navigation methods to know:

- `root.find("tag")` — first **direct** child named `tag`, or `None`.
- `root.findall("tag")` — all direct children named `tag`.
- `root.iter("tag")` — all descendants (recursive) named `tag`.
- `elem.findtext("tag")` — shortcut for `elem.find("tag").text`, or the
  default if absent.
- `.get("attr", default)` — read an attribute; `.attrib` is the whole dict.
- `.itertext()` — all text content of the subtree.

A file-based example (parsing + building), using the app-safe scratch
directory:

```python
import os
import tempfile
import xml.etree.ElementTree as ET

path = os.path.join(tempfile.gettempdir(), "config.xml")

root = ET.Element("config")
server = ET.SubElement(root, "server")
server.set("enabled", "true")
ET.SubElement(server, "host").text = "127.0.0.1"
ET.SubElement(server, "port").text = "8000"

tree = ET.ElementTree(root)
tree.write(path, encoding="utf-8", xml_declaration=True)

parsed = ET.parse(path)
root2 = parsed.getroot()
for node in root2.iter("server"):
    print("server enabled:", node.get("enabled"))
    print("host:", node.findtext("host"), "port:", node.findtext("port"))
```

> [!tip]
> `ET.Element("tag")` builds a node, `ET.SubElement(parent, "tag")` appends a
> child, `.set(attr, value)` adds an attribute, and
> `tree.write(path, encoding="utf-8", xml_declaration=True)` emits a proper
> `<?xml version="1.0" encoding="utf-8"?>` header.

## XML vs JSON

| | XML | JSON |
|---|---|---|
| Native concepts | elements + attributes + text | objects, arrays, scalars |
| Types | everything is text | numbers, booleans, null exist |
| Validation | DTD / XSD | usually schema-less |
| Verbosity | higher | lower |
| Use cases | configs, SOAP, docs | APIs, configs, logs |

Both travel in exactly the same way over sockets: bytes sent by the server,
parsed by the client.

## Common traps

- **Tag/attribute case sensitivity** — `<Book>` and `<book>` are different.
- **Forgetting the single root rule** — two top-level elements raise
  `ParseError`.
- **Confusing `find()` with `findall()`** — the first returns one element (or
  `None`), the second returns a list. `find()` on a missing tag gives `None`,
  not an exception.
- **Expecting `iter()` to find a node that is not a descendant** — `iter()`
  is recursive; `find()`/`findall()` only look at direct children.
- **Using `.text` before checking the element exists** — guard against `None`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In XML, what is the term for a name-value pair written inside an opening tag like id=\"b1\"?"
    type: single
    choices:
      - "an attribute"
      - "a sub-element"
      - "a comment"
      - "a namespace"
    answer: [0]
    explanation: "Values inside the opening tag are attributes: id=\"b1\" declares an attribute named id with value b1."
    difficulty: 1
  - id: q2
    prompt: "Which statement about a well-formed XML document is FALSE?"
    type: single
    choices:
      - "It must contain exactly one root element"
      - "Opening and closing tags must be properly nested"
      - "It must conform to a DTD"
      - "Attribute values must be quoted"
    answer: [2]
    explanation: "A document can be well-formed yet have no DTD at all. Conforming to a DTD is 'valid', a different step from being well-formed."
    difficulty: 2
  - id: q3
    prompt: "What does ElementTree's tree.write(path, encoding='utf-8', xml_declaration=True) produce?"
    type: single
    choices:
      - "A JSON document with an XML header"
      - "An XML file beginning with an XML declaration header"
      - "A gzipped binary archive"
      - "Nothing unless a DTD is supplied"
    answer: [1]
    explanation: "It serializes the tree to XML, encoded as UTF-8, and prepends the <?xml version=...?> declaration."
    difficulty: 2
  - id: q4
    prompt: "How does root.findall('book') differ from root.iter('book')?"
    type: single
    choices:
      - "iter() returns an iterator over literal text only"
      - "findall() returns only direct children named book; iter() returns book descendants at any depth"
      - "findall() recurses into nested elements while iter() does not"
      - "There is no difference; both return every element in the tree"
    answer: [1]
    explanation: "findall() is shallow (direct children only) and returns a list; iter('book') does a full recursive traversal of the subtree."
    difficulty: 2
  - id: q5
    prompt: "Which of the following correctly describe characteristics of DTDs and XML validation?"
    type: multi
    choices:
      - "A DTD declares which elements and attributes a document may use"
      - "ElementTree automatically validates documents against a DTD during parsing"
      - "Validation checks that a document conforms to declared rules"
      - "A well-formed document is always valid"
    answer: [0, 2]
    explanation: "A DTD describes allowed structure and validation checks conformance. ElementTree does NOT validate against DTDs, and well-formedness does not imply validity."
    difficulty: 2
```