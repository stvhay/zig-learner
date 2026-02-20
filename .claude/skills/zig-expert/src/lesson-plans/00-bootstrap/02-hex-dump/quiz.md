# Quiz 13: Build Your Own xxd

Implement a hex dump utility in Zig 0.15.2 that replicates the core behavior of Unix `xxd`.

**Total: 60 points (12 questions x 5 points)**

## Background: Hex Dump Format

### Standard Output Format

`xxd` displays binary data in three columns per line:

```
OFFSET: HEX_DATA  ASCII
```

Specifically, for a 16-byte line with default settings (`-g 2`, `-c 16`):

```
00000000: 4865 6c6c 6f2c 2057 6f72 6c64 2120 5468  Hello, World! Th
^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^
offset    hex groups (8 groups of 2 bytes = 16 bytes)  ASCII printable
```

**Offset**: 8 lowercase hex digits, followed by `: ` (colon + space).

**Hex data**: Bytes encoded as lowercase hex, grouped by `-g` octets (default 2), separated by single spaces. The last group may be partial.

**ASCII column**: Each byte displayed as its ASCII character if printable (0x20-0x7E), otherwise `.` (dot). Separated from hex by two spaces. The ASCII column is right-aligned to its expected position on partial (last) lines — the hex section is padded with spaces to maintain alignment.

### Padding on Partial Lines

When the last line has fewer than `-c` bytes, the hex section is padded with spaces so the ASCII column stays aligned:

```
Full line (16 bytes):   00000000: 4142 4344 4546 4748 494a 4b4c 4d4e 4f50  ABCDEFGHIJKLMNOP
Partial (8 bytes):      00000008: 4142 4344 4546 4748                      ABCDEFGH
Partial (1 byte):       00000010: 41                                       A
```

The padding fills the space where hex groups would appear, maintaining the two-space gap before ASCII.

### Grouping (`-g`)

The `-g` flag controls how many bytes per hex group:
- `-g 1`: `48 65 6c 6c ...` (space between every byte)
- `-g 2` (default): `4865 6c6c ...` (pairs)
- `-g 4`: `48656c6c 6f2c2057 ...` (quads)

Number of separating spaces between groups = 1.

### Little-Endian Mode (`-e`)

With `-e`, byte order within each group is reversed. Default grouping becomes 4:
- Normal: `48656c6c` → bytes `48 65 6c 6c` in file order
- `-e`: `6c6c6548` → same bytes, reversed within the 4-byte group

### Columns (`-c`)

The `-c` flag controls bytes per line (default: 16). This changes both the hex and ASCII column widths:
- `-c 8`: 8 bytes per line (4 groups of 2)
- `-c 32`: 32 bytes per line (16 groups of 2)

### Seeking (`-s`)

The `-s` flag skips to a byte offset before reading. The offset display reflects the actual file position:
```
xxd -s 10 file.txt
0000000a: 6c64 2120 ...  ld! ...
```
Supports hex offsets with `0x` prefix: `-s 0x10` = skip 16 bytes.

### Length Limit (`-l`)

The `-l` flag limits total bytes output:
```
xxd -l 16 file.txt     → only first 16 bytes
xxd -s 10 -l 16 file   → 16 bytes starting at offset 10
```

### Plain Hex Mode (`-p`)

`-p` outputs only continuous hex digits, no offset or ASCII:
```
48656c6c6f2c20576f726c64212054686973206973206120746573742066
696c6520666f72207878642e
```
Lines wrap at 60 hex characters (30 bytes) by default.

### Uppercase Mode (`-u`)

`-u` uses uppercase hex digits (A-F) instead of lowercase (a-f). The offset stays lowercase:
```
00000000: 4865 6C6C 6F2C 2057 6F72 6C64 2120 5468  Hello, World! Th
```

### C Include Mode (`-i`)

`-i` outputs a C-style array declaration:
```c
unsigned char filename_ext[] = {
  0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64,
  0x21, 0x20
};
unsigned int filename_ext_len = 14;
```

