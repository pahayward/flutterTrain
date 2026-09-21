---
id: 11-advanced-exceptions
title: Advanced techniques for exceptions
order: 11
section: 01-object-oriented
language: python
type: lesson
summary: Exceptions as objects, named attributes on custom exceptions, implicit vs explicit chaining, __cause__ and __context__, and __traceback__.
tags: [exceptions, raise, chaining, traceback, cause, context]
prereqs: [01-oop-basics, 03-magic-methods]
---

# Advanced techniques for exceptions

Exceptions are ordinary objects with a rich API. Beyond raising and catching
them, the exam expects you to:

- treat exceptions as objects with named attributes,
- inspect `__cause__`, `__context__`, `__suppress_context__`, `__traceback__`,
- choose between implicit and explicit chaining with `raise ... from ...`.

## Exceptions are objects

When you `raise SomeError(...)`, the argument tuple becomes the exception's
`args`. You can also attach your own data by overriding `__init__`.

```python title="custom-exception.py"
class ValidationError(Exception):
    def __init__(self, field, value, message):
        super().__init__(f"{field}: {message}")
        self.field = field
        self.value = value

try:
    raise ValidationError("age", -5, "must be positive")
except ValidationError as err:
    print(err.args[0])
    print("field:", err.field, "value:", err.value)
```

> [!note] **`except ... as err`**
>
> The `as err` binding names the exception object so you can reach its
> attributes inside the handler. After the block ends the reference is
> cleared in modern Python.

## Implicit chaining: __context__

When an exception is raised *while another is being handled*, Python records
the original in `__context__` automatically. That is **implicit** chaining.

```python title="implicit-chain.py"
def inner():
    raise ValueError("bad value")

def outer():
    try:
        inner()
    except ValueError:
        raise TypeError("user-facing error")   # raised while handling

try:
    outer()
except TypeError as err:
    print("cause is None:", err.__cause__ is None)
    print("context type:", type(err.__context__).__name__)
```

## Explicit chaining: raise ... from

Use `raise NewError() from original` to state that `original` was the direct
cause. This sets `__cause__`. The traceback shows chain:
`Traceback (most recent call last): [ValueError], The above exception was the
direct cause ...`.

```python title="explicit-chain.py"
def load_value():
    return int("abc")

try:
    try:
        load_value()
    except ValueError as cause:
        raise RuntimeError("config file is unreadable") from cause
except RuntimeError as err:
    print("direct cause type:", type(err.__cause__).__name__)
    print("cause args:", err.__cause__.args)
```

> [!tip] **`from err` vs `from None`**
>
> - `raise X from err` — explicit link, `__cause__` set.
> - `raise X from None` — hides the context, `__suppress_context__` becomes
>   `True`, and the display shows only `X`.

## Hiding the context: from None

```python title="from-none.py"
def load_value():
    return int("abc")

try:
    try:
        load_value()
    except ValueError:
        raise RuntimeError("load failed") from None
except RuntimeError as err:
    print("cause is None:", err.__cause__ is None)
    print("suppress_context:", err.__suppress_context__)
    print("handled:", type(err).__name__)
```

> [!warning] **Order matters in the args of raise**
>
> With `raise RuntimeError() from None`, no chaining happens — `__cause__`
> stays `None`. Only the explicit `from <exception>` sets `__cause__`.

## __traceback__ and the traceback module

Every exception carries a traceback object in `__traceback__`. The `traceback`
module can format it into strings for logging.

```python title="traceback-obj.py"
import traceback

def explode():
    raise ValueError("boom")

try:
    explode()
except ValueError as err:
    print("has traceback:", err.__traceback__ is not None)
    print("formatted lines:", len(traceback.format_exception(err)))
```

> [!key] **Which field when?**
>
> - `__context__` — set *implicitly* for exceptions raised during handling.
> - `__cause__` — set *explicitly* by `raise ... from ...`.
> - To suppress: `raise ... from None`.
> - `__traceback__` — the stack trail; `traceback.format_exception` turns it
>   into readable text.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "When is __context__ set?"
    type: single
    choices:
      - "Implicitly, when an exception is raised while another exception is being handled."
      - "Only when you write ... from ..."
      - "Whenever a program starts."
      - "It is never set; it is always None."
    answer: [0]
    explanation: "__context__ records the exception that was live when the new one was raised."
    difficulty: 2
  - id: q2
    prompt: "What does raise NewError() from old do?"
    type: single
    choices:
      - "Sets __cause__ to old and displays it in the traceback chain."
      - "Deletes the old exception's traceback."
      - "Replaces the exception class with a copy."
      - "Suppresses all output."
    answer: [0]
    explanation: "Explicit chaining links old as the direct cause via __cause__."
    difficulty: 1
  - id: q3
    prompt: "raise NewError() from None ..."
    type: single
    choices:
      - "Suppresses the implicit context so only NewError is displayed."
      - "Creates a Python None object as the exception value."
      - "Raises NewError twice."
      - "Is a syntax error."
    answer: [0]
    explanation: "from None sets __suppress_context__; the chain is hidden."
    difficulty: 2
  - id: q4
    prompt: "How can custom exceptions carry extra named attributes?"
    type: single
    choices:
      - "Override __init__ in the exception class and store values on self."
      - "Use sys.set_trace."
      - "Add attributes to the traceback module."
      - "Exceptions cannot hold attributes."
    answer: [0]
    explanation: "Exceptions are classes; a custom __init__ can save any data before calling super().__init__."
    difficulty: 1
  - id: q5
    prompt: "Select the true statements about exception chaining."
    type: multi
    choices:
      - "Explicit chaining requires the from keyword."
      - "Implicit chaining records the currently handled exception in __context__."
      - "__cause__ is set only by an explicit ... from ... clause."
      - "__traceback__ is available on every exception."
    answer: [0, 1, 2, 3]
    explanation: "All are correct descriptions of the exception-chain model."
    difficulty: 2
```