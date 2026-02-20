# Quiz 3: Huffman Compression Tool

Build a command-line Huffman compression/decompression tool in Zig 0.15.2.

**Total: 60 points (12 questions x 5 points)**

## Test Files

All test files are in this directory:
- `les_miserables.txt` — Les Misérables by Victor Hugo (3,369,045 bytes, 73,589 lines). Primary test file.
- `simple_test.txt` — Contains `aaabbc` (6 bytes). Use for early-step validation.

## Background: Huffman Coding Algorithm

Huffman coding is a lossless compression algorithm that assigns variable-length bit codes to characters based on frequency. More frequent characters get shorter codes. The codes are **prefix-free**: no code is a prefix of another, so the compressed stream can be decoded unambiguously.

### How It Works

1. **Count frequencies** of each byte in the input.
2. **Build a binary tree** bottom-up:
   - Start with one leaf node per unique byte, weighted by frequency.
   - Use a **priority queue** (min-heap). Repeatedly extract the two lowest-frequency nodes, create a new internal node with those as children (combined frequency = sum), and re-insert it. Repeat until one node remains — the root.
3. **Generate codes** by traversing the tree: left edge = `0`, right edge = `1`. The path from root to a leaf is that byte's code. Frequent bytes end up near the root (short codes); rare bytes are deeper (long codes).
4. **Encode**: Replace each input byte with its bit code, pack into bytes, write to file with a header that stores the tree/frequency table.
5. **Decode**: Read the header, rebuild the tree, walk the tree bit-by-bit to recover original bytes.

### Worked Example

Input: `aaabbc` (6 bytes)

Frequencies: `a=3, b=2, c=1`

Building the tree:
```
Priority queue: [(c,1), (b,2), (a,3)]
1. Extract (c,1) and (b,2) → combine → (cb,3)
   Queue: [(a,3), (cb,3)]
2. Extract (a,3) and (cb,3) → combine → (root,6)

Tree:
        (6)
       /   \
     a(3)  (3)
           / \
         c(1) b(2)

Codes: a=0, c=10, b=11
```

Encoding `aaabbc`: `0 0 0 11 11 10` = `00011110` = 1 byte + 2 padding bits
Original: 6 bytes → Compressed payload: 1 byte (plus header overhead)

### Reference Values for les_miserables.txt

Use these to validate your implementation:

| Byte | Char | Frequency | Expected Code Length |
|------|------|-----------|---------------------|
| 32 | (space) | 516,353 | 3 bits |
| 101 | 'e' | 325,664 | 3 bits |
| 116 | 't' | 223,000 | 4 bits |
| 97 | 'a' | 199,732 | 4 bits |
| 10 | (newline) | 73,589 | 6 bits |
| 88 | 'X' | 333 | 13 bits |

- Unique byte values: 123
- Minimum code length: 3 bits
- Maximum code length: 22 bits
- Total compressed payload (no header): 1,969,961 bytes
- Compression ratio (payload only): ~58.5%

---

## Questions

### Q1 (5 pts): Read File and Count Byte Frequencies

Write a Zig program that:
- Takes a filename as a command-line argument
- Reads the file and counts the frequency of each byte value (0-255)
- Prints each byte value and its count to stdout (only non-zero frequencies)
- Format: one line per byte, `<byte_value>: <count>` (decimal), sorted by byte value

**Validation:**
- `simple_test.txt` → `97: 3`, `98: 2`, `99: 1`
- `les_miserables.txt` → byte 88 (X) has count 333, byte 116 (t) has count 223000
- Total unique byte values in les_miserables.txt: 123

### Q2 (5 pts): Priority Queue for Tree Building

Implement a min-priority-queue of Huffman tree nodes suitable for building the tree. Each node is either:
- A **leaf**: holds a byte value and its frequency
- An **internal node**: holds a combined frequency and left/right children

Requirements:
- Use `std.PriorityQueue` (remember: compareFn returns `std.math.Order`, not `bool`)
- Nodes with equal frequency should be handled deterministically (break ties by inserting order or byte value)
- Print the queue contents after inserting all leaf nodes from `simple_test.txt` to verify ordering

**Validation with `simple_test.txt`:**
- After inserting all leaves, extracting min should yield: `c(1)`, then `b(2)`, then `a(3)`

### Q3 (5 pts): Build the Huffman Tree

Using the priority queue from Q2, implement the tree-building algorithm:
1. Insert one leaf node per unique byte (weighted by frequency)
2. Repeatedly extract two minimum-frequency nodes, create a parent with combined frequency, re-insert
3. Continue until one node (the root) remains

Requirements:
- Nodes must be heap-allocated (use `std.heap.page_allocator` or `GeneralPurposeAllocator`)
- Print the root's total frequency to verify

**Validation:**
- `simple_test.txt` → root frequency = 6
- `les_miserables.txt` → root frequency = 3,369,045 (equal to file size)

### Q4 (5 pts): Generate Prefix Codes from Tree

Traverse the Huffman tree to generate a prefix-code table mapping each byte to its variable-length bit string.

Requirements:
- Left child = append `0`, right child = append `1`
- Store codes as a fixed-size array: `[256]?Code` where `Code` holds the bit pattern and its length
- Print all codes for `simple_test.txt` to verify
- Print code lengths for bytes 32 (space), 101 (e), 116 (t), 88 (X) from `les_miserables.txt`

