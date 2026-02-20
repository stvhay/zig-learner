# Quiz 14: Build Your Own IRC Client

Implement an IRC client in Zig 0.15.2 that connects to an IRC server, handles the protocol, and provides an interactive chat experience.

**Total: 60 points (12 questions x 5 points)**

## Background: IRC Protocol (RFC 2812)

### Message Format

Every IRC message follows this structure, terminated by `\r\n` (CRLF):

```
[":" prefix SPACE] command [params] "\r\n"
```

**Maximum message length**: 512 bytes including the CRLF terminator (510 usable).

**Components:**
- **prefix** (optional): Identifies the message origin. Server-originated messages have a prefix starting with `:`. Format: `:servername` or `:nick!user@host`
- **command**: Either a named command (`PRIVMSG`, `JOIN`, etc.) or a 3-digit numeric code (`001`, `433`, etc.)
- **params**: Space-separated parameters. The last parameter may be prefixed with `:` to include spaces (the "trailing" parameter)

**Examples:**
```
PING :server.example.com\r\n
:server 001 yournick :Welcome to the IRC Network\r\n
:nick!user@host PRIVMSG #channel :Hello everyone!\r\n
:nick!user@host JOIN #channel\r\n
:nick!user@host PART #channel :Goodbye\r\n
:nick!user@host QUIT :Leaving\r\n
:nick!user@host NICK :newnick\r\n
:server 353 yournick = #channel :nick1 nick2 @op1 +voice1\r\n
:server 366 yournick #channel :End of /NAMES list\r\n
```

### Connection Registration

To register with an IRC server, send these commands in order:

```
NICK <nickname>\r\n
USER <username> 0 * :<realname>\r\n
```

The server responds with numeric codes 001-004 (welcome sequence) on success:
```
:server 001 yournick :Welcome to the Internet Relay Chat Network yournick!user@host
:server 002 yournick :Your host is server, running version ...
:server 003 yournick :This server was created ...
:server 004 yournick server version modes modes
```

### PING/PONG Keep-Alive

The server periodically sends `PING` messages. The client **must** respond with `PONG` or be disconnected:

```
Server: PING :token\r\n
Client: PONG :token\r\n
```

The token after `:` must be echoed back exactly.

### Core Commands

| Command | Client sends | Server relays |
|---------|-------------|---------------|
| **JOIN** | `JOIN #channel\r\n` | `:nick!user@host JOIN #channel\r\n` |
| **PART** | `PART #channel :reason\r\n` | `:nick!user@host PART #channel :reason\r\n` |
| **PRIVMSG** | `PRIVMSG #channel :text\r\n` | `:nick!user@host PRIVMSG #channel :text\r\n` |
| **NICK** | `NICK newnick\r\n` | `:oldnick!user@host NICK :newnick\r\n` |
| **QUIT** | `QUIT :message\r\n` | `:nick!user@host QUIT :message\r\n` |
| **TOPIC** | `TOPIC #channel\r\n` (query) or `TOPIC #channel :new topic\r\n` (set) | — |

### Key Numeric Replies

| Code | Name | Meaning |
|------|------|---------|
| 001 | RPL_WELCOME | Registration successful |
| 002 | RPL_YOURHOST | Server info |
| 003 | RPL_CREATED | Server creation date |
| 004 | RPL_MYINFO | Server modes info |
| 332 | RPL_TOPIC | Channel topic text |
| 333 | RPL_TOPICWHOTIME | Who set topic and when |
| 353 | RPL_NAMREPLY | Names list for channel |
| 366 | RPL_ENDOFNAMES | End of names list |
| 372 | RPL_MOTD | Message of the day line |
| 375 | RPL_MOTDSTART | Start of MOTD |
| 376 | RPL_ENDOFMOTD | End of MOTD |
| 431 | ERR_NONICKNAMEGIVEN | No nickname supplied |
| 432 | ERR_ERRONEUSNICKNAME | Invalid nickname |
| 433 | ERR_NICKNAMEINUSE | Nickname already taken |
| 461 | ERR_NEEDMOREPARAMS | Not enough parameters |
| 473 | ERR_INVITEONLYCHAN | Channel is invite-only |
| 474 | ERR_BANNEDFROMCHAN | Banned from channel |

