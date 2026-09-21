---
id: 06-input-validation-canvas
title: Input validation & Canvas
order: 6
section: 03-gui
language: python
summary: Entry widgets, Radiobuttons, input validation strategies, error handling, Canvas widget, and drawing primitives.
tags: [Entry, Radiobutton, validate, Canvas, draw, error-handling]
---

# Input Validation & Canvas

## Entry widget — text input

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Entry Demo")

e = tk.Entry(root, width=30, font=("Arial", 12))
e.pack(padx=10, pady=10)
e.insert(0, "Default text")          # pre-fill

tk.Button(root, text="Get", command=lambda: print(e.get())).pack()
tk.Button(root, text="Clear", command=lambda: e.delete(0, tk.END)).pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Key Entry methods

| Method | Purpose |
|---|---|
| `get()` | Return current text. |
| `insert(index, text)` | Insert text at position. |
| `delete(first, last)` | Remove characters between indices. |
| `icursor(index)` | Move the text cursor. |
| `select_range(start, end)` | Highlight a range. |
| `config(show="*")` | Mask input (e.g., passwords). |

## Radiobutton — mutually exclusive choices

```python eval=no
import tkinter as tk

def show_choice():
    print(f"You chose: {choice.get()}")

root = tk.Tk()
root.title("Radiobutton Demo")

choice = tk.StringVar(value="python")       # observable variable

tk.Radiobutton(root, text="Python", variable=choice,
               value="python", command=show_choice).pack(anchor="w")
tk.Radiobutton(root, text="Java", variable=choice,
               value="java", command=show_choice).pack(anchor="w")
tk.Radiobutton(root, text="C++", variable=choice,
               value="cpp", command=show_choice).pack(anchor="w")

tk.Button(root, text="Confirm", command=show_choice).pack(pady=10)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!key] All Radiobuttons sharing the same `variable` form a **mutually
> exclusive group**. Selecting one deselects the others.

## Input validation

The validation *rules* themselves are pure Python and run fine on-device.
Only the widget wiring needs a display:

```python
def validate_age(text):
    text = text.strip()
    if not text:
        return "Error: field is empty"
    if not text.isdigit():
        return "Error: enter a number only"
    age = int(text)
    if not 0 <= age <= 120:
        return "Error: age out of range"
    return f"Accepted: {age}"

for sample in ("", "abc", "-5", "25", "150"):
    print(f"{sample!r:8} -> {validate_age(sample)}")
```

```
''       -> Error: field is empty
'abc'    -> Error: enter a number only
'-5'     -> Error: enter a number only
'25'     -> Accepted: 25
'150'    -> Error: age out of range
```

### Before submission — manual check

```python eval=no
import tkinter as tk

def validate_and_submit():
    text = entry.get().strip()
    if not text:
        msg.config(text="Error: field is empty", fg="red")
    elif not text.isdigit():
        msg.config(text="Error: enter a number only", fg="red")
    else:
        msg.config(text=f"Accepted: {text}", fg="green")

root = tk.Tk()
root.title("Manual Validation")
root.geometry("300x150")

tk.Label(root, text="Enter your age:").pack(pady=(15, 5))
entry = tk.Entry(root, width=15)
entry.pack()
tk.Button(root, text="Submit", command=validate_and_submit).pack(pady=8)
msg = tk.Label(root, text="")
msg.pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Real-time validation with `validate` and `validatecommand`

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Real-time Validation")

vcmd = (root.register(lambda P: P.isdigit() or P == ""), "%P")

tk.Label(root, text="Digits only:").pack(pady=(15, 5))
e = tk.Entry(root, width=20, validate="key", validatecommand=vcmd)
e.pack()
e.insert(0, "123")

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| `validate` mode | When validation runs |
|---|---|
| `"key"` | Before any change (insert/delete). |
| `"focus"` | When the widget gains/loses focus. |
| `"focusin"` / `"focusout"` | On focus gain / loss only. |
| `"all"` | On any state change. |

> [!trap] The validation callback must be registered with `root.register()`
> and referenced through a tuple `(root.register(func), "%P")`. Passing
> the function directly does **not** work.

## Error handling patterns

