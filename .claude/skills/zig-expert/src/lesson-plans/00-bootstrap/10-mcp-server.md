# Quiz 16: Build Your Own MCP Server

Implement a Model Context Protocol (MCP) server in Zig 0.15.2 that exposes tools, resources, and prompts to AI clients over stdio.

**Total: 60 points (12 questions x 5 points)**

## Background: Model Context Protocol

### What is MCP?

MCP (Model Context Protocol) is an open standard for connecting AI applications to external data sources and tools. It uses JSON-RPC 2.0 over stdio (or HTTP), enabling AI agents to discover and invoke tools, read resources, and use prompt templates.

```
AI Host (Claude, etc.)              MCP Server
┌─────────────────┐  JSON-RPC/stdio  ┌──────────────┐
│  Client         │ ◄───────────────► │  ccmcp       │
│  (sends requests│   newline-delim   │  (your Zig   │
│   to server)    │   JSON messages   │   program)   │
└─────────────────┘                   └──────────────┘
```

### Transport: Newline-Delimited JSON over stdio

**Critical difference from LSP:** MCP uses **newline-delimited JSON** over stdio, NOT `Content-Length` headers.

**Rules:**
- Each message is a single line of JSON followed by a newline (`\n`)
- Messages **MUST NOT** contain embedded newlines
- The server reads JSON-RPC messages from `stdin` and writes to `stdout`
- The server **MAY** write UTF-8 log text to `stderr`
- The server **MUST NOT** write anything to `stdout` that is not a valid MCP message

**Reading a message:** Read one line from stdin, parse as JSON.

**Writing a message:** Serialize JSON (no embedded newlines), write to stdout, followed by `\n`.

### JSON-RPC 2.0

Three message types (same as LSP):

**Request** (has `id` + `method`):
```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}
```

**Response** (has `id` + `result` or `error`):
```json
{"jsonrpc":"2.0","id":1,"result":{...}}
```

**Notification** (has `method`, no `id`):
```json
{"jsonrpc":"2.0","method":"notifications/initialized"}
```

**Error response:**
```json
{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}
```

### Lifecycle

```
Client                              Server
  │                                    │
  │──── initialize ───────────────────►│
  │◄─── initialize result ────────────│
  │──── notifications/initialized ────►│  (notification)
  │                                    │
  │──── tools/list ───────────────────►│
  │◄─── tools list result ────────────│
  │──── tools/call ───────────────────►│
  │◄─── tool result ──────────────────│
  │                                    │
  │──── (close stdin) ────────────────►│  (server exits)
```

### Initialize Handshake

**Client sends:**
```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{"roots":{"listChanged":true}},"clientInfo":{"name":"TestClient","version":"1.0.0"}}}
```

**Server responds:**
```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-03-26","capabilities":{"tools":{"listChanged":true},"resources":{"subscribe":false,"listChanged":true},"prompts":{"listChanged":true},"logging":{}},"serverInfo":{"name":"ccmcp","version":"0.1.0"}}}
```

**Client sends initialized notification:**
```json
{"jsonrpc":"2.0","method":"notifications/initialized"}
```

**Key fields:**
- `protocolVersion`: Must be `"2025-03-26"` (current revision)
- `capabilities`: Declares what the server supports (tools, resources, prompts, logging)
- `serverInfo`: Name and version of the server

### Tools

Tools are functions the AI model can call. Three operations:

**tools/list** — discover available tools:
```json
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
```
Response:
```json
{"jsonrpc":"2.0","id":2,"result":{"tools":[{"name":"hello","description":"Say hello to someone","inputSchema":{"type":"object","properties":{"name":{"type":"string","description":"Name to greet"}},"required":["name"]}}]}}
```

**tools/call** — invoke a tool:
```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"hello","arguments":{"name":"World"}}}
```
Response:
```json
{"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":"Hello, World!"}],"isError":false}}
```

**Tool definition fields:**
- `name`: Unique identifier
- `description`: Human-readable description
- `inputSchema`: JSON Schema defining expected parameters

**Tool result content types:**
- `{"type":"text","text":"..."}` — text content
- `{"type":"image","data":"base64...","mimeType":"image/png"}` — image
- `{"type":"resource","resource":{"uri":"...","mimeType":"...","text":"..."}}` — embedded resource

**`isError`:** `true` if the tool execution failed (distinct from JSON-RPC protocol errors).

### Resources

Resources are data the server exposes for context:

**resources/list:**
```json
{"jsonrpc":"2.0","id":4,"method":"resources/list"}
```
Response:
```json
{"jsonrpc":"2.0","id":4,"result":{"resources":[{"uri":"file:///config.json","name":"config.json","description":"Application configuration","mimeType":"application/json"}]}}
```

**resources/read:**
```json
{"jsonrpc":"2.0","id":5,"method":"resources/read","params":{"uri":"file:///config.json"}}
```
Response:
```json
{"jsonrpc":"2.0","id":5,"result":{"contents":[{"uri":"file:///config.json","mimeType":"application/json","text":"{\"key\":\"value\"}"}]}}
```

### Prompts

Prompts are templated message sequences:

**prompts/list:**
```json
{"jsonrpc":"2.0","id":6,"method":"prompts/list"}
```
Response:
```json
{"jsonrpc":"2.0","id":6,"result":{"prompts":[{"name":"code_review","description":"Review code quality","arguments":[{"name":"code","description":"Code to review","required":true}]}]}}
```

**prompts/get:**
```json
{"jsonrpc":"2.0","id":7,"method":"prompts/get","params":{"name":"code_review","arguments":{"code":"fn main() {}"}}}
```
Response:
```json
{"jsonrpc":"2.0","id":7,"result":{"description":"Code review prompt","messages":[{"role":"user","content":{"type":"text","text":"Please review this code:\nfn main() {}"}}]}}
```

### Logging

Server can send log notifications to client:
```json
{"jsonrpc":"2.0","method":"notifications/message","params":{"level":"info","logger":"ccmcp","data":"Processing request..."}}
```
Levels: `debug`, `info`, `notice`, `warning`, `error`, `critical`, `alert`, `emergency`

### Error Codes

| Code | Meaning |
|------|---------|
| -32700 | Parse error (invalid JSON) |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |

### Zig Reference (0.15.2)

```zig
const std = @import("std");

// --- Newline-delimited I/O (MCP stdio transport) ---
const stdin = std.fs.File.stdin();
const stdin_reader = stdin.reader();

// Read one JSON message (one line)
var buf: [65536]u8 = undefined;
const line = (try stdin_reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
// line contains the JSON without the trailing \n

// Write one JSON message
var out_buf: [65536]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&out_buf);
const stdout = &out_writer.interface;
try stdout.writeAll(json_bytes);
try stdout.writeAll("\n");
try stdout.flush();

// --- JSON ---
// Parse dynamic value
const parsed = try std.json.parseFromSlice(
    std.json.Value, allocator, json_bytes, .{},
);
defer parsed.deinit();
const root = parsed.value.object;
const method = root.get("method").?.string;

// Build JSON objects
var obj = std.json.ObjectMap.init(allocator);
try obj.put("jsonrpc", .{ .string = "2.0" });
try obj.put("id", .{ .integer = request_id });

// Serialize
const json_str = try std.fmt.allocPrint(
    allocator, "{f}", .{std.json.fmt(
        std.json.Value{ .object = obj }, .{},
    )},
);

// --- HashMap for state ---
var tools = std.StringHashMap(Tool).init(allocator);
defer tools.deinit();

// --- String operations ---
if (std.mem.eql(u8, method, "tools/list")) { ... }
if (std.mem.startsWith(u8, method, "notifications/")) { ... }

// --- Child process (for testing) ---
var child = std.process.Child.init(.{
    .argv = &.{"./zig-out/bin/ccmcp"},
    .stdin_behavior = .pipe,
    .stdout_behavior = .pipe,
    .stderr_behavior = .pipe,
});
try child.spawn();
// Write to child.stdin.?, read from child.stdout.?
```

### Testing

Test by piping newline-delimited JSON messages:

```bash
# Initialize + list tools + call tool + close
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}\n{"jsonrpc":"2.0","method":"notifications/initialized"}\n{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"hello","arguments":{"name":"World"}}}\n' | ./ccmcp
```

Or use the **MCP Inspector** (`npx @anthropic-ai/mcp-inspector`) for interactive testing.

---

## Questions

### Q1 (5 pts): Newline-Delimited JSON Transport

Implement the MCP stdio transport layer:

Requirements:
- `readMessage(reader) → !?[]u8` — read one line from stdin, return JSON bytes (null on EOF)
- `writeMessage(writer, json: []const u8) → !void` — write JSON + `\n` to stdout, flush
- Messages must not contain embedded newlines
- Handle lines longer than buffer gracefully (return error, not crash)
- All non-protocol output goes to stderr only