### Prefix Parsing

Server messages include a prefix identifying the sender:

```
:nick!user@host COMMAND params
```

Parsing algorithm:
1. If line starts with `:`, extract prefix (up to first space)
2. From prefix, extract nick (before `!`), user (between `!` and `@`), host (after `@`)
3. If no `!` in prefix, the prefix is a server name

```
":JohnC!~guest@192.168.1.1 PRIVMSG #chat :Hello!"
 └─nick─┘└user─┘└──host───┘ └cmd──┘ └tgt┘ └text┘
```

### Channel Names

Channels start with `#`, `&`, `+`, or `!`. Up to 50 characters. Cannot contain spaces, control-G (0x07), or commas.

### Testing Without a Public Server

For development and testing, run a local IRC server. Options:

**Using ncat/netcat as a mock server** (simplest — for protocol testing):
```bash
# Terminal 1: Start a TCP listener that echoes
ncat -l -k 6667

# Terminal 2: Connect your client
./ccirc localhost 6667
```
You can manually type server responses in the ncat terminal.

**Using a real IRC server** (for integration testing):
- `irc.libera.chat:6667` (Libera.Chat, successor to Freenode)
- Use a unique nickname to avoid collisions

### Zig Networking Reference (0.15.2)

```zig
const std = @import("std");

// TCP client connection (hostname resolution included)
const stream = try std.net.tcpConnectToHost(
    allocator,          // std.mem.Allocator — needed for DNS resolution
    "irc.libera.chat",  // []const u8 — hostname
    6667,               // u16 — port
);
defer stream.close();

// Or connect by IP directly (no allocator needed)
const addr = try std.net.Address.resolveIp("127.0.0.1", 6667);
const stream2 = try std.net.tcpConnectToAddress(addr);

// Writing to stream
try stream.writeAll("NICK ccirc\r\n");

// Line-based reading (IRC messages end with \r\n)
var buf: [512]u8 = undefined;
const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
const trimmed = std.mem.trimRight(u8, line, "\r");
// trimmed now contains one IRC message without CRLF

// Formatting for sending
var send_buf: [512]u8 = undefined;
const msg = try std.fmt.bufPrint(&send_buf, "PRIVMSG {s} :{s}\r\n", .{ channel, text });
try stream.writeAll(msg);

// Thread for concurrent stdin + network reading
const thread = try std.Thread.spawn(.{}, networkReader, .{stream});
defer thread.join();

// Stdin reading
const stdin = std.fs.File.stdin();
const stdin_reader = stdin.reader();
const user_line = (try stdin_reader.readUntilDelimiterOrEof(&buf, '\n')) orelse break;

// Stdout (buffered)
var out_buf: [4096]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&out_buf);
const stdout = &out_writer.interface;
try stdout.print("[{s}] {s}: {s}\n", .{ channel, nick, message });
try stdout.flush();

// String operations for parsing
const idx = std.mem.indexOf(u8, line, " ");           // find first space
const prefix = line[1..idx.?];                         // skip leading ':'
const bang = std.mem.indexOf(u8, prefix, "!");         // find '!' in prefix
const nick = if (bang) |b| prefix[0..b] else prefix;  // extract nick

// Case-insensitive compare (for channel/nick matching)
const eql = std.ascii.eqlIgnoreCase(a, b);

// String starts-with
if (std.mem.startsWith(u8, line, "/join ")) { ... }
```

---

## Questions

### Q1 (5 pts): IRC Message Parser

Write a message parser that handles the IRC wire format:

Requirements:
- Define a `Message` struct with fields: `prefix: ?[]const u8`, `command: []const u8`, `params: [][]const u8`
- `parseMessage(line: []const u8) → Message` — parse a single IRC line (without CRLF)
- Handle optional prefix (lines starting with `:`)
- Handle trailing parameter (`:` prefix on last param — everything after `:` is one parameter including spaces)
- Handle messages with 0 to 15 parameters

