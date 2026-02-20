# Quiz 11: Build Your Own Git

Implement core git internals in Zig 0.15.2 — the object database, index, refs, and porcelain commands.

**Total: 60 points (12 questions x 5 points)**

## Background: Git's Object Model

Git is a content-addressable filesystem. All data is stored as **objects** identified by their SHA-1 hash. There are four object types:

### Object Types

| Type | Purpose | Example |
|------|---------|---------|
| **blob** | File contents (no metadata) | The bytes of `hello.txt` |
| **tree** | Directory listing (mode + name + hash per entry) | Maps filenames to blob/tree hashes |
| **commit** | Snapshot pointer + metadata (author, message, parent) | Points to a tree + parent commit(s) |
| **tag** | Named reference to an object (not required for this quiz) | — |

### Object Storage Format

Every object is stored as: `<type> <size>\0<content>`, zlib-deflated, at path `.git/objects/<first 2 hex chars>/<remaining 38 hex chars>`.

**Blob example** for file containing `hello world\n` (12 bytes):
```
Raw bytes:    "blob 12\0hello world\n"
SHA-1 hash:   3b18e512dba79e4c8300dd08aeb37f8e728b8dad
Stored at:    .git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad
File content: zlib-deflate(raw bytes)
```

### Tree Object Binary Format

A tree is a sequence of entries, each formatted as:
```
<mode> <filename>\0<20-byte SHA-1 hash in binary>
```
- **mode**: ASCII octal (`100644` for regular file, `100755` for executable, `40000` for directory)
- **filename**: the file/directory name (NOT full path)
- **hash**: 20 raw bytes (NOT hex-encoded)
- Entries are sorted by name (directories sort as if they had a trailing `/`)

Example (one file `hello.txt`):
```
Raw: "100644 hello.txt\0" + <20 bytes of 3b18e512...>
Wrapped: "tree <size>\0" + raw
SHA-1 of wrapped = tree hash
```

### Commit Object Format

Plain text, newline-delimited:
```
tree <tree-hash>\n
parent <parent-hash>\n        ← omit for first commit, repeat for merges
author <name> <email> <unix-timestamp> <timezone>\n
committer <name> <email> <unix-timestamp> <timezone>\n
\n
<commit message>\n
```

Wrapped as: `"commit <size>\0" + <text above>`

### Index (Staging Area) Format

The index (`.git/index`) is a binary file:

**Header** (12 bytes):
| Offset | Size | Content |
|--------|------|---------|
| 0 | 4 | Signature: `DIRC` (0x44495243) |
| 4 | 4 | Version: 2 (big-endian u32) |
| 8 | 4 | Number of entries (big-endian u32) |

**Each entry** (variable length):
| Offset | Size | Content |
|--------|------|---------|
| 0 | 4 | ctime seconds (big-endian u32) |
| 4 | 4 | ctime nanoseconds (big-endian u32) |
| 8 | 4 | mtime seconds (big-endian u32) |
| 12 | 4 | mtime nanoseconds (big-endian u32) |
| 16 | 4 | dev (big-endian u32) |
| 20 | 4 | ino (big-endian u32) |
| 24 | 4 | mode (big-endian u32, e.g., 0x000081A4 = 100644) |
| 28 | 4 | uid (big-endian u32) |
| 32 | 4 | gid (big-endian u32) |
| 36 | 4 | file size (big-endian u32) |
| 40 | 20 | SHA-1 hash (raw bytes) |
| 60 | 2 | flags: assume_valid(1) + extended(1) + stage(2) + name_length(12) |
| 62 | var | File path (variable length, NUL-terminated) |
| — | — | Padding to 8-byte boundary (1-8 NUL bytes) |

**Footer**: 20-byte SHA-1 checksum of all preceding bytes.

### Refs

- `.git/HEAD` contains: `ref: refs/heads/<branch>\n`
- `.git/refs/heads/<branch>` contains: `<commit-hash>\n` (40 hex chars + newline)

