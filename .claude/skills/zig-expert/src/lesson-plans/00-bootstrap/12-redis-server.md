# Quiz 17: Build Your Own Redis Server

Implement a Redis-compatible server in Zig 0.15.2 that speaks the RESP (Redis Serialization Protocol) over TCP.

**Total: 60 points (12 questions x 5 points)**

## Background: Redis and RESP

### What is Redis?

Redis is an in-memory key-value data store that supports strings, lists, sets, hashes, and more. It listens on TCP port 6379 and uses a simple text-based protocol called RESP (REdis Serialization Protocol).

```
Client                          Redis Server
┌─────────┐   RESP over TCP    ┌──────────────┐
│  redis-  │ ◄───────────────► │  ccredis     │
│  cli     │   port 6379       │  (your Zig   │
│          │                   │   program)   │
└─────────┘                   └──────────────┘
```

### RESP2 Protocol

All communication uses RESP2. Each data type starts with a type byte, and all lines end with `\r\n` (CRLF).

**Data Types:**

| Type | First Byte | Format | Example |
|------|-----------|--------|---------|
| Simple String | `+` | `+OK\r\n` | Success responses |
| Error | `-` | `-ERR message\r\n` | Error responses |
| Integer | `:` | `:42\r\n` | Numeric responses |
| Bulk String | `$` | `$5\r\nHello\r\n` | Binary-safe strings |
| Array | `*` | `*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n` | Command arguments |
| Null Bulk String | `$` | `$-1\r\n` | Key not found (nil) |
| Null Array | `*` | `*-1\r\n` | Absent list |

**Bulk String format:**
```
$<length>\r\n<data>\r\n
```
The length is the byte count of `<data>`, NOT including the trailing `\r\n`.

**Array format:**
```
*<count>\r\n<element1><element2>...
```
Each element is itself a complete RESP value.

**Commands are sent as arrays of bulk strings:**
```
Client sends SET key value:
*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n

Server responds:
+OK\r\n
```

**Inline commands (simple form):**
```
PING\r\n    →  +PONG\r\n
```
Redis also accepts inline commands (space-separated, no RESP framing) for simple usage.

### Command Reference

**Connection:**
- `PING [message]` → `+PONG\r\n` or `$<len>\r\n<message>\r\n`
- `ECHO message` → `$<len>\r\n<message>\r\n`

**String operations:**
- `SET key value [EX seconds] [PX milliseconds] [NX|XX]` → `+OK\r\n` or `$-1\r\n`
  - `EX seconds` — expire in N seconds
  - `PX milliseconds` — expire in N milliseconds
  - `NX` — only set if key does NOT exist
  - `XX` — only set if key DOES exist
- `GET key` → `$<len>\r\n<value>\r\n` or `$-1\r\n` (nil if missing/expired)
- `APPEND key value` → `:<new_length>\r\n`
- `STRLEN key` → `:<length>\r\n` (0 if key missing)
- `INCR key` → `:<new_value>\r\n` or `-ERR value is not an integer...\r\n`
- `DECR key` → `:<new_value>\r\n`
- `INCRBY key increment` → `:<new_value>\r\n`
- `DECRBY key decrement` → `:<new_value>\r\n`

**Key operations:**
- `EXISTS key [key ...]` → `:<count>\r\n` (number of keys that exist)
- `DEL key [key ...]` → `:<count>\r\n` (number of keys deleted)
- `TTL key` → `:<seconds>\r\n` (-2 if missing, -1 if no expiry)
- `PTTL key` → `:<milliseconds>\r\n` (-2 if missing, -1 if no expiry)
- `PERSIST key` → `:1\r\n` (expiry removed) or `:0\r\n` (key missing or no expiry)

**List operations:**
- `LPUSH key value [value ...]` → `:<list_length>\r\n`
- `RPUSH key value [value ...]` → `:<list_length>\r\n`
- `LPOP key` → bulk string or `$-1\r\n`
- `RPOP key` → bulk string or `$-1\r\n`
- `LLEN key` → `:<length>\r\n`
- `LRANGE key start stop` → array of bulk strings (inclusive range, supports negative indices)