Write as Zig tests:
- Parse `"PING :server.example.com"` → command=`PING`, params=[`server.example.com`]
- Parse `":server 001 nick :Welcome to IRC"` → prefix=`server`, command=`001`, params=[`nick`, `Welcome to IRC`]
- Parse `":nick!user@host PRIVMSG #channel :Hello world!"` → prefix=`nick!user@host`, command=`PRIVMSG`, params=[`#channel`, `Hello world!`]
- Parse `":nick!user@host JOIN #channel"` → prefix=`nick!user@host`, command=`JOIN`, params=[`#channel`]
- Parse `"QUIT"` → command=`QUIT`, params=[] (no params)

**Validation:**
```zig
test "parse PRIVMSG" {
    const msg = parseMessage(":Alice!a@host PRIVMSG #test :Hello world!");
    try testing.expectEqualStrings("Alice!a@host", msg.prefix.?);
    try testing.expectEqualStrings("PRIVMSG", msg.command);
    try testing.expectEqual(@as(usize, 2), msg.params.len);
    try testing.expectEqualStrings("#test", msg.params[0]);
    try testing.expectEqualStrings("Hello world!", msg.params[1]);
}
```

### Q2 (5 pts): Prefix Parser — Extract Nick, User, Host

Write a prefix parser to extract identity components:

Requirements:
- Define a `Prefix` struct: `nick: []const u8`, `user: ?[]const u8`, `host: ?[]const u8`
- `parsePrefix(prefix: []const u8) → Prefix`
- Handle full prefix: `nick!user@host` → nick=`nick`, user=`user`, host=`host`
- Handle nick-only prefix (server name): `server.example.com` → nick=`server.example.com`, user=null, host=null
- Handle nick with host but no user: `nick@host` → nick=`nick`, user=null, host=`host`

Write Zig tests:
- `"Alice!alice@192.168.1.1"` → nick=`Alice`, user=`alice`, host=`192.168.1.1`
- `"irc.libera.chat"` → nick=`irc.libera.chat`, user=null, host=null
- `"Bob!~bob@gateway/web"` → nick=`Bob`, user=`~bob`, host=`gateway/web`

**Validation:**
```zig
test "parse prefix with all parts" {
    const p = parsePrefix("Alice!alice@192.168.1.1");
    try testing.expectEqualStrings("Alice", p.nick);
    try testing.expectEqualStrings("alice", p.user.?);
    try testing.expectEqualStrings("192.168.1.1", p.host.?);
}
```

### Q3 (5 pts): TCP Connection and Registration

Implement connecting to an IRC server and sending the registration sequence:

Requirements:
- `connect(allocator, host: []const u8, port: u16, nickname: []const u8) → !Connection`
- `Connection` struct wraps `std.net.Stream` and stores nickname, a read buffer, etc.
- Send `NICK <nickname>\r\n` immediately after connecting
- Send `USER <nickname> 0 * :CC IRC Client\r\n`
- `readLine(conn: *Connection) → !?[]const u8` — read one IRC line, strip CRLF
- Lines longer than 512 bytes are truncated (IRC max message size)

Write Zig tests (against a loopback mock):
- Since we can't connect to a real server in tests, test the message formatting:
  - `formatNick("ccirc")` → `"NICK ccirc\r\n"`
  - `formatUser("ccirc")` → `"USER ccirc 0 * :CC IRC Client\r\n"`
  - `formatPong("token123")` → `"PONG :token123\r\n"`

**Validation:**
```zig
test "format registration messages" {
    var buf: [512]u8 = undefined;
    const nick_msg = try std.fmt.bufPrint(&buf, "NICK {s}\r\n", .{"ccirc"});
    try testing.expectEqualStrings("NICK ccirc\r\n", nick_msg);

    const user_msg = try std.fmt.bufPrint(&buf, "USER {s} 0 * :CC IRC Client\r\n", .{"ccirc"});
    try testing.expectEqualStrings("USER ccirc 0 * :CC IRC Client\r\n", user_msg);
}
```

