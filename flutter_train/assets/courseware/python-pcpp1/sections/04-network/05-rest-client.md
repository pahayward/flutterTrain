---
id: 05-rest-client
title: Building a REST client
order: 5
section: 04-network
language: python
summary: The requests module, test environments, GET/POST/PUT/DELETE, CRUD, response analysis, status codes.
tags: [rest, requests, crud, http, urllib, status-code]
---

# Building a REST client

A **REST client** is a program that calls a RESTful API over HTTP: send a
request (`GET`, `POST`, `PUT`, `DELETE`, …), receive a status code plus a
response body (usually JSON), and do something useful with it. This module
teaches how to write one and how to analyse the responses — a main exam
objective of PCPP-32-101 section 4.4.

## HTTP methods map to CRUD

REST exposes resources with HTTP methods — this mapping is exam gold:

| Method | Action (CRUD) | Typical status on success |
|---|---|---|
| `GET` | read / list | `200 OK` |
| `POST` | create a new resource (`/items`) | `201 Created` |
| `PUT` | update/replace a resource (`/items/7`) | `200 OK` (or `204`) |
| `DELETE` | remove a resource (`/items/7`) | `204 No Content` |

> [!key]
> `POST` targets the *collection* to create; `PUT` targets the *specific
> resource* to replace. `DELETE` to `/items/7` deletes that one item only.

## The requests library

`requests` is the community-standard HTTP client and the library the exam
expects you to know. Typical usage:

```python eval=no title="requests-basics.py"
import requests  # NOT in the on-device stdlib - cannot run on Android

base = "https://httpbin.org"  # public test API - needs real internet

r = requests.get(base + "/get")
print(r.status_code)          # 200
print(r.headers["content-type"])
print(r.json())               # parse the JSON body into a dict
```

Why is this `eval=no`? Two reasons: `requests` is not part of the bundled
CPython stdlib on device, and this target is on the public internet. Read it
as reference syntax — on-device you instead use standard-library tools
(`urllib`) or install `requests` in your own environment.

### Full requests CRUD (reference, not runnable)

```python eval=no title="requests-crud.py"
import requests

base = "https://jsonplaceholder.typicode.com"  # public demo REST API

# CREATE
r = requests.post(base + "/posts", json={"title": "hi", "body": "pcpp",
                                         "userId": 1})
print("create ->", r.status_code)               # 201

# READ
r = requests.get(base + "/posts/1")
print("read   ->", r.status_code, r.json()["title"])

# UPDATE
r = requests.put(base + "/posts/1", json={"title": "updated"})
print("update ->", r.status_code)

# DELETE
r = requests.delete(base + "/posts/1")
print("delete ->", r.status_code, len(r.content))
```

Notice `json=...` — `requests` serialises the dict to JSON, sets
`Content-Type: application/json`, and sends it. `r.json()` does the reverse.

> [!warning]
> The examples above hit real third-party services over the public internet.
> They cannot run inside the offline on-device sandbox and are shown only as a
> reference.

## Test environments

You rarely want to test against production APIs. Options:

- **Local stubs** — a small HTTP server you run on `localhost` (this course
  builds one below, entirely on `127.0.0.1`).
- **Public fake APIs** — `httpbin.org` (echoes your request back),
  `jsonplaceholder.typicode.com` (CRUD demo data). For browsing only — they
  are on the internet.
- **Mock libraries** — intercept requests in unit tests without any network.

> [!tip]
> A throwaway local server makes tests repeatable and offline-safe: the same
> code path that will later hit a real API runs against `127.0.0.1` with no
> internet dependency.

## Analysing responses

Whatever the client library, the response has the same parts:

- **status code** — the outcome (`200 OK`, `404 Not Found`, `500 Internal
  Server Error`).
- **headers** — `Content-Type`, `Content-Length`, `Location`, …
- **body** — raw text or parsed JSON.

Status code classes to recognise:

| Class | Meaning | Examples |
|---|---|---|
| `1xx` | informational | `100 Continue` |
| `2xx` | success | `200 OK`, `201 Created`, `204 No Content` |
| `3xx` | redirection | `301 Moved Permanently`, `304 Not Modified` |
| `4xx` | client error | `400 Bad Request`, `401 Unauthorized`, `404 Not Found` |
| `5xx` | server error | `500 Internal Server Error`, `503 Service Unavailable` |

The standard library `urllib.request` raises `HTTPError` for `4xx`/`5xx`, so a
client must catch it and inspect `.code` — exactly what analysing responses
means in practice.

## A runnable CRUD client against a local server

Everything below runs on-device: `urllib` (stdlib) client + a
`ThreadingHTTPServer` stub, both on `127.0.0.1`, with short timeouts:

