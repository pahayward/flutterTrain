---
id: 01-network-basics
title: Fundamentals of network programming
order: 1
section: 04-network
language: python
summary: REST, sockets, addresses, ports, protocols, services, and clients & servers.
tags: [network, rest, socket, tcp, udp, ip, port, protocol]
---

# Fundamentals of network programming

Section 4 of the PCPP-32-101 exam covers **network programming**. Before you
write a single line of socket code, you need a mental model of how programs
communicate: who talks to whom, on what address, through which port, and over
what protocol. This module builds that foundation.

## The client–server model

Almost every networked program is a pair:

- A **server** — a process that *listens* for incoming connections and waits
  for clients to initiate communication.
- A **client** — a process that *initiates* the communication by connecting to
  the server's known address.

```text
Client  --(request)-->  Server
Client  <--(response)-- Server
```

The server usually exposes a fixed **service** (e.g. HTTP on a web server).
The client asks the server to do something; the server answers.

> [!key]
> The client is the *initiator*. The server is the *listener*. Servers bind to
> a known `(address, port)` so clients can find them.

## Addresses: IP and domains

Every host on a network is identified by an **IP address**:

- **IPv4** — 4 decimal bytes, written like `192.168.1.10` or `127.0.0.1`.
- **IPv6** — 8 hexadecimal groups, written like `2001:db8::1`.

`127.0.0.1` is the **loopback** address — it always means "this machine". The
name `localhost` maps to it. On-device examples in this course use loopback so
they run with no network access at all.

People cannot remember numbers well, so we use **domain names** like
`python.org`. The **DNS** (Domain Name System) service translates a domain
name into an IP address. From Python, `socket` can do this for you:

```python
import socket

name = "localhost"
ip = socket.gethostbyname(name)
print(name, "->", ip)
print("loopback check:", ip == "127.0.0.1")
```

`socket.gethostbyname()` resolves a name to a single IPv4 address.
`socket.getaddrinfo()` returns a richer result: every address family, socket
type, and protocol combination available for a host *and* port:

```python
import socket

for info in socket.getaddrinfo("localhost", 80):
    family, socktype, proto, _, address = info
    print(family.name, socktype.name, proto, address)
```

`AF_INET` means IPv4, `SOCK_STREAM` is TCP (see below), and the last item is a
real `(host, port)` pair you can connect to.

## Ports: doors into a machine

A single machine runs many services. The **port number** selects which service
you want. Ports go from `0` to `65535`:

- **Well-known ports (0–1023)** — reserved for standard services, e.g. HTTP
  on `80`, HTTPS on `443`, SSH on `22`, DNS on `53`.
- **Registered (1024–49151)** — common applications (e.g. MySQL on `3306`).
- **Dynamic / ephemeral (49152–65535)** — free for your own test servers.

Python remembers the well-known ones via `/etc/services`-style tables:

```python
import socket

print("http  ->", socket.getservbyname("http", "tcp"))
print("http  ->", socket.getservbyname("https", "tcp"))
print("port 53 ->", socket.getservbyport(53, "udp"))
```

> [!tip]
> For learning, pick a high port like `45xxx` for your own local servers.
> Binding a low well-known port usually needs administrator rights and risks
> clashing with a real service.

## Protocols and services

A **network protocol** is a set of rules both sides agree on — message layout,
ordering, error handling. Two layers matter for this exam:

- **Transport** — how data is carried between processes: TCP or UDP.
- **Application** — what the data *means*: HTTP, FTP, SMTP, DNS, ...

**TCP** is the workhorse for HTTP. **UDP** is a lightweight choice for DNS,
VoIP, and games. Python exposes both through sockets (next module).

## Connection-oriented vs connectionless

This distinction is central to PCPP-32-101 4.1:

| | Connection-oriented (TCP) | Connectionless (UDP) |
|---|---|---|
| Setup | 3-way handshake before data | none — just send |
| Reliability | guaranteed delivery, ordering | best effort, may lose/duplicate |
| Data shape | stream of bytes (no boundaries) | discrete datagrams, size-limited |
| State | both ends remember the connection | stateless |
| Use | web (HTTP), e-mail, file transfer | DNS, streaming media, gaming |

The trade-off: TCP is reliable but has more overhead; UDP is fast and simple
but you must handle loss yourself.

A runnable example — a one-shot UDP echo (both ends in one block, strictly on
`localhost`):