Integration test (manual):
```
./ccirc localhost 6667 ccirc
# In ncat terminal, type:
:localhost 001 ccirc :Welcome to the test IRC server
# Client should display the welcome message
```

### Q4 (5 pts): PING/PONG Handler

Implement automatic PING response:

Requirements:
- When a `PING :token` message is received, immediately send `PONG :token\r\n`
- The token must be echoed back exactly (it may contain any characters)
- Do not display PING/PONG exchanges to the user (handle silently)
- If PONG fails to send, log error to stderr but don't crash

Write Zig tests:
- Parse `"PING :irc.libera.chat"` → extract token `irc.libera.chat`
- Format response: `"PONG :irc.libera.chat\r\n"`
- Parse `"PING :12345"` → response `"PONG :12345\r\n"`
- Parse `"PING :multiple words here"` → response `"PONG :multiple words here\r\n"`

**Validation (manual):**
```
# Connect client to ncat mock server
# In ncat, type: PING :test123
# Client should automatically send back: PONG :test123
# Nothing should be displayed to the user
```

### Q5 (5 pts): Display Incoming Messages

Format server messages for human-readable display:

Requirements:
- **PRIVMSG**: `[#channel] Alice: Hello everyone!` or `[DM] Alice: private message`
- **JOIN**: `→ Alice has joined #channel`
- **PART**: `← Alice has left #channel (reason)` or `← Alice has left #channel` if no reason
- **QUIT**: `← Alice has quit (Goodbye!)` or `← Alice has quit`
- **NICK**: `* Alice is now known as Bob`
- **NOTICE**: `[Notice] server: message text`
- **Numeric 332 (TOPIC)**: `Topic for #channel: the topic text`
- **Numeric 353 (NAMES)**: `Users in #channel: nick1 nick2 @op1`
- **Numeric 001-004**: Display the trailing text (welcome messages)
- **Other numerics**: Display raw: `[123] param1 param2 :trailing`
- Extract nick from prefix for display (not full `nick!user@host`)

Write Zig tests that verify formatting:
- Format a PRIVMSG to channel → `[#channel] Alice: Hello!`
- Format a JOIN → `→ Alice has joined #channel`
- Format a QUIT with message → `← Alice has quit (Bye!)`
- Format a NICK change → `* Alice is now known as Bob`

**Validation:**
```zig
test "format privmsg display" {
    const msg = parseMessage(":Alice!a@h PRIVMSG #test :Hello!");
    const display = formatDisplay(msg);
    try testing.expectEqualStrings("[#test] Alice: Hello!", display);
}
```

### Q6 (5 pts): User Input — JOIN, PART, QUIT Commands

Handle user commands from stdin:

Requirements:
- `/join #channel` → send `JOIN #channel\r\n`, track as active channel
- `/part` → send `PART #activechannel\r\n`, clear active channel
- `/part #channel` → send `PART #channel\r\n`
- `/part #channel reason text` → send `PART #channel :reason text\r\n`
- `/quit` → send `QUIT :Leaving\r\n`, close connection, exit
- `/quit message` → send `QUIT :message\r\n`, close connection, exit
- Text without `/` prefix → send as `PRIVMSG` to active channel
- If no active channel and user types a message → print error: `"No active channel. Use /join #channel first."`

Write Zig tests:
- Parse `/join #test` → command=`JOIN`, channel=`#test`
- Parse `/part` (no channel) → uses active channel
- Parse `/quit Goodbye!` → command=`QUIT`, message=`Goodbye!`
- Plain text with active channel → `PRIVMSG #active :text\r\n`
- Plain text without active channel → error message

**Validation (manual):**
```
./ccirc localhost 6667 ccirc
# After registration, type: /join #test
# ncat should receive: JOIN #test
# Type: Hello everyone!
# ncat should receive: PRIVMSG #test :Hello everyone!
# Type: /quit Bye
# ncat should receive: QUIT :Bye
# Client should exit
```

### Q7 (5 pts): Concurrent I/O — Network + Stdin

Handle simultaneous reading from network and stdin:

Requirements:
- Spawn a dedicated thread for reading from the network
- Main thread reads from stdin for user input
- Network thread parses incoming messages and displays them
- Use a mutex to protect shared state (active channel, nickname, output)
- Both threads share the same `Connection` (stream is thread-safe for read vs write)
- Network thread exits cleanly when connection closes (read returns 0 or error)
- Main thread signals network thread to stop on `/quit`

Write Zig tests:
- Test mutex-protected channel tracking (set/get active channel)
- Test that concurrent reads don't corrupt shared state (use `std.Thread.spawn`)

**Validation (manual):**
```
./ccirc localhost 6667 ccirc
# In ncat, type server messages — they should appear in client immediately
# Simultaneously type user commands in client — they should be sent to ncat
# Both directions should work without blocking each other
```

### Q8 (5 pts): NICK Command and Error Handling

Implement nickname changes and handle errors:

Requirements:
- `/nick newnickname` → send `NICK newnickname\r\n`
- When server confirms (`":oldnick!u@h NICK :newnick"`), update stored nickname
- Display: `* oldnick is now known as newnick`
- Handle error 433 (nickname in use):
  - Display: `Nickname 'desired' is already in use`
  - If during registration (before 001), auto-retry with `_` suffix: `ccirc` → `ccirc_` → `ccirc__`
  - Max 3 retries, then print error and exit
- Handle error 432 (erroneous nickname):
  - Display: `Invalid nickname 'desired'`

Write Zig tests:
- Process NICK confirmation → update internal nickname
- Process 433 during registration → auto-append `_` and retry
- Process 432 → display error, don't crash
- Three successive 433 errors → give up

**Validation (manual):**
```
# Start client, in ncat respond with:
:server 433 * ccirc :Nickname is already in use
# Client should automatically try NICK ccirc_
# Respond with 433 again → tries ccirc__
# Respond with 001 ccirc__ :Welcome → registration succeeds
```

### Q9 (5 pts): Channel State Tracking

Track joined channels and their user lists:

Requirements:
- Support multiple simultaneous channels (not just one active channel)
- `/join #channel` → add to joined set, make it the active channel
- `/part #channel` → remove from joined set, switch active if it was active
- `PART` from server (self) → remove from joined set
- `JOIN` from server (self) → confirm membership
- Track user lists per channel:
  - On JOIN, server sends 353 (NAMREPLY) with user list, followed by 366 (ENDOFNAMES)
  - Accumulate names from 353 messages until 366
  - Track joins/parts/quits to keep list current
- `/users` → print user list for active channel
- `/channels` → print list of joined channels, mark active with `*`
- `/switch #channel` → change active channel (must be joined)

Write Zig tests:
- Join two channels → both in set
- Part one → only the other remains
- Track names from 353+366 sequence
- QUIT from another user → remove from all channels
- `/switch` to unjoined channel → error

**Validation (manual):**
```
./ccirc localhost 6667 ccirc
# /join #test1
# /join #test2
# /channels → shows both, #test2 is active (marked *)
# /switch #test1 → switches active
# In ncat, send 353/366 sequence:
:server 353 ccirc = #test1 :ccirc @op alice bob
:server 366 ccirc #test1 :End of /NAMES list
# /users → shows: ccirc, @op, alice, bob
```

### Q10 (5 pts): Private Messages (DMs)

Support direct messaging between users:

Requirements:
- `/msg nick message text` → send `PRIVMSG nick :message text\r\n`
- Incoming PRIVMSG where target is your nick (not a channel) → display as DM:
  - `[DM] Alice: Hey there!`
- `/reply message text` → send to last person who DM'd you
- If no one has DM'd you yet, `/reply` shows error: `No one to reply to.`
- Track last DM sender for `/reply`

Write Zig tests:
- Parse `/msg Alice Hello!` → `PRIVMSG Alice :Hello!\r\n`
- Incoming PRIVMSG to self → display as DM, update last sender
- `/reply` without prior DM → error message
- `/reply` with prior DM → sends to last sender