### Zig + SHA-1 and Zlib

```zig
// SHA-1 (use std.crypto)
const Sha1 = std.crypto.hash.Sha1;
var hasher = Sha1.init(.{});
hasher.update(data);
const digest: [20]u8 = hasher.finalResult();
// hex encode: std.fmt.fmtSliceHexLower(&digest)

// Zlib compress — use @cImport(@cInclude("zlib.h"))
// Link with: mod.link_system_library("z")
// Or for simplicity, shell out to python/pigz for early steps,
// then implement proper zlib later.

// Alternative: std.compress.zlib (if available in 0.15.2)
// Check: std.compress.flate or std.compress.zlib
```

---

## Questions

### Q1 (5 pts): SHA-1 Hashing of Git Objects

Write a Zig function `hashObject` that computes the git blob hash for arbitrary content:

Requirements:
- Input: file contents as `[]const u8`
- Prepend the header: `"blob <size>\0"` where `<size>` is the decimal content length
- Compute SHA-1 of header+content
- Return the 20-byte digest
- Write a CLI: `./ccgit hash-object <filename>` prints the 40-char hex hash to stdout

**Validation:**
```
echo -n "hello world" > /tmp/test_blob.txt
./ccgit hash-object /tmp/test_blob.txt
```
Expected: `95d09f2b10159347eece71399a7e2e907ea3df4f`

```
echo "hello world" > /tmp/test_blob2.txt
./ccgit hash-object /tmp/test_blob2.txt
```
Expected: `3b18e512dba79e4c8300dd08aeb37f8e728b8dad`

Verify against: `git hash-object <file>`

### Q2 (5 pts): Write Blob Objects to Object Store

Extend `hash-object` with a `-w` flag that writes the object to `.git/objects/`:

Requirements:
- Zlib-deflate the `"blob <size>\0<content>"` bytes
- Write to `.git/objects/<first 2 hex>/<remaining 38 hex>`
- Create the subdirectory if it doesn't exist
- If the object already exists, skip writing (content-addressable = idempotent)
- For zlib: use `std.compress.flate.compressor` or link system zlib via `@cImport`

**Validation:**
```
cd /tmp && mkdir test_repo && cd test_repo && git init
echo "hello world" > hello.txt
./ccgit hash-object -w hello.txt
git cat-file -p 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
```
Expected output from `git cat-file`: `hello world`

### Q3 (5 pts): Read and Display Objects (cat-file)

Implement `cat-file` to read objects from the store:

Requirements:
- `./ccgit cat-file -t <hash>` — print the object type (`blob`, `tree`, `commit`)
- `./ccgit cat-file -s <hash>` — print the content size in bytes
- `./ccgit cat-file -p <hash>` — pretty-print the content
  - For blobs: print raw content
  - For trees: print `<mode> <type> <hash>\t<name>` per entry (type inferred from mode)
  - For commits: print raw text
- Read the file at `.git/objects/<2>/<38>`, zlib-inflate, parse header

**Validation:**
```
# In a real git repo:
./ccgit cat-file -t 3b18e512dba79e4c8300dd08aeb37f8e728b8dad   → "blob"
./ccgit cat-file -s 3b18e512dba79e4c8300dd08aeb37f8e728b8dad   → "12"
./ccgit cat-file -p 3b18e512dba79e4c8300dd08aeb37f8e728b8dad   → "hello world"
```

### Q4 (5 pts): Init Command

Implement `./ccgit init [directory]`:

Requirements:
- Create the following structure:
  ```
  .git/
    HEAD          → contains "ref: refs/heads/main\n"
    objects/      → empty directory
    refs/
      heads/      → empty directory
      tags/       → empty directory
  ```
- If `.git` already exists, print error and exit 1
- If `directory` argument is given, create repo there; otherwise use current directory
- Print: `Initialized empty repository in <absolute path>/.git/`