Write Zig tests:
- Round-trip: write a message, read it back → identical
- Multiple messages in sequence
- Empty line → handle gracefully (skip or error)
- EOF → returns null

**Validation:**
```zig
test "transport round trip" {
    var buf: [4096]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    const msg = "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"test\"}";
    try writeMessage(fbs.writer(), msg);

    fbs.pos = 0;
    const result = try readMessage(fbs.reader());
    try testing.expectEqualStrings(msg, result.?);
}
```

### Q2 (5 pts): JSON-RPC Message Handling

Implement JSON-RPC request/response/notification dispatch:

Requirements:
- Parse incoming JSON to determine message type:
  - Has `id` + `method` → Request (needs response)
  - Has `method`, no `id` → Notification (no response)
- `formatResult(allocator, id: i64, result: std.json.Value) → ![]u8` — format success response
- `formatError(allocator, id: i64, code: i32, message: []const u8) → ![]u8` — format error response
- Every response must include `"jsonrpc":"2.0"` and matching `id`
- Handle non-integer ids (string ids are valid per JSON-RPC spec)

Write Zig tests:
- Parse request → extract id, method, params
- Parse notification → has method, no id
- Format result → valid JSON with correct id
- Format error → valid JSON with error code and message
- Non-integer id (string) → preserved in response

**Validation:**
```zig
test "format error response" {
    const err = try formatError(allocator, 1, -32601, "Method not found");
    defer allocator.free(err);
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, err, .{});
    defer parsed.deinit();
    const error_obj = parsed.value.object.get("error").?.object;
    try testing.expectEqual(@as(i64, -32601), error_obj.get("code").?.integer);
}
```

### Q3 (5 pts): Initialize Handshake

Implement the MCP initialization flow:

Requirements:
- On `initialize` request:
  - Check `params.protocolVersion` — if unsupported, return error
  - Respond with server capabilities and info:
    - `protocolVersion: "2025-03-26"`
    - `capabilities: { tools: {}, resources: {}, prompts: {} }`
    - `serverInfo: { name: "ccmcp", version: "0.1.0" }`
  - Set internal state to "initializing"
- On `notifications/initialized`: set state to "ready"
- Before initialization, respond to all requests (except `initialize`) with error -32002
- After initialization, reject duplicate `initialize` requests

Write Zig tests:
- Initialize → returns correct capabilities JSON
- Request before initialize → error -32002
- Initialized notification → state transitions to ready
- Second initialize → error

**Validation:**
```bash
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}\n' | ./ccmcp 2>/dev/null
# Should output one line: {"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-03-26",...}}
```

### Q4 (5 pts): Tool Registration and Listing

Implement tool registration and the `tools/list` handler:

Requirements:
- Define a `ToolDef` struct: `name`, `description`, `input_schema` (as JSON string or structured)
- Register tools at startup (before serving):
  - `hello`: Takes `name: string`, returns `"Hello, <name>!"`
  - `add`: Takes `a: number, b: number`, returns sum as string
  - `echo`: Takes `message: string`, returns the message back
- On `tools/list` request: return all registered tools with their input schemas
- Input schemas must be valid JSON Schema (type, properties, required, descriptions)

Write Zig tests:
- Register 3 tools → list returns all 3
- Each tool has name, description, inputSchema
- inputSchema has correct type/properties/required fields

**Validation:**
```bash
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}\n{"jsonrpc":"2.0","method":"notifications/initialized"}\n{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n' | ./ccmcp 2>/dev/null
# Second output line should contain tools array with hello, add, echo
```

### Q5 (5 pts): Tool Execution

Implement `tools/call` to invoke registered tools:

Requirements:
- On `tools/call` with `params.name` and `params.arguments`:
  - Look up tool by name
  - Validate arguments against input schema (check required fields)
  - Execute the tool function
  - Return `{ content: [{ type: "text", text: "..." }], isError: false }`
- Unknown tool → JSON-RPC error -32602: `"Unknown tool: <name>"`
- Missing required argument → tool result with `isError: true` and descriptive message
- Tool execution error → result with `isError: true` (NOT a JSON-RPC error)

Write Zig tests:
- Call `hello` with `{"name":"World"}` → `"Hello, World!"`
- Call `add` with `{"a":2,"b":3}` → `"5"`
- Call unknown tool → error -32602
- Call `hello` without `name` → isError: true

**Validation:**
```bash
printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}\n{"jsonrpc":"2.0","method":"notifications/initialized"}\n{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"hello","arguments":{"name":"World"}}}\n' | ./ccmcp 2>/dev/null
# Should include: "Hello, World!"
```

