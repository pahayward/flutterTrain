---
id: 02-sockets
title: Working with sockets
order: 2
section: 04-network
language: python
summary: Creating sockets, connecting to HTTP servers, send/recv, closing, and exception handling.
tags: [socket, tcp, bind, listen, accept, connect, recv, sendall]
---

# Working with sockets

A **socket** is Python's doorway to the network. It is the endpoint of a
two-way communication link between two programs. The `socket` module is part
of the standard library, so everything in this module runs on-device against
`localhost`.

## Creating a socket

`socket.socket(family, type)` creates an unbound endpoint:

```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print("created:", s.family, s.type)
s.close()
```

- `AF_INET` — IPv4 (address family).
- `SOCK_STREAM` — TCP: reliable, connection-oriented, byte stream.
- `SOCK_DGRAM` — UDP: connectionless datagrams.

> [!key]
> `socket()` only creates the endpoint — nothing is bound or connected yet.
> Every created socket should be closed when done (`s.close()`), which frees
> the underlying OS descriptor.

For a TCP conversation the two sides do different things:

```text
SERVER                       CLIENT
socket()                     socket()
bind(addr, port)             
listen(backlog)              
accept()  <--wait--          connect(addr, port)
recv()/send()                send()/recv()
close()                      close()
```

## The server side: bind, listen, accept

- `bind((host, port))` — attach the socket to a local address. Use
  `"127.0.0.1"` to accept loopback only, `"0.0.0.0"` for all interfaces.
- `listen(backlog)` — start accepting connections; `backlog` is the maximum
  number of queued connections.
- `accept()` — block until a client connects; returns a **new socket** for that
  conversation plus the client's address. The listening socket keeps listening.
- `SO_REUSEADDR` lets you rebind quickly after a crash without
  "address already in use" errors.

## The client side: connect and send

- `connect((host, port))` — open a connection to the server.
- `send(data)` — send bytes; may send *fewer* bytes than given. Use
  `sendall(data)` to be sure everything is delivered.
- `recv(bufsize)` — receive up to `bufsize` bytes; returns empty bytes `b""`
  when the peer has closed its end (this is how a TCP client detects the end
  of a response).

A complete, runnable echo exchange — both sides in one block via a daemon
thread, against `127.0.0.1`:

```python
import socket
import threading
import time

def run_server(port):
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", port))
    srv.listen(1)
    conn, addr = srv.accept()
    data = conn.recv(1024)
    conn.sendall(data.upper())
    conn.close()
    srv.close()

port = 45701
threading.Thread(target=run_server, args=(port,), daemon=True).start()
time.sleep(0.2)  # give the server time to bind

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.settimeout(3)
client.connect(("127.0.0.1", port))
client.sendall(b"echo me")
reply = client.recv(1024)
print("server sent back:", reply.decode())
client.close()
```

> [!tip]
> `recv()` returns at *most* the requested number of bytes. For a stream you
> usually need a loop until `recv()` yields `b""` or until you've read the
> expected size.

## Talking to an HTTP server with raw sockets

HTTP is just a text protocol over TCP. A raw-socket client can address any
HTTP server itself — this is exactly what higher-level libraries automate:

```python
import socket
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

class StubServer(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"Hello over raw sockets!"
        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *args):
        pass

srv = HTTPServer(("127.0.0.1", 45702), StubServer)
threading.Thread(target=srv.serve_forever, daemon=True).start()

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(3)
s.connect(("127.0.0.1", srv.server_address[1]))
s.sendall(b"GET / HTTP/1.0\r\nHost: localhost\r\n\r\n")

response = b""
while True:
    chunk = s.recv(4096)
    if not chunk:
        break
    response += chunk
s.close()
srv.shutdown()
srv.server_close()

status = response.split(b"\r\n", 1)[0].decode()
body = response.split(b"\r\n\r\n", 1)[1].decode()
print("status line:", status)
print("body:", body)
```

Key insights:

- The request is an ASCII request line, headers, blank line, and optional body.
- `HTTP/1.0` tells the server to close the connection after the reply — so
  reading until `b""` cleanly terminates the loop.
- The same pattern underpins `urllib`, `requests`, and browsers.

> [!note]
> Interacting with a *real* web server on the public internet cannot run
> on-device (no network there), so internet examples appear as `eval=no` in
> `05-rest-client.md`.

