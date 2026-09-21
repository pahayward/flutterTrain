---
id: 07-observables-dialogs-colors
title: Observable variables, dialogs, colors
order: 7
section: 03-gui
language: python
summary: StringVar/IntVar/DoubleVar/BooleanVar, observer pattern, tkinter messagebox and filedialog, RGB/HEX color models.
tags: [StringVar, IntVar, observer, messagebox, filedialog, color, hex]
---

# Observable Variables, Dialogs & Colors

## Observable (tkinter) variables

Ordinary Python variables are **not** linked to widgets. tkinter provides
special variable classes that automatically update widgets when their
value changes — and vice versa.

| Class | Python type | Typical use |
|---|---|---|
| `StringVar` | `str` | Labels, Entry text, Radiobutton groups |
| `IntVar` | `int` | Checkbuttons, numeric entries |
| `DoubleVar` | `float` | Sliders, numeric entries |
| `BooleanVar` | `bool` | Checkbutton on/off state |

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Observable Variables")

name = tk.StringVar(value="Alice")          # initial value

lbl = tk.Label(root, textvariable=name, font=("Arial", 14))
lbl.pack(pady=10)

def update_name():
    name.set(name.get() + "!")             # label updates automatically

tk.Button(root, text="Append !", command=update_name).pack()
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!key] Using `textvariable=` (or `variable=` on other widgets) creates the
> two-way link. Writing to the variable **immediately** reflects in the widget.

### Observer / trace mechanism

You can **observe** changes to an observable variable with `trace_add()`:

```python eval=no
import tkinter as tk

root = tk.Tk()

value = tk.IntVar(value=0)

def on_change(*args):
    print(f"Value changed to: {value.get()}")

value.trace_add("write", on_change)       # fires on every write

entry = tk.Entry(root, textvariable=value)
entry.pack(padx=10, pady=10)

tk.Button(root, text="Set 42", command=lambda: value.set(42)).pack()
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

The `trace_add` callback receives three arguments: `name`, `index`, and
`mode`. The mode string is:

| Mode | Trigger |
|---|---|
| `"write"` | Variable is set or modified. |
| `""read""` | Variable is read via `get()`. |
| `"unset"` | Variable is deleted (`name.set(None)`). |

> [!warning] Avoid creating infinite loops: a trace handler that modifies the
> same variable will trigger itself. Check `args` or use a guard flag.

### Practical: live-linked labels

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Live Labels")

count = tk.IntVar(value=0)

status = tk.Label(root, textvariable=count, font=("Courier", 24))
status.pack(pady=20)

tk.Button(root, text="+1", command=lambda: count.set(count.get() + 1)).pack()
tk.Button(root, text="Reset", command=lambda: count.set(0)).pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## tkinter dialogs

### messagebox — simple alert/confirm dialogs

```python eval=no
import tkinter as tk
from tkinter import messagebox

root = tk.Tk()
root.title("Dialog Demo")

def show_info():
    messagebox.showinfo("Info", "Operation completed!")

def show_warning():
    messagebox.showwarning("Warning", "Disk space low.")

def ask_yes_no():
    answer = messagebox.askyesno("Confirm", "Save changes?")
    result.config(text=f"User said: {'Yes' if answer else 'No'}")

tk.Button(root, text="Info", command=show_info).pack(pady=5)
tk.Button(root, text="Warning", command=show_warning).pack(pady=5)
tk.Button(root, text="Yes/No", command=ask_yes_no).pack(pady=5)

result = tk.Label(root, text="")
result.pack(pady=10)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Function | Shows |
|---|---|
| `showinfo(title, message)` | Information dialog. |
| `showwarning(title, message)` | Warning dialog. |
| `showerror(title, message)` | Error dialog. |
| `askyesno(title, message)` | Yes / No question → `bool`. |
| `askokcancel(title, message)` | OK / Cancel → `bool`. |
| `askretrycancel(title, message)` | Retry / Cancel → `bool`. |

### filedialog — open and save files

