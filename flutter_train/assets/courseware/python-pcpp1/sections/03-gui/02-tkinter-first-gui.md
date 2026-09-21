---
id: 02-tkinter-first-gui
title: First tkinter program
order: 2
section: 03-gui
language: python
summary: Importing tkinter, creating the root window, basic widgets, title/geometry, and the event loop.
tags: [tkinter, Tk, mainloop, window]
---

# First tkinter Program

## Importing tkinter

The conventional import:

```python eval=no
import tkinter as tk          # standard alias
root = tk.Tk()                # create root window
```

> tkinter is not available on Android, so this GUI example is non-runnable.

You can also use `from tkinter import *`, but the aliased import avoids
name clashes and is considered best practice.

## Creating and configuring the root window

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("My First App")
root.geometry("400x300")      # width x height in pixels
root.resizable(True, True)    # allow horizontal and vertical resize
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Method | Purpose |
|---|---|
| `title(text)` | Set the window title bar text. |
| `geometry("WxH")` | Set initial size (string format `"400x300"`). |
| `resizable(h, v)` | Boolean flags for resize capability. |
| `config(**kw)` | Batch-set multiple properties. |
| `maxsize(w, h)` | Impose a maximum window size. |
| `minsize(w, h)` | Impose a minimum window size. |

## Adding basic widgets

### Label — displays text or an image

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Label Demo")

lbl = tk.Label(root, text="Hello, PCPP1!", font=("Arial", 16), fg="blue")
lbl.pack(pady=20)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Button — triggers an action

```python eval=no
import tkinter as tk

def say_hello():
    print("Button clicked!")

root = tk.Tk()
btn = tk.Button(root, text="Click Me", command=say_hello)
btn.pack(pady=10)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Entry — single-line text input

```python eval=no
import tkinter as tk

root = tk.Tk()
entry = tk.Entry(root, width=30)
entry.pack(pady=10)

tk.Button(root, text="Read", command=lambda: print(entry.get())).pack()
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## The mainloop() call

```python eval=no
import tkinter as tk

root = tk.Tk()
# ... build the interface ...
root.mainloop()        # blocks here until window is closed
print("Window closed") # executes after mainloop returns
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!warning] Code *after* `mainloop()` only runs once the event loop ends (i.e.,
> the user closes the window). Never put widget creation after `mainloop()`.

## Minimal complete application

```python eval=no
import tkinter as tk

def on_greet():
    label.config(text=f"Hello, {name_entry.get()}!")

root = tk.Tk()
root.title("Greeting App")
root.geometry("300x150")

name_entry = tk.Entry(root, width=25)
name_entry.pack(pady=(20, 5))

label = tk.Label(root, text="", font=("Arial", 14))
label.pack(pady=10)

tk.Button(root, text="Greet", command=on_greet).pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!tip] This single-file example demonstrates the three essential ingredients
> of any tkinter app: (1) create `Tk`, (2) add widgets, (3) call `mainloop()`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the standard alias for importing tkinter?"
    type: single
    choices:
      - "import tkinter as ti"
      - "import tkinter as tk"
      - "import tk"
      - "from tk import *"
    answer: [1]
    explanation: "The conventional alias is `tk`."
    difficulty: 1
  - id: q2
    prompt: "Which method sets the window title in tkinter?"
    type: single
    choices:
      - "root.set_title('My App')"
      - "root.title('My App')"
      - "root.window_title('My App')"
      - "root.config(title='My App')"
    answer: [1]
    explanation: "The title() method sets or gets the window title."
    difficulty: 1
  - id: q3
    prompt: "What does the string '500x400' passed to geometry() represent?"
    type: single
    choices:
      - "500 pixels from left, 400 from top"
      - "500 columns, 400 rows"
      - "500 pixels wide, 400 pixels tall"
      - "500 mm wide, 400 mm tall"
    answer: [2]
    explanation: "The format is 'WIDTHxHEIGHT' in screen pixels."
    difficulty: 1
  - id: q4
    prompt: "What happens to code placed after the mainloop() call?"
    type: single
    choices:
      - "It runs immediately alongside the event loop"
      - "It runs only after the event loop ends (window closed)"
      - "It causes a SyntaxError"
      - "It is ignored silently"
    answer: [1]
    explanation: "mainloop() blocks; code after it executes only when the loop exits."
    difficulty: 2
```
