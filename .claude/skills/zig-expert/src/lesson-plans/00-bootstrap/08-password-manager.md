# Quiz 12: Password Manager

Build a secure CLI password manager in Zig 0.15.2 with encrypted vault storage, key derivation, and credential CRUD operations.

**Total: 60 points (12 questions x 5 points)**

## Background: Cryptographic Foundations

### Threat Model

A password manager protects credentials at rest. The attacker has:
- Full access to the vault file on disk
- No access to the master password (it exists only in memory during a session)

The vault file must be indistinguishable from random data without the master password.

### Key Derivation (Argon2id)

A master password is low-entropy (human-chosen). A **key derivation function** (KDF) stretches it into a high-entropy encryption key, deliberately slow to resist brute force.

**Argon2id** is the recommended KDF (winner of the Password Hashing Competition). Parameters:
- **t** (time cost): number of iterations (higher = slower, more secure)
- **m** (memory cost): kilobytes of RAM used (higher = resists GPU attacks)
- **p** (parallelism): number of threads
- **salt**: random 16-byte value, unique per vault (stored alongside ciphertext)

```
master_password + salt → Argon2id(t=3, m=65536, p=1) → 32-byte encryption key
```

### Authenticated Encryption (AES-256-GCM)

**AES-256-GCM** provides both confidentiality and integrity in one operation:
- **Encrypts** plaintext → ciphertext (same length)
- **Produces a 16-byte authentication tag** that detects tampering
- **Requires a 12-byte nonce** (number used once) — must be unique per encryption

Decryption verifies the tag first. If the key is wrong or data is tampered with, decryption fails with an `AuthenticationFailed` error — this is how you detect a wrong master password.

```
encrypt(key, nonce, plaintext, aad) → (ciphertext, tag)
decrypt(key, nonce, ciphertext, tag, aad) → plaintext | error.AuthenticationFailed
```

**AAD** (Additional Authenticated Data): extra data that's authenticated but not encrypted (e.g., a version header).

### Vault File Format

Design the vault as a binary file with this layout:

```
Offset  Size  Field
0       4     Magic: "CCPW" (0x43435057)
4       1     Version: 1
5       16    Salt (for Argon2id)
21      12    Nonce (for AES-256-GCM)
33      16    Auth tag (from AES-256-GCM)
49      var   Encrypted payload (AES-256-GCM ciphertext)
```

The **payload** (before encryption) is JSON:
```json
{
  "records": [
    {"name": "github", "username": "alice", "password": "s3cret"},
    {"name": "email", "username": "alice@example.com", "password": "hunter2"}
  ]
}
```

### Zig Crypto API Reference (0.15.2)

```zig
const crypto = std.crypto;

// Random bytes
var buf: [16]u8 = undefined;
crypto.random.bytes(&buf);

// AES-256-GCM
const Aes256Gcm = crypto.aead.aes_gcm.Aes256Gcm;
// key_length = 32, nonce_length = 12, tag_length = 16

// Encrypt:
var ciphertext: [plaintext.len]u8 = undefined;   // same size as plaintext
var tag: [Aes256Gcm.tag_length]u8 = undefined;
Aes256Gcm.encrypt(&ciphertext, &tag, plaintext, &.{}, nonce, key);

// Decrypt (returns error.AuthenticationFailed on wrong key/tampered data):
Aes256Gcm.decrypt(&decrypted, &ciphertext, tag, &.{}, nonce, key)
    catch return error.WrongPassword;

// Argon2id KDF (REQUIRES allocator as first arg in 0.15.2):
const argon2 = crypto.pwhash.argon2;
var derived_key: [32]u8 = undefined;
try argon2.kdf(
    allocator,         // allocator needed for internal memory
    &derived_key,
    password,          // []const u8
    &salt,             // []const u8, min 8 bytes
    .{ .t = 3, .m = 65536, .p = 1 },
    .argon2id,
);

// SHA-256 HMAC (for key verification)
const HmacSha256 = crypto.auth.hmac.sha2.HmacSha256;
var mac: [HmacSha256.mac_length]u8 = undefined;
HmacSha256.create(&mac, data, &key);
```

