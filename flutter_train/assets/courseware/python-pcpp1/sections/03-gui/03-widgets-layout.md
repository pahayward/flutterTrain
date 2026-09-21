---
id: 03-widgets-layout
title: Widgets & geometry managers
order: 3
section: 03-gui
language: python
summary: Common widgets (Button, Label, Frame), geometry managers (pack/grid/place), and essential widget properties.
tags: [widgets, pack, grid, place, Frame, Button, Label]
---

# Widgets & Geometry Managers

## Common widgets

### Button

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Button Variants")

btn1 = tk.Button(root, text="Default", command=lambda: print("clicked"))
btn1.pack(pady=5)

btn2 = tk.Button(root, text="Styled", bg="steelblue", fg="white",
                 font=("Helvetica", 12, "bold"), padx=10, pady=5,
                 command=lambda: print("styled clicked"))
btn2.pack(pady=5)

btn3 = tk.Button(root, text="Disabled", state=tk.DISABLED)
btn3.pack(pady=5)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

Key Button properties:

| Property | Description |
|---|---|
| `text` | Label displayed on the button. |
| `command` | Callback invoked on click. |
| `state` | `tk.NORMAL` or `tk.DISABLED`. |
| `bg` / `fg` | Background / foreground colour. |
| `font` | Font tuple, e.g. `("Arial", 12, "bold")`. |
| `padx` / `pady` | Internal padding (pixels). |
| `width` / `height` | Size in characters (text) or pixels (images). |

### Label

```python eval=no
import tkinter as tk

root = tk.Tk()
lbl = tk.Label(root, text="Static text", font=("Courier", 14),
               bg="lightyellow", relief=tk.SUNKEN, bd=2)
lbl.pack(padx=20, pady=20)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

Useful Label properties: `text`, `image`, `compound`, `wraplength`,
`justify`, `anchor`, `relief`, `bd`.

### Frame — a container widget

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Frames as containers")

outer = tk.Frame(root, bg="grey", padx=5, pady=5)
outer.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

inner1 = tk.Frame(outer, bg="lightblue", padx=10, pady=10)
inner1.pack(fill=tk.X, pady=2)
tk.Label(inner1, text="Section A", bg="lightblue").pack()

inner2 = tk.Frame(outer, bg="lightgreen", padx=10, pady=10)
inner2.pack(fill=tk.X, pady=2)
tk.Label(inner2, text="Section B", bg="lightgreen").pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!key] Frames group widgets logically. They are invisible containers that help
> organise complex layouts.

## Geometry managers

tkinter provides three ways to position widgets inside a container.

### pack() — simplest, top-to-bottom by default

```python eval=no
import tkinter as tk

root = tk.Tk()
tk.Label(root, text="First").pack()
tk.Label(root, text="Second").pack()
tk.Label(root, text="Third").pack(side=tk.LEFT, padx=5)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Option | Purpose |
|---|---|
| `side` | `TOP`, `BOTTOM`, `LEFT`, `RIGHT`. |
| `fill` | `X`, `Y`, `BOTH`, or `NONE`. |
| `expand` | `True` to claim extra space. |
| `padx` / `pady` | External padding. |
| `anchor` | Where to place widget in unused space. |

### grid() — row/column table

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Grid Layout")

tk.Label(root, text="Name:").grid(row=0, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root, width=25).grid(row=0, column=1, padx=5, pady=5)

tk.Label(root, text="Email:").grid(row=1, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root, width=25).grid(row=1, column=1, padx=5, pady=5)

tk.Button(root, text="Submit").grid(row=2, column=0, columnspan=2, pady=10)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Option | Purpose |
|---|---|
| `row` / `column` | Position in the grid. |
| `sticky` | Alignment within the cell (`N`, `S`, `E`, `W`, `NSEW`). |
| `columnspan` / `rowspan` | Merge cells. |
| `padx` / `pady` | External padding. |
| `ipadx` / `ipady` | Internal padding. |

### place() — absolute or relative positioning

```python eval=no
import tkinter as tk

root = tk.Tk()
root.geometry("300x200")
tk.Label(root, text="Top-left", bg="yellow").place(x=10, y=10)
tk.Label(root, text="Center", bg="lightblue").place(relx=0.5, rely=0.5, anchor="center")
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Option | Purpose |
|---|---|
| `x` / `y` | Absolute pixel offset from parent's top-left. |
| `relx` / `rely` | Fraction of parent size (0.0–1.0). |
| `anchor` | Which point of the widget is placed at (x, y). |
| `width` / `height` | Override the widget's natural size. |

> [!warning] **Never mix** `pack()` and `grid()` inside the same parent widget.
> This raises `TclError`. Choose one geometry manager per container.

## Combining managers with Frames

The recommended pattern: use `pack()` for top-level layout of Frames, and
`grid()` *inside* each Frame for form-like content.

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Mixed managers")

# Top frame uses pack
top = tk.Frame(root)
top.pack(fill=tk.X, padx=10, pady=10)

# Label inside top frame
tk.Label(top, text="Registration Form", font=("Arial", 14)).pack()

# Form frame uses grid inside itself
form = tk.Frame(root)
form.pack(fill=tk.BOTH, expand=True, padx=10)

tk.Label(form, text="Username:").grid(row=0, column=0, sticky="e", pady=3)
tk.Entry(form).grid(row=0, column=1, pady=3)

tk.Label(form, text="Password:").grid(row=1, column=0, sticky="e", pady=3)
tk.Entry(form, show="*").grid(row=1, column=1, pady=3)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which geometry manager positions widgets using row and column numbers?"
    type: single
    choices:
      - "pack()"
      - "grid()"
      - "place()"
      - "layout()"
    answer: [1]
    explanation: "grid() arranges widgets in a table of rows and columns."
    difficulty: 1
  - id: q2
    prompt: "What happens if you call pack() and grid() on children of the same Frame?"
    type: single
    choices:
      - "They work together automatically"
      - "TclError is raised"
      - "grid() silently overrides pack()"
      - "pack() silently overrides grid()"
    answer: [1]
    explanation: "You must not mix geometry managers inside the same parent container."
    difficulty: 2
  - id: q3
    prompt: "In grid(), what does sticky='NSEW' do?"
    type: single
    choices:
      - "Centres the widget in its cell"
      - "Makes the widget fill its entire cell"
      - "Aligns the widget to the north-east"
      - "Stretches the widget diagonally"
    answer: [1]
    explanation: "NSEW means the widget expands to fill all four edges of its cell."
    difficulty: 2
  - id: q4
    prompt: "Which widget is commonly used as an invisible container to group other widgets?"
    type: single
    choices:
      - "Label"
      - "Button"
      - "Frame"
      - "Canvas"
    answer: [2]
    explanation: "Frame is a container widget used for logical grouping and layout."
    difficulty: 1
  - id: q5
    prompt: "What does the expand=True option do in pack()?"
    type: single
    choices:
      - "Makes the widget fill the entire parent"
      - "Allows the widget to claim extra available space"
      - "Expands the font size"
      - "Automatically adds padding"
    answer: [1]
    explanation: "expand=True tells pack to allocate extra space to this widget."
    difficulty: 2
```
