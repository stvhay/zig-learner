# Quiz 8: HTTP Web Server

Build a basic HTTP/1.1 web server in Zig 0.15.2, progressing from raw TCP sockets to a concurrent, secure static file server.

**Total: 60 points (12 questions x 5 points)**

## Test Files

The `www/` directory in this quiz folder contains test assets:
- `www/index.html` — main page (HTML)
- `www/about.html` — secondary page (HTML)
- `www/style.css` — stylesheet (CSS)
- `www/data.json` — JSON data file
- `www/subdir/nested.html` — file in a subdirectory

## Background: HTTP/1.1 Protocol

HTTP (Hypertext Transfer Protocol) is a text-based request/response protocol over TCP.

### Request Format

A client sends a request like:
```
GET /index.html HTTP/1.1\r\n
Host: localhost:8080\r\n
Connection: close\r\n
\r\n
```

The first line is the **request line**: `<METHOD> <PATH> <VERSION>\r\n`
Subsequent lines are **headers**: `<Name>: <Value>\r\n`
An empty line (`\r\n`) marks the end of headers.

- **Method**: `GET`, `POST`, `HEAD`, etc. This quiz focuses on `GET` and `HEAD`.
- **Path**: The requested resource (e.g., `/`, `/about.html`, `/subdir/nested.html`).
- **Version**: `HTTP/1.1`

### Response Format

The server responds with:
```
HTTP/1.1 200 OK\r\n
Content-Type: text/html\r\n
Content-Length: 142\r\n
Connection: close\r\n
\r\n
<file contents here>
```

The first line is the **status line**: `HTTP/1.1 <STATUS_CODE> <REASON>\r\n`
Then headers, a blank line, and the optional **body**.

### Common Status Codes

| Code | Reason | When |
|------|--------|------|
| 200 | OK | File found and served |
| 400 | Bad Request | Malformed request line |
| 403 | Forbidden | Path traversal attempt |
| 404 | Not Found | File does not exist |
| 405 | Method Not Allowed | Method other than GET/HEAD |

### Content-Type by Extension

| Extension | Content-Type |
|-----------|-------------|
| `.html` | `text/html` |
| `.css` | `text/css` |
| `.js` | `application/javascript` |
| `.json` | `application/json` |
| `.txt` | `text/plain` |
| `.png` | `image/png` |
| `.jpg` | `image/jpeg` |
| other | `application/octet-stream` |

### Zig Networking Primer

Zig's `std.posix` provides BSD socket functions. The key types and flow:

```zig
// Server socket lifecycle:
// 1. socket()  → create file descriptor
// 2. bind()    → assign address + port
// 3. listen()  → mark as passive (accepting connections)
// 4. accept()  → block until client connects, returns new fd
// 5. read()    → read client request from connection fd
// 6. write()   → send response to connection fd
// 7. close()   → close connection fd
// 8. goto 4

// Zig API (0.15.2):
const addr = std.net.Address.parseIp4("127.0.0.1", port);
const server = try addr.listen(.{ .reuse_address = true });
// server is a std.net.Server
const conn = try server.accept();   // returns std.net.Server.Connection
defer conn.stream.close();
var buf: [4096]u8 = undefined;
const n = try conn.stream.read(&buf);       // read request
try conn.stream.writeAll(response_bytes);   // send response
```

**Important 0.15.2 notes:**
- Use `std.net.Address.parseIp4` (not `std.net.Address.resolveIp`)
- `server.accept()` returns a `Connection` with a `.stream` field
- The stream has `.read()`, `.writeAll()`, and `.close()`
- Use port 8080 (not 80) to avoid requiring root privileges

---

## Questions

### Q1 (5 pts): TCP Listener — Accept and Echo

Write a Zig program that:
- Listens on `127.0.0.1:8080`
- Accepts a single TCP connection
- Reads up to 4096 bytes from the client
- Prints the raw request to stdout
- Sends back a fixed response: `HTTP/1.1 200 OK\r\n\r\nHello, World!\n`
- Closes the connection and exits

**Validation:**
- Run the server, then in another terminal: `curl http://localhost:8080/`
- curl should print `Hello, World!`
- The server's stdout should show the full HTTP request including `GET / HTTP/1.1` and headers

### Q2 (5 pts): Parse the Request Line

Extend the server to run in a loop (accept → handle → accept again) and parse the HTTP request line.