---

## Questions

### Q1 (5 pts): Random Byte Generation and Hex Encoding

Write utility functions for the crypto layer:

Requirements:
- `generateSalt() → [16]u8` — 16 cryptographically random bytes
- `generateNonce() → [12]u8` — 12 cryptographically random bytes
- `hexEncode(bytes: []const u8, buf: []u8) → []const u8` — encode bytes to lowercase hex string
- `hexDecode(hex: []const u8, buf: []u8) → ![]u8` — decode hex string to bytes, return error on invalid hex

Write as Zig tests that verify:
- Generated salts are 16 bytes, nonces are 12 bytes
- Two consecutive generations produce different values
- `hexEncode(hexDecode(hex)) == hex` round-trips

**Validation:**
All tests pass with `zig build test`. Use `std.fmt.fmtSliceHexLower` for encoding and `std.fmt.hexToBytes` for decoding (or hand-roll).

### Q2 (5 pts): Key Derivation from Master Password

Implement key derivation:

Requirements:
- `deriveKey(allocator, password: []const u8, salt: [16]u8) → ![32]u8`
- Use Argon2id with parameters: `t=3, m=65536, p=1`
- Same password + salt must always produce the same key
- Different password OR different salt must produce a different key

Write Zig tests:
- Same inputs → same output
- Different password → different output
- Different salt → different output
- Empty password works (edge case)

**Validation:**
```zig
test "key derivation deterministic" {
    const salt = [_]u8{0} ** 16;  // fixed salt for testing
    const key1 = try deriveKey(testing.allocator, "password", salt);
    const key2 = try deriveKey(testing.allocator, "password", salt);
    try testing.expectEqualSlices(u8, &key1, &key2);

    const key3 = try deriveKey(testing.allocator, "different", salt);
    try testing.expect(!std.mem.eql(u8, &key1, &key3));
}
```

### Q3 (5 pts): Encrypt and Decrypt Payload

Implement authenticated encryption:

Requirements:
- `encrypt(key: [32]u8, plaintext: []const u8) → struct { ciphertext: []u8, nonce: [12]u8, tag: [16]u8 }`
- `decrypt(key: [32]u8, ciphertext: []const u8, nonce: [12]u8, tag: [16]u8) → ![]u8`
- Generate a random nonce for each encryption
- Decrypt must return `error.AuthenticationFailed` (or a mapped error) when the key is wrong
- Use an allocator for the output buffers

Write Zig tests:
- Encrypt then decrypt with same key → original plaintext
- Decrypt with wrong key → error
- Tampered ciphertext → error
- Empty plaintext works

**Validation:**
```zig
test "encrypt-decrypt round trip" {
    const key = deriveKey(allocator, "password", salt);
    const result = try encrypt(allocator, key, "secret data");
    defer allocator.free(result.ciphertext);
    const decrypted = try decrypt(allocator, key, result.ciphertext, result.nonce, result.tag);
    defer allocator.free(decrypted);
    try testing.expectEqualStrings("secret data", decrypted);
}
```

### Q4 (5 pts): Vault File Write and Read

Implement vault file I/O using the binary format from the Background section:

Requirements:
- `writeVault(path: []const u8, salt: [16]u8, nonce: [12]u8, tag: [16]u8, ciphertext: []const u8) → !void`
- `readVault(allocator, path: []const u8) → !struct { salt, nonce, tag, ciphertext }`
- Validate magic bytes on read — return error if not `"CCPW"`
- Validate version byte — return error if not 1

Write Zig tests:
- Write then read round-trips all fields
- Reading a file with wrong magic returns error
- Reading a truncated file returns error

**Validation:**
Write a vault, read it back, verify all fields match. Inspect the file with `xxd` to verify the magic bytes `43 43 50 57` at offset 0.