Variable name derived from filename: replace non-alphanumeric chars with `_`, prepend `_` if starts with digit.

### Reverse Mode (`-r`)

`-r` converts a hex dump back to binary. It reads lines in the standard `xxd` format (offset: hex  ascii) and extracts the hex bytes, ignoring the offset and ASCII columns:
- Parses hex digits after the `: ` on each line
- Stops at the double-space before ASCII (or end of hex data)
- Ignores spacing between groups
- Writes raw bytes to output

Combined with `-p`, reverses plain hex mode (reads continuous hex, no offsets).

### Binary/Bits Mode (`-b`)

`-b` displays each byte as 8 binary digits instead of 2 hex digits:
```
00000000: 01000001 01000010                                      AB
```
Groups are always 1 byte (8 chars each), separated by spaces.

### Zig I/O Reference (0.15.2)

```zig
const std = @import("std");

// CLI arguments
const args = try std.process.argsAlloc(allocator);
defer std.process.argsFree(allocator, args);

// File reading
const file = try std.fs.cwd().openFile(filename, .{});
defer file.close();
// Seek:
try file.seekTo(offset);
// Read into buffer:
const n = try file.read(&buf);  // returns usize (bytes read)

// Stdin
const stdin = std.fs.File.stdin();

// Stdout (buffered)
var out_buf: [4096]u8 = undefined;
var out_writer = std.fs.File.stdout().writer(&out_buf);
const stdout = &out_writer.interface;
// IMPORTANT: flush() is on .interface, NOT on the writer struct
try stdout.flush();

// Stderr
var err_buf: [256]u8 = undefined;
var err_writer = std.fs.File.stderr().writer(&err_buf);
const stderr = &err_writer.interface;
try stderr.flush();

// Formatting
try stdout.print("{x:0>8}: ", .{offset});     // 8-digit hex offset
try stdout.print("{x:0>2}", .{byte});          // 2-digit hex byte
try stdout.print("{X:0>2}", .{byte});          // uppercase hex
try stdout.print("{b:0>8}", .{byte});          // 8-digit binary

// String to int (for parsing hex offsets like "0x10")
const offset = try std.fmt.parseInt(usize, str, 0);  // base 0 = auto-detect

// Hex char to nibble
fn hexCharToNibble(c: u8) ?u4 {
    return switch (c) {
        '0'...'9' => @intCast(c - '0'),
        'a'...'f' => @intCast(c - 'a' + 10),
        'A'...'F' => @intCast(c - 'A' + 10),
        else => null,
    };
}
```

---

## Test Files

Create these before starting:

```bash
# test1.txt — simple ASCII
echo -n "Hello, World! This is a test file for xxd." > test1.txt

# test2.bin — all 256 byte values
python3 -c "import sys; sys.stdout.buffer.write(bytes(range(256)))" > test2.bin

# test3.txt — short file (2 bytes)
echo -n "AB" > test3.txt

# test4.txt — exactly 16 bytes
echo -n "ABCDEFGHIJKLMNOP" > test4.txt

# test5.txt — 17 bytes (one full line + partial)
echo -n "ABCDEFGHIJKLMNOPQ" > test5.txt
```

---

## Questions

### Q1 (5 pts): Basic Hex Dump — Read and Format

Implement the basic hex dump output for a file argument:

Requirements:
- `./ccxxd <filename>` — read file and output standard hex dump to stdout
- 16 bytes per line (`-c 16` default)
- 2-byte grouping (`-g 2` default)
- 8-digit lowercase hex offset with `: ` separator
- Lowercase hex digits for data
- ASCII column: printable chars (0x20-0x7E) shown as-is, all others as `.`
- Two spaces between hex and ASCII columns
- Partial last lines: pad hex section with spaces so ASCII column aligns

**Validation:**
```
./ccxxd test1.txt
```
Expected:
```
00000000: 4865 6c6c 6f2c 2057 6f72 6c64 2120 5468  Hello, World! Th
00000010: 6973 2069 7320 6120 7465 7374 2066 696c  is is a test fil
00000020: 6520 666f 7220 7878 642e                 e for xxd.
```

