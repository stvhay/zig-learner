# Quiz 9: HTTP Load Balancer

Build an application-layer (Layer 7) HTTP load balancer in Zig 0.15.2 that distributes requests across backend servers with health checking.

**Total: 60 points (12 questions x 5 points)**

## Test Files

- `backend.py` — Python test backend server. Usage: `python3 backend.py <port> [--name NAME] [--unhealthy]`
  - `GET /` — returns `Hello from <name> on port <port>`
  - `GET /health` — returns 200 (or 503 if `--unhealthy`)
  - `GET /slow` — waits 3 seconds then responds
  - `GET /echo` — returns request headers as JSON

**Standard test setup** (run each in a separate terminal):
```
python3 backend.py 8081 --name backend-A
python3 backend.py 8082 --name backend-B
python3 backend.py 8083 --name backend-C
```

## Background: Load Balancing

A load balancer sits between clients and a pool of backend servers. It accepts client HTTP requests and forwards them to a selected backend, then returns the backend's response to the client. The client talks only to the load balancer.

```
Client ──► Load Balancer ──► Backend A (port 8081)
                         ──► Backend B (port 8082)
                         ──► Backend C (port 8083)
```

### Why Load Balance?
- **Throughput**: Spread work across multiple servers
- **Availability**: If one backend dies, others continue serving
- **Transparency**: Clients see a single endpoint

### Round-Robin Algorithm

The simplest distribution strategy. Maintain a counter; for each request, send to `backends[counter % num_backends]` and increment. With 3 backends and 6 requests:

```
Request 1 → A    Request 4 → A
Request 2 → B    Request 5 → B
Request 3 → C    Request 6 → C
```

### Health Checking

Periodically send `GET /health` to each backend. If the response is `200 OK`, mark healthy. Any other response (or connection failure) marks unhealthy. Only route requests to healthy backends.

### HTTP Proxying Essentials

When forwarding a request, the load balancer must:
1. **Connect** to the selected backend via TCP
2. **Send** the client's request line and headers (may modify `Host`, add `X-Forwarded-For`)
3. **Read** the backend's full response (status line + headers + body)
4. **Forward** the backend's response back to the client

Reading the response requires parsing `Content-Length` or handling `Transfer-Encoding: chunked`. For this quiz, backends always send `Content-Length`.

### Zig TCP Client Connections

To connect to a backend:
```zig
const addr = std.net.Address.parseIp4("127.0.0.1", port);
const stream = try std.net.tcpConnectToAddress(addr);
defer stream.close();
try stream.writeAll(request_bytes);
var buf: [4096]u8 = undefined;
const n = try stream.read(&buf);
// buf[0..n] contains the response
```

---

## Questions

### Q1 (5 pts): TCP Proxy — Forward to One Backend

Write a Zig program that:
- Listens on `127.0.0.1:8080`
- Accepts a TCP connection from a client
- Reads the client's HTTP request (up to 4096 bytes)
- Opens a new TCP connection to a single backend at `127.0.0.1:8081`
- Forwards the entire request to the backend
- Reads the backend's response (up to 4096 bytes)
- Sends the response back to the client
- Closes both connections
- Loops back to accept the next client

**Validation:**
```
# Start backend:  python3 backend.py 8081
# Start LB:       ./lb
curl http://localhost:8080/         → "Hello from server-8081 on port 8081"
curl http://localhost:8080/health   → "OK"
```

### Q2 (5 pts): Log Incoming Requests

Add request logging to stdout for every proxied request:

Requirements:
- Parse the request line from the client's request bytes (method, path, version)
- Log format: `<client_ip>:<client_port> -> <backend>:<backend_port> "<method> <path> <version>" <backend_status>`
- Parse the backend's response to extract the status code (first line: `HTTP/1.0 200 OK`)
- Log AFTER the response is sent to the client

**Validation:**
```
curl http://localhost:8080/
curl http://localhost:8080/health
```
Stdout should show:
```
127.0.0.1:54321 -> 127.0.0.1:8081 "GET / HTTP/1.1" 200
127.0.0.1:54322 -> 127.0.0.1:8081 "GET /health HTTP/1.1" 200
```

### Q3 (5 pts): Concurrent Client Handling

Handle multiple clients simultaneously:

Requirements:
- Spawn a thread per accepted connection using `std.Thread.spawn`
- The accept loop must never block while a client is being served
- Each thread: read request → forward to backend → send response → close → exit
- Handle thread errors gracefully (don't crash the server if one connection fails)

**Validation:**
```
# Slow client holds connection for 3 seconds:
curl http://localhost:8080/slow &
# Fast client should respond immediately:
curl http://localhost:8080/
# Both should succeed without blocking each other
```

### Q4 (5 pts): Round-Robin Across Multiple Backends

Distribute requests across multiple backends using round-robin:

Requirements:
- Accept backend addresses as command-line arguments: `./lb 8080 127.0.0.1:8081 127.0.0.1:8082 127.0.0.1:8083`
  - First argument: listen port
  - Remaining arguments: backend addresses in `host:port` format
- Maintain an atomic counter (`std.atomic.Value(usize)`) for thread-safe round-robin
- Select backend: `backends[counter.fetchAdd(1, .monotonic) % backends.len]`

**Validation:**
```
# Start 3 backends:
python3 backend.py 8081 --name A &
python3 backend.py 8082 --name B &
python3 backend.py 8083 --name C &

# Start LB:
./lb 8080 127.0.0.1:8081 127.0.0.1:8082 127.0.0.1:8083

# Send 6 requests:
for i in $(seq 6); do curl -s http://localhost:8080/; done
```
Expected output (one per line):
```
Hello from A on port 8081
Hello from B on port 8082
Hello from C on port 8083
Hello from A on port 8081
Hello from B on port 8082
Hello from C on port 8083
```

### Q5 (5 pts): Backend Connection Error Handling

Handle backend failures gracefully when forwarding:

Requirements:
- If connecting to the selected backend fails (connection refused), return `502 Bad Gateway` to the client
- Response: `HTTP/1.1 502 Bad Gateway\r\nContent-Type: text/plain\r\nContent-Length: 16\r\nConnection: close\r\n\r\n502 Bad Gateway\n`
- If the backend accepts but returns no data (timeout/crash), return `504 Gateway Timeout`
- Log the error: `ERROR: backend 127.0.0.1:8082 connection failed`
- Do NOT crash the load balancer — continue accepting new connections

**Validation:**
```
# Start only 2 of 3 backends (skip 8082):
python3 backend.py 8081 --name A &
python3 backend.py 8083 --name C &
./lb 8080 127.0.0.1:8081 127.0.0.1:8082 127.0.0.1:8083

# Requests hitting the dead backend get 502:
curl -s http://localhost:8080/    → "Hello from A..."
curl -s http://localhost:8080/    → 502 Bad Gateway
curl -s http://localhost:8080/    → "Hello from C..."
```

### Q6 (5 pts): Health Check — Background Polling

Implement periodic health checks that run independently of request handling:

Requirements:
- Spawn a background thread that runs health checks in a loop
- Every N seconds (configurable, default 10), send `GET /health HTTP/1.1\r\nHost: <backend>\r\n\r\n` to each backend
- Parse the response status code: `200` = healthy, anything else = unhealthy
- If connection fails entirely, mark unhealthy
- Store health status per backend using an array of `std.atomic.Value(bool)` (one per backend)
- Log health transitions: `HEALTH: 127.0.0.1:8082 UP -> DOWN` and `HEALTH: 127.0.0.1:8082 DOWN -> UP`
- Add CLI option for check interval: `./lb 8080 --health-interval 5 127.0.0.1:8081 127.0.0.1:8082`

**Validation:**
```
./lb 8080 --health-interval 5 127.0.0.1:8081 127.0.0.1:8082 127.0.0.1:8083

# Kill backend B (Ctrl+C on its terminal)
# Within 5 seconds, log should show:
HEALTH: 127.0.0.1:8082 UP -> DOWN

# Restart backend B:
python3 backend.py 8082 --name B
# Within 5 seconds:
HEALTH: 127.0.0.1:8082 DOWN -> UP
```

### Q7 (5 pts): Skip Unhealthy Backends in Routing

Integrate health status into the round-robin routing:

Requirements:
- When selecting a backend, skip any marked unhealthy
- If all backends are unhealthy, return `503 Service Unavailable` to client
- The round-robin counter still increments globally, but unhealthy backends are skipped
- Try up to `backends.len` times to find a healthy backend before giving up

**Validation:**
```
# Start 3 backends, kill backend B:
curl -s http://localhost:8080/   → response from A or C (never B)
curl -s http://localhost:8080/   → response from A or C
curl -s http://localhost:8080/   → response from A or C

# Kill all backends:
curl -i http://localhost:8080/   → 503 Service Unavailable

# Restart one backend:
# (after health check interval)
curl -s http://localhost:8080/   → response from restarted backend
```

### Q8 (5 pts): X-Forwarded-For Header

Add proxy headers so backends know the real client IP:

Requirements:
- Add `X-Forwarded-For: <client_ip>` header to the request sent to the backend
- If the client already sent `X-Forwarded-For`, append: `X-Forwarded-For: <existing>, <client_ip>`
- Add `X-Forwarded-Host: <host_header_value>` preserving the client's original Host
- Replace the `Host` header with the backend's address before forwarding

Implementation:
- Parse all client request headers into a buffer
- Insert/modify the required headers
- Reassemble the request before forwarding

**Validation:**
```
curl http://localhost:8080/echo
```
The `/echo` endpoint on the backend returns headers as JSON. The output should include:
```json
{
  "headers": {
    "X-Forwarded-For": "127.0.0.1",
    "X-Forwarded-Host": "localhost:8080",
    "Host": "127.0.0.1:8081"
  }
}
```

### Q9 (5 pts): Read Full HTTP Responses

Handle responses larger than a single read buffer:

Requirements:
- Parse the backend's response headers to find `Content-Length`
- Read exactly `Content-Length` bytes of body (may require multiple `read()` calls)
- Forward the complete response (headers + body) to the client
- Handle responses with no `Content-Length` by reading until the backend closes the connection
- Support responses up to 10 MB

**Validation:**
Create a large test file and serve it via a backend:
```
dd if=/dev/urandom bs=1024 count=1024 | base64 > /tmp/bigfile.txt
python3 -m http.server 8081 --directory /tmp &
./lb 8080 127.0.0.1:8081

# Download through LB and compare:
curl -s http://localhost:8080/bigfile.txt > /tmp/downloaded.txt
diff /tmp/bigfile.txt /tmp/downloaded.txt   → no differences
```

### Q10 (5 pts): Connection Timeouts

Implement timeouts at the proxy level:

Requirements:
- **Connect timeout** (2 seconds): If TCP connection to backend doesn't establish, fail fast
- **Read timeout** (10 seconds): If backend doesn't send a response, return `504 Gateway Timeout`
- Use `std.posix.setsockopt` with `std.posix.SO.RCVTIMEO` to set read timeout on the backend socket
- For connect timeout, use a non-blocking connect or set `SO.SNDTIMEO`
- A timed-out backend should be treated the same as a failed connection for error handling

**Validation:**
```
# Start a backend that responds slowly:
python3 backend.py 8081

# /slow takes 3 seconds — within 10s read timeout, should succeed:
curl http://localhost:8080/slow   → response after 3s

# With a 1-second read timeout (modify for testing), /slow should 504:
# (temporarily set read timeout to 1s to verify)
```

### Q11 (5 pts): Graceful Shutdown

Handle SIGINT/SIGTERM for clean shutdown:

Requirements:
- Register a signal handler for SIGINT (Ctrl+C) and SIGTERM
- On signal: set an atomic `running` flag to false
- The accept loop checks `running` and exits cleanly when false
- Wait for in-flight requests to complete (with a 5-second deadline)
- Close the listening socket
- Stop the health check thread
- Print `Shutting down...` then `Shutdown complete.` to stdout

Implementation hint in Zig:
```zig
// std.posix.sigaction or std.os.linux.sigaction for signal handling
// Or simpler: use a separate thread that blocks on sigwait
```

**Validation:**
```
./lb 8080 127.0.0.1:8081 &
LB_PID=$!
curl http://localhost:8080/       → success
kill -SIGINT $LB_PID
# Should print shutdown messages and exit cleanly
# Should NOT leave orphan threads or zombie processes
```

### Q12 (5 pts): Statistics Endpoint

Add an internal stats endpoint so operators can monitor the load balancer:

Requirements:
- Requests to `GET /__lb/stats` are handled directly by the load balancer (not forwarded)
- Return JSON with:
  ```json
  {
    "uptime_seconds": 142,
    "total_requests": 5037,
    "active_connections": 3,
    "backends": [
      {
        "address": "127.0.0.1:8081",
        "healthy": true,
        "requests_served": 1680,
        "errors": 2,
        "avg_response_ms": 12
      }
    ]
  }
  ```
- Track per-backend: requests served, connection errors, average response time
- Track global: total requests, active connection count (atomic counter incremented on accept, decremented on close), uptime
- Use `std.time.Timer` or `std.time.nanoTimestamp` to measure response times
- Respond with `Content-Type: application/json`

**Validation:**
```
# Send some traffic:
for i in $(seq 100); do curl -s http://localhost:8080/ > /dev/null; done

# Check stats:
curl -s http://localhost:8080/__lb/stats | python3 -m json.tool
```
Should show request counts distributed across backends, health status, and timing data.