Requirements:
- Extract: method (e.g., `GET`), path (e.g., `/index.html`), version (e.g., `HTTP/1.1`)
- Use `std.mem.splitScalar` or `std.mem.indexOfScalar` to parse
- Respond with: `HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nMethod: <method>\nPath: <path>\nVersion: <version>\n`
- Handle malformed requests (no space, missing fields) by responding with `HTTP/1.1 400 Bad Request\r\n\r\n`

**Validation:**
```
curl http://localhost:8080/hello       → "Method: GET\nPath: /hello\n..."
curl http://localhost:8080/foo/bar     → "Method: GET\nPath: /foo/bar\n..."
printf "GARBAGE\r\n\r\n" | nc localhost 8080  → "HTTP/1.1 400 Bad Request"
```

### Q3 (5 pts): Serve Static Files

Serve files from a `www` directory (use the `www/` in this quiz folder):

Requirements:
- Map request path to filesystem: path `/about.html` → `www/about.html`
- Path `/` maps to `www/index.html`
- Read the file contents and return with `200 OK`
- If the file doesn't exist, return `404 Not Found` with a plain-text body: `404 Not Found\n`
- Set `Content-Length` header to the file size in bytes
- Set `Content-Type` header based on file extension (see table above)

**Validation:**
```
curl -i http://localhost:8080/              → 200, HTML content of index.html
curl -i http://localhost:8080/index.html    → 200, same content
curl -i http://localhost:8080/about.html    → 200, about page
curl -i http://localhost:8080/style.css     → 200, Content-Type: text/css
curl -i http://localhost:8080/data.json     → 200, Content-Type: application/json
curl -i http://localhost:8080/nope.html     → 404
```

### Q4 (5 pts): Support HEAD Method

Implement the `HEAD` method:
- Same as `GET` but the response must NOT include a body
- All headers (Content-Type, Content-Length) must still be present and correct
- Return `405 Method Not Allowed` for any method other than `GET` or `HEAD`

**Validation:**
```
curl -I http://localhost:8080/index.html    → 200, headers only, no body
curl -I http://localhost:8080/nope.html     → 404, no body
curl -X DELETE http://localhost:8080/       → 405 Method Not Allowed
```

### Q5 (5 pts): Subdirectory and Path Handling

Handle paths with subdirectories and normalize edge cases:

Requirements:
- `/subdir/nested.html` serves `www/subdir/nested.html`
- Paths with trailing slashes: `/subdir/` looks for `www/subdir/index.html`
- Percent-encoded paths: decode `%20` → space, `%2F` → `/`, etc. (at minimum: `%20`, `%2F`, `%3F`, `%3D`, `%26`)
- Reject paths containing `\0` (null byte) with `400 Bad Request`

**Validation:**
```
curl -i http://localhost:8080/subdir/nested.html  → 200, nested page content
curl -i http://localhost:8080/subdir/              → 404 or 200 (if subdir/index.html exists)
curl -i "http://localhost:8080/about%2Ehtml"       → 200, about page (. is %2E)
```

### Q6 (5 pts): Path Traversal Protection

Prevent directory traversal attacks:

Requirements:
- Reject any request where the resolved path escapes the `www` root directory
- Must handle: `/../etc/passwd`, `/../../etc/shadow`, `/subdir/../../etc/passwd`
- Must handle encoded traversals: `/%2e%2e/etc/passwd`, `/%2e%2e%2fetc%2fpasswd`
- Use `std.fs.path.resolve` or equivalent to canonicalize, then verify the result starts with the www root
- Return `403 Forbidden` with body `403 Forbidden\n` for traversal attempts

**Validation:**
```
curl -i http://localhost:8080/../etc/passwd          → 403 Forbidden
curl -i http://localhost:8080/subdir/../../etc/passwd → 403 Forbidden
curl -i "http://localhost:8080/%2e%2e/etc/passwd"    → 403 Forbidden
curl -i http://localhost:8080/index.html             → 200 (normal paths still work)
```

### Q7 (5 pts): Connection Keep-Alive

Implement HTTP/1.1 persistent connections:

Requirements:
- After sending a response, don't close the connection immediately
- Read the next request on the same connection
- Honor the `Connection: close` header — close after responding if present
- Implement a read timeout: if no new request arrives within 5 seconds, close the connection
- Use `std.posix.setsockopt` or poll/select for the timeout
- Add `Connection: close` or `Connection: keep-alive` to response headers