**Validation:**
```
cd /tmp && rm -rf test_init && mkdir test_init
./ccgit init /tmp/test_init
ls /tmp/test_init/.git/HEAD        → exists
cat /tmp/test_init/.git/HEAD       → "ref: refs/heads/main"
ls /tmp/test_init/.git/objects     → exists (empty)
ls /tmp/test_init/.git/refs/heads  → exists (empty)
```

### Q5 (5 pts): Write Tree Objects

Implement a function that creates a tree object from a list of entries:

Requirements:
- Each entry: `(mode, name, hash)` where mode is `"100644"`, name is filename, hash is 20-byte SHA-1
- Sort entries by name
- Serialize in tree binary format: `<mode> <name>\0<20-byte hash>` concatenated
- Wrap with `"tree <size>\0"`, compute SHA-1, zlib-deflate, write to object store
- Implement `./ccgit write-tree` — reads the index and writes tree objects for the current staging area (for now: create tree from all tracked files in the working directory, flat — no subdirectories yet)

**Validation:**
```
cd /tmp/test_init
echo "hello world" > hello.txt
./ccgit hash-object -w hello.txt
# Manually create a tree with one entry
./ccgit write-tree    → prints tree hash
git cat-file -p <tree-hash>   → "100644 blob 3b18e5... hello.txt"
```

### Q6 (5 pts): Write Index File

Implement writing the git index (`.git/index`):

Requirements:
- `./ccgit update-index --add <filename>` — hash the file, write the blob, add an entry to the index
- Write the index in v2 format (see Index Format in Background section)
- Fill stat fields (ctime, mtime, dev, ino, mode, uid, gid, size) from `std.fs.cwd().statFile()`
- Hash field = the blob's SHA-1
- Flags: name_length = min(path.len, 0xFFF), other flag bits = 0
- Pad each entry to 8-byte boundary
- Write 20-byte SHA-1 checksum of all preceding bytes as footer
- Multiple calls should merge entries (sorted by path), updating existing entries

**Validation:**
```
cd /tmp/test_init
echo "hello world" > hello.txt
./ccgit update-index --add hello.txt
git status
```
`git status` should show `hello.txt` as "Changes to be committed" (new file).

### Q7 (5 pts): Read Index File

Implement reading the index back:

Requirements:
- `./ccgit ls-files` — list all files in the index, one per line
- `./ccgit ls-files --stage` — show mode, hash, stage, and path: `<mode> <hash> <stage>\t<path>`
- Parse the binary index format: header, entries, footer
- Validate the checksum (SHA-1 of all bytes before the final 20)
- Handle index files written by real `git` (to verify interop)

**Validation:**
```
# After Q6's update-index:
./ccgit ls-files              → hello.txt
./ccgit ls-files --stage      → 100644 3b18e512... 0	hello.txt

# Also works on a real git index:
cd /path/to/real/git/repo
./ccgit ls-files              → lists all tracked files
```

### Q8 (5 pts): Commit Command

Implement `./ccgit commit -m "<message>"`:

Requirements:
1. Read the index
2. Write all blobs (if not already written)
3. Build and write a tree object from the index entries
4. Create a commit object:
   - `tree <tree-hash>`
   - `parent <parent-hash>` if HEAD points to an existing commit (omit for first commit)
   - `author ccgit <ccgit@example.com> <unix-timestamp> +0000`
   - `committer ccgit <ccgit@example.com> <unix-timestamp> +0000`
   - blank line
   - commit message
5. Write the commit object to the object store
6. Update `.git/refs/heads/main` (or whatever HEAD points to) with the new commit hash
7. Print: `[main <short-hash>] <message>`