## Closing sockets

Always close sockets you no longer need:

- `s.close()` — release the OS resource immediately.
- `with socket.socket(...) as s:` — auto-close, even on errors.
- `srv.shutdown()` / `srv.server_close()` — stop a listening `socketserver`.

```python
import socket

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.settimeout(0.3)
    try:
        s.connect(("127.0.0.1", 45999))  # nothing is listening -> refused
        print("connected")
    except OSError as err:
        print("connect failed:", type(err).__name__, err)
print("socket closed by context manager")
```

The `with` block guarantees `close()` runs, even after an exception.

## Exception handling in network code

Network code fails in predictable, examinable ways:

| Exception | When it happens |
|---|---|
| `socket.timeout` | an operation took longer than the socket timeout |
| `ConnectionRefusedError` | nothing is listening on the `(host, port)` |
| `ConnectionResetError` | the peer closed the connection abruptly |
| `gaierror` | the hostname could not be resolved (DNS failure) |
| `socket.error` | base class for most socket problems |

`settimeout(seconds)` arms a `socket.timeout` on blocking operations; numeric
non-integer values are allowed (`0.25`). A timeout of `None` restores blocking.

```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(0.25)
try:
    s.connect(("127.0.0.1", 45998))
except socket.timeout:
    print("timed out connecting (silently caught)")
except OSError as err:
    print("other network error:", err)
finally:
    s.close()
```

> [!trap]
> `socket.timeout` is a subclass of `OSError` — but it is *also* a subclass of
> `socket.error`. Catch the specific `socket.timeout` *before* a broad
> `OSError` handler, or the timeout will be swallowed by the general case.

## Common traps

- **Forgetting `SO_REUSEADDR`** — an immediately restarted server can hit
  "Address already in use".
- **Using `send()` and assuming all bytes went out** — it can send a partial
  chunk; prefer `sendall()`.
- **Calling `accept()` twice for one client** — `accept()` returns a fresh
  socket; keep the listener for the *next* client.
- **Not setting a timeout** — `connect()` to an unreachable address can block
  for a very long time. On-device, a stale read can hang your script.
- **Reading `recv()` once and assuming you got the whole message** — TCP is a
  stream; loop until `b""`.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which method places a server socket into listening state on a bound address?"
    type: single
    choices:
      - "accept()"
      - "listen()"
      - "connect()"
      - "recv()"
    answer: [1]
    explanation: "A server binds, then calls listen(backlog) to start accepting queued connections; accept() then returns each incoming conversation."
    difficulty: 1
  - id: q2
    prompt: "What does send() risk that sendall() avoids?"
    type: single
    choices:
      - "Sending only part of the data before returning"
      - "Encrypting the data before transmission"
      - "Closing the socket unintentionally"
    answer: [1]
    explanation: "send() may transmit fewer bytes than provided and return the count; sendall() keeps sending until the whole buffer is out."
    difficulty: 1
  - id: q3
    prompt: "In a TCP client, what signals that the server has closed its end of the connection?"
    type: single
    choices:
      - "recv() raises a TypeError"
      - "recv() returns an empty bytes object"
      - "send() raises a ValueError"
      - "The socket object becomes None"
    answer: [1]
    explanation: "recv() returning b'' (empty bytes) is the TCP end-of-stream signal; clients read until b'' to finish collecting a response."
    difficulty: 2
  - id: q4
    prompt: "Which statement about socket timeouts is correct?"
    type: single
    choices:
      - "socket.timeout is raised when a blocking operation exceeds the configured timeout"
      - "settimeout() forces the socket to close itself automatically"
      - "Timeouts only apply to UDP sockets, never TCP"
      - "A socket timeout can never be changed after the socket is created"
    answer: [0]
    explanation: "settimeout(x) arms a socket.timeout on blocking calls. It applies to streams and datagrams alike and can be changed at any time."
    difficulty: 2
  - id: q5
    prompt: "Choose the exceptions that commonly indicate network problems during a connect() call."
    type: multi
    choices:
      - "socket.timeout"
      - "ConnectionRefusedError"
      - "ZeroDivisionError"
      - "KeyError"
    answer: [0, 1]
    explanation: "socket.timeout (operation too slow) and ConnectionRefusedError (nothing listening) are classic socket failures. The other two are unrelated runtime errors."
    difficulty: 2
```