### Q6 (5 pts): File System Tools

Add tools that interact with the filesystem:

Requirements:
- `read_file`: Takes `path: string`, returns file contents as text
  - Return `isError: true` if file not found
  - Limit to 1MB reads
- `write_file`: Takes `path: string, content: string`, writes content to file
  - Return success message with bytes written
- `list_directory`: Takes `path: string`, returns directory listing
  - One entry per line: `<type> <name>` where type is `F` (file) or `D` (directory)
  - Return `isError: true` if directory not found
- All paths are relative to a configurable root directory (set via CLI arg or env var)
- **Security**: Reject paths containing `..` (path traversal)

Write Zig tests:
- Read existing file → contents match
- Read nonexistent file → isError: true
- Write file → file created, read back matches
- List directory → shows files and subdirectories
- Path traversal (`../etc/passwd`) → rejected with error

**Validation:**
```bash
echo "test content" > /tmp/mcp_test.txt
printf '...initialize...\n...initialized...\n{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"read_file","arguments":{"path":"/tmp/mcp_test.txt"}}}\n' | ./ccmcp 2>/dev/null
# Should return "test content"
```

### Q7 (5 pts): Resources

Implement the resources capability:

Requirements:
- On `resources/list`: return list of available resources
  - Each resource: `uri`, `name`, `description`, `mimeType`
- On `resources/read` with `params.uri`: return resource contents
  - Text content: `{ uri, mimeType, text }`
  - Unknown URI → error -32002 (Resource not found)
- Register at least 3 resources at startup:
  - `config://server` → JSON with server config (name, version, tools count)
  - `stats://usage` → text with request count, uptime, etc.
  - `help://commands` → text listing all available tools and their descriptions
- Resources update dynamically (stats change on each read)

Write Zig tests:
- List resources → returns 3+ items with uri, name, mimeType
- Read `config://server` → valid JSON with server info
- Read `stats://usage` → contains request count
- Read unknown URI → error
- Stats resource updates between reads

**Validation:**
```bash
printf '...init...\n...initialized...\n{"jsonrpc":"2.0","id":2,"method":"resources/list"}\n{"jsonrpc":"2.0","id":3,"method":"resources/read","params":{"uri":"config://server"}}\n' | ./ccmcp 2>/dev/null
```

### Q8 (5 pts): Prompts

Implement the prompts capability:

Requirements:
- On `prompts/list`: return available prompt templates
- On `prompts/get` with `params.name` and `params.arguments`: return expanded messages
- Register prompts:
  - `greet`: arg `name` (required) → `[{role:"user", content:{type:"text", text:"Please greet <name> warmly"}}]`
  - `summarize`: arg `text` (required) → user message asking to summarize the text
  - `code_review`: arg `code` (required), `language` (optional) → user message asking for review
- Unknown prompt → error -32602
- Missing required argument → error -32602
- Arguments are interpolated into the message templates

Write Zig tests:
- List prompts → returns 3 prompts with names and argument lists
- Get `greet` with `{"name":"Alice"}` → message contains "Alice"
- Get `code_review` with code but no language → works (optional arg)
- Get unknown prompt → error
- Missing required arg → error

**Validation:**
```bash
printf '...init...\n...initialized...\n{"jsonrpc":"2.0","id":2,"method":"prompts/get","params":{"name":"greet","arguments":{"name":"Alice"}}}\n' | ./ccmcp 2>/dev/null
# Should contain messages array with "Alice" in text
```

### Q9 (5 pts): Logging and Notifications

Implement server-initiated logging:

Requirements:
- Send `notifications/message` to client for important events:
  - On initialize: `info` — "Server initialized"
  - On tool call: `debug` — "Calling tool: <name>"
  - On error: `error` — descriptive error message
- Log format: `{"jsonrpc":"2.0","method":"notifications/message","params":{"level":"info","logger":"ccmcp","data":"..."}}`
- Levels: `debug`, `info`, `warning`, `error`
- Also write structured logs to stderr for debugging
- `notifications/tools/list_changed` — send when tools are dynamically added/removed

Write Zig tests:
- After initialize, log notification is sent
- After tool call, debug log is sent
- Log notification is valid JSON with correct method and params

**Validation:**
Capture all stdout lines. After initialize + tool call, verify log notifications appear in output (they are interleaved with responses).

### Q10 (5 pts): Dynamic Tool Registration

Add the ability to register tools at runtime:

Requirements:
- New tool: `register_tool` — meta-tool that registers a new tool
  - Input: `name: string`, `description: string`, `template: string`
  - The template is a format string like `"The answer to {question} is 42"`
  - Registered tool uses template interpolation from arguments
  - After registration, send `notifications/tools/list_changed`
- New tool: `unregister_tool` — removes a registered tool by name
  - Cannot unregister built-in tools (hello, add, echo, etc.)
  - After unregistration, send `notifications/tools/list_changed`
- `tools/list` reflects dynamically added/removed tools
- Persist registered tools in memory (no need for disk persistence)

Write Zig tests:
- Register tool → appears in tools/list
- Call registered tool → template interpolation works
- Unregister tool → disappears from tools/list
- Unregister built-in → error
- List changed notification sent after register/unregister

**Validation:**
```bash
# Register a custom tool, then call it
printf '...init...\n...initialized...\n{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"register_tool","arguments":{"name":"greet_formal","description":"Formal greeting","template":"Dear {name}, it is a pleasure to meet you."}}}\n{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"greet_formal","arguments":{"name":"Professor Smith"}}}\n' | ./ccmcp 2>/dev/null
# Should include "Dear Professor Smith, it is a pleasure to meet you."
```

### Q11 (5 pts): Input Validation and Error Handling

Implement robust validation and error handling:

Requirements:
- **JSON parse error** → error -32700 with descriptive message
- **Missing jsonrpc field** → error -32600 (Invalid Request)
- **Unknown method** → error -32601 (Method not found) for requests; silently ignore for notifications
- **Invalid params** → error -32602 with details about what's wrong
- **Tool argument validation**: Check types match inputSchema
  - String argument given number → `isError: true` with message
  - Number argument given string → `isError: true` with message
- **Graceful shutdown**: On EOF (stdin closes), exit cleanly with code 0
- **Handle rapid messages**: Process multiple messages without losing any
- **Oversized messages**: Lines > 1MB → error -32600

Write Zig tests:
- Invalid JSON → -32700
- Missing method → -32600
- Unknown method request → -32601
- Unknown notification → silently ignored
- Wrong argument type → isError: true
- EOF → clean shutdown (no crash)

**Validation:**
```bash
printf 'not valid json\n{"jsonrpc":"2.0","id":1,"method":"unknown_method"}\n' | ./ccmcp 2>/dev/null
# First response: parse error (-32700)
# Second response: method not found (-32601)
```

### Q12 (5 pts): End-to-End Test Harness

Write a comprehensive test client that validates the full MCP server:

Requirements:
- Spawn `./ccmcp` as a child process
- Implement `McpClient` helper:
  - `sendRequest(method, params) → response` — send request, read response, match id
  - `sendNotification(method, params)` — send notification (no response)
  - `readNotification() → ?notification` — read any pending server notifications
- Run full test scenario:
  1. Send `initialize` → verify protocolVersion and capabilities
  2. Send `notifications/initialized`
  3. Send `tools/list` → verify hello, add, echo tools
  4. Call `hello` with `{"name":"MCP"}` → verify `"Hello, MCP!"`
  5. Call `add` with `{"a":10,"b":32}` → verify `"42"`
  6. Call unknown tool → verify error
  7. Send `resources/list` → verify resources
  8. Send `resources/read` for config → verify JSON content
  9. Send `prompts/list` → verify prompts
  10. Send `prompts/get` for greet → verify message
  11. Send invalid JSON → verify -32700 error
  12. Close stdin → verify server exits cleanly

Write as a Zig test runnable with `zig build test`.

**Validation:**
```zig
test "end-to-end MCP session" {
    var child = std.process.Child.init(.{
        .argv = &.{"./zig-out/bin/ccmcp"},
        .stdin_behavior = .pipe,
        .stdout_behavior = .pipe,
        .stderr_behavior = .pipe,
    });
    try child.spawn();
    defer _ = child.wait() catch {};

    const writer = child.stdin.?.writer();
    const reader = child.stdout.?.reader();

    // 1. Initialize
    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0\"}}}\n");
    var buf: [65536]u8 = undefined;
    const resp = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    // Verify response contains protocolVersion
    try testing.expect(std.mem.indexOf(u8, resp, "2025-03-26") != null);

    // 2. Initialized
    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}\n");

    // 3. tools/list
    try writer.writeAll("{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\"}\n");
    const tools_resp = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    try testing.expect(std.mem.indexOf(u8, tools_resp, "hello") != null);

    // ... continue with all 12 steps ...
}
```
