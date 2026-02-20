# Quiz 10: Stream Editor (sed)

Build a Unix-style stream editor in Zig 0.15.2 that processes text line-by-line, applying pattern-based transformations.

**Total: 60 points (12 questions x 5 points)**

## Test Files

- `test.txt` — 10 lines of quoted text (quotes around each line)
- `unquoted.txt` — same 10 lines without surrounding quotes
- `mixed.txt` — 10 lines with interspersed blank lines
- `log.txt` — 14 lines of simulated server log entries (INFO, DEBUG, WARN, ERROR)

## Background: How sed Works

`sed` (stream editor) reads input line-by-line, applies commands to each line, and writes the result to stdout. It does NOT load the entire file into memory.

### Processing Model

```
for each line in input:
    1. Read line into "pattern space" (strip trailing newline)
    2. For each command:
       a. Check if command's address matches this line
       b. If yes, execute the command
    3. Unless suppressed (-n), print the pattern space
    4. Clear pattern space, advance to next line
```

### Command Structure

Every sed command has the form: `[address]command[arguments]`

- **Address** (optional): selects which lines the command applies to
- **Command**: single character (`s`, `p`, `d`, `G`, `q`, `a`, `i`, `c`, `y`)
- **Arguments**: command-specific (e.g., replacement text for `s`)

### Address Types

| Syntax | Meaning | Example |
|--------|---------|---------|
| (none) | All lines | `s/a/b/g` — substitute on every line |
| `N` | Line number N (1-based) | `3d` — delete line 3 |
| `$` | Last line | `$p` — print last line |
| `N,M` | Lines N through M | `2,4p` — print lines 2-4 |
| `/regex/` | Lines matching regex | `/error/p` — print lines containing "error" |
| `N,/regex/` | From line N until regex match | `3,/end/d` — delete from line 3 until "end" found |
| `/regex1/,/regex2/` | From first match to second | `/start/,/stop/p` |

### Substitution Command

`s/pattern/replacement/flags`

- **pattern**: regex to match
- **replacement**: text to substitute (may use `&` for whole match, `\1`-`\9` for groups)
- **flags**:
  - (none): replace first occurrence per line
  - `g`: replace all occurrences per line
  - `p`: print line if substitution was made
  - `N` (number): replace Nth occurrence only
- The delimiter `/` can be any character: `s|path|newpath|g`

### Regex Subset (for this quiz)

Implement these regex features (no need for full PCRE):

| Pattern | Matches | Example |
|---------|---------|---------|
| `.` | Any single character | `c.t` matches `cat`, `cut` |
| `*` | Zero or more of preceding | `ab*c` matches `ac`, `abc`, `abbc` |
| `+` | One or more of preceding | `ab+c` matches `abc`, `abbc` but not `ac` |
| `?` | Zero or one of preceding | `ab?c` matches `ac`, `abc` |
| `^` | Start of line | `^The` matches lines starting with "The" |
| `$` | End of line | `\.$` matches lines ending with period |
| `[...]` | Character class | `[aeiou]` matches vowels |
| `[^...]` | Negated class | `[^0-9]` matches non-digits |
| `\(` `\)` | Capture group | `\(word\)` captures "word" |
| `\1`-`\9` | Back-reference | `\(.\)\1` matches repeated char |
| `\` | Escape next char | `\.` matches literal dot |
| `&` | Whole match (in replacement) | `s/word/[&]/` → `[word]` |

### Other Commands

| Command | Description |
|---------|-------------|
| `p` | Print the pattern space |
| `d` | Delete pattern space, skip to next line |
| `q` | Quit (stop processing) |
| `G` | Append newline + hold space to pattern space (if no hold commands used, appends empty line) |
| `a\text` | Append text after current line |
| `i\text` | Insert text before current line |
| `c\text` | Replace current line with text |
| `y/src/dst/` | Transliterate characters (like `tr`) |
| `=` | Print current line number |

### Command-Line Options

| Option | Meaning |
|--------|---------|
| `-n` | Suppress automatic printing (only explicit `p` prints) |
| `-e cmd` | Specify command (can repeat: `-e cmd1 -e cmd2`) |
| `-i` | Edit file in place |
| `-f file` | Read commands from file |

---

## Questions

### Q1 (5 pts): Line-by-Line Reader and Printer

Write a Zig program `ccsed` that:
- Takes a filename as the last command-line argument
- Reads the file line-by-line (do not load entire file into memory)
- Prints each line to stdout followed by a newline
- If no file is given, read from stdin
- Use buffered reading: `std.io.bufferedReader` or manual chunk-based reading with newline scanning

**Validation:**
```
./ccsed test.txt              → prints all 10 lines (identical to cat test.txt)
echo "hello" | ./ccsed       → prints "hello"
./ccsed nonexistent.txt      → error message to stderr, exit 1
```

### Q2 (5 pts): Basic Substitution (s/pattern/replacement/)

Implement the `s` command for literal string substitution (no regex yet):

Requirements:
- Parse command from first non-option argument: `./ccsed 's/old/new/' file`
- Replace first occurrence of `old` with `new` on each line
- Support the `g` flag: `s/old/new/g` replaces all occurrences
- Support custom delimiters: `s|old|new|g` works the same as `s/old/new/g`
- Handle empty replacement: `s/old//g` deletes all occurrences
- Print each line (modified or not) to stdout

