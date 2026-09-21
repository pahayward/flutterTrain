---
id: 06-section-practice
title: Section 4 Practice
order: 6
section: 04-network
language: python
summary: Compact review of network programming plus an 8-question exam bank for section 4.
tags: [review, practice, exam, network]
---

# Section 4 Practice

A compact recap of everything from `Fundamentals of network programming`
through `Building a REST client`, followed by a short quiz and the section's
exam bank.

## Section review

**Clients & servers (4.1)**

- The **server** binds a known `(host, port)` and *listens*; the **client**
  *connects* (initiates). The client is always the initiator.
- **IPv4/IPv6** address the host; **ports** (0–65535) select the service
  (`80` HTTP, `443` HTTPS, `53` DNS). **DNS** maps domain names to addresses.
- **TCP** = connection-oriented, reliable stream (`SOCK_STREAM`). **UDP** =
  connectionless datagrams (`SOCK_DGRAM`).
- **REST** is a style on top of HTTP: resources addressed by URI, methods
  `GET`/`POST`/`PUT`/`DELETE`, stateless exchanges, status-code outcomes.

**Sockets (4.2)**

- Server flow: `socket()` → `bind()` → `listen()` → `accept()` → `recv()/send()`
  → `close()`.
- Client flow: `socket()` → `connect()` → `sendall()/recv()` → `close()`.
- `send()` may write partial data — use `sendall()`. `recv()` returning `b""`
  means the peer closed. Set `settimeout()` and catch `socket.timeout`,
  `ConnectionRefusedError`, `OSError`.

**Payload formats (4.3)**

- **JSON**: objects `{...}`, arrays `[...]`, strings (double quotes),
  numbers, `true`/`false`/`null`. Python mapping: `dict`→object,
  `list`/`tuple`→array, `True`→`true`, `None`→`null`.
  `json.dumps`/`json.loads` (strings), `json.dump`/`json.load` (files).
- **XML**: one root element, nested tags, quoted attributes.
  `ElementTree.fromstring`, `ElementTree.parse`, `.find()`, `.findall()`,
  `.iter()`, `.get()`, `.text`. A **DTD** validates structure — ElementTree
  parses but does not validate.

**REST clients (4.4)**

- `GET` read, `POST` create (`201 Created`), `PUT` update, `DELETE` remove
  (`204 No Content`). Interpret the status class: `2xx` success, `4xx` client
  error, `5xx` server error.
- `requests` is the standard tool in the wild (not on-device); stdlib
  `urllib.request` can do the same locally, and raises `HTTPError` on `4xx`.

One combined runnable recap — JSON over a local TCP socket:

```python
import json
import socket
import threading
import time

def echo_server(port):
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.bind(("127.0.0.1", port))
    srv.listen(1)
    conn, _ = srv.accept()
    raw = conn.recv(2048)
    reply = json.dumps({"received": json.loads(raw)}).encode()
    conn.sendall(reply)
    conn.close()
    srv.close()

port = 46123
threading.Thread(target=echo_server, args=(port,), daemon=True).start()
time.sleep(0.2)

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.settimeout(3)
client.connect(("127.0.0.1", port))
client.sendall(json.dumps({"hello": "pcpp"}).encode())
back = json.loads(client.recv(2048).decode())
client.close()

print("server echoed:", back["received"])
```

The pattern is always the same: **serialize to bytes → push over a socket →
parse the bytes back**, whether the format is JSON, XML, or a plain HTTP
body.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "Which sequence correctly describes a server socket's lifecycle?"
    type: single
    choices:
      - "connect, send, recv, close"
      - "bind, listen, accept, recv/send, close"
      - "bind, connect, accept, send, close"
      - "listen, connect, accept, recv, close"
    answer: [1]
    explanation: "A server binds a local address, listens for connections, and accept()es each client before exchanging and closing — the listener itself never connect()s."
    difficulty: 2
  - id: q2
    prompt: "A REST client receives 404 from GET /items/9. What does that tell you?"
    type: single
    choices:
      - "The server crashed"
      - "The network was too slow"
      - "No item with id 9 exists (client-side error)"
      - "The request was successfully created"
    answer: [2]
    explanation: "404 Not Found is a 4xx client error meaning the requested resource does not exist — not an infrastructure or transport problem."
    difficulty: 1
  - id: q3
    prompt: "Which Python expression converts the JSON text '{\"a\": [1, 2]}' into its Python equivalent?"
    type: single
    choices:
      - "json.dumps('{\"a\": [1, 2]}')"
      - "json.loads('{\"a\": [1, 2]}')"
      - "json.load('{\"a\": [1, 2]}')"
      - "str('{\"a\": [1, 2]}')"
    answer: [1]
    explanation: "loads parses a JSON string into a Python object (a dict with a list value here). load reads from a file object; dumps does the reverse."
    difficulty: 1