```python title="local-rest-crud.py"
import json
import threading
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

store = {}

class Crud(BaseHTTPRequestHandler):
    def do_GET(self):
        key = self.path.rsplit("/", 1)[1]
        if key in store:
            self._send(200, {"id": key, "value": store[key]})
        else:
            self._send(404, {"error": "not found"})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        payload = json.loads(self.rfile.read(length))
        key = str(len(store) + 1)
        store[key] = payload["value"]
        self._send(201, {"id": key})

    def do_PUT(self):
        key = self.path.rsplit("/", 1)[1]
        length = int(self.headers.get("Content-Length", 0))
        payload = json.loads(self.rfile.read(length))
        store[key] = payload["value"]
        self._send(200, {"id": key, "value": store[key]})

    def do_DELETE(self):
        key = self.path.rsplit("/", 1)[1]
        deleted = store.pop(key, None)
        self._send(204, None if deleted is not None else {"error": "missing"})

    def _send(self, code, body):
        data = b"" if body is None else json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        if data:
            self.wfile.write(data)

    def log_message(self, *args):
        pass

srv = ThreadingHTTPServer(("127.0.0.1", 45991), Crud)
threading.Thread(target=srv.serve_forever, daemon=True).start()

BASE = "http://127.0.0.1:45991"

def call(method, url, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    if body is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=3) as res:
            return res.status, res.read().decode()
    except urllib.error.HTTPError as err:
        return err.code, err.read().decode()

print("POST /items   ->", call("POST", BASE + "/items", {"value": "alpha"}))
print("GET  /items/1 ->", call("GET", BASE + "/items/1"))
print("PUT  /items/1 ->", call("PUT", BASE + "/items/1", {"value": "beta"}))
print("GET  /items/1 ->", call("GET", BASE + "/items/1"))
print("DELETE /items/1 ->", call("DELETE", BASE + "/items/1"))
print("GET  /items/1 ->", call("GET", BASE + "/items/1"))  # 404 now

srv.shutdown()
srv.server_close()
```

Run it and watch the status codes tell the story: `201`, then `200`, then
`200` (updated), then `204`, then `404`. That sequence *is* the CRUD lifecycle.

> [!note]
> The exact same logic works with `requests` — swap `urllib.request.Request`
> for `requests.request(method, url, json=...)`. `requests` only automates
> encoding/decoding; the HTTP semantics do not change.

## Common traps

- **Reading `.json()` on a non-JSON body** — check `Content-Type` first, or
  guard with a `try/except ValueError`.
- **Forgetting `method=` on `urlopen`** — a `Request` with a body defaults to
  `POST`; without one it is `GET`. Be explicit about the method.
- **Assuming `404` means the server is down** — `404` is a *client* error:
  the resource was not found. A down server raises a connection error instead.
- **Not handling `HTTPError`** — with `urllib`, `4xx`/`5xx` raise instead of
  returning a response object; you must catch and inspect `.code`.
- **Cashiering everything as GET** — `POST`/`PUT`/`DELETE` can change state;
  use the method the API documents, not whichever is convenient.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which pair of HTTP methods and CRUD operations is correct?"
    type: single
    choices:
      - "GET creates a new resource"
      - "POST reads a specific resource"
      - "PUT updates or replaces a specific resource"
      - "DELETE never changes server state"
    answer: [2]
    explanation: "PUT maps to replace/update on a specific resource URI; GET reads, POST creates on the collection, DELETE removes."
    difficulty: 1
  - id: q2
    prompt: "A successful request that creates a new resource should normally return which status code?"
    type: single
    choices:
      - "200 OK"
      - "201 Created"
      - "204 No Content"
      - "404 Not Found"
    answer: [1]
    explanation: "201 Created is the conventional success status for POST that creates a resource. 204 signals success with no response body (often DELETE)."
    difficulty: 1
  - id: q3
    prompt: "Why can the requests-based examples in this module not be marked runnable on-device?"
    type: single
    choices:
      - "The requests syntax is invalid Python"
      - "requests is not bundled with the on-device standard library and the targets need real internet"
      - "REST clients must use C instead of Python"
      - "The threads would deadlock on the loopback interface"
    answer: [1]
    explanation: "requests is a third-party package absent from the bundled CPython stdlib, and the demo APIs live on the public internet."
    difficulty: 2
  - id: q4
    prompt: "Which of the following correctly describe the response analysis tools a REST client should use?"
    type: multi
    choices:
      - "the status code to classify the outcome"
      - "headers such as Content-Type to interpret the body"
      - "the parsed JSON body produced by r.json() or json.loads()"
      - "the TCP sequence number to detect lost packets"
    answer: [0, 1, 2]
    explanation: "Clients analyse status code, headers, and (parsed) body. TCP sequence numbers are a transport-layer detail invisible to HTTP clients."
    difficulty: 2
  - id: q5
    prompt: "What happens when urllib.request.urlopen() receives a 404 response?"
    type: single
    choices:
      - "It returns a response object with status 404"
      - "It raises urllib.error.HTTPError whose .code is 404"
      - "It silently returns an empty bytes object"
      - "It reconnects to the server automatically"
    answer: [1]
    explanation: "urllib raises HTTPError for 4xx/5xx responses; catching it and reading .code is the standard way to analyse such failures."
    difficulty: 2
```