**Validation:**
```
./ccsed 's/"//g' test.txt
```
Expected: each line with surrounding quotes removed. Compare with:
```
sed 's/"//g' test.txt
```

Additional tests:
```
./ccsed 's/busy/BUSY/' unquoted.txt    → replaces first "busy" per line
./ccsed 's/busy/BUSY/g' unquoted.txt   → replaces all "busy" per line
./ccsed 's|life|LIFE|g' unquoted.txt   → pipe delimiter works
```

### Q3 (5 pts): Line Number Addressing and the p Command

Implement line-number addresses and the `p` (print) command:

Requirements:
- Single line address: `3p` prints line 3 (extra copy, since default also prints)
- Range address: `2,4p` prints lines 2-4 (extra copy)
- Last line address: `$p` prints the last line
- Implement `-n` flag: suppress default printing, so only explicit `p` output appears
- Line numbering is 1-based

**Validation:**
```
./ccsed -n '2,4p' unquoted.txt
```
Expected output (lines 2-4 only):
```
The purpose of our lives is to be happy.
Get busy living or get busy dying.
You only live once, but if you do it right, once is enough.
```

Additional tests:
```
./ccsed -n '1p' unquoted.txt      → first line only
./ccsed -n '$p' unquoted.txt      → last line only
./ccsed '3p' unquoted.txt         → all lines printed, line 3 printed twice
```

### Q4 (5 pts): Regex Pattern Matching in Addresses

Implement regex-based addresses:

Requirements:
- `/pattern/p` — print lines matching the pattern
- `/pattern/d` — delete lines matching the pattern
- Support: `.` (any char), `*` (zero+), `^` (start), `$` (end), `[...]` char classes, `\` escape
- The regex engine matches anywhere in the line (not anchored unless `^`/`$` used)

**Validation:**
```
./ccsed -n '/roads/p' unquoted.txt     → prints line containing "roads"
./ccsed -n '/^Life/p' unquoted.txt     → prints line starting with "Life"
./ccsed -n '/\.$/p' unquoted.txt       → prints lines ending with period
./ccsed '/^$/d' mixed.txt              → removes blank lines
```

Compare each with `sed` output.

### Q5 (5 pts): Regex in Substitution

Extend the `s` command to use regex patterns:

Requirements:
- `s/regex/replacement/` — match regex, replace with literal replacement
- `&` in replacement refers to the entire matched text
- `\1` through `\9` refer to captured groups (`\(...\)`)
- `+` (one or more), `?` (zero or one) in patterns

**Validation:**
```
# Wrap each word "life" (case-insensitive via class) in brackets:
./ccsed 's/[Ll]ife/[&]/g' unquoted.txt

# Extract just the log level from log lines:
./ccsed -n 's/^[^ ]* \([A-Z]*\).*/\1/p' log.txt
```
Expected for the log extraction: `INFO`, `DEBUG`, `INFO`, `WARN`, `ERROR`, etc. (one per line).

Additional tests:
```
# Replace multiple spaces with single space:
echo "hello    world" | ./ccsed 's/  */ /g'    → "hello world"

# Swap first two words:
echo "hello world" | ./ccsed 's/\([^ ]*\) \([^ ]*\)/\2 \1/'  → "world hello"
```

### Q6 (5 pts): The d (Delete) and q (Quit) Commands

Implement `d` and `q`:

- `d`: Delete the pattern space. Skip remaining commands for this line and move to the next line. No output for this line (even without `-n`).
- `q`: Quit immediately. Print the current line (unless `-n`), then stop processing.

**Validation:**
```
# Delete lines 3-5:
./ccsed '3,5d' unquoted.txt       → prints 7 lines (lines 3,4,5 removed)

# Delete lines matching ERROR:
./ccsed '/ERROR/d' log.txt        → prints 11 lines (3 ERROR lines removed)

# Print first 3 lines then quit:
./ccsed '3q' unquoted.txt         → prints lines 1-3 only

# Print until pattern found:
./ccsed '/fear/q' unquoted.txt    → prints lines 1-7 (quits after "fear" line)
```

### Q7 (5 pts): The G, =, and y Commands

Implement three more commands:

- `G`: Append a newline character and then the hold space to the pattern space. (With no prior `h`/`H` commands, the hold space is empty, so `G` effectively appends a blank line.)
- `=`: Print the current line number (followed by newline) to stdout.
- `y/source/dest/`: Transliterate each character in `source` to the corresponding character in `dest`. Source and dest must be the same length.

**Validation:**
```
# Double-space the file:
./ccsed G unquoted.txt            → each line followed by blank line (20 lines total)

