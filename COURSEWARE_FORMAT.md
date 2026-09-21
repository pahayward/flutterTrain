# Courseware Format Specification v1

This document defines the on-disk format for all course content in the PCPP1
Study app. Both bundled content (`courseware/`) and AI/user-generated content
(installed into the app's documents directory) use the **same format**, so the
content engine (M7) loads one unified schema.

## Terminology

- **Course** — a top-level subject (e.g. `python-pcpp1`, `golang`). Backed by
  `courseware/<course-id>/manifest.json` plus `/assets/courseware/<id>/styles.mdc`
  (optional per-course branding).
- **Part / Section** — a grouping of course units. *Course sections for the
  Python course map to the official PCPP-32-101 exam sections; Go "parts" map
  to the zero-to-hero curriculum parts.*
- **Module / Lesson** — smallest navigable unit. Exactly one `.md` file.
- **Content block** — a piece of a module body: prose, code, callout, or quiz.

## Directory layout

```
courseware/<course-id>/
├── manifest.json
└── sections/01-<key>/
    ├── 01-<module-slug>.md
    └── ...
```

- Section directories are sorted by numeric prefix for ordering.
- Module filenames are sorted by numeric prefix for ordering.
- All ids/slugs are lowercase `kebab-case`, ASCII only.

## `manifest.json`

```json
{
  "courseId": "python-pcpp1",
  "title": "PCPP1: Certified Professional Python Programmer",
  "subtitle": "Advanced OOP, best practices, GUI, networking, file processing",
  "language": "python",
  "examMode": {
    "questionCount": 45,
    "durationMinutes": 65,
    "passPct": 70
  },
  "sections": [
    {
      "id": "01-object-oriented",
      "title": "Section 1: Advanced Object-Oriented Programming",
      "weight": 35,
      "modules": [
        { "id": "01-oop-basics", "title": "Classes, instances, attributes, methods" }
      ]
    }
  ]
}
```

- `sections[].weight` — exam section weight as a percentage (Python course only;
  Go course may omit or set weights to 0).
- `modules[]` is redundant metadata; the engine discovers modules from the
  filesystem but uses this list for quick title lookup and to guarantee order.
- Extra keys may exist; unknown keys are ignored by the engine.

## Module file (`<slug>.md`)

Each module is a Markdown file with a YAML front-matter block.

```markdown
---
id: 01-oop-basics
title: Classes, instances, attributes, methods
order: 1
section: 01-object-oriented
language: python        # "python" | "golang"
type: lesson            # "lesson" | "cheatsheet"
tags: [oop, class, instance]
---

# Heading (optional; engine falls back to title)

Body content. See "Content blocks" below.

```python
# An example block
class Foo:
    pass
```
```

### Front matter fields

| Field | Required | Type | Notes |
|---|---|---|---|
| `id` | yes | string | matches the filename slug |
| `title` | yes | string | display title |
| `order` | yes | int | ordering within the section |
| `section` | yes | string | section id (must exist in manifest) |
| `language` | yes | "python"\|"golang" | primary language for example runner |
| `type` | no | "lesson"\|"cheatsheet" | default `lesson` |
| `tags` | no | [string] | used by search + flashcards |
| `summary` | no | string | one-line description used in lists |
| `prereqs` | no | [string] | module ids that should be read first |

### Front matter extension: freeform fields

Generated modules may add `expandedBy`, `generated: true`, any custom string
fields. The engine ignores them; the AI expansion flow may use them.

## Content blocks

Blocks are detected by parsing the rendered Markdown in order. The renderer
produces a block list, each with a `kind`.

### 1. Prose (`kind: prose`)
Everything that is not code/callout/quiz. Supports standard Markdown plus
special inline callouts:

- `> [!note]`, `> [!tip]`, `> [!warning]`, `> [!trap]`, `> [!key]` — GitHub
  alert syntax. Rendered as color-coded callout cards.

### 2. Example code (`kind: code`)
Fenced code block.

````markdown
```python
print("hello")
```
````

Language tag required (`python` or `go`). A code block with language `python`
or `go` is **runnable** by default: the reader shows a Run button in addition
to Copy.

### Non-runnable examples (`eval=no`)

Code that cannot execute on-device (headless `tkinter` GUIs, code requiring
external network access, code with side effects) is tagged so the reader shows
only Copy:

````markdown
```python eval=no
import tkinter as tk
root = tk.Tk()  # would need a display
```
````

The parser regex for the info string is `<lang> <info...>`; the token `eval=no`
disables the Run button. When unsure, prefer runnable examples.

Special `title` attribute:

````markdown
```python title="chained-exceptions.py"
raise ...
```
````

Conventions for code that must run on device:

- Python: runs under the bundled CPython (**3.13.x**). Must never depend on
  network, filesystem outside a scratch dir, or packages beyond the stdlib
  bundled by Chaquopy. Prefer `print()`-based observable output.
- Go: runs in the embedded `yaegi` interpreter on device. **Only use language
  features and stdlib packages known to work in yaegi** (list in
  `courseware/golang/parts/00/…`, "yaegi supported features"). Avoid cgo,
  unsafe-pointer-heavy code, `os.Exit`, etc.
- Timeout: max 10s per run on device; output captured as text.

### 3. Callout (`kind: callout`)
See prose alerts above. If a fenced block tag is a known alert, the parser
promotes it to a callout block.

### 4. Quiz (`kind: quiz`) — `## Quiz` section

A H2 heading `## Quiz` followed by YAML front matter inside a fenced block.

````markdown
## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which magic method implements truthiness?"
    type: single          # "single" | "multi"
    choices:
      - "__bool__"
      - "__truth__"
      - "__len__"
      - "__and__"
    answer: [0]           # zero-indexed choice list (single → length 1)
    explanation: "__bool__ is called by bool(); __len__ only as a fallback."
    difficulty: 1         # 1..3
  - id: q2
    prompt: "Select the decorators that are real Python syntax."
    type: multi
    choices: ["@classmethod", "#static", "@property", "@staticmethod"]
    answer: [0, 2, 3]
    explanation: "@property and @static*" + " are builtins; # is a comment."
    difficulty: 2
```

Quiz placement: at the end of most lessons; a cheatsheet may omit it.
- `choices` must be length >= 2; exactly one correct set per question.
- `explanation` is shown after answering (English).
- Explanations my contain single-line `code` spans.

## Exam question bank

Any course may declare an exam bank to drive the simulator.

````markdown
## ExamQuestions

```yaml
bank:
  - question: "..."
    type: single
    choices: [...]
    answer: [1]
    explanation: "..."
    weight: 4
    section: 01-object-oriented
```
````

The simulator draws `examMode.questionCount` items proportionally to section
weights and % weight field. Same schema as quiz questions plus `section` and
`weight`.

## Cheatsheet

A `type: cheatsheet` module is a lesson whose body should read as a reference:
compact prose, heavy code, almost no quiz. Rendered same as a lesson; shown
with a different icon in the tree.

## Validation (tools/validate_content.py)

Run from repo root:

```bash
python3 tools/validate_content.py
```

Checks (non-exhaustive):
1. manifest parses; course ids match directory names.
2. Every `sections[].modules[].id` has a matching `.md` file and vice versa.
3. Front matter: required fields present & typed; `section` exists in manifest.
4. `## Quiz` / `## ExamQuestions` YAML parses; schema constraints above.
5. Fenced code fences balance per file.
6. Alert syntax `> [!kind]` uses a known kind.
7. (Optional) every runnable code block is smoke-executed offline if a runner
   exists for the language (see `--exec` flag).

Exit code 0 = pass. Any failure = 1 with pointer to the offending file/block.