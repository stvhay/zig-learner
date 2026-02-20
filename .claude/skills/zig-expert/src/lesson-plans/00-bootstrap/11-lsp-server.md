# Quiz 15: Build Your Own Language Server (LSP)

Implement a Language Server Protocol server in Zig 0.15.2 that provides diagnostics, completion, and hover for a simple language (Markdown or a custom config format).

**Total: 60 points (12 questions x 5 points)**

## Background: Language Server Protocol

### What is LSP?

The Language Server Protocol (LSP) separates editor intelligence from editors. A **language server** runs as a separate process, communicating with the editor (client) over stdin/stdout using JSON-RPC 2.0.

```
Editor (Client)                    Language Server
┌─────────────┐   JSON-RPC/stdio   ┌──────────────┐
│  VS Code    │ ◄──────────────────► │  cclsp       │
│  Neovim     │   Content-Length    │  (your Zig   │
│  Helix      │   + JSON body      │   program)   │
└─────────────┘                     └──────────────┘
```

### Transport: Header-Delimited Messages

Each message has an HTTP-style header followed by JSON content:

```
Content-Length: 52\r\n
\r\n
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}
```

**Rules:**
- `Content-Length` header is **required** — value is the byte count of the JSON body
- `Content-Type` header is optional (default: `application/vscode-jsonrpc; charset=utf-8`)
- Headers are ASCII, separated by `\r\n`
- A blank line (`\r\n`) separates headers from content
- Content is UTF-8 encoded JSON

**Reading a message:**
1. Read lines until blank line (`\r\n\r\n`)
2. Parse `Content-Length: N` from headers
3. Read exactly N bytes of JSON content

**Writing a message:**
1. Serialize JSON to bytes
2. Write `Content-Length: <byte count>\r\n\r\n`
3. Write JSON bytes

### JSON-RPC 2.0

Three message types:

**Request** (client → server, expects response):
```json
{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {...}}
```

**Response** (server → client, matches request id):
```json
{"jsonrpc": "2.0", "id": 1, "result": {...}}
```
Or on error:
```json
{"jsonrpc": "2.0", "id": 1, "error": {"code": -32601, "message": "Method not found"}}
```

**Notification** (no `id` field, no response expected):
```json
{"jsonrpc": "2.0", "method": "initialized", "params": {}}
```

### Lifecycle

```
Client                          Server
  │                                │
  │──── initialize ───────────────►│
  │◄─── initialize result ────────│
  │──── initialized ──────────────►│  (notification)
  │                                │
  │──── textDocument/didOpen ─────►│  (notification)
  │◄─── textDocument/publishDiag──│  (notification)
  │──── textDocument/completion ──►│  (request)
  │◄─── completion result ────────│
  │                                │
  │──── shutdown ─────────────────►│  (request)
  │◄─── shutdown result ──────────│
  │──── exit ─────────────────────►│  (notification)
  │                                │  (process exits)
```

### Initialize Handshake

**Client sends:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "processId": 1234,
    "rootUri": "file:///workspace",
    "capabilities": {}
  }
}
```

**Server responds:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "capabilities": {
      "textDocumentSync": 1,
      "completionProvider": {},
      "hoverProvider": true,
      "diagnosticProvider": {
        "interFileDependencies": false,
        "workspaceDiagnostics": false
      }
    },
    "serverInfo": {
      "name": "cclsp",
      "version": "0.1.0"
    }
  }
}
```

**`textDocumentSync` values:**
- `0` = None
- `1` = Full (client sends entire document on each change)
- `2` = Incremental (client sends only changes)

Use `1` (Full) for simplicity.

### Document Synchronization

**didOpen** — client opens a file:
```json
{
  "jsonrpc": "2.0",
  "method": "textDocument/didOpen",
  "params": {
    "textDocument": {
      "uri": "file:///path/to/file.md",
      "languageId": "markdown",
      "version": 1,
      "text": "# Hello\n\nThis is content.\n"
    }
  }
}
```