```

## ExamQuestions

```yaml
bank:
  - id: ex1
    prompt: "In the client-server model, which statement is true?"
    type: single
    choices:
      - "The server initiates the connection to the client"
      - "The client initiates communication with a server that listens"
      - "Both client and server must call listen()"
      - "The client binds a fixed well-known port"
    answer: [1]
    explanation: "The server binds a known address and listens; the client is the initiator that connects to it."
    weight: 4
    section: 04-network
  - id: ex2
    prompt: "Which port does HTTP use by default, and how would you look it up programmatically?"
    type: single
    choices:
      - "80, via socket.getservbyname('http', 'tcp')"
      - "443, via socket.getservbyname('http', 'tcp')"
      - "25, via socket.getservbyname('smtp', 'tcp')"
      - "53, via socket.getservbyport('http', 'tcp')"
    answer: [0]
    explanation: "HTTP's well-known port is 80; getservbyname('http', 'tcp') returns it. 443 is HTTPS (same lookup target), 25 is SMTP, 53 is DNS (UDP)."
    weight: 4
    section: 04-network
  - id: ex3
    prompt: "Complete the sentence: UDP is ______, while TCP is ______."
    type: single
    choices:
      - "connectionless and best-effort; connection-oriented and reliable"
      - "connection-oriented and reliable; connectionless and best-effort"
      - "connectionless and reliable; connection-oriented and best-effort"
      - "stateless only when slow; stateful only when fast"
    answer: [0]
    explanation: "UDP sends discrete datagrams without a connection (best-effort delivery); TCP establishes a connection and guarantees ordered, complete delivery."
    weight: 4
    section: 04-network
  - id: ex4
    prompt: "A server's socket has returned a new socket from accept(). What does this new socket represent?"
    type: single
    choices:
      - "The listening socket continues listening; the new socket serves that one client"
      - "The server must now call listen() again before receiving"
      - "The client's address but a connectionless datagram stream"
      - "A socket bound to a different IP address for load balancing"
    answer: [0]
    explanation: "accept() returns a fresh socket for the accepted conversation; the original listening socket stays open for further connections."
    weight: 4
    section: 04-network
  - id: ex5
    prompt: "Why is sendall() usually safer than send() for TCP clients?"
    type: single
    choices:
      - "sendall() encrypts data automatically"
      - "send() may transmit only part of the buffer before returning"
      - "sendall() waits for a confirmation from the remote application"
      - "send() is deprecated and no longer works"
    answer: [1]
    explanation: "send() returns the number of bytes sent and may send fewer than provided; sendall() loops internally until the entire buffer is transmitted."
    weight: 4
    section: 04-network
  - id: ex6
    prompt: "Which status code best fits a successful POST that created a new REST resource?"
    type: single
    choices:
      - "200 OK"
      - "201 Created"
      - "301 Moved Permanently"
      - "500 Internal Server Error"
    answer: [1]
    explanation: "201 Created is the conventional success code when POST has created a resource; 200 is a generic success, 301 is redirection, 500 a server error."
    weight: 4
    section: 04-network
  - id: ex7
    prompt: "After json.loads(), which type does the JSON substructure [1, 2, 3] become in Python?"
    type: single
    choices:
      - "tuple"
      - "list"
      - "set"
      - "range"
    answer: [1]
    explanation: "JSON arrays always decode to Python lists. Tuples are never reconstructed, even if they were serialized from a tuple."
    weight: 4
    section: 04-network
  - id: ex8
    prompt: "With xml.etree.ElementTree, how do you obtain all direct children named 'book' of a root element?"
    type: single
    choices:
      - "root.find('book')"
      - "root.findall('book')"
      - "root.iter('book')"
      - "root.attrib['book']"
    answer: [1]
    explanation: "findall('book') returns a list of direct children named book. find() returns only the first, iter() recurses to all depths, attrib holds attributes."
    weight: 4
    section: 04-network
```