# Content Authoring Guide (for agents)

You are authoring offline study courseware. Follow `COURSEWARE_FORMAT.md` (read
it first — it is the contract between authors, the validator, and the app
engine). Below are the universal rules. Your task prompt supplies the exact
section, module file paths, titles, and syllabus points.

> **App note:** after content changes the Flutter app reads `courseware/` via a
> build-time export (`tools/export_content.py` → `app/assets/courseware/pack.json`).
> For a `flutter run` dev loop you must re-run that export after editing content;
> the whole pipeline is in `tools/build_apk.sh`.

## Files you will create

One Markdown file per module under the given section directory, named exactly
as listed in your prompt, e.g. `courseware/python-pcpp1/sections/01-object-oriented/01-oop-basics.md`.
You do NOT need to edit `manifest.json` (the engine discovers files).

## Front matter template

```markdown
---
id: <filename-stem>
title: <display title>
order: <N>
section: <section-id>
language: python        # or golang
summary: <one line>
tags: [tag1, tag2]
---
```

## Content quality bar

- **Teach to the exam**: each module maps to the listed syllabus objectives.
  Include: definitions, why-it-matters, short code examples, and common traps.
- **Devices**: notes read comfortably on a phone (short paragraphs, headers,
  bullet lists). Use GitHub alert callouts where useful:
  `> [!key]`, `> [!note]`, `> [!tip]`, `> [!warning]`, `> [!trap]`.
- **Zero-to-hero ordering**: earlier modules introduce, later modules build on.

## Runnable code rules (important!)

- Every module should contain at least 2 runnable examples (more for
  fundamentals). Language tag is `python` or `go`.
- Optional short title: ` ```python title="guess.py"`.
- **Python (PCPP1 course)**:
  - Examples must run on the embedded CPython 3.13 with **stdlib only**, no
    network, and no GUI. `print()`-observable output preferred.
  - GUI/tkinter, anything needing a display/network, or anything with external
    side effects: tag ` ```python eval=no ` and add a note explaining why it
    can't run on-device.
  - The GUI section examples will be mostly `eval=no` (tkinter isn't on
    Android); that's fine and expected.
  - Network examples: server+client against `localhost` ARE runnable. Anything
    hitting the real internet must be `eval=no`.
- **Go (golang course)**:
  - Examples execute in the `yaegi` interpreter. Confirm each runs with:
    `tools/verify_go_examples.sh <your-files...>` (build failure email/shell
    stops you — run `(cd app/go && go run ./cmd/checkcontent <files>)`).
  - yaegi supports: functions, structs/methods/interfaces, closures, channels,
    goroutines, most stdlib (fmt, strings, encoding/json, etc). Avoid cgo,
    `os.Exit`, package `init` tricks, and exotic reflection.
  - Statements like `x := 1` must sit inside `func main(){...}` in your example
    (the engine wraps them) — that's normal.
  - Output ONLY via `print(...)` or `fmt.Println(...)`. `fmt.Println` requires
    `import "fmt"` at the top of the block.

## Quizzes

End most modules with:

````markdown
## Quiz

```yaml
questions:
  - id: q1
    prompt: "..."
    type: single            # or multi
    choices: ["...", "..."]
    answer: [0]             # zero-indexed
    explanation: "why"
    difficulty: 1           # 1..3
```
````

- 3-5 questions per normal module.
- **Practice modules** (the highest-numbered file in a section, `NN-section-practice.md`):
  contain a short "Section review" summary plus a `## ExamQuestions` YAML block
  (schema identical to quiz, plus `section: <id>` and `weight: N` per question).
  Provide the number of questions your prompt specifies. These feed the exam
  simulator.

## Verification (REQUIRED before finishing)

Run and fix all failures:

```bash
python3 tools/validate_content.py
python3 tools/verify_python_examples.py --course python-pcpp1   # python courses only
tools/verify_go_examples.sh <your-md-files...>                  # go courses only
```

Do not proceed past `FAIL` results on your own files. `eval=no` blocks are
skipped by design.

## When you're done

Report: files written (paths), module titles, total quiz question count,
exam-bank question count, verification results (validator + example runner).
Do NOT paste large file contents into your report.