**Server:**
- `SAVE` → `+OK\r\n` (trigger RDB snapshot)
- `CONFIG GET parameter` → array of [name, value] pairs
- `CONFIG SET parameter value` → `+OK\r\n`

### Zig 0.15.2 Networking Reference

**TCP Server:**
```zig
const std = @import("std");

// Create a TCP server
const address = std.net.Address.parseIp4("127.0.0.1", 6379) catch unreachable;
var server = try address.listen(.{
    .reuse_address = true,
});
defer server.deinit();

// Accept a connection
const conn = try server.accept();
defer conn.stream.close();

// Read from client
var buf: [4096]u8 = undefined;
const n = try conn.stream.read(&buf);
const data = buf[0..n];

// Write to client
try conn.stream.writeAll("+OK\r\n");
```

**Buffered I/O for line reading:**
```zig
var buf_reader = std.io.bufferedReader(conn.stream.reader());
const reader = buf_reader.reader();

var line_buf: [512]u8 = undefined;
const line = try reader.readUntilDelimiterOrEof(&line_buf, '\n');
// line includes everything up to (not including) '\n'
// For RESP, trim '\r' with std.mem.trimRight(u8, line, "\r")
```

**Thread spawning:**
```zig
const thread = try std.Thread.spawn(.{}, handleClient, .{conn});
thread.detach();
```

**HashMap for storage:**
```zig
var map = std.StringHashMap([]const u8).init(allocator);
defer map.deinit();
try map.put("key", "value");
const val = map.get("key"); // returns ?[]const u8
_ = map.remove("key"); // returns bool
```

**Mutex for thread safety:**
```zig
var mutex: std.Thread.Mutex = .{};
mutex.lock();
defer mutex.unlock();
```

**Timestamp:**
```zig
const ts = std.time.milliTimestamp(); // returns i64, milliseconds since epoch
```

**Integer parsing:**
```zig
const num = std.fmt.parseInt(i64, string, 10) catch {
    // not a valid integer
};
```

**Integer formatting:**
```zig
var buf: [20]u8 = undefined;
const str = std.fmt.bufPrint(&buf, ":{d}\r\n", .{value}) catch unreachable;
```

**ArrayList for lists:**
```zig
var list: std.ArrayList([]const u8) = .empty;
defer list.deinit(allocator);
try list.append(allocator, "value");
try list.insert(allocator, 0, "prepend"); // LPUSH = insert at 0
const item = list.orderedRemove(0); // LPOP = remove from front
const item2 = list.pop(); // RPOP = remove from back
```

### Testing with redis-cli

```bash
# Connect to your server
redis-cli -p 6379

# Or send a single command
redis-cli -p 6379 PING
redis-cli -p 6379 SET foo bar
redis-cli -p 6379 GET foo

# Or pipe raw RESP
printf '*1\r\n$4\r\nPING\r\n' | nc localhost 6379
```

---

## Questions

### Q1: RESP Serializer and Deserializer (5 points)

**Build a RESP protocol codec** — a serializer and deserializer for the RESP2 protocol.

**Requirements:**

1. Define a tagged union representing RESP values:
   ```zig
   const RespValue = union(enum) {
       simple_string: []const u8,  // +OK\r\n
       err: []const u8,            // -ERR message\r\n
       integer: i64,               // :42\r\n
       bulk_string: ?[]const u8,   // $5\r\nHello\r\n or $-1\r\n (null)
       array: ?[]RespValue,        // *N\r\n... or *-1\r\n (null)
   };
   ```

2. **Deserializer** — `fn parseResp(data: []const u8) !struct { value: RespValue, bytes_consumed: usize }`:
   - Parse one complete RESP value from a byte buffer
   - Return the parsed value and how many bytes were consumed
   - Handle all 5 types (simple string, error, integer, bulk string, array)
   - Handle null bulk string (`$-1`) and null array (`*-1`)
   - Return error if data is incomplete or malformed

