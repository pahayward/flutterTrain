---
id: 03-xml-processing
title: Building and parsing XML
order: 3
section: 05-file-processing
language: python
type: lesson
summary: Parse and build XML documents using xml.etree.ElementTree with find, findall, Element, and SubElement.
tags: [xml, elementtree, parsing, building]
---

# Building and Parsing XML

Python's `xml.etree.ElementTree` module (commonly imported as `ET`) lets you parse existing XML and build new XML trees entirely in memory.

> [!key] Two modes of use
- **Parsing**: read an XML string/file, navigate the tree with `find()` / `findall()`.
- **Building**: create elements from scratch, attach sub-elements, and serialize.

## Parsing XML — find and findall

`ET.fromstring()` parses an XML string and returns the root `Element`. From there, `find()` returns the first matching child, and `findall()` returns all matches.

```python
import xml.etree.ElementTree as ET

xml_data = """
<catalog>
    <book id="1">
        <title>Python basics</title>
        <price>29.99</price>
    </book>
    <book id="2">
        <title>Advanced Python</title>
        <price>49.99</price>
    </book>
</catalog>
"""

root = ET.fromstring(xml_data)

first_book = root.find("book")
print("First title:", first_book.find("title").text)

all_books = root.findall("book")
for book in all_books:
    title = book.find("title").text
    price = book.find("price").text
    print(f"  {title} — ${price}")
```

> [!tip] Attribute access
Elements behave like dicts for attributes: `elem.get("id")` retrieves the `id` attribute.

## Navigating with XPath

`find()` and `findall()` support limited XPath syntax including `.` (current), `..` (parent), and `//` (descendant search).

```python
import xml.etree.ElementTree as ET

xml_data = """
<shop>
    <category name="fruit">
        <item>apple</item>
        <item>banana</item>
    </category>
    <category name="veg">
        <item>carrot</item>
    </category>
</shop>
"""

root = ET.fromstring(xml_data)

items = root.findall(".//item")
print("All items:", [i.text for i in items])

root_items = root.findall("category/item")
print("Direct children:", [i.text for i in root_items])
```

## Building XML — Element and SubElement

`ET.Element()` creates a new root element. `ET.SubElement()` creates a child under an existing element.

```python
import xml.etree.ElementTree as ET

root = ET.Element("catalog")

book1 = ET.SubElement(root, "book", attrib={"id": "1"})
ET.SubElement(book1, "title").text = "Python basics"
ET.SubElement(book1, "price").text = "29.99"

book2 = ET.SubElement(root, "book", attrib={"id": "2"})
ET.SubElement(book2, "title").text = "Advanced Python"
ET.SubElement(book2, "price").text = "49.99"

tree = ET.ElementTree(root)
ET.indent(tree, space="    ")
print(ET.tostring(root, encoding="unicode"))
```

> [!note] `ET.indent()`
`indent()` adds pretty-printing whitespace (Python 3.9+). Use it before serializing for human-readable output.

## Modifying an XML Tree

You can change text, attributes, add or remove elements on a parsed tree.

```python
import xml.etree.ElementTree as ET

xml_data = """
<store>
    <product name="pen" price="1.50"/>
    <product name="book" price="12.00"/>
</store>
"""

root = ET.fromstring(xml_data)

for product in root.findall("product"):
    old = float(product.get("price"))
    product.set("price", f"{old * 1.1:.2f}")

print(ET.tostring(root, encoding="unicode"))
```

## Serializing — tostring and write

Use `ET.tostring()` to get an XML string, or `tree.write()` to write to a file (or `io.BytesIO` for in-memory).

```python
import xml.etree.ElementTree as ET
import io

root = ET.Element("greeting")
root.text = "Hello, XML!"

xml_bytes = ET.tostring(root, encoding="unicode")
print(xml_bytes)

buf = io.BytesIO()
tree = ET.ElementTree(root)
tree.write(buf, encoding="utf-8", xml_declaration=True)
print("Written bytes:", buf.tell())
buf.close()
```

> [!trap] `tostring` encoding
Pass `encoding="unicode"` to get a `str`. Pass `encoding="utf-8"` to get `bytes`. Mixing them up is a common bug.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which function parses an XML string and returns the root Element?"
    type: single
    choices: ["ET.parse()", "ET.fromstring()", "ET.load()", "ET.read()"]
    answer: [1]
    explanation: "ET.fromstring() parses an XML string and returns the root Element directly."
    difficulty: 1
  - id: q2
    prompt: "What does elem.find('tag') return if no match is found?"
    type: single
    choices: ["[]", "None", "An empty Element", "It raises ValueError"]
    answer: [1]
    explanation: "find() returns None when no matching child is found."
    difficulty: 1
  - id: q3
    prompt: "Which creates a new child element under an existing parent?"
    type: single
    choices: ["ET.Element()", "ET.SubElement()", "ET.append()", "ET.child()"]
    answer: [1]
    explanation: "ET.SubElement(parent, tag) creates a child element and appends it to the parent."
    difficulty: 2
  - id: q4
    prompt: "What does ET.indent(tree) do?"
    type: single
    choices: ["Validates the XML structure", "Adds pretty-print whitespace", "Compresses the tree", "Sorts elements alphabetically"]
    answer: [1]
    explanation: "indent() adds newline and indentation whitespace for human-readable output."
    difficulty: 2
  - id: q5
    prompt: "To get a string from tostring() with encoding='utf-8', the return type is:"
    type: single
    choices: ["str", "bytes", "bytearray", "memoryview"]
    answer: [1]
    explanation: "When encoding is not 'unicode', tostring() returns bytes."
    difficulty: 2
```
