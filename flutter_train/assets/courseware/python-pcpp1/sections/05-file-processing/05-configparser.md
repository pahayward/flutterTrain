---
id: 05-configparser
title: Configuration files with configparser
order: 5
section: 05-file-processing
language: python
type: lesson
summary: Read, write, and query .ini-style configuration files using configparser, including sections, keys, defaults, and interpolation.
tags: [configparser, ini, configuration, interpolation]
---

# Configuration Files with configparser

Python's `configparser` module reads and writes `.ini`-style configuration files. These files organize key-value pairs into **sections**.

> [!key] INI file structure
```ini
[section]
key = value
another_key = another_value
```
Sections are denoted by `[brackets]`. Keys and values are separated by `=` or `:`.

## Reading Configuration

Use `ConfigParser()` to load and query configuration data. Pass a file-like object to `read_file()`.

```python
import configparser
import io

ini_data = """[database]
host = localhost
port = 5432
name = myapp

[logging]
level = INFO
file = app.log
"""

config = configparser.ConfigParser()
config.read_string(ini_data)

print("Sections:", config.sections())
print("DB host:", config["database"]["host"])
print("Log level:", config.get("logging", "level"))
```

> [!note] Case sensitivity
By default, section names and keys are **case-insensitive** and stored lowercased.

## Writing Configuration

`configparser` can write configuration back to a file or `StringIO`.

```python
import configparser
import io

config = configparser.ConfigParser()
config["app"] = {
    "name": "MyTool",
    "version": "1.0",
    "debug": "false",
}

output = io.StringIO()
config.write(output)
print(output.getvalue())
output.close()
```

## Defaults and Fallbacks

You can provide a `DEFAULT` section or use `get()` with fallback values.

```python
import configparser
import io

ini_data = """[server]
host = 127.0.0.1
port = 8080

[DEFAULT]
timeout = 30
retries = 3
"""

config = configparser.ConfigParser()
config.read_string(ini_data)

print("Timeout:", config.get("server", "timeout"))
print("Custom retries:", config.get("server", "retries", fallback=5))
print("Missing key:", config.get("server", "missing", fallback="N/A"))
```

> [!tip] DEFAULT section
Keys in `[DEFAULT]` are available in **every** section as fallback values.

## Checking Sections and Keys

```python
import configparser
import io

ini_data = """[database]
host = localhost

[cache]
backend = redis
"""

config = configparser.ConfigParser()
config.read_string(ini_data)

print("Has database:", config.has_section("database"))
print("Has 'host':", config.has_option("database", "host"))
print("Has 'timeout':", config.has_option("database", "timeout"))
```

## Value Interpolation

`configparser` supports `%(key)s` interpolation syntax, referencing values within the same section or from `DEFAULT`.

```python
import configparser
import io

ini_data = """[paths]
base = /tmp
data = %(base)s/data
logs = %(base)s/logs
"""

config = configparser.ConfigParser()
config.read_string(ini_data)

print("Base:", config["paths"]["base"])
print("Data:", config["paths"]["data"])
print("Logs:", config["paths"]["logs"])
```

> [!trap] Interpolation errors
If a `%(name)s` reference points to a missing key, `configparser.InterpolationMissingOptionError` is raised at access time — not at parse time.

## Modifying and Removing

```python
import configparser
import io

config = configparser.ConfigParser()
config.read_string("[app]\nversion = 1.0\n")

config["app"]["version"] = "2.0"
config.set("app", "author", "Alice")
config.add_section("new")
config["new"]["key"] = "value"

if config.has_section("new"):
    config.remove_section("new")

output = io.StringIO()
config.write(output)
print(output.getvalue())
output.close()
```

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which method reads configuration from a file-like object?"
    type: single
    choices: ["read_file()", "load()", "parse()", "read_string()"]
    answer: [0]
    explanation: "read_file() accepts an open file object. read_string() accepts a string directly."
    difficulty: 1
  - id: q2
    prompt: "What does the [DEFAULT] section do in a config file?"
    type: single
    choices: ["It overrides all other sections", "Its keys are available as fallbacks in every section", "It is ignored by configparser", "It defines environment variables"]
    answer: [1]
    explanation: "Keys in [DEFAULT] serve as fallback values accessible from any section."
    difficulty: 2
  - id: q3
    prompt: "What happens when %(missing_key)s is referenced but not defined?"
    type: single
    choices: ["It returns an empty string", "It raises InterpolationMissingOptionError", "It is left as literal text", "It silently skips the line"]
    answer: [1]
    explanation: "A missing interpolation target raises an error when the value is accessed."
    difficulty: 2
  - id: q4
    prompt: "By default, are section names case-sensitive in configparser?"
    type: single
    choices: ["Yes", "No, they are lowercased", "Only on Windows", "Only if raw=True"]
    answer: [1]
    explanation: "By default, all section names and keys are lowercased and compared case-insensitively."
    difficulty: 1
  - id: q5
    prompt: "Which method checks whether a specific option exists in a section?"
    type: single
    choices: ["config.has_key()", "config.has_option()", "config.option_exists()", "config.contains()"]
    answer: [1]
    explanation: "has_option(section, option) returns True if the key exists in the given section."
    difficulty: 2
```
