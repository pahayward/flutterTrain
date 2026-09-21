---
id: 05-events-handlers
title: Events & event handling
order: 5
section: 03-gui
language: python
summary: Event-driven programming, callbacks, the bind() method, event identifiers, key/mouse events, and destroy().
tags: [events, callbacks, bind, key, mouse, destroy, event-driven]
---

# Events & Event Handling

## Event-driven programming review

A tkinter application spends most of its time inside `mainloop()`. That
function continuously checks for events (mouse moves, key presses, timer
ticks) and dispatches them to the appropriate handler functions.

```
mainloop()  ──→  event queue  ──→  handler(callback)
    ↑                                    │
    └────────────────────────────────────┘
```

### A runnable event dispatcher

Before the tkinter listings, here is the same dispatch logic in pure Python —
a mini event loop you can run on-device:

```python
class Event:
    def __init__(self, x, y):
        self.x, self.y = x, y        # mimic tkinter's Event attributes

class Widget:
    def __init__(self, name):
        self.name = name
        self._bindings = {}

    def bind(self, event, handler):
        self._bindings.setdefault(event, []).append(handler)

    def fire(self, event, **payload):
        for handler in self._bindings.get(event, []):
            handler(Event(**payload))   # pass an Event-like object

def report(event):
    print(f"clicked at ({event.x}, {event.y})")

lbl = Widget("label")
lbl.bind("<Button-1>", report)
lbl.fire("<Button-1>", x=40, y=75)
```

```
clicked at (40, 75)
```

## Two ways to handle events

### 1. The `command` option

The simplest mechanism — used by Button and a few other widgets:

```python eval=no
import tkinter as tk

def on_press():
    print("Button pressed!")

root = tk.Tk()
tk.Button(root, text="Press", command=on_press).pack(pady=10)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!note] `command` only works with widgets that support it (Button,
> Radiobutton, etc.). For full flexibility, use `bind()`.

### 2. The `bind()` method

`bind()` connects any widget to an event string. The callback receives an
**Event** object:

```python eval=no
import tkinter as tk

def on_click(event):
    print(f"Clicked at ({event.x}, {event.y})")

root = tk.Tk()
lbl = tk.Label(root, text="Click me!", bg="lightyellow", padx=30, pady=20)
lbl.pack()
lbl.bind("<Button-1>", on_click)     # left mouse button
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Event identifiers

Events are identified by strings. Common patterns:

| Event string | Trigger |
|---|---|
| `<Button-1>` | Left mouse click |
| `<Button-2>` / `<Button-3>` | Middle / right click |
| `<Double-Button-1>` | Double left-click |
| `<Motion>` | Mouse movement over widget |
| `<Enter>` / `<Leave>` | Mouse enters / leaves widget |
| `<Return>` | Enter/Return key |
| `<KeyPress-a>` | Specific key press |
| `<Key>` | Any key press |
| `<Configure>` | Widget resized/moved |
| `<FocusIn>` / `<FocusOut>` | Focus gained / lost |

## The Event object

When a callback is triggered by `bind()`, tkinter passes an Event instance
with these useful attributes:

| Attribute | Description |
|---|---|
| `event.x`, `event.y` | Mouse position relative to widget. |
| `event.x_root`, `event.y_root` | Mouse position relative to screen. |
| `event.widget` | The widget that received the event. |
| `event.keysym` | Symbolic name of the key pressed. |
| `event.char` | Character produced by the key press. |
| `event.num` | Mouse button number (1, 2, 3). |
| `event.type` | Integer event type code. |

```python eval=no
import tkinter as tk

def key_handler(event):
    print(f"Key: {event.keysym}  Char: '{event.char}'")

root = tk.Tk()
root.title("Type something")
root.bind("<Key>", key_handler)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Keyboard event example

```python eval=no
import tkinter as tk

def on_enter(e):
    status.config(text="Enter pressed")

def on_escape(e):
    root.destroy()

root = tk.Tk()
root.title("Keyboard demo")
root.geometry("300x150")

status = tk.Label(root, text="Press Enter or Escape", font=("Arial", 12))
status.pack(expand=True)

root.bind("<Return>", on_enter)
root.bind("<Escape>", on_escape)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Mouse event example

```python eval=no
import tkinter as tk

def motion(event):
    coords.config(text=f"x={event.x}  y={event.y}")

root = tk.Tk()
root.title("Mouse tracker")
root.geometry("300x200")

coords = tk.Label(root, text="Move mouse here", font=("Courier", 12))
coords.pack(expand=True)

root.bind("<Motion>", motion)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Unbinding events

```python eval=no
import tkinter as tk

def on_click(event):
    print("Clicked — unbinding now")
    root.unbind("<Button-1>")

root = tk.Tk()
root.bind("<Button-1>", on_click)
root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!tip] `unbind()` removes a previously registered handler for a specific
> event string on a widget.

## destroy() — closing windows

```python eval=no
import tkinter as tk

root = tk.Tk()
root.title("Close me")

def close_app():
    print("Goodbye!")
    root.destroy()

tk.Button(root, text="Quit", command=close_app, padx=20, pady=10).pack(pady=30)
root.mainloop()
print("Program ended")
```

> tkinter is not available on Android, so this GUI example is non-runnable.

> [!warning] Calling `root.destroy()` terminates the `mainloop()` and ends the
> application. Use it instead of `sys.exit()` for clean shutdown.

## Combining command and bind

```python eval=no
import tkinter as tk

def greet(name="World"):
    print(f"Hello, {name}!")

root = tk.Tk()
root.title("Dual binding")

entry = tk.Entry(root, width=20)
entry.pack(padx=10, pady=10)

# Button uses command=
tk.Button(root, text="Greet", command=lambda: greet(entry.get())).pack()

# Enter key uses bind=
root.bind("<Return>", lambda e: greet(entry.get()))

root.mainloop()
```

> tkinter is not available on Android, so this GUI example is non-runnable.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What argument does bind() receive as its second parameter?"
    type: single
    choices:
      - "A string event name"
      - "A widget class"
      - "A callback function"
      - "A boolean flag"
    answer: [2]
    explanation: "bind() takes an event string and a callback function."
    difficulty: 1
  - id: q2
    prompt: "Which event string fires when the user presses the Enter key?"
    type: single
    choices:
      - "<Enter>"
      - "<Return>"
      - "<Key-Enter>"
      - "<Press-Return>"
    answer: [1]
    explanation: "The Enter/Return key is represented by <Return>. <Enter> fires when the mouse enters a widget."
    difficulty: 2
  - id: q3
    prompt: "What does the event.keysym attribute contain?"
    type: single
    choices:
      - "The Unicode code point of the key"
      - "The symbolic name of the key pressed (e.g. 'Return', 'a')"
      - "The physical key code"
      - "A boolean indicating modifier keys"
    answer: [1]
    explanation: "keysym is a human-readable name like 'Return', 'Escape', 'a'."
    difficulty: 2
  - id: q4
    prompt: "What method removes a previously bound event handler?"
    type: single
    choices:
      - "remove_handler()"
      - "unbind()"
      - "disconnect()"
      - "off()"
    answer: [1]
    explanation: "widget.unbind(event_string) removes the handler."
    difficulty: 1
  - id: q5
    prompt: "What is the difference between command= on a Button and bind() for <Button-1>?"
    type: single
    choices:
      - "There is no difference"
      - "command is widget-specific; bind() works on any widget for any event"
      - "command runs faster than bind()"
      - "bind() cannot use lambda functions"
    answer: [1]
    explanation: "command is limited to specific widgets; bind() is the general mechanism for all events on all widgets."
    difficulty: 2
```