```
./ccxxd test3.txt
```
Expected:
```
00000000: 4142                                     AB
```

Compare byte-for-byte against `xxd test1.txt`.

### Q2 (5 pts): Binary File and Non-Printable Characters

Verify correct handling of all 256 byte values:

Requirements:
- Bytes 0x00-0x1F → `.` in ASCII column
- Bytes 0x20-0x7E → literal character
- Bytes 0x7F-0xFF → `.` in ASCII column
- Hex encoding must be correct for every byte value

**Validation:**
```
./ccxxd test2.bin
```
Expected (first 4 lines):
```
00000000: 0001 0203 0405 0607 0809 0a0b 0c0d 0e0f  ................
00000010: 1011 1213 1415 1617 1819 1a1b 1c1d 1e1f  ................
00000020: 2021 2223 2425 2627 2829 2a2b 2c2d 2e2f   !"#$%&'()*+,-./
00000030: 3031 3233 3435 3637 3839 3a3b 3c3d 3e3f  0123456789:;<=>?
```

Expected (last line, bytes 0xF0-0xFF):
```
000000f0: f0f1 f2f3 f4f5 f6f7 f8f9 fafb fcfd feff  ................
```

Verify: `diff <(./ccxxd test2.bin) <(xxd test2.bin)` should show no differences.

### Q3 (5 pts): Grouping (`-g`) Flag

Implement the `-g` flag to control bytes per hex group:

Requirements:
- `-g 1`: one byte per group (`48 65 6c 6c ...`)
- `-g 2`: two bytes per group (default: `4865 6c6c ...`)
- `-g 4`: four bytes per group (`48656c6c 6f2c2057 ...`)
- `-g 0`: no grouping — all hex digits continuous per line (no spaces in hex section, but still has 2-space gap before ASCII)
- Groups separated by single space
- Partial last group on last line handled correctly
- ASCII column alignment must adjust for different group sizes

**Validation:**
```
./ccxxd -g 1 test1.txt | head -1
```
Expected:
```
00000000: 48 65 6c 6c 6f 2c 20 57 6f 72 6c 64 21 20 54 68  Hello, World! Th
```

```
./ccxxd -g 4 test1.txt | head -1
```
Expected:
```
00000000: 48656c6c 6f2c2057 6f726c64 21205468  Hello, World! Th
```

Verify against `xxd -g 1`, `xxd -g 4`.

### Q4 (5 pts): Columns (`-c`) and Length (`-l`) Flags

Implement column width and length limiting:

Requirements:
- `-c N`: N bytes per line (default 16)
- `-l N`: limit total output to N bytes
- `-c` and `-l` can be combined
- `-l 0`: produce no output
- `-c` affects both hex and ASCII column widths

**Validation:**
```
./ccxxd -c 8 test1.txt
```
Expected:
```
00000000: 4865 6c6c 6f2c 2057  Hello, W
00000008: 6f72 6c64 2120 5468  orld! Th
00000010: 6973 2069 7320 6120  is is a
00000018: 7465 7374 2066 696c  test fil
00000020: 6520 666f 7220 7878  e for xx
00000028: 642e                 d.
```

```
./ccxxd -l 16 test1.txt
```
Expected:
```
00000000: 4865 6c6c 6f2c 2057 6f72 6c64 2120 5468  Hello, World! Th
```

```
./ccxxd -l 16 -c 4 test1.txt
```
Expected:
```
00000000: 4865 6c6c  Hell
00000004: 6f2c 2057  o, W
00000008: 6f72 6c64  orld
0000000c: 2120 5468  ! Th
```

### Q5 (5 pts): File Seeking (`-s`) Flag

Implement byte offset seeking:

Requirements:
- `-s N`: skip to byte N before reading
- Offset display reflects actual file position
- Supports decimal: `-s 10`
- Supports hex with prefix: `-s 0x10`
- Combinable with `-l`: `-s 10 -l 16` reads 16 bytes starting at offset 10
- Seeking past end of file: produce no output (not an error)

