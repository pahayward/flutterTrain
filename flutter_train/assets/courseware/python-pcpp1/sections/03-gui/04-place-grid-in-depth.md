---
id: 04-place-grid-in-depth
title: place() and grid() in depth
order: 4
section: 03-gui
language: python
summary: Coordinates, relative sizing, column/row weights, anchor options, and relx/rely for precise widget positioning.
tags: [place, grid, weights, anchor, relx, rely, coordinates]
---

# place() and grid() in Depth

## place() — precise positioning

`place()` gives you pixel-level or proportional control over where a widget
sits inside its parent.

### Absolute coordinates

```python eval=no
import tkinter as tk

root = tk.Tk()
root.geometry("350x250")
root.title("Absolute Placement")

tk.Label(root, text="(10,10)", bg="yellow").place(x=10, y=10)
tk.Label(root, text="(100,80)", bg="lightblue").place(x=100, y=80)
tk.Label(root, text="(50,180)", bg="lightgreen").place(x=50, y=180)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!warning] Absolute positioning is **not responsive** — widgets do not move
> when the window is resized. Prefer `grid()` or `pack()` for most layouts.

### Relative coordinates (relx / rely)

```python eval=no
import tkinter as tk

root = tk.Tk()
root.geometry("400x300")
root.title("Relative Placement")

# Centre a label regardless of window size
tk.Label(root, text="Always centred", bg="salmon",
         font=("Arial", 14)).place(relx=0.5, rely=0.5, anchor="center")

# Top-right corner
tk.Label(root, text="Top-right", bg="lightyellow").place(
    relx=1.0, rely=0.0, anchor="ne"
)

# Bottom-left corner
tk.Label(root, text="Bottom-left", bg="lightcyan").place(
    relx=0.0, rely=1.0, anchor="sw"
)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

Values of `relx`/`rely` range from `0.0` (left/top) to `1.0` (right/bottom).

### anchor reference points

The `anchor` option tells `place()` which point of the widget corresponds to
the given (x, y):

| Value | Meaning |
|---|---|
| `"n"` | North — top centre |
| `"ne"` | North-east — top right |
| `"e"` | East — middle right |
| `"se"` | South-east — bottom right |
| `"s"` | South — bottom centre |
| `"sw"` | South-west — bottom left |
| `"w"` | West — middle left |
| `"nw"` | North-west — top left |
| `"center"` | Centre of the widget |

> [!tip] `anchor="center"` with `relx=0.5, rely=0.5` is the classic
> "centre this widget in its parent" pattern.

### Sizing with place()

You can override a widget's natural dimensions:

```python eval=no
import tkinter as tk

root = tk.Tk()
root.geometry("300x200")

# Stretch a label to fill the entire parent
lbl = tk.Label(root, text="Fills parent", bg="plum", anchor="w")
lbl.place(x=0, y=0, relwidth=1.0, relheight=1.0)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## grid() — advanced features

### Column and row weights

By default, grid columns/rows are only as wide as their widest widget.
Setting a **weight** tells grid how to distribute extra space:

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Column Weights")
root.geometry("400x150")

# Column 0 keeps its content width; column 1 expands
root.columnconfigure(0, weight=1)
root.columnconfigure(1, weight=3)

tk.Label(root, text="Fixed", bg="lightyellow").grid(row=0, column=0, sticky="nsew")
tk.Label(root, text="Expands 3x", bg="lightblue").grid(row=0, column=1, sticky="nsew")

# Row 0 should also grow vertically
root.rowconfigure(0, weight=1)
tk.Button(root, text="Bottom").grid(row=1, column=0, columnspan=2, sticky="ew")

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!key] **weight** is the ratio. `weight=3` gets three times as much extra space
> as `weight=1`. Default weight is `0` — the column/row does not grow.

### Columnspan and rowspan

Span multiple cells for wider or taller widgets:

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Spanning")
root.geometry("300x200")

# Header spans both columns
tk.Label(root, text="Header", bg="navy", fg="white",
         font=("Arial", 14)).grid(row=0, column=0, columnspan=2, sticky="nsew")

# Two-column form
tk.Label(root, text="First:").grid(row=1, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root).grid(row=1, column=1, sticky="w", padx=5, pady=5)

tk.Label(root, text="Last:").grid(row=2, column=0, sticky="e", padx=5, pady=5)
tk.Entry(root).grid(row=2, column=1, sticky="w", padx=5, pady=5)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Sticky values

`sticky` controls alignment *within* a cell. Combine compass directions:

```
nw  n  ne
w   c   e
sw  s  se
```

- `"nsew"` → fill the entire cell.
- `"w"` → left-align.
- `"center"` → centre (default).

## A practical form with grid()

```python eval=no
import tkinter as tk

def submit():
    print(f"User: {entries[0].get()}, Email: {entries[1].get()}")

root = tk.Tk()
root.title("Contact Form")
root.geometry("350x200")

labels = ["Name:", "Email:", "Phone:"]
entries = []

for i, text in enumerate(labels):
    tk.Label(root, text=text).grid(row=i, column=0, sticky="e", padx=8, pady=6)
    e = tk.Entry(root, width=25)
    e.grid(row=i, column=1, padx=8, pady=6)
    entries.append(e)

tk.Button(root, text="Submit", command=submit).grid(
    row=len(labels), column=0, columnspan=2, pady=12
)

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does place(relx=0.5, rely=0.5, anchor='center') achieve?"
    type: single
    choices:
      - "Places the widget at the top-left corner"
      - "Centres the widget in its parent"
      - "Stretches the widget to fill the parent"
      - "Places the widget at pixel (0.5, 0.5)"
    answer: [1]
    explanation: "relx/rely=0.5 with anchor='center' positions the widget's centre at the parent's centre."
    difficulty: 2
  - id: q2
    prompt: "If column 0 has weight=1 and column 1 has weight=4, how is extra horizontal space distributed?"
    type: single
    choices:
      - "Evenly between both columns"
      - "Column 0 gets all extra space"
      - "Column 1 gets four times as much extra space as column 0"
      - "Neither column expands"
    answer: [2]
    explanation: "Weights are ratios — 1:4 means column 1 gets 4/5 of extra space."
    difficulty: 2
  - id: q3
    prompt: "What is the default weight of a grid row or column?"
    type: single
    choices:
      - "1"
      - "0"
      - "-1"
      - "auto"
    answer: [1]
    explanation: "Default weight is 0 — the row/column does not grow to fill extra space."
    difficulty: 1
  - id: q4
    prompt: "Which place() option lets you make a widget fill the full width of its parent?"
    type: single
    choices:
      - "fill='x'"
      - "relwidth=1.0"
      - "expand=True"
      - "stretch=True"
    answer: [1]
    explanation: "relwidth=1.0 makes the widget 100% of parent width. 'fill' is a pack() option."
    difficulty: 2
  - id: q5
    prompt: "In grid(), sticky='e' on a Label in column 0 does what?"
    type: single
    choices:
      - "Centres the label in its cell"
      - "Aligns the label to the right edge of its cell"
      - "Makes the label fill the cell"
      - "Moves the label to column 1"
    answer: [1]
    explanation: "sticky='e' right-aligns (east) the widget within its grid cell."
    difficulty: 2
```