3. **Serializer** — `fn writeResp(writer: anytype, value: RespValue) !void`:
   - Serialize a `RespValue` to a writer in RESP format
   - Handle all types including null bulk string and null array

**Test cases:**
- Parse `+OK\r\n` → `.{ .simple_string = "OK" }`
- Parse `-ERR unknown\r\n` → `.{ .err = "ERR unknown" }`
- Parse `:42\r\n` → `.{ .integer = 42 }`
- Parse `:-1\r\n` → `.{ .integer = -1 }` (this is NOT null — it's the integer -1)
- Parse `$5\r\nHello\r\n` → `.{ .bulk_string = "Hello" }`
- Parse `$-1\r\n` → `.{ .bulk_string = null }`
- Parse `$0\r\n\r\n` → `.{ .bulk_string = "" }` (empty string, NOT null)
- Parse `*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n` → array of two bulk strings
- Parse `*-1\r\n` → `.{ .array = null }`
- Parse `*0\r\n` → `.{ .array = &.{} }` (empty array, NOT null)
- Round-trip: serialize then parse should yield same value

**Validation:** `zig test` — all parsing and serialization tests pass.

---

### Q2: TCP Server and PING/ECHO (5 points)

**Create a TCP server** that listens on a configurable port and handles PING and ECHO commands.

**Requirements:**

1. Accept a port number from command-line args (default 6379):
   ```
   ./ccredis --port 6380
   ```

2. Listen for TCP connections and parse incoming RESP commands

3. Handle both **RESP-framed** and **inline** commands:
   - RESP: `*1\r\n$4\r\nPING\r\n`
   - Inline: `PING\r\n`

4. Implement commands:
   - `PING` → `+PONG\r\n`
   - `PING message` → `$<len>\r\n<message>\r\n` (bulk string echo)
   - `ECHO message` → `$<len>\r\n<message>\r\n`

5. Commands should be **case-insensitive** (`ping`, `PING`, `Ping` all work)

6. Handle client disconnect gracefully (don't crash)

**Test:**
```bash
# Terminal 1: start server
./ccredis

# Terminal 2: test with redis-cli
redis-cli -p 6379 PING          # → PONG
redis-cli -p 6379 PING hello    # → "hello"
redis-cli -p 6379 ECHO world    # → "world"

# Test inline command
printf "PING\r\n" | nc localhost 6379   # → +PONG\r\n
```

**Validation:** redis-cli returns expected responses for PING and ECHO.

---

### Q3: SET and GET with HashMap Storage (5 points)

**Implement SET and GET** with in-memory key-value storage.

**Requirements:**

1. Use a `StringHashMap` (or similar) for storage

2. `SET key value` → `+OK\r\n`
   - Store the key-value pair
   - Overwriting an existing key is allowed

3. `GET key` → `$<len>\r\n<value>\r\n` or `$-1\r\n`
   - Return the value if key exists
   - Return null bulk string if key does not exist

4. Keys and values are binary-safe (any bytes allowed, use bulk string lengths, not delimiters)

5. Handle memory: keys/values must be copied into owned storage (the client's read buffer will be reused)

**Test:**
```bash
redis-cli -p 6379 SET mykey myvalue     # → OK
redis-cli -p 6379 GET mykey             # → "myvalue"
redis-cli -p 6379 GET nonexistent       # → (nil)
redis-cli -p 6379 SET mykey newvalue    # → OK
redis-cli -p 6379 GET mykey             # → "newvalue"
```

**Validation:** SET stores, GET retrieves, missing keys return nil.

---

### Q4: Concurrent Client Handling (5 points)

**Support multiple simultaneous clients** using threads.

**Requirements:**

1. Spawn a new thread for each accepted client connection

2. All threads share the same data store (HashMap), protected by a `Mutex`

3. Each client has its own read buffer and can send multiple commands per connection (persistent connection — do NOT close after one command)

4. Client disconnect (read returns 0 bytes or error) should clean up the thread without crashing the server

5. Server continues accepting new connections even when existing clients are connected

**Test:**
```bash
# Terminal 1: start server
./ccredis

# Terminal 2: client 1 — stays connected
redis-cli -p 6379
127.0.0.1:6379> SET a 1
OK
127.0.0.1:6379> GET a
"1"

# Terminal 3: client 2 — concurrent
redis-cli -p 6379
127.0.0.1:6379> GET a        # ← sees client 1's data
"1"
127.0.0.1:6379> SET b 2
OK

# Back in Terminal 2:
127.0.0.1:6379> GET b        # ← sees client 2's data
"2"
```

**Validation:** Two concurrent redis-cli sessions can read/write shared data.

---

### Q5: Key Expiration (EX, PX) (5 points)

**Add TTL-based key expiration** to SET.

**Requirements:**

1. Extend SET with options:
   - `SET key value EX seconds` — expire in N seconds
   - `SET key value PX milliseconds` — expire in N milliseconds

2. Store expiry as an absolute millisecond timestamp:
   ```zig
   const expiry_ms: ?i64 = if (ex) |secs|
       std.time.milliTimestamp() + secs * 1000
   else if (px) |ms|
       std.time.milliTimestamp() + ms
   else
       null;
   ```

3. **Lazy expiration**: On GET (and other read commands), check if the key has expired. If `milliTimestamp() >= expiry_ms`, delete the key and return nil.

4. SET without EX/PX removes any existing expiry (key becomes persistent)

5. SET with EX/PX on an existing key replaces both value and expiry

**Test:**
```bash
redis-cli -p 6379 SET temp hello EX 2    # → OK (expires in 2 seconds)
redis-cli -p 6379 GET temp               # → "hello" (immediately)
sleep 3
redis-cli -p 6379 GET temp               # → (nil) (expired)

redis-cli -p 6379 SET temp2 hi PX 500    # → OK (expires in 500ms)
# Wait 1 second
redis-cli -p 6379 GET temp2              # → (nil)
```

**Validation:** Keys with EX/PX return nil after their TTL elapses.

---

### Q6: EXISTS, DEL, INCR/DECR (5 points)

**Implement key existence checks, deletion, and atomic integer operations.**

**Requirements:**

1. `EXISTS key [key ...]` → `:<count>\r\n`
   - Count how many of the specified keys exist
   - Same key listed twice counts twice if it exists

2. `DEL key [key ...]` → `:<count>\r\n`
   - Delete specified keys, return count of keys that were actually deleted
   - Free the memory for deleted key-value pairs

3. `INCR key` → `:<new_value>\r\n`
   - If key doesn't exist, treat as 0 then increment → `:1\r\n`
   - If key exists and value is a valid integer string, increment by 1
   - If value is not a valid integer, return: `-ERR value is not an integer or out of range\r\n`

4. `DECR key` → `:<new_value>\r\n` (same rules, decrement by 1)

5. `INCRBY key increment` → `:<new_value>\r\n`
   - Same as INCR but by specified amount

6. `DECRBY key decrement` → `:<new_value>\r\n`

**Test:**
```bash
redis-cli -p 6379 SET key1 hello
redis-cli -p 6379 SET key2 world
redis-cli -p 6379 EXISTS key1            # → (integer) 1
redis-cli -p 6379 EXISTS key1 key2 key3  # → (integer) 2
redis-cli -p 6379 DEL key1              # → (integer) 1
redis-cli -p 6379 EXISTS key1            # → (integer) 0

redis-cli -p 6379 SET counter 10
redis-cli -p 6379 INCR counter           # → (integer) 11
redis-cli -p 6379 DECR counter           # → (integer) 10
redis-cli -p 6379 INCRBY counter 5       # → (integer) 15
redis-cli -p 6379 INCR newkey            # → (integer) 1 (auto-creates)
redis-cli -p 6379 SET text hello
redis-cli -p 6379 INCR text              # → ERR value is not an integer...
```

**Validation:** EXISTS counts correctly, DEL removes keys, INCR/DECR handle integer strings and auto-creation.

---

### Q7: List Operations (5 points)

**Implement Redis list commands** using `ArrayList` as the backing store.

**Requirements:**

1. Each key can hold either a string or a list — they're different types:
   - Using a list command on a string key → `-WRONGTYPE Operation against a key holding the wrong kind of value\r\n`

2. Store type information with each value (tagged union recommended):
   ```zig
   const Value = union(enum) {
       string: []const u8,
       list: std.ArrayList([]const u8),
   };
   ```

3. Implement:
   - `LPUSH key value [value ...]` → `:<length>\r\n` — prepend values (multiple values added left-to-right, so `LPUSH k a b c` results in `[c, b, a]`)
   - `RPUSH key value [value ...]` → `:<length>\r\n` — append values
   - `LPOP key` → bulk string or `$-1\r\n` — remove and return first element
   - `RPOP key` → bulk string or `$-1\r\n` — remove and return last element
   - `LLEN key` → `:<length>\r\n` — return list length (0 if key missing)
   - `LRANGE key start stop` → array of bulk strings
     - Indices are 0-based, inclusive on both ends
     - Negative indices count from end (-1 = last, -2 = second-to-last)
     - Out-of-range indices are clamped (not errors)
     - `LRANGE key 0 -1` returns entire list

4. Auto-create list on first LPUSH/RPUSH to nonexistent key

5. If list becomes empty after LPOP/RPOP, delete the key

**Test:**
```bash
redis-cli -p 6379 RPUSH mylist a b c     # → (integer) 3
redis-cli -p 6379 LRANGE mylist 0 -1     # → 1) "a"  2) "b"  3) "c"
redis-cli -p 6379 LPUSH mylist z         # → (integer) 4
redis-cli -p 6379 LRANGE mylist 0 -1     # → 1) "z"  2) "a"  3) "b"  4) "c"
redis-cli -p 6379 LPOP mylist            # → "z"
redis-cli -p 6379 RPOP mylist            # → "c"
redis-cli -p 6379 LLEN mylist            # → (integer) 2
redis-cli -p 6379 LRANGE mylist 0 0      # → 1) "a"
redis-cli -p 6379 SET str hello
redis-cli -p 6379 LPUSH str x            # → WRONGTYPE error
```

**Validation:** List push/pop/range work correctly, WRONGTYPE error on type mismatch.

---

### Q8: TTL, PTTL, PERSIST (5 points)

**Add TTL inspection and removal commands.**

**Requirements:**

1. `TTL key` → `:<seconds>\r\n`
   - Returns remaining time-to-live in seconds
   - Returns `-2` if key does not exist
   - Returns `-1` if key exists but has no expiry

2. `PTTL key` → `:<milliseconds>\r\n`
   - Same as TTL but millisecond precision

3. `PERSIST key` → `:1\r\n` or `:0\r\n`
   - Remove the expiry from a key, making it persistent
   - Returns 1 if expiry was removed
   - Returns 0 if key doesn't exist or has no expiry

4. For TTL, convert milliseconds to seconds by integer division (truncate, don't round):
   ```zig
   const ttl_secs = @divTrunc(remaining_ms, 1000);
   ```

5. Expired keys should be lazily cleaned up (check expiry on access)

**Test:**
```bash
redis-cli -p 6379 SET mykey hello EX 100
redis-cli -p 6379 TTL mykey              # → (integer) ~100
redis-cli -p 6379 PTTL mykey             # → (integer) ~100000
redis-cli -p 6379 PERSIST mykey          # → (integer) 1
redis-cli -p 6379 TTL mykey              # → (integer) -1
redis-cli -p 6379 TTL nonexistent        # → (integer) -2
redis-cli -p 6379 PERSIST nonexistent    # → (integer) 0
```

**Validation:** TTL/PTTL return correct remaining time; PERSIST removes expiry.

---

### Q9: APPEND, STRLEN, NX/XX Flags (5 points)

**Implement string append, length, and conditional SET flags.**

**Requirements:**

1. `APPEND key value` → `:<new_length>\r\n`
   - If key exists (and is a string), append value to existing value
   - If key doesn't exist, equivalent to SET key value
   - Return the length of the new string

2. `STRLEN key` → `:<length>\r\n`
   - Return the length of the string stored at key
   - Return 0 if key doesn't exist

3. Extend SET with `NX` and `XX` flags:
   - `SET key value NX` — only set if key does **not** exist. Return `$-1\r\n` if key already exists.
   - `SET key value XX` — only set if key **does** exist. Return `$-1\r\n` if key doesn't exist.
   - NX/XX can combine with EX/PX: `SET key value EX 10 NX`

4. Parse all SET options in any order: `SET key val NX EX 10` and `SET key val EX 10 NX` both work.

**Test:**
```bash
redis-cli -p 6379 SET mykey "Hello"
redis-cli -p 6379 APPEND mykey " World"   # → (integer) 11
redis-cli -p 6379 GET mykey               # → "Hello World"
redis-cli -p 6379 STRLEN mykey            # → (integer) 11
redis-cli -p 6379 STRLEN nonexistent      # → (integer) 0

redis-cli -p 6379 SET nx_key val NX       # → OK (key didn't exist)
redis-cli -p 6379 SET nx_key val2 NX      # → (nil) (key exists)
redis-cli -p 6379 GET nx_key              # → "val" (unchanged)

redis-cli -p 6379 SET xx_key val XX       # → (nil) (key doesn't exist)
redis-cli -p 6379 SET nx_key val2 XX      # → OK (key exists)
redis-cli -p 6379 GET nx_key              # → "val2" (updated)
```

**Validation:** APPEND concatenates, STRLEN returns length, NX/XX gate SET correctly.

---

### Q10: RDB Persistence with SAVE (5 points)

**Implement basic persistence** so data survives server restarts.

**Requirements:**

1. `SAVE` command triggers a synchronous snapshot to disk → `+OK\r\n`

2. Use a simple binary format for the dump file (e.g., `dump.rdb`):
   - For each key-value pair, write:
     - Type tag: 1 byte (0 = string, 1 = list)
     - Key: 4-byte little-endian length + key bytes
     - Value (string): 4-byte little-endian length + value bytes
     - Value (list): 4-byte count, then each element as 4-byte length + bytes
     - Expiry: 1 byte flag (0 = no expiry, 1 = has expiry), if 1: 8-byte little-endian ms timestamp
   - Header: magic bytes `"CCREDIS1"` (8 bytes)
   - Footer: magic bytes `"EOF"` (3 bytes)

3. On server startup, if `dump.rdb` exists, load all key-value pairs into memory

4. Skip expired keys during load (check timestamp against current time)

5. Handle file I/O errors gracefully (missing file on startup = fresh start, write error on SAVE = return error to client)

**Example binary layout:**
```
CCREDIS1                    ← 8-byte header
\x00                        ← type: string
\x03\x00\x00\x00foo        ← key "foo" (length 3)
\x03\x00\x00\x00bar        ← value "bar" (length 3)
\x01                        ← has expiry
\x88\x77\x66\x55\x44\x33\x22\x11  ← expiry timestamp (i64 LE)
EOF                         ← 3-byte footer
```

**Test:**
```bash
redis-cli -p 6379 SET persistent hello
redis-cli -p 6379 SET temp bye EX 1
redis-cli -p 6379 SAVE                   # → OK
# Stop and restart server
redis-cli -p 6379 GET persistent          # → "hello" (survived restart)
# Wait for temp to expire, then restart
redis-cli -p 6379 GET temp               # → (nil) (expired, not loaded)
```

**Validation:** Data persists across server restarts via SAVE and load.

---

### Q11: CONFIG GET/SET and SELECT (5 points)

**Implement server configuration and multi-database support.**

**Requirements:**

1. `CONFIG GET parameter` → array of alternating name-value pairs:
   ```
   CONFIG GET save → *2\r\n$4\r\nsave\r\n$0\r\n\r\n
   ```
   - Support glob patterns: `CONFIG GET *` returns all config
   - Each match produces TWO array elements: [name, value]
   - Unknown parameters return empty array `*0\r\n`

2. `CONFIG SET parameter value` → `+OK\r\n`
   - Support at minimum: `save`, `appendonly`, `dir`, `dbfilename`
   - Store config in a HashMap

3. Implement the `dir` and `dbfilename` config options:
   - `dir` — directory for RDB file (default `.`)
   - `dbfilename` — RDB filename (default `dump.rdb`)
   - SAVE should use `{dir}/{dbfilename}` as the dump path

4. `CONFIG GET` supports glob matching:
   - `CONFIG GET d*` matches `dir`, `dbfilename`
   - Use `std.mem.indexOf` or manual glob matching for `*` wildcards

**Test:**
```bash
redis-cli -p 6379 CONFIG SET dir /tmp
redis-cli -p 6379 CONFIG GET dir          # → 1) "dir" 2) "/tmp"
redis-cli -p 6379 CONFIG SET dbfilename test.rdb
redis-cli -p 6379 CONFIG GET dbfilename   # → 1) "dbfilename" 2) "test.rdb"
redis-cli -p 6379 CONFIG GET d*           # → 1) "dir" 2) "/tmp" 3) "dbfilename" 4) "test.rdb"
redis-cli -p 6379 CONFIG GET nonexistent  # → (empty array)
```

**Validation:** CONFIG GET/SET store and retrieve configuration; glob patterns match.

---

### Q12: Integration Test and Benchmarking (5 points)

**Write a comprehensive integration test and run a benchmark.**

**Requirements:**

1. **Zig integration test** (`test "redis integration"`) that:
   - Starts the server in a background thread
   - Connects as a TCP client
   - Sends raw RESP commands and validates responses byte-for-byte
   - Tests this complete sequence:
     ```
     PING → +PONG\r\n
     SET foo bar → +OK\r\n
     GET foo → $3\r\nbar\r\n
     SET counter 0 → +OK\r\n
     INCR counter → :1\r\n
     INCR counter → :2\r\n
     GET counter → $1\r\n2\r\n
     DEL foo → :1\r\n
     GET foo → $-1\r\n
     RPUSH list a b c → :3\r\n
     LRANGE list 0 -1 → *3\r\n$1\r\na\r\n$1\r\nb\r\n$1\r\nc\r\n
     LPOP list → $1\r\na\r\n
     SET temp hi EX 1 → +OK\r\n
     GET temp → $2\r\nhi\r\n
     (sleep 1.1 seconds)
     GET temp → $-1\r\n
     SET nx new NX → +OK\r\n
     SET nx newer NX → $-1\r\n
     ```

2. **Benchmark** with `redis-benchmark` (if available) or a custom Zig benchmark:
   ```bash
   redis-benchmark -p 6379 -t ping,set,get -n 10000 -c 10
   ```
   - Report throughput (requests/sec) for PING, SET, GET
   - If redis-benchmark is not available, write a Zig client that:
     - Opens 10 concurrent connections
     - Sends 1000 PING commands each
     - Measures total time and reports requests/sec

3. Print benchmark results to stdout

**Validation:** Integration test passes (`zig test`); benchmark completes and reports throughput.

---

## Scoring

Each question is worth 5 points. Deductions:
- Solution does not fully answer the question: -100%
- Each failed compile attempt: -1 point (new mistake) or -2 points (known mistake from skill knowledge base)

**Grade scale:** A: ≥90% | B: ≥80% | C: ≥70% | D: ≥60% | F: <60%