**didChange** — client edits a file (with Full sync):
```json
{
  "jsonrpc": "2.0",
  "method": "textDocument/didChange",
  "params": {
    "textDocument": {
      "uri": "file:///path/to/file.md",
      "version": 2
    },
    "contentChanges": [
      { "text": "# Hello\n\nThis is updated content.\n" }
    ]
  }
}
```

**didClose** — client closes a file:
```json
{
  "jsonrpc": "2.0",
  "method": "textDocument/didClose",
  "params": {
    "textDocument": { "uri": "file:///path/to/file.md" }
  }
}
```

### Diagnostics

Server pushes diagnostics to the client as a notification (no request needed):

```json
{
  "jsonrpc": "2.0",
  "method": "textDocument/publishDiagnostics",
  "params": {
    "uri": "file:///path/to/file.md",
    "diagnostics": [
      {
        "range": {
          "start": { "line": 2, "character": 0 },
          "end": { "line": 2, "character": 10 }
        },
        "severity": 2,
        "source": "cclsp",
        "message": "Line exceeds 80 characters"
      }
    ]
  }
}
```

**DiagnosticSeverity:** 1=Error, 2=Warning, 3=Information, 4=Hint

**Position:** `line` and `character` are both zero-based.

**Range:** `start` is inclusive, `end` is exclusive.

### Completion

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "textDocument/completion",
  "params": {
    "textDocument": { "uri": "file:///path/to/file.md" },
    "position": { "line": 3, "character": 2 }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "isIncomplete": false,
    "items": [
      {
        "label": "## Heading 2",
        "kind": 15,
        "detail": "Insert a level-2 heading",
        "insertText": "## "
      }
    ]
  }
}
```

**CompletionItemKind** (selected): 1=Text, 3=Function, 6=Variable, 14=Keyword, 15=Snippet

### Hover

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "textDocument/hover",
  "params": {
    "textDocument": { "uri": "file:///path/to/file.md" },
    "position": { "line": 0, "character": 3 }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "result": {
    "contents": {
      "kind": "markdown",
      "value": "**Heading Level 1**\n\nThis is the document title."
    }
  }
}
```

If nothing to show: `"result": null`

### JSON-RPC Error Codes

| Code | Meaning |
|------|---------|
| -32700 | Parse error (invalid JSON) |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |
| -32002 | Server not initialized |

### Zig JSON & I/O Reference (0.15.2)

```zig
const std = @import("std");

// --- JSON parsing ---
// Parse a JSON string into a dynamic value tree
const parsed = try std.json.parseFromSlice(
    std.json.Value,       // parse into dynamic Value
    allocator,
    json_bytes,
    .{},                  // parse options
);
defer parsed.deinit();
const root = parsed.value;

// Access object fields
const method = root.object.get("method") orelse return error.MissingField;
const method_str = method.string;  // []const u8

// Access nested fields
const params = root.object.get("params").?.object;
const uri = params.get("textDocument").?.object.get("uri").?.string;

// Access optional id (may be integer or string, or absent for notifications)
const id_val = root.object.get("id");
const is_notification = (id_val == null);

// --- JSON serialization ---
// Build response using std.json.Value (dynamic)
var obj = std.json.Value{ .object = std.json.ObjectMap.init(allocator) };
try obj.object.put("jsonrpc", .{ .string = "2.0" });
try obj.object.put("id", .{ .integer = request_id });
// ... build result object ...

// Serialize to string
const json_str = try std.fmt.allocPrint(
    allocator,
    "{f}",
    .{std.json.fmt(obj, .{})},
);

// --- Alternative: parse into typed struct ---
const InitializeParams = struct {
    processId: ?i64 = null,
    rootUri: ?[]const u8 = null,
    capabilities: struct {} = .{},
};
const params_parsed = try std.json.parseFromSlice(
    InitializeParams,
    allocator,
    params_json,
    .{ .ignore_unknown_fields = true },
);

// --- Stdin/Stdout I/O ---
const stdin = std.fs.File.stdin();

// Read exact N bytes
var content_buf = try allocator.alloc(u8, content_length);
const bytes_read = try stdin.readAll(content_buf);
// readAll returns bytes read; for stdin it may need a loop

// Read line (for headers)
var header_buf: [256]u8 = undefined;
const header_line = (try stdin.reader().readUntilDelimiterOrEof(
    &header_buf, '\n'
)) orelse return error.EndOfStream;
const trimmed = std.mem.trimRight(u8, header_line, "\r");

// Write to stdout
var out_buf: [65536]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&out_buf);
const stdout = &out_writer.interface;
try stdout.print("Content-Length: {d}\r\n\r\n", .{json_bytes.len});
try stdout.writeAll(json_bytes);
try stdout.flush();

// Parse Content-Length header
// Header: "Content-Length: 123"
if (std.mem.startsWith(u8, trimmed, "Content-Length: ")) {
    const len_str = trimmed["Content-Length: ".len..];
    const content_length = try std.fmt.parseInt(usize, len_str, 10);
}

// Logging to stderr (never write non-LSP data to stdout!)
var err_buf: [4096]u8 = undefined;
var err_writer = std.fs.File.stderr().writer(&err_buf);
const log = &err_writer.interface;
try log.print("[cclsp] Received: {s}\n", .{method_str});
try log.flush();

// HashMap for document storage
var documents = std.StringHashMap([]const u8).init(allocator);
defer documents.deinit();
try documents.put(uri, text);
const doc_text = documents.get(uri);
```

