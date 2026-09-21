---
id: 04-logging
title: Logging
order: 4
section: 05-file-processing
language: python
type: lesson
summary: Configure logging levels, use LogRecord attributes, and create custom handlers and formatters for controlled output.
tags: [logging, handlers, formatters, levels]
---

# Logging

Python's `logging` module provides a flexible framework for emitting diagnostic messages. Unlike `print()`, logging lets you control severity, destination, and formatting.

> [!key] Logging vs. print
`print()` is for development. `logging` is for production: it supports severity levels, multiple handlers, rotation, and structured output — all configurable at runtime.

## Basic Usage and Logging Levels

The module defines five standard severity levels (lowest to highest): `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`.

```python
import logging

logging.basicConfig(level=logging.DEBUG, format="%(levelname)s: %(message)s")

logging.debug("Detailed info for developers")
logging.info("General informational message")
logging.warning("Something might be wrong")
logging.error("Something went wrong")
logging.critical("Fatal — program may stop")
```

> [!tip] Default level
Without `basicConfig`, the default level is `WARNING`, so `debug()` and `info()` calls are silently ignored.

## Configuring with basicConfig

`basicConfig()` sets up the root logger. Common keyword arguments: `level`, `format`, `filename`, `filemode`.

```python
import logging
import io

stream = io.StringIO()
handler = logging.StreamHandler(stream)
handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

logger = logging.getLogger("myapp")
logger.setLevel(logging.INFO)
logger.addHandler(handler)

logger.info("Application started")
logger.warning("Disk usage high")
print(stream.getvalue())
stream.close()
```

> [!note] getLogger("name")
Named loggers allow per-component configuration. `"myapp"` is a child of the root logger.

## LogRecord Attributes

Every log call creates a `LogRecord` object. The format string can reference any attribute of `LogRecord`.

```python
import logging
import io

stream = io.StringIO()
handler = logging.StreamHandler(stream)
fmt = logging.Formatter("%(name)s | %(levelname)s | %(funcName)s | %(message)s")
handler.setFormatter(fmt)

logger = logging.getLogger("demo")
logger.setLevel(logging.DEBUG)
logger.addHandler(handler)

def process_data():
    logger.info("Processing started")

process_data()
logger.warning("Slow response detected")
print(stream.getvalue())
stream.close()
```

Common LogRecord attributes:

| Attribute | Meaning |
|---|---|
| `name` | Logger name |
| `levelname` | Severity as string |
| `funcName` | Function that called the logger |
| `lineno` | Line number of the call |
| `asctime` | Human-readable timestamp |
| `message` | The formatted log message |

## Custom Formatters

Formatters control the layout of log output. You can include timestamps, source locations, and custom fields.

```python
import logging
import io

stream = io.StringIO()
handler = logging.StreamHandler(stream)
fmt = logging.Formatter(
    "[%(asctime)s] %(levelname)-8s %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
handler.setFormatter(fmt)

logger = logging.getLogger("app")
logger.setLevel(logging.DEBUG)
logger.addHandler(handler)

logger.info("System initialized")
logger.error("Connection refused")
print(stream.getvalue())
stream.close()
```

## Multiple Handlers

Attach several handlers to the same logger — each with its own level and format.

```python
import logging
import io

err_stream = io.StringIO()
info_stream = io.StringIO()

err_handler = logging.StreamHandler(err_stream)
err_handler.setLevel(logging.ERROR)
err_handler.setFormatter(logging.Formatter("ERR: %(message)s"))

info_handler = logging.StreamHandler(info_stream)
info_handler.setLevel(logging.INFO)
info_handler.setFormatter(logging.Formatter("INFO: %(message)s"))

logger = logging.getLogger("multi")
logger.setLevel(logging.DEBUG)
logger.addHandler(err_handler)
logger.addHandler(info_handler)

logger.info("Startup complete")
logger.error("Disk full")

print("Error stream:", err_stream.getvalue().strip())
print("Info stream:", info_stream.getvalue().strip())
err_stream.close()
info_stream.close()
```

> [!trap] Handlers accumulate
Calling `basicConfig()` or `addHandler()` multiple times without clearing handlers leads to duplicate output. Use `logger.handlers.clear()` if needed.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the default logging level if basicConfig() is not called?"
    type: single
    choices: ["DEBUG", "INFO", "WARNING", "ERROR"]
    answer: [2]
    explanation: "The default level is WARNING, so only WARNING and above are emitted."
    difficulty: 1
  - id: q2
    prompt: "Which LogRecord attribute contains the function name that issued the log call?"
    type: single
    choices: ["%(name)s", "%(funcName)s", "%(caller)s", "%(method)s"]
    answer: [1]
    explanation: "funcName holds the name of the function containing the logging call."
    difficulty: 2
  - id: q3
    prompt: "How can you direct log output to an in-memory buffer instead of the console?"
    type: single
    choices: ["Use print() instead", "Attach a StreamHandler wrapping io.StringIO", "Set logging.to_string = True", "Pass encoding='memory' to basicConfig"]
    answer: [1]
    explanation: "StreamHandler accepts any file-like object, including io.StringIO."
    difficulty: 2
  - id: q4
    prompt: "What does logger.setLevel(logging.ERROR) do to INFO-level messages?"
    type: single
    choices: ["They are printed anyway", "They are silently ignored", "They raise an exception", "They are buffered for later"]
    answer: [1]
    explanation: "Messages below the effective level are not processed by the logger."
    difficulty: 1
```