**Validation:**
- `simple_test.txt`: all 3 characters should have codes. Most frequent (`a`) should have the shortest code.
- `les_miserables.txt`: space and 'e' should have 3-bit codes, 't' should have 4-bit code, 'X' should have 13-bit code

### Q5 (5 pts): Bit Writer — Pack Bits into Bytes

Implement a bit-level writer that can:
- Accept individual bits or a sequence of bits
- Buffer them and flush full bytes to an underlying writer (e.g., a `std.fs.File` writer or `std.ArrayList(u8)`)
- Flush remaining bits (with zero-padding) and report how many padding bits were added

**Validation:**
- Writing bits `0,0,0,1,1,1,1,0` should produce the byte `0x1E`
- Writing bits `1,1,0` then flushing should produce `0xC0` (11000000) with 5 padding bits
- Writing the codes for `aaabbc` from Q4's table and flushing should produce the expected compressed payload

### Q6 (5 pts): Encode File to Compressed Format

Combine Q1-Q5 to compress a file:
- Read the input file
- Build frequency table, Huffman tree, and code table
- Write a header containing the frequency table (format: number of entries as u16, then for each entry: byte value as u8, frequency as u32, all little-endian)
- Write the total number of bits in the payload as a u64 (little-endian) after the frequency table
- Write the compressed bit stream

Command: `./huffman encode <input> <output>`

**Validation:**
- Compressing `les_miserables.txt` should produce a file smaller than the original (3,369,045 bytes)
- The compressed file (excluding header) should be approximately 1,969,961 bytes
- Header size: 1 entry = 5 bytes (1 byte value + 4 freq), plus 2 bytes count + 8 bytes bit count = `2 + (123 * 5) + 8 = 625 bytes`

### Q7 (5 pts): Read Header and Rebuild Tree

Implement decoding of the header written in Q6:
- Read the frequency table from the header
- Rebuild the Huffman tree from the frequencies (must produce identical tree to encoding)
- Print the root frequency and number of unique bytes to verify

Command: `./huffman decode <input> <output>` (this question: just parse header and verify)

**Validation:**
- Reading the header from a compressed `les_miserables.txt` should yield: 123 unique bytes, root frequency 3,369,045

### Q8 (5 pts): Bit Reader — Unpack Bytes to Bits

Implement a bit-level reader (inverse of Q5):
- Read from a byte stream one bit at a time
- Track total bits read
- Stop after reading exactly the number of bits specified in the header (to ignore padding)

**Validation:**
- Reading the byte `0x1E` (00011110) bit-by-bit should yield: 0, 0, 0, 1, 1, 1, 1, 0
- Reading `0xC0` and stopping after 3 bits should yield: 1, 1, 0

### Q9 (5 pts): Decode Compressed Data

Complete the decoder:
- Read header, rebuild tree (Q7)
- Read compressed bits using bit reader (Q8)
- Walk the Huffman tree: for each bit, go left (0) or right (1). When a leaf is reached, output that byte and restart from root
- Stop after consuming exactly the number of payload bits from the header
- Write decoded bytes to the output file

**Validation:**
- Compressing then decompressing `simple_test.txt` should produce identical output
- Compressing then decompressing `les_miserables.txt` should produce a file identical to the original (compare with `std.mem.eql` or file hash)

### Q10 (5 pts): Round-Trip Verification

Add a `verify` command that:
- Compresses a file to a temporary location
- Decompresses the result to another temporary location
- Compares the decompressed output byte-for-byte with the original
- Reports: original size, compressed size, compression ratio, and whether round-trip succeeded
- Cleans up temporary files

Command: `./huffman verify <input>`

**Validation:**
- `./huffman verify simple_test.txt` → round-trip match, reports sizes
- `./huffman verify les_miserables.txt` → round-trip match, compressed size < 1,971,000 bytes (payload + 625 byte header), ratio ~58-59%

### Q11 (5 pts): Handle Edge Cases

Ensure your implementation correctly handles:
1. **Empty file** (0 bytes) — compresses and decompresses to empty file
2. **Single-byte file** (e.g., just `A`) — tree has one leaf, code is `0`, compresses and decompresses correctly
3. **Single repeated byte** (e.g., `AAAA`) — tree has one leaf, still works
4. **All 256 byte values present** — generate a test file with one of each byte value, verify round-trip

Write these as Zig `test` blocks that the build system can run with `zig build test`.

**Validation:**
- All 4 edge cases round-trip correctly
- No panics, no memory leaks (use `std.testing.allocator`)

### Q12 (5 pts): Performance and Final Integration

Create the final polished CLI tool with proper error handling:
- `./huffman encode <input> <output>` — compress
- `./huffman decode <input> <output>` — decompress
- `./huffman verify <input>` — round-trip test
- Invalid arguments print usage to stderr and exit with code 1
- File-not-found prints error message to stderr and exits with code 1
- Use buffered I/O for performance (read/write in 4096+ byte chunks, not byte-by-byte)
- Must handle `les_miserables.txt` in under 5 seconds

**Validation:**
- All commands work correctly with proper error messages
- `les_miserables.txt` round-trips successfully
- Compressed output is smaller than original
- No memory leaks
- Runs within time limit