### Testing with a Script

Since LSP communicates over stdin/stdout, test by piping messages:

```bash
# Send an initialize request
printf 'Content-Length: 95\r\n\r\n{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":1,"rootUri":null,"capabilities":{}}}' | ./cclsp
```

Or write a test harness in Zig that spawns the server as a child process and sends/receives messages programmatically.

---

## Questions

### Q1 (5 pts): LSP Transport — Read and Write Messages

Implement the LSP base protocol (header-framed JSON messages over stdin/stdout):

Requirements:
- `readMessage(allocator, reader) → ![]u8` — read one LSP message from stdin
  - Parse `Content-Length` header
  - Handle `\r\n\r\n` header/body separator
  - Read exactly `Content-Length` bytes of JSON body
  - Return the JSON bytes (caller owns memory)
  - Return error on malformed headers or EOF
- `writeMessage(writer, json_bytes: []const u8) → !void` — write one LSP message to stdout
  - Write `Content-Length: <N>\r\n\r\n` header
  - Write JSON body
  - Flush the writer
- **Never write non-LSP data to stdout** — all logging goes to stderr

Write Zig tests:
- Round-trip: write a message to a buffer, read it back → identical JSON
- Parse header with extra whitespace/other headers → still works
- Missing Content-Length → error
- Content-Length mismatch (too short) → handle gracefully

**Validation:**
```zig
test "read-write round trip" {
    const json = "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"test\"}";
    var buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    try writeMessage(fbs.writer(), json);

    fbs.pos = 0;  // reset to beginning
    const result = try readMessage(testing.allocator, fbs.reader());
    defer testing.allocator.free(result);
    try testing.expectEqualStrings(json, result);
}
```

### Q2 (5 pts): JSON-RPC Message Types

Implement JSON-RPC request, response, and notification handling:

