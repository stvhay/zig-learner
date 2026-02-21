# Self-Improvement Report: 00-bootstrap

Observer notes on how well the skill self-updates during training.

## Lesson 01: Core Language Fundamentals — 180/200 (A)

**What it learned:** defer/errdefer LIFO interleaving rule — registration order is all that matters, not type grouping.

**Quality of update:** Update was NOT made by the agent. The self-improvement loop was broken — the agent identified the pattern in GRADES.md but failed to edit SKILL.md. Fixed manually. Subagent prompt was strengthened for subsequent lessons.

**Gap:** First lesson, loop not yet functional.

## Lesson 02: Standard Library Essentials — 200/200 (A)

**What it learned:** Nothing — perfect score, no failures to learn from.

**Quality of update:** N/A. No SKILL.md changes needed.

**Gap:** None. Existing skill knowledge was sufficient for all stdlib exercises.

## Lesson 03: Error Handling & Allocator Patterns — 194/200 (A)

**What it learned:** Three new entries:
1. Defer timing — defers execute after return expression is evaluated (can't observe side effects through return value)
2. Custom allocator VTable signatures (alloc, resize, remap, free with exact types)
3. StackFallbackAllocator, FailingAllocator, checkAllAllocationFailures patterns

**Quality of update:** Good. Self-improvement loop confirmed working — agent directly edited SKILL.md with 3 entries covering all failure patterns. Updates placed in correct sections.

**Gap:** None identified. First lesson where the full cycle (fail → identify → update skill) worked end-to-end.

## Lesson 04: Comptime & Metaprogramming — 194/200 (A)

**What it learned:** Comptime string/array return pattern — functions with comptime params that build strings must return `*const [N]u8` where N is comptime-known via a helper function. Can't return `[]const u8` from a comptime block. This was the #1 failure source (4 of 5 compile failures).

**Quality of update:** Adequate. Dense paragraph added to the "Comptime vs runtime" section covering return type, `comptime var` + `inline for`, and redundant `comptime` keyword trap. Captures all 4 failures in one update.

**Gap:** Prose-heavy — a code snippet showing the pattern would be more scannable than a paragraph. If this pattern recurs in applied lessons, we'll see if the documentation is clear enough.

## Lesson 05: Idioms & Design Patterns — 198/200 (A)

**What it learned:** Two API pitfalls:
1. `mem.sliceTo` requires sentinel-terminated pointer `[*:0]u8`, not plain `[*]u8`
2. Function parameters that shadow same-named methods cause compile errors

**Quality of update:** Appropriate scope — two one-liner comments in the API corrections code block. Right format for quick-reference pitfalls.

**Gap:** No deeper idiom patterns captured from 25 exercises on vtables, iterators, tagged unions, builders. Agent got 23/25 clean, meaning existing knowledge was solid — arguably no update needed.

## Lesson 06: Concurrency & Threading — 199/200 (A)

**What it learned:** Comprehensive concurrency knowledge — the largest single SKILL.md update in the plan:
1. Full concurrency primitives table (Thread, Mutex, Condition, RwLock, Semaphore, WaitGroup, ResetEvent, Thread.Pool) with init patterns and key API
2. Atomics reference: fetchAdd/fetchSub return OLD value, cmpxchgStrong/Weak semantics, memory ordering pairs
3. Thread.Pool.spawn returns error union (must use `try`)

**Quality of update:** Best of the plan. Structured as two tables (primitives + atomics) with bullet-point API notes. Highly scannable. Placed correctly in the data structures / decision frameworks area. This is the format the Lesson 04 comptime update should have used.

**Gap:** No curated code snippets added to `src/exercises/` — the agent updated SKILL.md rules but didn't extract working examples for RAG indexing. (This gap has now been addressed by adding snippet curation as an explicit step in the lesson cycle in CLAUDE.md.)

## Plan Summary

The agent also wrote a final self-evaluation in GRADES.md identifying:
- **Recurring failure categories**: 0.15.2 API diffs (3), comptime return constraints (4), shadowing/naming (2), type strictness (1), defer ordering (2)
- **Knowledge gaps remaining**: io_uring/async I/O, build system, C interop, file I/O/networking
- **Improvement trajectory**: 90% → 100% → 97% → 97% → 99% → 99.5%

## Trend

| Metric | L01 | L02 | L03 | L04 | L05 | L06 |
|--------|-----|-----|-----|-----|-----|-----|
| Score | 180 | 200 | 194 | 194 | 198 | 199 |
| SKILL.md updates | 0 (broken) | 0 (none needed) | 3 entries | 1 entry | 2 entries | 3 entries (largest) |
| Compile failures | ~5 | 0 | 2 | 5 | 2 | 1 |
| Known-mistake repeats | n/a | 0 | 0 | 1 (-2pts) | 0 | 0 |
| Tokens (est.) | ~80k | ~100k | ~152k | ~117k | ~132k | ~70k |
| Tool calls | ? | ? | ? | 81 | 78 | ~45 |

**Final self-improvement assessment:**

The loop is functional and improving. Key observations:

1. **Rule capture works well** — the agent reliably converts compile failures into SKILL.md entries. 10 compile failures across 150 exercises produced 11 skill entries (some proactive additions).

2. **Format quality improved over time** — L03 added inline comments, L04 wrote a prose paragraph, L05 added one-liners, L06 added structured tables. The agent is learning that tables > prose for reference material.

3. **No snippet curation** — the biggest gap. The agent updates rules/pitfalls but never extracted working code examples into `src/exercises/` for RAG. Future sessions searching for concurrency or comptime patterns will find the pre-seeded examples but not the patterns learned during training. Addressed by adding explicit step to lesson cycle.

4. **Token efficiency improved dramatically** — L06 (70k, ~45 calls) was half the cost of L03 (152k) despite similar complexity. The agent learned to batch exercises and use RAG more efficiently.

5. **Known-mistake avoidance is strong** — only 1 repeat penalty in 150 exercises. The skill is being read and applied.

---

## Applied Lessons

### Hex Dump (Applied) — 58/60 (A)

**Self-updating:** Expanded the `getStdOut/getStdErr/getStdIn` warning and added `stdin()` accessor pattern. Known-mistake repeat (-2pts) on `std.io.getStdErr()` despite existing SKILL.md entry.

**RAG:** Used during exercises (stream editor lesson query log confirms pattern). First curated snippet file added: `file_io_cli.zig` (6 tests).

**Skills invoked:** None. Predates skill invocation in subagent prompts.

### Huffman Compression (Applied) — 58/60 (A)

**Self-updating:** Added PriorityQueue API, `createFile`/`writeAll`/`readFileAlloc`, binary I/O patterns (`std.mem.toBytes`, `readInt`). Bit-width trap note (u3 can't hold value 8).

**RAG:** Used during exercises. Created `bit_io_priority_queue.zig` (5 tests).

**Skills invoked:** None. Predates skill invocation in subagent prompts.

### Stream Editor (Applied) — 58/60 (A)

**Self-updating:** Added `readToEndAlloc` (from opened File handle, distinct from `readFileAlloc` which takes a path) and buffered line reading pattern (`bufferedReaderSize` + `readUntilDelimiterOrEof`).

**RAG:** 5 queries in the log (bufferedReader, std.mem, argsWithAllocator, openFile, readAll). All to `zig-references` and `zig-src`. No new snippet file — gap.

**Skills invoked:** None. Predates skill invocation in subagent prompts.

### HTTP Server (Applied) — 59/60 (A)

**Self-updating:** Largest applied lesson update — 24 lines of TCP server patterns, socket timeout, Dir.close() mutability, EpochSeconds date/time chain.

**RAG:** 10 queries covering networking, sockets, path traversal, epoch time, CLI args. Created `networking_http.zig` (170 lines, 6 tests).

**Skills invoked:** First lesson to use complementary skills:
- `writing-skills` — before editing SKILL.md
- `verification-before-completion` — before claiming done
- `systematic-debugging` — not invoked (only 1 compile failure, fixed quickly)

## Applied Trend

| Metric | Hex Dump | Huffman | Stream Editor | HTTP Server |
|--------|----------|---------|---------------|-------------|
| Score | 58/60 | 58/60 | 58/60 | 59/60 |
| SKILL.md updates | 2 entries | 4 entries | 2 entries | 5 entries (24 lines) |
| Snippets added | file_io_cli.zig | bit_io_priority_queue.zig | none | networking_http.zig |
| Skills invoked | none | none | none | writing-skills + verification |
| RAG queries | ? | ? | 5 | 10 |
| Actual tokens | 115k | 119k | ? | 129k |

**Key observations:**
1. Snippet curation now working in 3 of 4 applied lessons (stream editor missed it)
2. Skill invocation only started working in HTTP server — the first lesson where the prompt included them
3. RAG query quality is low (RRF scores ~0.01) — the agent makes the queries but may not get much value
4. Self-estimates consistently undercount actual tokens by 30-40%