```python eval=no
import tkinter as tk
from tkinter import filedialog

root = tk.Tk()
root.withdraw()              # hide the root window for a clean dialog

path = filedialog.askopenfilename(
    title="Select a file",
    filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
)
if path:
    print(f"Selected: {path}")

save_path = filedialog.asksaveasfilename(
    defaultextension=".txt",
    filetypes=[("Text files", "*.txt")]
)
if save_path:
    print(f"Save to: {save_path}")
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Function | Purpose |
|---|---|
| `askopenfilename(...)` | Open-file dialog. |
| `asksaveasfilename(...)` | Save-as dialog. |
| `askdirectory(...)` | Choose a directory. |
| `askopenfilenames(...)` | Multiple file selection. |

## Colors in tkinter

### RGB model

Every colour on screen is a mix of **Red**, **Green**, and **Blue** channels,
each ranging `0`–`255`.

| Colour | R | G | B |
|---|---|---|---|
| Red | 255 | 0 | 0 |
| Green | 0 | 255 | 0 |
| Blue | 0 | 0 | 255 |
| White | 255 | 255 | 255 |
| Black | 0 | 0 | 0 |

### HEX notation

tkinter commonly uses **hexadecimal** strings: `"#RRGGBB"` or `"#RRGGBBAA"`.

The conversion between HEX and RGB is pure Python, so this example **runs
on-device** — no display required:

```python
# Pure Python — the maths behind tkinter hex colours
def hex_to_rgb(code):
    code = code.lstrip("#")
    return tuple(int(code[i:i + 2], 16) for i in (0, 2, 4))

def rgb_to_hex(r, g, b):
    return f"#{r:02X}{g:02X}{b:02X}"

for name, code in [("red", "#FF0000"), ("green", "#00FF00"),
                   ("blue", "#0000FF"), ("mixed", "#8040C0")]:
    r, g, b = hex_to_rgb(code)
    print(f"{name}: {code} -> R={r} G={g} B={b}  (round-trip {rgb_to_hex(r, g, b)})")
```

```
red: #FF0000 -> R=255 G=0 B=0  (round-trip #FF0000)
green: #00FF00 -> R=0 G=255 B=0  (round-trip #00FF00)
blue: #0000FF -> R=0 G=0 B=255  (round-trip #0000FF)
mixed: #8040C0 -> R=128 G=64 B=192  (round-trip #8040C0)
```

We can mimic an observable variable with a tiny observer-list class — the
same idea tkinter's `trace_add()` uses:

```python
class FakeVar:
    def __init__(self, value):
        self._value = value
        self._observers = []

    def get(self):
        return self._value

    def set(self, value):
        self._value = value
        for callback in self._observers:
            callback(self._value)

    def trace_add(self, mode, callback):
        self._observers.append(callback)

count = FakeVar(0)
count.trace_add("write", lambda v: print(f"widget updated to {v}"))
count.set(1)
count.set(42)
```

### Named colours

tkinter also recognises many standard colour names:

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Colour Demo")

colours = ["red", "orange", "yellow", "green", "blue", "purple",
           "white", "lightyellow", "lightblue", "lightgreen",
           "salmon", "plum", "khaki", "tomato", "steelblue"]

for i, c in enumerate(colours):
    tk.Label(root, text=c, bg=c, fg="black" if i < 5 else "white",
             width=15, relief=tk.RIDGE).grid(row=i // 3, column=i % 3, padx=2, pady=2)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!tip] If a named colour is not recognised, tkinter raises `TclError`. When
> in doubt, use hex notation — it always works.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does StringVar() do that a plain Python string cannot?"
    type: single
    choices:
      - "It stores longer text"
      - "It automatically updates linked widgets when its value changes"
      - "It is faster than a string"
      - "It supports regex operations"
    answer: [1]
    explanation: "Observable variables propagate changes to any widget linked via textvariable= or variable=."
    difficulty: 1
  - id: q2
    prompt: "What are the three arguments passed to a trace_add callback?"
    type: single
    choices:
      - "old, new, timestamp"
      - "name, index, mode"
      - "widget, event, handler"
      - "key, value, action"
    answer: [1]
    explanation: "The callback receives name (variable name), index, and mode ('write', 'read', 'unset')."
    difficulty: 2
  - id: q3
    prompt: "Which function opens a file-selection dialog?"
    type: single
    choices:
      - "filedialog.open()"
      - "filedialog.askopenfilename()"
      - "filedialog.select_file()"
      - "tkinter.open_file()"
    answer: [1]
    explanation: "askopenfilename() returns the chosen file path as a string."
    difficulty: 1
  - id: q4
    prompt: "What is the HEX representation of pure green (R=0, G=255, B=0)?"
    type: single
    choices:
      - "#0000FF"
      - "#FF0000"
      - "#00FF00"
      - "#FFFF00"
    answer: [2]
    explanation: "HEX is #RRGGBB, so green = #00FF00."
    difficulty: 1
  - id: q5
    prompt: "Which trace mode fires when a variable is modified?"
    type: single
    choices:
      - "read"
      - "write"
      - "change"
      - "modify"
    answer: [1]
    explanation: "The 'write' mode fires when the variable is set or changed."
    difficulty: 1
```
