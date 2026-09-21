---
id: 06-args-kwargs-decorators
title: Extended argument syntax & decorators
order: 6
section: 01-object-oriented
language: python
type: lesson
summary: Collect and forward arguments with *args and **kwargs, build closures, and write function and class-based decorators.
tags: [args, kwargs, closures, decorators, callable, syntax-sugar]
prereqs: [01-oop-basics]
---

# Extended argument syntax & decorators

Two Python features change how functions are written: **extended argument
syntax** (`*args`, `**kwargs`) and **decorators** (function- and class-based).
They appear constantly in libraries, and the exam tests both.

## *args and **kwargs

- `*args` collects **extra positional arguments** into a tuple.
- `**kwargs` collects **extra keyword arguments** into a dict.
- When *calling*, `f(*t)` unpacks a sequence into positional args and
  `f(**d)` unpacks a dict into keyword args — a perfect **forwarding** tool.

```python title="forwarding.py"
def collect(*args, **kwargs):
    return args, kwargs

def forward(*args, **kwargs):
    return collect(*args, **kwargs)   # forward as-is

pos, kw = forward(1, 2, name="Ada", retries=3)
print(pos)
print(kw)

def multiply(a, b, c):
    return a * b * c

nums = (2, 3, 4)
print(multiply(*nums))       # unpack tuple into positional params
```

> [!tip] **Parameter order**
>
> `def f(a, b, *args, c=10, **kwargs)` — positional params first, then `*args`,
> then keyword-only/defaulted parameters, then `**kwargs`. Put `**kwargs`
> last; `*args` after keyword-only params would be a syntax error.

## Closures

A **closure** is a nested function that remembers variables from the enclosing
function even after the enclosing call returns. The captured variable lives on
as long as the inner function lives.

```python title="closures.py"
def make_counter():
    count = 0

    def tick():
        nonlocal count
        count += 1
        return count

    return tick

c1 = make_counter()
c2 = make_counter()
print(c1(), c1(), c1())   # each closure has its own count
print(c2())
```

> [!trap] **`nonlocal` is required**
>
> Assigning to `count` inside `tick` without `nonlocal` would create a *new
> local* variable instead of updating the captured one — a classic bug.

## Function decorators: syntactic sugar

`@` is sugar: the code below the decorator is defined, then passed to the
decorator, which returns a replacement. Any callable can be a decorator.

```python title="decorator-sugar.py"
def shout(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return str(result).upper() + "!"
    return wrapper

def star(func):
    def wrapper(*args, **kwargs):
        return f"** {func(*args, **kwargs)} **"
    return wrapper

@shout
def hi():
    return "hi"

@star
def low():
    return "low"

print(hi())    # equivalent to: hi = shout(hi)
print(low())
print(star(lambda: "lambda"))   # works without @ too
```

### Decorator factories and stacking

A decorator that takes *arguments* (`@tag("b")`) is a function that *returns a
decorator*. Decorators stack bottom-up: `@a` over `@b` means `f = a(b(f))`.

```python title="stacking.py"
def tag(t):
    def decorator(func):
        def wrapper(*args, **kwargs):
            return f"<{t}>{func(*args, **kwargs)}</{t}>"
        return wrapper
    return decorator

def shout(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs).upper()
    return wrapper

@shout
@tag("b")
def greet(name):
    return f"hello {name}"

print(greet("Ada"))    # <B>HELLO ADA</B>  (tag runs first, then shout)
```

> [!note] **Decorating functions with classes**
>
> A class works as a decorator if calling it returns a callable — that is, if
> it defines `__call__` (module 03). This lets a decorator keep extra state.

## Class-based decorators and __call__

```python title="class-decorator.py"
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.calls = 0

    def __call__(self, *args, **kwargs):
        self.calls += 1
        result = self.func(*args, **kwargs)
        print(f"call #{self.calls} -> {result}")
        return result

@CountCalls
def add(a, b):
    return a + b

add(1, 2)
add(10, 20)
print("total calls:", add.calls)
```

> [!warning] **Metadata is lost**
>
> A hand-written `wrapper` replaces the original function, so `greet.__name__`
> becomes `"wrapper"`. Use `@functools.wraps` on the wrapper to copy the
> original name, docstring, and signature (stdlib, same pattern).

## Quiz

```yaml
questions:
  - id: q1
    prompt: "In def f(*args, **kwargs), what do *args and **kwargs collect?"
    type: single
    choices:
      - "Extra positional arguments into a tuple and extra keyword arguments into a dict."
      - "Extra positionals into a dict and keywords into a tuple."
      - "All arguments into one string."
      - "Only arguments that are None."
    answer: [0]
    explanation: "*args gathers a tuple of positionals; **kwargs gathers a dict of keyword arguments."
    difficulty: 1
  - id: q2
    prompt: "What is a closure?"
    type: single
    choices:
      - "A nested function that keeps referencing variables from its enclosing scope."
      - "An anonymous function that cannot be stored."
      - "A function that returns a list of functions."
      - "A class that has a __call__ method."
    answer: [0]
    explanation: "Closures capture enclosing variables; they outlive the enclosing call."
    difficulty: 2
  - id: q3
    prompt: "@decorator applied to def f(): ... is equivalent to which line?"
    type: single
    choices: ["f = decorator(f)", "f = decorator()", "decorator = f", "decorator = decorator()"]
    answer: [0]
    explanation: "@ is sugar for f = decorator(f); the decorated name is rebound to the returned callable."
    difficulty: 1
  - id: q4
    prompt: "What does a class-based decorator rely on to make instances callable?"
    type: single
    choices: ["__call__", "__str__", "__len__", "__hash__"]
    answer: [0]
    explanation: "Defining __call__ makes an instance behave like a function, which is how the wrapper is invoked."
    difficulty: 2
  - id: q5
    prompt: "Select the true statements about stacked decorators."
    type: multi
    choices:
      - "Decorators apply bottom-up."
      - "The topmost decorator is applied last."
      - "A decorator factory takes arguments and returns a decorator."
      - "@functools.wraps copies metadata onto the wrapper."
    answer: [0, 1, 2, 3]
    explanation: "All four are true: @a over @b gives f = a(b(f)), factories return decorators, and wraps preserves metadata."
    difficulty: 3
```