**Validation:**
- `curl -H "Connection: close" http://localhost:8080/` → server closes after response
- `curl http://localhost:8080/ http://localhost:8080/about.html` → both served on one connection (curl reuses by default with HTTP/1.1)
- Open `nc localhost 8080`, send a request, wait >5 seconds → connection closed by server

### Q8 (5 pts): Concurrent Connections with Threads

Handle multiple clients simultaneously using Zig threads:

Requirements:
- Spawn a new thread (or use `std.Thread.Pool`) for each accepted connection
- The accept loop must never block on a single client's I/O
- Each thread handles one connection (including keep-alive loop from Q7)
- Use `std.Thread.spawn` with a handler function that takes the connection
- Properly join/detach threads to avoid resource leaks

**Validation:**
Launch 3 concurrent slow clients:
```
# Terminal 1: slow client (holds connection)
(echo -e "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"; sleep 10) | nc localhost 8080 &
# Terminal 2: should respond immediately despite Terminal 1
curl http://localhost:8080/about.html
# Terminal 3: should also respond immediately
curl http://localhost:8080/style.css
```
All three should succeed without blocking each other.

### Q9 (5 pts): Response Headers and HTTP Compliance

Add standard HTTP response headers:

Requirements:
- `Date`: current UTC time in HTTP format: `Date: Thu, 01 Jan 2025 12:00:00 GMT`
  - Format: `std.fmt.bufPrint` with day-of-week, day, month-name, year, HH:MM:SS GMT
  - Use `std.time.timestamp()` to get epoch seconds, convert manually or use `std.time.epoch.EpochSeconds`
- `Server: zig-http/0.1`
- `Content-Length`: exact byte count of body (already from Q3)
- `Content-Type`: based on extension (already from Q3)
- `Connection`: `keep-alive` or `close` (already from Q7)

**Validation:**
```
curl -i http://localhost:8080/ | head -10
```
Should show:
```
HTTP/1.1 200 OK
Date: <current date in HTTP format>
Server: zig-http/0.1
Content-Type: text/html
Content-Length: <size>
Connection: keep-alive
```

### Q10 (5 pts): Error Pages with HTML Bodies

Serve proper HTML error pages instead of plain text:

Requirements:
- All error responses (400, 403, 404, 405) return an HTML body with the error code and reason
- Template: `<!DOCTYPE html><html><body><h1>{status} {reason}</h1></body></html>`
- Set `Content-Type: text/html` and correct `Content-Length` on error responses
- Ensure HEAD requests to missing files still return 404 with headers but no body

**Validation:**
```
curl -i http://localhost:8080/nope.html
```
Should return:
```
HTTP/1.1 404 Not Found
Content-Type: text/html
Content-Length: 65
...

<!DOCTYPE html><html><body><h1>404 Not Found</h1></body></html>
```

### Q11 (5 pts): Configurable Root Directory

Accept the www root directory as a command-line argument:

Requirements:
- `./webserver <port> <www-root>` — both arguments required
- Validate that `www-root` exists and is a directory; if not, print error to stderr and exit 1
- Validate that `port` is a valid number 1-65535; if not, print error to stderr and exit 1
- Store the canonicalized absolute path of `www-root` for path traversal checks
- Default behavior if no args: port 8080, www root `./www`

**Validation:**
```
./webserver 9090 /tmp/testsite    → serves from /tmp/testsite on port 9090
./webserver 8080 /nonexistent     → error: directory does not exist
./webserver abc ./www             → error: invalid port number
./webserver                       → defaults to port 8080, ./www
```

### Q12 (5 pts): Access Logging

Log each request to stdout in Common Log Format:

Requirements:
- Format: `<client_ip> - - [<date>] "<method> <path> <version>" <status_code> <body_size>`
- Date format: `[19/Feb/2025:14:30:00 +0000]`
- `body_size` is the Content-Length of the response body (0 for HEAD, error body size for errors)
- Log AFTER the response is sent
- Each log line ends with `\n`
- Use a mutex to prevent interleaved log output from concurrent threads

**Validation:**
Run several requests, stdout should show:
```
127.0.0.1 - - [19/Feb/2025:14:30:00 +0000] "GET /index.html HTTP/1.1" 200 142
127.0.0.1 - - [19/Feb/2025:14:30:01 +0000] "GET /nope.html HTTP/1.1" 404 65
127.0.0.1 - - [19/Feb/2025:14:30:02 +0000] "HEAD /index.html HTTP/1.1" 200 0
127.0.0.1 - - [19/Feb/2025:14:30:03 +0000] "GET /../etc/passwd HTTP/1.1" 403 67
```
