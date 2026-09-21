---
id: 08-section-practice
title: Section 3 Practice
order: 8
section: 03-gui
language: python
summary: Compact review of GUI programming concepts and an 8-question exam bank for Section 3.
tags: [practice, exam, gui, review]
---

# Section 3 Practice

## Section review

- **GUI rationale**: graphical interfaces use windows, icons, buttons, and menus for direct user interaction.
- **Widgets**: visual components (Button, Label, Entry, Frame, Canvas). Containers hold other widgets.
- **Classical vs event-driven**: procedural code runs top-to-bottom; GUI apps wait for events and dispatch to handlers.
- **Toolkit**: tkinter is the standard library GUI toolkit bundled with CPython; the PCPP1 exam tests only tkinter.
- **Root window**: `tk.Tk()` creates the root; `mainloop()` enters the event loop.
- **Geometry managers**: `pack()` (simple stacking), `grid()` (row/column table), `place()` (absolute or relative). Never mix `pack()` and `grid()` in the same parent.
- **Grid weights**: `columnconfigure()` / `rowconfigure()` with `weight` controls extra-space distribution.
- **Events**: `widget.bind("<Event>", handler)` registers a callback; the handler receives an `Event` object with `x`, `y`, `keysym`, `char`, etc.
- **destroy()**: terminates the event loop and closes the application cleanly.
- **Input validation**: use `validate="key"` + `validatecommand` for real-time checks; `root.register()` is required for the Tcl layer.
- **Canvas**: `create_line`, `create_rectangle`, `create_oval`, `create_polygon`, `create_text`; items returned by integer IDs modified via `itemconfig()`.
- **Observable variables**: `StringVar`, `IntVar`, `DoubleVar`, `BooleanVar` automatically update linked widgets; `trace_add()` observes changes.
- **Dialogs**: `messagebox.showinfo/warning/error/askyesno`, `filedialog.askopenfilename/asksaveasfilename/askdirectory`.
- **Colours**: RGB channels (0–255), HEX notation `"#RRGGBB"`, named colours (`"salmon"`, `"steelblue"`, etc.).

## ExamQuestions

```yaml
bank:
  - prompt: "Which method enters the tkinter event loop?"
    type: single
    choices:
      - "run()"
      - "start()"
      - "mainloop()"
      - "event_loop()"
    answer: [2]
    explanation: "mainloop() blocks and processes events until the root window is destroyed."
    section: 03-gui
    weight: 4

  - prompt: "What happens when you call pack() and then grid() on children of the same Frame"
    type: single
    choices:
      - "Both work normally"
      - "TclError is raised"
      - "Only grid() takes effect"
      - "Only pack() takes effect"
    answer: [1]
    explanation: "Mixing geometry managers in the same parent is prohibited and raises TclError."
    section: 03-gui
    weight: 4

  - prompt: "In grid() what does columnconfigure(0, weight=2) mean"
    type: single
    choices:
      - "Column 0 is two pixels wide"
      - "Column 0 gets twice as much extra space as a column with weight=1"
      - "Column 0 is locked at two cells"
      - "Column 0 spans two rows"
    answer: [1]
    explanation: "Weight is a ratio for distributing extra space."
    section: 03-gui
    weight: 4

  - prompt: "Which event string matches a left mouse button double-click"
    type: single
    choices:
      - "<DoubleClick>"
      - "<Double-Button-1>"
      - "<Double-Click-1>"
      - "<2-Button-1>"
    answer: [1]
    explanation: "The pattern is <Double-Button-1> for a double left-click."
    section: 03-gui
    weight: 4

  - prompt: "What must you do before using validatecommand with a Python function in an Entry widget"
    type: single
    choices:
      - "Nothing special"
      - "Register the function with root.register()"
      - "Import it from tkinter.validate"
      - "Define it as a class method"
    answer: [1]
    explanation: "register() creates a Tcl-callable proxy for the Python callback."
    section: 03-gui
    weight: 4

  - prompt: "What does canvas.create_oval(20, 20, 120, 80) draw"
    type: single
    choices:
      - "A circle centred at (20,20) with radius 120"
      - "An ellipse inside a bounding box from (20,20) to (120,80)"
      - "A rectangle with rounded corners"
      - "An oval at pixel (120,80)"
    answer: [1]
    explanation: "create_oval draws an ellipse inscribed in the rectangle defined by the two corner coordinates."
    section: 03-gui
    weight: 4

  - prompt: "Which observable variable should you use to store a floating-point temperature reading"
    type: single
    choices:
      - "StringVar"
      - "IntVar"
      - "DoubleVar"
      - "BooleanVar"
    answer: [2]
    explanation: "DoubleVar stores float values."
    section: 03-gui
    weight: 4

  - prompt: "What does messagebox.askyesno return when the user clicks Yes"
    type: single
    choices:
      - "The string 'Yes'"
      - "True"
      - "1"
      - "None"
    answer: [1]
    explanation: "askyesno returns a boolean: True for Yes, False for No."
    section: 03-gui
    weight: 4
```