Requirements:
- Distinguish message types:
  - **Request**: has `id` and `method` → requires a response
  - **Notification**: has `method` but no `id` → no response
  - **Response**: has `id` and `result` or `error` → should not happen (server doesn't send requests yet)
- `parseJsonRpc(allocator, json: []const u8) → !JsonRpcMessage`
  - Extract `id` (integer or string or absent), `method`, `params`
- `formatResponse(allocator, id, result_json: []const u8) → ![]u8`
  - Build `{"jsonrpc":"2.0","id":<id>,"result":<result>}`
- `formatError(allocator, id, code: i32, message: []const u8) → ![]u8`
  - Build `{"jsonrpc":"2.0","id":<id>,"error":{"code":<code>,"message":"<msg>"}}`
- `formatNotification(allocator, method: []const u8, params_json: []const u8) → ![]u8`
  - Build `{"jsonrpc":"2.0","method":"<method>","params":<params>}`

Write Zig tests:
- Parse request → has id, method, params
- Parse notification → has method, no id
- Format response with integer id
- Format error with code -32601
- Format notification (for publishDiagnostics)

**Validation:**
```zig
test "format response" {
    const resp = try formatResponse(allocator, 1, "{\"capabilities\":{}}");
    defer allocator.free(resp);
    // Parse it back and verify structure
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, resp, .{});
    defer parsed.deinit();
    try testing.expectEqualStrings("2.0", parsed.value.object.get("jsonrpc").?.string);
    try testing.expectEqual(@as(i64, 1), parsed.value.object.get("id").?.integer);
}
```

### Q3 (5 pts): Initialize Handshake

Implement the server initialization flow:

Requirements:
- On receiving `initialize` request:
  - Parse `processId`, `rootUri`, `capabilities` from params
  - Respond with `ServerCapabilities`:
    - `textDocumentSync: 1` (Full sync)
    - `completionProvider: {}`
    - `hoverProvider: true`
  - Include `serverInfo: { name: "cclsp", version: "0.1.0" }`
  - Mark server as initialized internally
- On receiving `initialized` notification: acknowledge (no response needed)
- Before initialization completes, respond to any other request with error code -32002 (`ServerNotInitialized`)
- On `shutdown` request: respond with `null` result, mark as shutting down
- On `exit` notification: exit process with code 0 (if shutdown received) or 1 (if not)

Write Zig tests:
- Process initialize → returns capabilities JSON with correct fields
- Request before initialize → returns -32002 error
- Shutdown then exit → clean exit

**Validation:**
```bash
# Send initialize + initialized + shutdown + exit
printf 'Content-Length: 107\r\n\r\n{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":1,"rootUri":null,"capabilities":{}}}Content-Length: 52\r\n\r\n{"jsonrpc":"2.0","method":"initialized","params":{}}Content-Length: 44\r\n\r\n{"jsonrpc":"2.0","id":2,"method":"shutdown"}Content-Length: 38\r\n\r\n{"jsonrpc":"2.0","method":"exit"}' | ./cclsp 2>/dev/null
```
Should output two responses (for initialize and shutdown) and exit cleanly.

### Q4 (5 pts): Document Store

Implement document open/change/close tracking:

Requirements:
- On `textDocument/didOpen`: store document URI → text content, language ID, version
- On `textDocument/didChange` (Full sync): replace stored text with new content
- On `textDocument/didClose`: remove document from store
- Use `std.StringHashMap` for URI → document mapping
- Store document metadata: `uri`, `languageId`, `version`, `text`
- After open or change, trigger analysis (diagnostics — implemented in Q5)

Write Zig tests:
- Open document → stored in map
- Change document → text updated, version incremented
- Close document → removed from map
- Open same URI twice → replaces (no error)
- Access closed document → returns null

**Validation:**
```zig
test "document lifecycle" {
    var store = DocumentStore.init(allocator);
    defer store.deinit();

    store.open("file:///test.md", "markdown", 1, "# Hello\n");
    try testing.expectEqualStrings("# Hello\n", store.get("file:///test.md").?.text);

    store.change("file:///test.md", 2, "# Updated\n");
    try testing.expectEqualStrings("# Updated\n", store.get("file:///test.md").?.text);

    store.close("file:///test.md");
    try testing.expect(store.get("file:///test.md") == null);
}
```

### Q5 (5 pts): Diagnostics — Line Length and Heading Analysis

Implement basic document analysis that produces diagnostics:

Requirements:
- `analyze(allocator, uri, text) → ![]Diagnostic` — analyze document and return diagnostic list
- **Rule 1**: Lines longer than 80 characters → Warning: `"Line exceeds 80 characters (N chars)"`
- **Rule 2**: Markdown heading without space after `#` → Error: `"Missing space after heading marker"`
  - E.g., `#Hello` is an error, `# Hello` is correct
  - Check `##`, `###`, etc. too
- **Rule 3**: Empty document → Hint: `"Document is empty"`
- **Rule 4**: Trailing whitespace → Information: `"Trailing whitespace"`
- Diagnostics include: range (line, start char, end char), severity, source (`"cclsp"`), message
- After analysis, send `textDocument/publishDiagnostics` notification to client
- Clear diagnostics (send empty array) when document is closed

Write Zig tests:
- `"# Hello\n"` → no diagnostics
- `"#Hello\n"` → 1 error (missing space)
- Long line (81+ chars) → 1 warning
- Empty string → 1 hint
- `"hello   \n"` → 1 info (trailing whitespace)
- Multiple issues → multiple diagnostics

**Validation:**
Test by piping an initialize + didOpen sequence:
```bash
# After initialize/initialized, send didOpen with a problematic document:
# {"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///test.md","languageId":"markdown","version":1,"text":"#Bad Heading\nThis line is fine.\n"}}}
# Server should send back publishDiagnostics with the heading error
```

### Q6 (5 pts): Completion — Markdown Snippets

Implement basic code completion:

Requirements:
- On `textDocument/completion` request at cursor position:
  - If cursor is at start of line or after only whitespace, offer heading completions:
    - `# ` (Heading 1), `## ` (Heading 2), `### ` (Heading 3)
    - `- ` (bullet list), `1. ` (numbered list)
    - `> ` (blockquote), `` ``` `` (code block)
  - If cursor is after `[`, offer link template: `[text](url)`
  - If cursor is after `!`, offer image template: `![alt](url)`
  - Otherwise, offer word completions based on words already in the document
- Each `CompletionItem`: `label`, `kind` (Snippet=15 for templates, Text=1 for words), `insertText`
- Response format: `{"isIncomplete": false, "items": [...]}`

Write Zig tests:
- Completion at line start → heading snippets offered
- Completion after `[` → link template
- Completion after `!` → image template
- Completion mid-word → word completions from document
- Empty document → only structural completions

**Validation:**
```zig
test "completion at line start" {
    var store = DocumentStore.init(allocator);
    store.open("file:///t.md", "markdown", 1, "# Title\n\nSome text.\n");
    const items = try getCompletions(allocator, &store, "file:///t.md", .{ .line = 1, .character = 0 });
    // Should include heading snippets
    var found_h2 = false;
    for (items) |item| {
        if (std.mem.eql(u8, item.label, "## ")) found_h2 = true;
    }
    try testing.expect(found_h2);
}
```

### Q7 (5 pts): Hover — Heading and Link Info

Implement hover information:

Requirements:
- On `textDocument/hover` request at a position:
  - If on a heading line (`# ...`), return: level info and character count
    - E.g., `"**Heading Level 2** (15 characters)"`
  - If on a link `[text](url)`, return: `"Link: url"`
  - If on a word, return: word frequency in document
    - E.g., `"'hello' appears 3 times in this document"`
  - If nothing meaningful at position, return `null`
- Response: `{"contents": {"kind": "markdown", "value": "..."}}`
- Include `range` in response to highlight the hovered element

Write Zig tests:
- Hover on heading → returns level info
- Hover on link → returns URL
- Hover on regular word → returns word count
- Hover on empty line → returns null

**Validation:**
```zig
test "hover on heading" {
    var store = DocumentStore.init(allocator);
    store.open("file:///t.md", "markdown", 1, "## My Title\n");
    const result = try getHover(allocator, &store, "file:///t.md", .{ .line = 0, .character = 5 });
    try testing.expect(result != null);
    try testing.expect(std.mem.indexOf(u8, result.?.contents, "Level 2") != null);
}
```

### Q8 (5 pts): Request Dispatch and Method Routing

Implement the main server loop with method dispatch:

Requirements:
- Main loop: read message → parse JSON-RPC → dispatch by method → send response
- Method routing table:
  - `initialize` → handleInitialize
  - `initialized` → handleInitialized (notification, no response)
  - `shutdown` → handleShutdown
  - `exit` → handleExit (exits process)
  - `textDocument/didOpen` → handleDidOpen
  - `textDocument/didChange` → handleDidChange
  - `textDocument/didClose` → handleDidClose
  - `textDocument/completion` → handleCompletion
  - `textDocument/hover` → handleHover
  - Unknown method → respond with error -32601 (Method not found) for requests; ignore for notifications
- Handle JSON parse errors gracefully → error -32700
- Handle malformed params → error -32602
- Log all incoming methods to stderr for debugging

Write Zig tests:
- Dispatch table maps method strings to handlers correctly
- Unknown request method → error response with -32601
- Unknown notification method → silently ignored (no response)
- Malformed JSON → error -32700

**Validation:**
```bash
# Send unknown method request
printf 'Content-Length: 65\r\n\r\n{"jsonrpc":"2.0","id":99,"method":"unknownMethod","params":{}}' | ./cclsp 2>/dev/null
# Should respond with: {"jsonrpc":"2.0","id":99,"error":{"code":-32601,"message":"Method not found"}}
```

### Q9 (5 pts): Diagnostic — Markdown Link Validation

Extend diagnostics with link checking:

Requirements:
- **Rule 5**: Detect broken link syntax — `[text]` without `(url)` following → Warning: `"Link text without URL"`
- **Rule 6**: Detect image without alt text — `![]()` → Warning: `"Image missing alt text"`
- **Rule 7**: Detect duplicate headings at same level → Information: `"Duplicate heading: '<text>'"`
- **Rule 8**: Detect heading level skip (e.g., `#` followed by `###` without `##`) → Warning: `"Heading level skipped (from H1 to H3)"`
- All diagnostics include precise range (line + character span)
- Accumulate all rule violations (don't stop after first)

Write Zig tests:
- `"[broken link]\n"` → 1 warning
- `"![](img.png)\n"` → 1 warning (empty alt)
- `"# Title\n### Skip\n"` → 1 warning (level skip)
- `"# Title\n# Title\n"` → 1 info (duplicate)
- Clean document → no diagnostics

**Validation:**
```zig
test "broken link diagnostic" {
    const diags = try analyze(allocator, "file:///t.md",
        "# Title\n\nSee [this link] for details.\n");
    try testing.expectEqual(@as(usize, 1), diags.len);
    try testing.expectEqual(@as(i32, 2), diags[0].severity); // Warning
    try testing.expect(std.mem.indexOf(u8, diags[0].message, "without URL") != null);
}
```

### Q10 (5 pts): Go-to-Definition for Headings

Implement go-to-definition that jumps to heading anchors:

Requirements:
- Declare capability: `"definitionProvider": true` in initialize response
- On `textDocument/definition` request:
  - If cursor is on a `[link](#anchor)` reference, find the heading matching `anchor`
  - Heading anchor: lowercase, spaces → hyphens, strip non-alphanumeric
    - `## My Cool Heading` → anchor `my-cool-heading`
  - Return `Location { uri, range }` pointing to the heading line
  - If anchor not found, return `null`
- Build a heading index on document open/change for fast lookup

Write Zig tests:
- `"# Hello World"` → anchor `hello-world`
- `"## Special! Chars@Here"` → anchor `special-chars-here`
- Link `[see above](#hello-world)` → definition at line 0
- Link to non-existent anchor → null
- Anchor computation: verify against CommonMark algorithm

**Validation:**
```zig
test "heading anchor generation" {
    try testing.expectEqualStrings("hello-world", computeAnchor("Hello World"));
    try testing.expectEqualStrings("api-reference-v2", computeAnchor("API Reference v2"));
}

test "go to definition" {
    var store = DocumentStore.init(allocator);
    store.open("file:///t.md", "markdown", 1,
        "# Introduction\n\nSee [intro](#introduction) for details.\n");
    const loc = try getDefinition(allocator, &store, "file:///t.md",
        .{ .line = 2, .character = 12 });
    try testing.expectEqual(@as(usize, 0), loc.?.range.start.line);
}
```

### Q11 (5 pts): Document Symbols

Implement document symbol listing (outline view):

Requirements:
- Declare capability: `"documentSymbolProvider": true`
- On `textDocument/documentSymbol` request, return document outline:
  - Each heading becomes a `DocumentSymbol`:
    - `name`: heading text (without `#` markers)
    - `kind`: 25 (Operator — no "Heading" kind exists; or use String=15)
    - `range`: full line range
    - `selectionRange`: text range (excluding `# ` prefix)
    - `children`: nested headings (H2 under H1, H3 under H2, etc.)
  - Build a hierarchy: H1 contains H2, which contains H3, etc.
- Also include code blocks as symbols (kind=12, Value)

Write Zig tests:
- `"# Title\n## Section\n### Sub\n"` → nested tree: Title → Section → Sub
- `"## A\n## B\n"` → two siblings at same level
- No headings → empty array
- Code block → appears as symbol

**Validation:**
```zig
test "document symbols" {
    var store = DocumentStore.init(allocator);
    store.open("file:///t.md", "markdown", 1,
        "# Title\n## Section 1\n### Details\n## Section 2\n");
    const symbols = try getDocumentSymbols(allocator, &store, "file:///t.md");
    try testing.expectEqual(@as(usize, 1), symbols.len);  // 1 top-level
    try testing.expectEqualStrings("Title", symbols[0].name);
    try testing.expectEqual(@as(usize, 2), symbols[0].children.len);  // 2 sections
}
```

### Q12 (5 pts): End-to-End Integration Test

Write a comprehensive test harness that validates the full server:

Requirements:
- Spawn `./cclsp` as a child process
- Send messages to its stdin, read responses from stdout
- Implement a `LspClient` helper:
  - `sendRequest(method, params) → response` — send request, read response, match id
  - `sendNotification(method, params)` — send notification (no response expected)
  - `readNotification() → notification` — read a server-initiated notification
- Run the following test scenario:
  1. Send `initialize` → verify capabilities in response
  2. Send `initialized` notification
  3. Send `didOpen` with a markdown document containing errors
  4. Read `publishDiagnostics` notification → verify correct diagnostics
  5. Send `completion` request → verify completion items
  6. Send `hover` request on a heading → verify hover content
  7. Send `didChange` with fixed document
  8. Read `publishDiagnostics` → verify diagnostics cleared
  9. Send `didClose`
  10. Send `shutdown` → verify null result
  11. Send `exit` → verify process terminates

Write as a Zig test that can run with `zig build test`.

**Validation:**
```zig
test "end-to-end LSP session" {
    // Spawn server
    var child = std.process.Child.init(.{
        .argv = &.{"./zig-out/bin/cclsp"},
        .stdin_behavior = .pipe,
        .stdout_behavior = .pipe,
        .stderr_behavior = .pipe,
    });
    try child.spawn();
    defer _ = child.wait() catch {};

    var client = LspClient.init(child.stdin.?, child.stdout.?);

    // 1. Initialize
    const init_resp = try client.sendRequest("initialize",
        \\{"processId":1,"rootUri":null,"capabilities":{}}
    );
    // Verify capabilities
    try testing.expect(std.mem.indexOf(u8, init_resp, "textDocumentSync") != null);

    // 2. Initialized
    try client.sendNotification("initialized", "{}");

    // 3. Open document with errors
    try client.sendNotification("textDocument/didOpen",
        \\{"textDocument":{"uri":"file:///test.md","languageId":"markdown","version":1,"text":"#BadHeading\nThis line is fine.\n"}}
    );

    // 4. Read diagnostics
    const diag_notif = try client.readNotification();
    try testing.expect(std.mem.indexOf(u8, diag_notif, "Missing space") != null);

    // ... continue with completion, hover, shutdown, exit ...
}
```