# Number all lines:
./ccsed = unquoted.txt            → line number before each line

# ROT13:
echo "Hello World" | ./ccsed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm/'
→ "Uryyb Jbeyq"
```

### Q8 (5 pts): The a, i, and c Commands

Implement text insertion commands:

- `a\text`: After printing the current line, also print `text` on a new line
- `i\text`: Before printing the current line, print `text` on a new line
- `c\text`: Replace the current line entirely with `text`

**Validation:**
```
# Add a header before line 1:
./ccsed '1i\=== QUOTES ===' unquoted.txt    → header, then all 10 lines

# Add footer after last line:
./ccsed '$a\=== END ===' unquoted.txt       → all 10 lines, then footer

# Replace line 5 with custom text:
./ccsed '5c\[REDACTED]' unquoted.txt        → line 5 replaced

# Add separator after every ERROR line:
./ccsed '/ERROR/a\---' log.txt              → "---" after each ERROR line
```

### Q9 (5 pts): Multiple Commands (-e and -f)

Support executing multiple commands in sequence:

Requirements:
- `-e command`: specify a command (can be repeated)
- `-f script_file`: read commands from a file (one per line)
- Commands execute in order for each line
- A `d` command skips remaining commands for that line

**Validation:**
Create `script.sed`:
```
s/"//g
/^$/d
3,5s/busy/BUSY/g
```

```
# Multiple -e flags:
./ccsed -e 's/"//g' -e '/^$/d' test.txt

# Script file:
./ccsed -f script.sed test.txt

# Mixed:
./ccsed -e '1i\HEADER' -f script.sed -e '$a\FOOTER' test.txt
```

### Q10 (5 pts): Regex Range Addresses

Implement regex-based ranges and mixed ranges:

Requirements:
- `/regex1/,/regex2/command`: apply command from first line matching regex1 through first line matching regex2
- `N,/regex/command`: from line N through first matching line
- After the range ends, a new range can begin if regex1 matches again
- Range is inclusive of both boundary lines

**Validation:**
```
# Print from first INFO to first ERROR:
./ccsed -n '/INFO/,/ERROR/p' log.txt

# Delete from line 3 to line matching "success":
./ccsed '3,/success/d' unquoted.txt

# Print between WARN markers:
./ccsed -n '/WARN/,/WARN/p' log.txt    → prints from first WARN through second WARN
```

Compare each with `sed` output.

### Q11 (5 pts): In-Place Editing (-i)

Implement the `-i` flag for in-place file editing:

Requirements:
- Write output to a temporary file in the same directory
- After processing completes, rename the temporary file to the original filename
- Preserve file permissions of the original file
- If processing fails (error), do NOT modify the original file
- `-i` combined with other flags: `./ccsed -i -e 's/old/new/g' file.txt`

**Validation:**
```
# Create a working copy:
cp unquoted.txt /tmp/edit_test.txt

# Edit in place:
./ccsed -i 's/Life/Code/g' /tmp/edit_test.txt

# Verify:
grep Code /tmp/edit_test.txt    → shows modified lines
grep Life /tmp/edit_test.txt    → no output (all replaced)
```

### Q12 (5 pts): Substitution Flags (p, N) and Final Integration

Implement remaining substitution flags and ensure full integration:

Requirements:
- `p` flag on substitution: `s/pattern/replacement/p` — if substitution was made, print the line (useful with `-n`)
- Numeric flag: `s/pattern/replacement/2` — replace only the 2nd occurrence
- Combined flags: `s/pattern/replacement/gp` — global replace and print
- Ensure all commands, addresses, and flags work together correctly

**Validation:**
```
# Print only lines where substitution occurred:
./ccsed -n 's/ERROR/***ERROR***/p' log.txt    → only the 3 ERROR lines, modified

# Replace second occurrence only:
echo "aaa bbb aaa bbb" | ./ccsed 's/aaa/XXX/2'    → "aaa bbb XXX bbb"

# Complex pipeline — clean and filter log:
./ccsed -n -e '/ERROR/s/^[^ ]* //' -e '/ERROR/p' log.txt
→ prints ERROR lines with date prefix removed
```

Final integration test — compare all outputs against system `sed`:
```
for cmd in \
    "s/\"//g" \
    "-n '2,4p'" \
    "-n '/roads/p'" \
    "G" \
    "/^$/d" \
    "'3,5d'" \
    "'3q'" \
    "=" \
; do
    diff <(sed $cmd test.txt) <(./ccsed $cmd test.txt) && echo "PASS: $cmd" || echo "FAIL: $cmd"
done
```