**Validation:**
```
./ccxxd -s 10 test1.txt
```
Expected:
```
0000000a: 6c64 2120 5468 6973 2069 7320 6120 7465  ld! This is a te
0000001a: 7374 2066 696c 6520 666f 7220 7878 642e  st file for xxd.
```

```
./ccxxd -s 0x10 test1.txt
```
Expected:
```
00000010: 6973 2069 7320 6120 7465 7374 2066 696c  is is a test fil
00000020: 6520 666f 7220 7878 642e                 e for xxd.
```

```
./ccxxd -s 10 -l 16 test1.txt
```
Expected:
```
0000000a: 6c64 2120 5468 6973 2069 7320 6120 7465  ld! This is a te
```

### Q6 (5 pts): Stdin Support

Support reading from standard input when no filename is given:

Requirements:
- `./ccxxd` with no filename reads from stdin
- `./ccxxd -` also reads from stdin (explicit)
- All flags (`-g`, `-c`, `-l`, `-s`) work with stdin
- `-s` with stdin: skip N bytes by reading and discarding (cannot seek on pipe)
- Output format identical to file mode

**Validation:**
```
echo -n "stdin test" | ./ccxxd
```
Expected:
```
00000000: 7374 6469 6e20 7465 7374                 stdin test
```

```
echo -n "Hello, World!" | ./ccxxd -c 8
```
Expected:
```
00000000: 4865 6c6c 6f2c 2057  Hello, W
00000008: 6f72 6c64 21         orld!
```

```
echo -n "0123456789ABCDEF" | ./ccxxd -s 4 -l 8
```
Expected:
```
00000004: 3435 3637 3839 4142  456789AB
```

### Q7 (5 pts): Plain Hex Mode (`-p`)

Implement plain hex dump mode:

Requirements:
- `-p`: output only continuous hex digits, no offset or ASCII columns
- Lines wrap at 60 hex characters (30 bytes) by default
- Works with `-l` to limit bytes
- Works with `-s` to seek
- Works with `-u` for uppercase
- No trailing spaces on lines

**Validation:**
```
./ccxxd -p test1.txt
```
Expected:
```
48656c6c6f2c20576f726c64212054686973206973206120746573742066
696c6520666f72207878642e
```

```
./ccxxd -p -l 10 test1.txt
```
Expected:
```
48656c6c6f2c20576f726c64
```

(Note: 10 bytes = 20 hex chars, fits on one line.)

### Q8 (5 pts): Uppercase Mode (`-u`)

Implement uppercase hex output:

Requirements:
- `-u`: hex digits A-F instead of a-f
- Offset remains lowercase hex
- Works with all other flags (`-g`, `-c`, `-l`, `-s`, `-p`)
- Only affects hex data, not ASCII column

**Validation:**
```
./ccxxd -u test1.txt | head -1
```
Expected:
```
00000000: 4865 6C6C 6F2C 2057 6F72 6C64 2120 5468  Hello, World! Th
```

Note: digits 0-9 are unchanged; only a→A, b→B, c→C, d→D, e→E, f→F.

```
./ccxxd -u -p test1.txt | head -1
```
Expected:
```
48656C6C6F2C20576F726C64212054686973206973206120746573742066
```

### Q9 (5 pts): Little-Endian Mode (`-e`)

Implement little-endian byte order display:

Requirements:
- `-e`: reverse byte order within each hex group
- Default grouping changes to 4 bytes (not 2) when `-e` is used without `-g`
- Can be combined with `-g` to set custom group size
- ASCII column remains in file order (not reversed)
- Offset unchanged
- Partial groups (last group with fewer bytes): hex digits are right-aligned within group width, with leading spaces

**Validation:**
```
./ccxxd -e test1.txt | head -1
```
Expected:
```
00000000: 6c6c6548 57202c6f 646c726f 68542021  Hello, World! Th
```

```
./ccxxd -e -g 8 test1.txt | head -1
```
Expected:
```
00000000: 57202c6f6c6c6548 68542021646c726f  Hello, World! Th
```