### Q5 (5 pts): JSON Record Serialization

Implement record storage as JSON:

Requirements:
- Define a `Record` struct: `name: []const u8, username: []const u8, password: []const u8`
- Define a `Vault` struct: `records: []Record`
- `serializeVault(allocator, vault: Vault) → ![]u8` — produce JSON string
- `deserializeVault(allocator, json: []const u8) → !Vault` — parse JSON string back
- Use `std.json.parseFromSlice` and `std.json.fmt` (or `std.fmt.allocPrint` with `{f}`)

Write Zig tests:
- Serialize then deserialize round-trips
- Empty records list works
- Records with special characters (quotes, backslashes, unicode) survive round-trip

**Validation:**
```zig
test "json round trip" {
    const vault = Vault{ .records = &.{
        .{ .name = "test", .username = "user", .password = "pass" },
    }};
    const json = try serializeVault(allocator, vault);
    defer allocator.free(json);
    const parsed = try deserializeVault(allocator, json);
    try testing.expectEqualStrings("test", parsed.records[0].name);
}
```

### Q6 (5 pts): Create Vault (Full Pipeline)

Combine Q1-Q5 into a `createVault` function:

Requirements:
- `createVault(allocator, path: []const u8, master_password: []const u8) → !void`
- Generate random salt and nonce
- Derive encryption key from master password + salt
- Serialize an empty vault `{"records": []}` to JSON
- Encrypt the JSON payload
- Write the vault file

Also implement `openVault`:
- `openVault(allocator, path: []const u8, master_password: []const u8) → !Vault`
- Read vault file, derive key, decrypt, parse JSON
- Wrong password → returns descriptive error

Write Zig tests:
- Create vault, open with correct password → empty records
- Create vault, open with wrong password → error
- Open nonexistent file → error

**Validation:**
```zig
test "create and open vault" {
    try createVault(allocator, "/tmp/test.ccpw", "master123");
    const vault = try openVault(allocator, "/tmp/test.ccpw", "master123");
    try testing.expectEqual(@as(usize, 0), vault.records.len);
}
```

### Q7 (5 pts): Add and Retrieve Records

Implement CRUD operations on an open vault:

Requirements:
- `addRecord(allocator, vault: *Vault, name, username, password) → !void` — append a record
- `getRecord(vault: Vault, name: []const u8) → ?Record` — find by name (case-insensitive)
- `saveVault(allocator, path, master_password, vault) → !void` — re-encrypt and write
- Reject duplicate names (return error)
- After adding, must `saveVault` to persist

Write Zig tests:
- Add record, retrieve by name → correct username/password
- Retrieve nonexistent name → null
- Add duplicate name → error
- Add record, save, reopen → record persists

**Validation:**
Create vault, add 3 records, save, reopen with correct password, verify all 3 records are retrievable.

### Q8 (5 pts): CLI — Create and Open Commands

Build the command-line interface:

Requirements:
- `./ccpw create <vault-name>` — prompts for master password (twice for confirmation), creates `<vault-name>.ccpw`
- `./ccpw open <vault-name>` — prompts for master password, enters interactive session
- Password prompt: print `"Master password: "` to stderr, read line from stdin
  - Note: true terminal masking requires `termios` — for this quiz, plaintext input is acceptable
- Confirm prompt for create: `"Confirm password: "` — must match
- Error on mismatch: `"Passwords do not match"` to stderr, exit 1
- Error on wrong password: `"Error: wrong master password"` to stderr, exit 1
- Vault file stored in current directory as `<vault-name>.ccpw`

**Validation:**
```
echo -e "mypass\nmypass" | ./ccpw create testvault
ls testvault.ccpw                    → exists
echo "mypass" | ./ccpw open testvault → enters session (or exits if non-interactive)
echo "wrong" | ./ccpw open testvault  → "Error: wrong master password"
```

### Q9 (5 pts): Interactive Session Commands

After `open`, run an interactive command loop:

Requirements:
- Prompt: `"vault> "`
- Commands:
  - `add` — prompts for name, username, password; adds record; auto-saves
  - `get <name>` — prints username and password for the named record
  - `list` — prints all record names (one per line, sorted)
  - `help` — prints available commands
  - `quit` / `q` — exits session
- Unknown commands: `"Unknown command. Type 'help' for available commands."`
- `get` with no match: `"No record found for '<name>'"`

**Validation:**
```
echo -e "mypass\nmypass" | ./ccpw create demo
printf "mypass\nadd\ngithub\nalice\ns3cret\nget github\nlist\nquit\n" | ./ccpw open demo
```
Expected output includes:
```
vault> Name: Username: Password: Record 'github' saved.
vault> github:
  Username: alice
  Password: s3cret
vault> github
vault>
```

### Q10 (5 pts): Update and Delete Records

Add modification commands:

Requirements:
- `update <name>` — prompts for new username and password; updates existing record; auto-saves
  - If name not found: `"No record found for '<name>'"`
  - Prompt: `"New username (enter to keep): "` — empty input keeps existing value
  - Prompt: `"New password (enter to keep): "` — empty input keeps existing value
- `delete <name>` — removes record after confirmation prompt `"Delete '<name>'? (y/n): "`
  - Only `y` or `Y` confirms; anything else cancels
  - Auto-saves after deletion

Write Zig tests:
- Update changes username/password
- Update with empty input preserves values
- Delete removes record
- Delete confirmation `n` preserves record

**Validation:**
```
printf "mypass\nget github\nupdate github\nbob\nnewpass\nget github\nquit\n" | ./ccpw open demo
```
Should show old credentials, then updated credentials.

### Q11 (5 pts): Password Generator

Add a built-in password generator:

Requirements:
- `generate [length]` — generate and print a random password (default length: 16)
- Character set: uppercase + lowercase + digits + symbols (`!@#$%^&*()-_=+`)
- Use `std.crypto.random` for generation (cryptographically secure)
- Guarantee at least 1 of each character class (uppercase, lowercase, digit, symbol)
- `generate-add <name> <username> [length]` — generate password AND add as a new record
- Print the generated password so the user can see it

Write Zig tests:
- Generated password has correct length
- Generated password contains at least 1 of each character class
- Two consecutive generations produce different passwords
- Length < 4 returns error (can't fit all classes)

**Validation:**
```
printf "mypass\ngenerate\ngenerate 32\ngenerate-add aws admin 20\nget aws\nquit\n" | ./ccpw open demo
```

### Q12 (5 pts): Export, Import, and Master Password Change

Add vault management commands:

Requirements:
- `export <filename>` — write all records as plaintext JSON to the given file
  - Warn: `"WARNING: exported file is NOT encrypted"`
  - Format: `[{"name":"...","username":"...","password":"..."},...]`
- `import <filename>` — read records from a JSON file and merge into vault
  - Skip duplicates (by name), report: `"Skipped duplicate: '<name>'"`
  - Report: `"Imported N records"`
- `change-password` — prompts for current password, new password (twice)
  - Verify current password matches (re-derive key and test)
  - Re-encrypt vault with new master password (new salt, new nonce, new key)

Write Zig tests:
- Export then import into a new vault → same records
- Import with duplicates skips correctly
- Change password → old password fails, new password works

**Validation:**
```
printf "mypass\nexport /tmp/exported.json\nquit\n" | ./ccpw open demo
cat /tmp/exported.json    → readable JSON array

echo -e "newpass\nnewpass" | ./ccpw create demo2
printf "newpass\nimport /tmp/exported.json\nlist\nquit\n" | ./ccpw open demo2
→ shows imported records

printf "mypass\nchange-password\nmypass\nnewpass\nnewpass\nquit\n" | ./ccpw open demo
echo "newpass" | ./ccpw open demo    → succeeds
echo "mypass" | ./ccpw open demo     → "Error: wrong master password"
```