**Validation:**
```
cd /tmp/test_init
echo "hello world" > hello.txt
./ccgit update-index --add hello.txt
./ccgit commit -m "first commit"
git log --oneline              → shows the commit
git cat-file -p HEAD           → shows tree, author, message
git cat-file -p HEAD^{tree}    → shows hello.txt entry
```

### Q9 (5 pts): Status Command

Implement `./ccgit status`:

Requirements:
- Read HEAD ref to determine current branch name
- Compare index against HEAD's tree to find staged changes:
  - **new file**: in index but not in HEAD tree
  - **modified**: in both but different hash
  - **deleted**: in HEAD tree but not in index
- Compare working directory against index to find unstaged changes:
  - **modified**: file exists but hash differs from index
  - **deleted**: in index but missing from filesystem
- Find untracked files: in working directory but not in index
- Skip `.git/` directory when scanning
- Output format similar to `git status` (grouped by category)

**Validation:**
```
cd /tmp/test_init
./ccgit status                     → clean (after commit from Q8)
echo "changed" > hello.txt
./ccgit status                     → "modified: hello.txt" (unstaged)
./ccgit update-index --add hello.txt
./ccgit status                     → "modified: hello.txt" (staged)
echo "new file" > new.txt
./ccgit status                     → new.txt appears as untracked
```

### Q10 (5 pts): Log Command

Implement `./ccgit log`:

Requirements:
- Start from HEAD, follow parent chain
- For each commit, print:
  ```
  commit <full-hash>
  Author: <author-name> <author-email>
  Date:   <human-readable date>

      <commit message>
  ```
- Stop when a commit has no parent (root commit)
- Support `--oneline` flag: `<short-hash> <first line of message>`

**Validation:**
```
cd /tmp/test_init
# Make a second commit:
echo "updated" > hello.txt
./ccgit update-index --add hello.txt
./ccgit commit -m "second commit"
./ccgit log
```
Should show two commits, newest first, with full details. Compare with `git log`.

### Q11 (5 pts): Tree Objects with Subdirectories

Extend `write-tree` to handle nested directories:

Requirements:
- Scan the index for paths containing `/` (e.g., `src/main.zig`)
- Build tree objects recursively: leaf trees for deepest directories, then parent trees
- Each directory becomes its own tree object in the store
- A tree entry for a subdirectory uses mode `40000` (note: 5 digits, not 6)
- Sort entries correctly: files and directories sorted together by name

**Validation:**
```
cd /tmp/test_init
mkdir -p src
echo "fn main() void {}" > src/main.zig
echo "readme" > README.md
./ccgit update-index --add src/main.zig
./ccgit update-index --add README.md
./ccgit write-tree
git cat-file -p <tree-hash>
```
Expected tree output:
```
100644 blob <hash>	README.md
040000 tree <hash>	src
```
And `git cat-file -p <src-tree-hash>` should show `main.zig`.

### Q12 (5 pts): Diff Command

Implement `./ccgit diff` showing unstaged changes:

Requirements:
- Compare each file in the index against its working directory version
- For modified files, output unified diff format:
  ```
  diff --git a/<path> b/<path>
  index <old-hash>..<new-hash> <mode>
  --- a/<path>
  +++ b/<path>
  @@ -<old-start>,<old-count> +<new-start>,<new-count> @@
   context line
  -removed line
  +added line
   context line
  ```
- Implement a basic diff algorithm: find longest common subsequence (LCS), then output additions/deletions with 3 lines of context
- For deleted files: all lines prefixed with `-`
- For new files in index with no working copy: skip (that's a staged delete)
- Color output is optional

**Validation:**
```
cd /tmp/test_init
echo "hello world" > hello.txt
./ccgit update-index --add hello.txt
./ccgit commit -m "base"
echo "hello zig" > hello.txt
./ccgit diff
```
Expected:
```
diff --git a/hello.txt b/hello.txt
--- a/hello.txt
+++ b/hello.txt
@@ -1 +1 @@
-hello world
+hello zig
```
Compare with `git diff`.