Note: With `-g 8`, each group is 8 bytes reversed. The ASCII column still reads left-to-right in file order.

**Partial group padding with `-e`:** When the last group has fewer bytes than `-g`, the hex digits are right-aligned within the group width, with leading spaces:
```
echo -n "ABCDE" | ./ccxxd -e
```
Expected:
```
00000000: 44434241       45                    ABCDE
```
The first group (4 bytes: `ABCD` → reversed `DCBA` → `44434241`) is full. The second group (1 byte: `E` → `45`) is right-aligned in a 4-char-wide field with leading spaces.

### Q10 (5 pts): C Include Mode (`-i`)

Implement C source output:

Requirements:
- `-i`: output as C array declaration
- Variable name derived from filename:
  - Replace `/`, `.`, `-`, and other non-alphanumeric chars with `_`
  - Full path included (e.g., `/tmp/test.txt` → `__tmp_test_txt`)
- Array contents: `0x` prefixed hex bytes, 12 per line, comma-separated
- Final line: `unsigned int <name>_len = <byte count>;`
- Works with `-l` to limit bytes

**Validation:**
```
./ccxxd -i test3.txt
```
Expected:
```
unsigned char test3_txt[] = {
  0x41, 0x42
};
unsigned int test3_txt_len = 2;
```

```
./ccxxd -i test4.txt
```
Expected:
```
unsigned char test4_txt[] = {
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c,
  0x4d, 0x4e, 0x4f, 0x50
};
unsigned int test4_txt_len = 16;
```

### Q11 (5 pts): Reverse Mode (`-r`)

Implement converting hex dump back to binary:

Requirements:
- `-r`: read hex dump from file (or stdin), output binary
- Parse standard xxd format: skip offset + `:`, parse hex digits, ignore ASCII column
- The ASCII column begins after a double-space (`  `) gap — stop hex parsing there
- Ignore spacing between groups
- Output raw bytes to stdout
- Round-trip must be exact: `./ccxxd file | ./ccxxd -r` produces original file

**Validation:**
```
./ccxxd test1.txt | ./ccxxd -r > /tmp/restored.txt
diff test1.txt /tmp/restored.txt
```
Should show no differences.

```
./ccxxd test2.bin | ./ccxxd -r > /tmp/restored.bin
diff test2.bin /tmp/restored.bin
```
Should show no differences (all 256 byte values survive round-trip).

```
./ccxxd -c 8 test1.txt | ./ccxxd -r > /tmp/restored2.txt
diff test1.txt /tmp/restored2.txt
```
Different `-c` values in the dump should still reverse correctly.

### Q12 (5 pts): Reverse Plain Hex (`-r -p`) and Binary Mode (`-b`)

Implement reverse-plain and binary display:

**Reverse plain hex (`-r -p`):**
- Read continuous hex digits (no offsets, no ASCII), output binary
- Ignore whitespace and newlines in input
- Round-trip: `./ccxxd -p file | ./ccxxd -r -p` produces original file

**Binary mode (`-b`):**
- Display each byte as 8 binary digits (0/1) instead of 2 hex digits
- Grouping fixed at 1 byte (8 chars per group)
- ASCII column still present, right-aligned as with hex mode
- Works with `-c`, `-l`, `-s`

**Validation (reverse plain):**
```
./ccxxd -p test1.txt | ./ccxxd -r -p > /tmp/restored_p.txt
diff test1.txt /tmp/restored_p.txt
```
Should show no differences.

**Validation (binary mode):**
```
echo -n "AB" | ./ccxxd -b
```
Expected:
```
00000000: 01000001 01000010                                      AB
```

```
echo -n "Hello" | ./ccxxd -b
```
Expected:
```
00000000: 01001000 01100101 01101100 01101100 01101111           Hello
```

Note: With `-b`, default columns is 6 bytes per line (each byte is 8+1 chars wide, so 6 fits in ~54 chars). Verify actual `xxd -b` column count — it uses 6 bytes/line by default.
