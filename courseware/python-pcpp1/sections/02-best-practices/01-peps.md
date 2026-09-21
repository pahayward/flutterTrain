---
id: 01-peps
title: PEPs and the Python philosophy
order: 1
section: 02-best-practices
language: python
summary: What a PEP is, how PEP 1 structures proposals, and the Zen of Python from PEP 20.
tags: [pep, zen, philosophy, import-this]
---

# PEPs and the Python philosophy

## What is a PEP?

A **PEP — Python Enhancement Proposal** — is a design document that describes a
feature, a process, or an informational guideline for the Python language and
its ecosystem. PEPs are the formal way the community proposes, debates, and
records changes. Anyone can submit one, but it only becomes official after
review and acceptance by the community and the Steering Council.

> [!key] On the PCPP1 exam you must recognize a PEP by its number and general
> purpose. Two are central to this section: **PEP 1** (how PEPs work) and
> **PEP 8** (code style). **PEP 20** covers philosophy, **PEP 257** docstrings,
> and **PEP 484** type hints.

## PEP 1 — purpose, types, and formats

PEP 1 is itself a PEP: it defines the PEP process. Its key points:

- **Purpose:** a central place to propose new features, collect community input,
  and record design decisions and history.
- **Types:**
  - **Standards Track** — changes to the language, standard library, or tools
    (e.g. PEP 8, PEP 484).
  - **Informational** — guidelines or information that does not change the
    language (e.g. PEP 20, PEP 257).
  - **Process** — about Python's own processes and tools (e.g. how releases
    work, how the core team is governed).
- **Format:** a header (PEP number, title, author, status, type, Python
  version), followed by the Rationale, Specification, and Backwards
  Compatibility sections.
- **Statuses** proceed roughly: *Draft → Accepted → Final*, with detours like
  *Rejected*, *Withdrawn*, *Superseded*, *Active*, and *Deferred*.

> [!note] Rationale discipline: PEP 1 asks every proposal to explain *why* a
> change is needed. On the exam, "every PEP must include a rationale" is a fair
> test point.

## PEP 20 — the Zen of Python

PEP 20 is an *informational* PEP containing **19 aphorisms** (the 20th slot is
"the Zen of Python, by Tim Peters" itself). Type `import this` in any
interpreter to print it.

> [!note] The Zen of Python — runnable

```python
import this
```

The guiding principles you must know:

| Aphorism | Meaning |
|---|---|
| Beautiful is better than ugly. | Readable code is a goal. |
| Explicit is better than implicit. | Prefer clear, direct code over clever shortcuts. |
| Simple is better than complex. | Prefer simple solutions over complicated ones. |
| Complex is better than complicated. | If complexity is needed, keep it *necessary*. |
| Flat is better than nested. | Favor flat structures over deep nesting. |
| Readability counts. | Code is read more than written. |
| There should be one obvious way to do it. | Favor a single idiomatic approach. |
| Errors should never pass silently. | Handle failures deliberately or make them loud. |
| Now is better than never. | Ship an imperfect solution rather than none. |
| Namespaces are one honking great idea. | Modules and scopes keep names apart. |

> [!trap] "There should be one way" is aspirational. Python often has *two*
> obvious ways (e.g. `%`, `str.format`, f-strings); the Zen asks you to prefer
> the clearest one.

All 19 lines are worth reading before the exam — the questions reword them, so
memorize the *meaning*, not only the words.

## Pounds and quiet imports

The `this` module stores its Zen as a ROT13-encoded string. Fittingly, the
module *uses* `import` inside itself, an obvious violation of "explicit is
better than implicit" — drawn intentionally as a joke.

```python
import this
import codecs

# Decode the hidden text and count its aphorisms.
plain = codecs.decode(this.s, "rot_13")
lines = [ln.strip() for ln in plain.splitlines() if ln.strip()]
print(f"{len(lines)} aphorisms in the Zen")
print("First:", lines[0])
print("Explicit is better than implicit:", any(
    "Explicit" in ln for ln in lines
))
```

## How the Zen guides the exam

- "Errors should never pass silently" appears again in the *programming
  recommendations* objective: never swallow exceptions without a reason.
- "Readability counts" is the justification behind nearly every PEP 8 rule in
  the rest of this section.
- "Now is better than never. Although never is often better than *right* now."
  Warnings you to avoid premature optimization — another gift to the exam.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does the acronym PEP stand for?"
    type: single
    choices:
      - "Python Enhancement Proposal"
      - "Programming Error Prevention"
      - "Python Executive Product"
      - "Public Example Program"
    answer: [0]
    explanation: "A PEP is a Python Enhancement Proposal — a design document for features, processes, or informational guidelines."
    difficulty: 1
  - id: q2
    prompt: "Which PEP describes how PEPs themselves are written and managed?"
    type: single
    choices:
      - "PEP 20"
      - "PEP 1"
      - "PEP 8"
      - "PEP 484"
    answer: [1]
    explanation: "PEP 1 defines the purpose, types, format, statuses, and guidelines of the PEP process."
    difficulty: 2
  - id: q3
    prompt: "A document that only gives guidelines and does not change the language (such as the Zen of Python) is what type of PEP?"
    type: single
    choices:
      - "Standards Track"
      - "Process"
      - "Informational"
      - "Draft"
    answer: [2]
    explanation: "Informational PEPs record guidelines and information; Standards Track changes the language, and Process PEPs govern Python's workflows."
    difficulty: 2
  - id: q4
    prompt: "Which aphorism from the Zen of Python is most relevant to handling exceptions carefully?"
    type: single
    choices:
      - "Flat is better than nested."
      - "Errors should never pass silently."
      - "Now is better than never."
      - "There should be one obvious way to do it."
    answer: [1]
    explanation: "'Errors should never pass silently' means failures must be handled deliberately or made loud — a core principle for exception handling."
    difficulty: 1
  - id: q5
    prompt: "How can you print the Zen of Python from an interactive interpreter?"
    type: single
    choices:
      - "Run the command: import this"
      - "Press Ctrl+Z"
      - "Import the sys module"
      - "Print the os.environ variable"
    answer: [0]
    explanation: "Typing import this imports the this module, which prints the 19 aphorisms."
    difficulty: 1
```