```python
import socket
import threading
import time

# --- connectionless (UDP) echo server, short-lived ---
def udp_echo(port):
    srv = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    srv.bind(("127.0.0.1", port))
    data, addr = srv.recvfrom(64)
    srv.sendto(b"pong from server", addr)
    srv.close()

port = 45678
threading.Thread(target=udp_echo, args=(port,), daemon=True).start()
time.sleep(0.1)  # let the server bind

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.settimeout(2)
client.sendto(b"ping from client", ("127.0.0.1", port))
reply, _ = client.recvfrom(64)
print("UDP reply:", reply.decode())
client.close()
```

> [!key]
> `SOCK_STREAM` = TCP (connection-oriented). `SOCK_DGRAM` = UDP
> (connectionless). A UDP send needs no `connect()` or handshake — the
> response, if any, comes back to whatever address you sent from.

## REST: the modern way to design services

**REST (REpresentational State Transfer)** is an architectural style for web
APIs, not a protocol — it rides on top of plain HTTP. A REST API models real
things as **resources**, each addressed by a **URI**:

```text
GET    /api/users        -> list users            (read)
POST   /api/users        -> create a user         (create)
GET    /api/users/7      -> show user 7           (read)
PUT    /api/users/7      -> replace user 7        (update)
DELETE /api/users/7      -> delete user 7         (delete)
```

Each request gets a **status code** from the server (`200 OK`, `201 Created`,
`404 Not Found`, ...). REST is **stateless**: every request carries everything
the server needs; the server stores no per-client conversation.

> [!note]
> Later modules build on this: `02-sockets.md` transmits raw bytes,
> `03-json.md` and `04-xml.md` define the *payload* formats a REST API
> commonly returns, and `05-rest-client.md` ties them together with real HTTP
> methods.

## Common traps

- **Confusing TCP and UDP** — TCP is a reliable *stream*; UDP is an unreliable
  *datagram* service. There is no "UDP handshake".
- **Thinking `localhost` is a real host** — it is the loopback interface on
  your own machine; good for testing, invisible on the network.
- **Binding to port 80** in a classroom or on Android — use a high, free port.
- **Ignoring the well-known-port table** — the exam may ask what port HTTP or
  HTTPS uses, or how to look it up (`getservbyname`).
- **Assuming the client and server are `connect()`ed symmetrically** — only the
  client connects; the server binds and listens.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What is the defining difference between a network server and a network client?"
    type: single
    choices:
      - "The server uses UDP while the client uses TCP"
      - "The server listens and waits; the client initiates communication"
      - "The client always runs before the server is started"
      - "The server sends data first in every exchange"
    answer: [1]
    explanation: "A server binds a known address and listens for connections, while a client is the initiator that connects to that address."
    difficulty: 1
  - id: q2
    prompt: "Which socket type constant corresponds to a connection-oriented, reliable stream protocol?"
    type: single
    choices:
      - "socket.SOCK_RAW"
      - "socket.SOCK_DGRAM"
      - "socket.SOCK_STREAM"
      - "socket.AF_INET"
    answer: [2]
    explanation: "SOCK_STREAM selects TCP, the connection-oriented reliable protocol. SOCK_DGRAM selects connectionless UDP; AF_INET is an address family, not a socket type."
    difficulty: 1
  - id: q3
    prompt: "Which statement about UDP is true?"
    type: single
    choices:
      - "It guarantees ordered, complete delivery of messages"
      - "It requires a three-way handshake before any data is sent"
      - "It sends discrete datagrams without establishing a connection"
      - "It is the transport protocol used by HTTPS websites"
    answer: [2]
    explanation: "UDP is connectionless and sends discrete datagrams fired immediately, with best-effort delivery only."
    difficulty: 2
  - id: q4
    prompt: "In a RESTful API, which pair correctly matches an HTTP method with the operation it performs in CRUD terms?"
    type: single
    choices:
      - "POST retrieves an existing resource"
      - "GET updates a resource"
      - "PUT replaces (updates) a resource"
      - "DELETE creates a new resource"
    answer: [2]
    explanation: "PUT maps to update/replace, POST to create, GET to read, DELETE to delete. This GET/POST/PUT/DELETE mapping is standard REST."
    difficulty: 2
  - id: q5
    prompt: "Which of the following are typical responsibilities of the DNS service?"
    type: multi
    choices:
      - "Translating domain names into IP addresses"
      - "Reserving well-known TCP ports for services"
      - "Letting users write hostnames instead of numeric addresses"
      - "Guaranteeing that UDP datagrams are never lost"
    answer: [0, 2]
    explanation: "DNS maps human-readable domain names to IP addresses so users (and programs) can avoid numeric addresses. It has nothing to do with ports or delivery guarantees."
    difficulty: 1
```