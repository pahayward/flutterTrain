---
id: 01-gui-concepts
title: GUI concepts & terminology
order: 1
section: 03-gui
language: python
summary: Why GUIs exist, core terminology, classical vs event-driven models, and an overview of Python GUI toolkits.
tags: [gui, widgets, events, tkinter]
---

# GUI Concepts & Terminology

## Why graphical interfaces?

Command-line programs communicate through text. For many tasks — editing images,
browsing files, filling forms — a **graphical user interface (GUI)** is far more
intuitive. A GUI presents visual elements the user can see and interact with
directly.

> [!key] A GUI is any interface that uses windows, icons, buttons, and menus
> rather than typed commands.

## Core vocabulary

| Term | Meaning |
|---|---|
| **Widget** | A visual component: button, label, text field, canvas, etc. |
| **Control** | A widget the user interacts with directly (Button, Entry, Slider). |
| **Container** | A widget that holds other widgets (Frame, Window). |
| **Layout manager** | Decides where child widgets appear inside a container. |
| **Event** | Something that happens: a click, a key press, a window resize. |
| **Callback / Handler** | A function the framework calls when an event fires. |
| **Root window** | The top-level application window; usually one per app. |

## Classical vs event-driven programming

### Classical (procedural) flow

The program decides the order of execution top-to-bottom:

```python eval=no
# Classical flow — you control the sequence
print("Step 1: ask for name")
name = input("Name: ")
print(f"Hello, {name}")
print("Step 2: done")
```

> tkinter is not available on Android, so this GUI example is non-runnable.

### Event-driven flow

In a GUI the program **waits** for the user to act, then responds:

```python eval=no
import tkinter as tk

def on_click():
    print(f"Hello, {entry.get()}")

root = tk.Tk()
entry = tk.Entry(root)
entry.pack()
tk.Button(root, text="Greet", command=on_click).pack()
root.mainloop()          # waits here until the window is closed
```

> tkinter is not available on Android, so this GUI example is non-runnable.

Key differences:

- **Classical**: you call `input()` and the program blocks.
- **Event-driven**: `mainloop()` blocks, and *callbacks* fire when events occur.

> [!note] The entire tkinter library is built on an event loop. Every widget
> creation call merely *describes* the interface; nothing appears until
> `mainloop()` starts processing events.

### Simulating the event loop in plain Python

You don't need a display to understand the mechanism. The example below is a
tiny event loop with callbacks — the same pattern tkinter uses internally
(and it runs on-device):

```python
class Button:
    def __init__(self, text):
        self.text = text
        self.handlers = []                 # one callback per bound event

    def bind(self, event, callback):
        self.handlers.append((event, callback))

    def trigger(self, event):              # pretend the user acted
        for name, callback in self.handlers:
            if name == event:
                callback(self)             # dispatch to the handler

btn = Button("Greet")
btn.bind("click", lambda w: print(f"{w.text} was clicked"))
btn.bind("hover", lambda w: print(f"mouse over {w.text}"))

btn.trigger("hover")                       # event queue delivers events
btn.trigger("click")
```

> This is a simplified model — real tkinter adds a Tcl event queue and timer
> management — but the callback-dispatch idea is identical.

## GUI toolkits for Python

| Toolkit | Notes |
|---|---|
| **tkinter** | Bundled with CPython; lightweight; used in the PCPP1 exam. |
| PyQt / PySide | Qt bindings; powerful; commercial licence considerations. |
| wxPython | Wraps the native wxWidgets C++ library. |
| Kivy | Touch-friendly; targets mobile and multi-touch. |
| PyGObject | GTK bindings for Linux desktops. |

> [!tip] The PCPP1 exam focuses exclusively on **tkinter**. Master it first; the
> concepts transfer to other toolkits.

## How tkinter works under the hood

tkinter is a Python wrapper around **Tcl/Tk**, an interpreted GUI toolkit.
When you call `tk.Tk()`, Python starts a Tcl interpreter in the background.
Each widget maps to a Tcl command — but you interact only through the
Pythonic object API.

```
Your Python code
       ↓
   tkinter API
       ↓
   Tcl interpreter  (hidden)
       ↓
   Tk drawing primitives
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is a widget in GUI terminology?"
    type: single
    choices:
      - "A Python decorator for GUI classes"
      - "A visual component such as a button or label"
      - "A callback function bound to an event"
      - "A variable that stores colour values"
    answer: [1]
    explanation: "A widget is a visual element — button, label, text field, etc. — that makes up a GUI."
    difficulty: 1
  - id: q2
    prompt: "In classical (procedural) programming, what determines the order of execution?"
    type: single
    choices:
      - "User mouse clicks"
      - "The order of statements in the source code"
      - "The operating system event queue"
      - "The order widgets are packed"
    answer: [1]
    explanation: "In procedural code the interpreter runs statements top-to-bottom."
    difficulty: 1
  - id: q3
    prompt: "What does mainloop() do in a tkinter application?"
    type: single
    choices:
      - "Creates the root window"
      - "Draws all widgets on screen once"
      - "Starts the event loop, blocking until the window is closed"
      - "Destroys all widgets and exits Python"
    answer: [2]
    explanation: "mainloop() enters the event loop, processing user actions until the root window is destroyed."
    difficulty: 2
  - id: q4
    prompt: "Which of the following is a container widget?"
    type: multi
    choices:
      - "Frame"
      - "Button"
      - "Tk"
      - "Label"
    answer: [0, 2]
    explanation: "Tk (the root window) and Frame are containers that hold other widgets. Button and Label are controls."
    difficulty: 2
```