**Validation (manual):**
```
# In ncat, send:
:Alice!a@h PRIVMSG ccirc :Hey there!
# Client should display: [DM] Alice: Hey there!
# Type: /reply Hi Alice!
# ncat should receive: PRIVMSG Alice :Hi Alice!
```

### Q11 (5 pts): TOPIC and WHO Commands

Implement channel information commands:

Requirements:
- `/topic` → send `TOPIC #activechannel\r\n` (query current topic)
- `/topic new topic text` → send `TOPIC #activechannel :new topic text\r\n` (set topic)
- Display numeric 332 (topic response): `Topic for #channel: the topic text`
- Display topic change event: `:nick!u@h TOPIC #channel :new topic` → `* nick changed the topic of #channel to: new topic`
- Track topic per channel (store most recent)
- `/whois nick` → send `WHOIS nick\r\n`
- Display WHOIS responses (numerics 311, 312, 313, 317, 318, 319 — print the trailing text)
- `/who #channel` → send `WHO #channel\r\n`
- Display WHO responses (numeric 352, one line per user)

Write Zig tests:
- Parse `/topic New topic!` → `TOPIC #active :New topic!\r\n`
- Format topic change event display
- Parse `/whois Alice` → `WHOIS Alice\r\n`
- Store and retrieve topic per channel

**Validation (manual):**
```
# After joining #test, type: /topic
# In ncat, respond with:
:server 332 ccirc #test :Welcome to the test channel
# Client should display: Topic for #test: Welcome to the test channel
# Type: /topic New topic
# ncat should receive: TOPIC #test :New topic
```

### Q12 (5 pts): CLI Interface and Graceful Shutdown

Polish the client with proper argument handling and clean shutdown:

Requirements:
- **Usage**: `./ccirc <host> <port> <nickname>`
  - `./ccirc irc.libera.chat 6667 mynick`
  - Default port if omitted: 6667
  - Print usage on wrong arg count: `Usage: ccirc <host> [port] <nickname>`
- `/help` → print all available commands:
  ```
  Available commands:
    /join #channel        — Join a channel
    /part [#channel]      — Leave a channel
    /msg nick message     — Send private message
    /reply message        — Reply to last DM
    /nick newnick         — Change nickname
    /topic [text]         — View or set channel topic
    /users                — List users in active channel
    /channels             — List joined channels
    /switch #channel      — Switch active channel
    /whois nick           — Get user info
    /quit [message]       — Disconnect and exit
    /help                 — Show this help
  ```
- **Graceful shutdown**:
  - On `/quit`, send QUIT message, wait up to 2 seconds for server acknowledgement, then close
  - On network error (server closes connection), print `Disconnected from server.` and exit
  - On Ctrl+C (SIGINT), send `QUIT :Interrupted\r\n` before exiting (if possible)
- **Reconnection prompt**: On unexpected disconnect, ask `Reconnect? (y/n)` — if yes, reconnect with same params
- **Timestamps** (optional): Prefix messages with `[HH:MM]` timestamp

Write Zig tests:
- Parse CLI args: `["ccirc", "localhost", "6667", "mynick"]` → host=`localhost`, port=6667, nick=`mynick`
- Parse CLI args: `["ccirc", "localhost", "mynick"]` → host=`localhost`, port=6667 (default), nick=`mynick`
- Help text contains all commands
- Format QUIT message with and without reason

**Validation (manual, full integration):**
```
# Full session test:
./ccirc localhost 6667 testuser

# In ncat, send welcome:
:localhost 001 testuser :Welcome
:localhost 376 testuser :End of /MOTD

# Type: /join #test
# ncat receives: JOIN #test
# In ncat, send:
:testuser!~testuser@localhost JOIN #test
:localhost 353 testuser = #test :testuser
:localhost 366 testuser #test :End of /NAMES list

# Type: Hello!
# ncat receives: PRIVMSG #test :Hello!

# In ncat, send:
:Alice!a@host PRIVMSG #test :Hi there testuser!
# Client displays: [#test] Alice: Hi there testuser!

# Type: /quit Goodbye
# ncat receives: QUIT :Goodbye
# Client exits cleanly
```