```python eval=no
import tkinter as tk

def safe_submit():
    try:
        value = int(entry.get())
        if value < 0 or value > 120:
            raise ValueError("out of range")
        result.config(text=f"Valid age: {value}", fg="green")
    except ValueError as exc:
        result.config(text=f"Error: {exc}", fg="red")

root = tk.Tk()
root.title("Error Handling")
root.geometry("280x140")

tk.Label(root, text="Age:").pack(pady=(15, 2))
entry = tk.Entry(root)
entry.pack()
tk.Button(root, text="Submit", command=safe_submit).pack(pady=8)
result = tk.Label(root, text="")
result.pack()

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!tip] Display errors **inside the GUI** (e.g., a red Label) rather than
> printing to the console, so the user can see them.

## Canvas widget — drawing primitives

`Canvas` is a free-form drawing surface. Common methods:

| Method | Draws |
|---|---|
| `create_line(x0,y0,x1,y1,...)` | Line or polyline. |
| `create_rectangle(x0,y0,x1,y1)` | Rectangle outline (or fill). |
| `create_oval(x0,y0,x1,y1)` | Ellipse inscribed in the bounding box. |
| `create_arc(...)` | Arc or pie slice. |
| `create_polygon(x0,y0,...)` | Filled polygon. |
| `create_text(x, y, text=...)` | Text at a position. |
| `create_image(x, y, image=...)` | An image on the canvas. |

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Canvas Demo")

canvas = tk.Canvas(root, width=400, height=300, bg="white")
canvas.pack(padx=10, pady=10)

# Line
canvas.create_line(10, 10, 390, 10, fill="red", width=2)

# Rectangle
canvas.create_rectangle(20, 40, 200, 120, fill="lightblue", outline="navy")

# Oval
canvas.create_oval(220, 40, 380, 160, fill="lightyellow", outline="orange")

# Polygon (triangle)
canvas.create_polygon(200, 200, 300, 280, 100, 280,
                      fill="lightgreen", outline="darkgreen")

# Text
canvas.create_text(200, 150, text="Canvas", font=("Arial", 16, "bold"))

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Canvas item IDs

Every `create_*` call returns an integer **item ID**. Use it to modify
or delete items later:

```python eval=no
import tkinter as tk

root = tk.Tk()
canvas = tk.Canvas(root, width=300, height=200, bg="white")
canvas.pack()

rect = canvas.create_rectangle(50, 50, 250, 150, fill="grey")

def change_color():
    canvas.itemconfig(rect, fill="steelblue")

tk.Button(root, text="Change colour", command=change_color).pack(pady=5)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

| Canvas method | Purpose |
|---|---|
| `itemconfig(id, **kw)` | Change properties of an item. |
| `coords(id, ...)` | Move / reshape an item. |
| `delete(id)` | Remove an item. |
| `find_all()` | Return all item IDs. |
| `move(id, dx, dy)` | Shift an item by pixels. |

## Quiz

```yaml
questions:
  - id: q1
    prompt: "How do you mask password input in an Entry widget?"
    type: single
    choices:
      - "entry.config(password=True)"
      - "entry.config(show='*')"
      - "entry.config(mask=True)"
      - "entry.config(hidden=True)"
    answer: [1]
    explanation: "show='*' replaces each character with an asterisk."
    difficulty: 1
  - id: q2
    prompt: "What ensures that only one Radiobutton in a group can be selected?"
    type: single
    choices:
      - "They share the same parent"
      - "They share the same variable"
      - "They have the same command"
      - "They are packed in order"
    answer: [1]
    explanation: "Radiobuttons bound to the same StringVar form a mutually exclusive group."
    difficulty: 1
  - id: q3
    prompt: "Why must the validation callback be registered with root.register()?"
    type: single
    choices:
      - "It is a tkinter requirement for the Tcl layer to call the Python function"
      - "It speeds up validation"
      - "It prevents garbage collection"
      - "It is optional but recommended"
    answer: [0]
    explanation: "Tcl cannot call Python directly; register() creates a Tcl-callable proxy."
    difficulty: 3
  - id: q4
    prompt: "What does canvas.create_rectangle(10, 10, 100, 100) draw?"
    type: single
    choices:
      - "A 90×90 pixel rectangle"
      - "A 100×100 pixel rectangle"
      - "A line from (10,10) to (100,100)"
      - "An ellipse inside a 90×90 box"
    answer: [0]
    explanation: "The rectangle spans from (10,10) to (100,100), which is 90 pixels in each dimension."
    difficulty: 2
  - id: q5
    prompt: "Which method changes the fill colour of an existing Canvas item?"
    type: single
    choices:
      - "canvas.config(id, fill=...)"
      - "canvas.itemconfig(id, fill=...)"
      - "canvas.set(id, fill=...)"
      - "canvas.update(id, fill=...)"
    answer: [1]
    explanation: "itemconfig() modifies properties of a specific canvas item."
    difficulty: 2
```
