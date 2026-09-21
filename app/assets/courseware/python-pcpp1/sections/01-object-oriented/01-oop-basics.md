---
id: 01-oop-basics
title: Classes, instances, attributes, methods
order: 1
section: 01-object-oriented
language: python
type: lesson
summary: "The building blocks of object-oriented Python: classes, objects, attributes, methods, and __init__."
tags: [oop, class, instance, attribute, method, init, self]
prereqs: []
---

# Classes, instances, attributes, methods

Object-oriented programming lets you bundle **data** and **behavior** into one
unit. This module defines the core vocabulary you will use for the whole
section: **class**, **instance (object)**, **attribute**, and **method**.

> [!key] **The vocabulary**
>
> - **Class** — a blueprint that describes what data (attributes) and behavior
>   (methods) its objects will have.
> - **Instance (object)** — one concrete thing created from the blueprint.
>   Two instances of the same class usually carry different data.
> - **Attribute** — a value bound to an object (or to a class).
> - **Method** — a function that belongs to a class and usually acts on an
>   instance.

## Defining a class

A class is defined with the `class` keyword. Inside it you write methods, which
are ordinary functions whose first parameter is conventionally called `self`.
`self` refers to the *particular instance* the method is called on.

```python title="dog.py"
class Dog:
    species = "Canis familiaris"

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def bark(self):
        return f"{self.name} says Woof!"

rex = Dog("Rex", 3)
bella = Dog("Bella", 5)
print(rex.bark())
print(bella.bark())
print(rex.name, rex.age, bella.age)
print(rex.species, bella.species)
```

`Dog("Rex", 3)` creates one instance, `Dog("Bella", 5)` another. Each instance
remembers its own `name` and `age`, but they share the class-design.

> [!note] **`self` is not a keyword**
>
> You could name the first parameter anything, but `self` is the universal
> convention. Readability and static tooling expect `self`.

## `__init__`: the initializer

`__init__` runs automatically right after an instance is created. It is **not**
the "constructor" in the C++ sense (that role is played by `__new__`), but it
is where you normally set up initial instance attributes.

```python
class Student:
    school = "North High"

    def __init__(self, name):
        self.name = name

s1 = Student("Ana")
s2 = Student("Bo")
print(Student.school, s1.school)
s1.school = "West High"
print(s1.school, s2.school, Student.school)
del s1.school
print(s1.school)
```

## Class variables vs instance variables

Attributes assigned on `self` inside methods are **instance variables**: each
instance owns its own copy. Attributes assigned inside the class body are
**class variables**: they belong to the class and are shared by all instances.

> [!trap] **Assignment shadows instead of mutating**
>
> `s1.school = "West High"` does **not** change the class variable. It creates a
> brand-new instance attribute that hides the class attribute for `s1` only.
> `s2.school` and `Student.school` are untouched. Deleting the new attribute
> (`del s1.school`) "un-shadows" it again.

## Calling methods and accessing attributes

There are two equivalent ways to call an instance method:

- `obj.method()` — Python passes `obj` as `self` automatically.
- `Class.method(obj)` — you pass the instance explicitly.

You can read, set, test, and delete attributes dynamically with dot notation
or with the built-ins `getattr`, `setattr`, `hasattr`, and `delattr`.

```python title="movie.py"
class Movie:
    def __init__(self, title):
        self.title = title

    def describe(self):
        return f"Movie: {self.title}"

m = Movie("2001")
print(m.describe())
print(Movie.describe(m))
print(hasattr(m, "title"))
setattr(m, "rating", 9)
print(getattr(m, "rating"), m.rating)
delattr(m, "rating")
print(hasattr(m, "rating"))
```

> [!tip] **Why `Class.method(obj)` matters**
>
> The PCPP exam likes to check that you understand both call forms. They are
> interchangeable: `Movie.describe(m)` is exactly the thing `m.describe()`
> turns into.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the conventional name of the first parameter of an instance method?"
    type: single
    choices: ["self", "this", "cls", "me"]
    answer: [0]
    explanation: "self is the universal convention; cls belongs to class methods."
    difficulty: 1
  - id: q2
    prompt: "Select the true statements about __init__."
    type: multi
    choices:
      - "It runs automatically when a new instance is created."
      - "It must be defined in every class."
      - "Its first parameter is the new instance."
      - "It should return the new instance."
    answer: [0, 2]
    explanation: "__init__ is optional, never returns a value, and receives the fresh instance as self."
    difficulty: 2
  - id: q3
    prompt: "Given a class Movie and instance m, which call is equivalent to m.describe()?"
    type: single
    choices: ["Movie.describe(m)", "Movie.describe()", "m.describe(Movie)", "describe(m)"]
    answer: [0]
    explanation: "m.describe() is syntactic sugar for Movie.describe(m): the instance is passed as self."
    difficulty: 1
  - id: q4
    prompt: "What happens when you assign instance.x = 5 if x is a class variable?"
    type: single
    choices:
      - "A new instance attribute is created that hides the class variable."
      - "The class variable changes for every instance."
      - "A TypeError is raised."
      - "The class variable is deleted."
    answer: [0]
    explanation: "Assignment always creates an instance attribute; use Class.x = 5 to modify the class variable."
    difficulty: 2
```