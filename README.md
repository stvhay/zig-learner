# zig-learner

An AI that teaches itself a programming language — and improves measurably.

`zig-learner` is a self-improving Claude Code skill that learns Zig through graded practice. It writes exercises, attempts them, grades itself, and updates its own reference manual after each failure. Every entry in the manual traces to a mistake.

## The Idea

Large language models forget everything between sessions. But they can read. Load a reference document at session start, and the model behaves as if it knows that material.

What if the model writes its own reference document?

`zig-learner` tests this. An agent works through programming exercises, compiles them, grades itself, reflects on failures, and updates a persistent skill file. The next session loads that file and performs better. The loop: exercise, compile, grade, reflect, update, repeat.

The skill file grew from zero to 350 lines of curated Zig reference — 40+ API corrections, 7 decision frameworks, and 8 style idioms. Every line traces to a compile failure or a broken test.

## What It Builds

Each applied lesson builds a complete, working program:

- **Hex dump** — xxd-compatible with 12 output modes, verified byte-for-byte against the real thing
- **Huffman compressor** — full encode/decode pipeline with bit-level I/O, compresses Les Misérables to 58.5%
- **Stream editor** — sed clone with a recursive regex engine, BRE support, in-place editing
- **HTTP server** — static file serving, keep-alive, concurrent connections, path traversal protection
- **Load balancer** — 580-line TCP proxy with round-robin, health checks, graceful shutdown, live stats
- **Git internals** — SHA-1 object store, index format, commits, status, log, unified diff

Six more planned: encrypted password manager, IRC client, MCP server, LSP server, Redis server.

## Results

Twelve lessons completed. All A's.

| Lesson | Topic | Score | Grade |
|--------|-------|-------|-------|
| 01 | Core Language Fundamentals | 180/200 | A |
| 02 | Standard Library Essentials | 200/200 | A |
| 03 | Error Handling & Allocators | 194/200 | A |
| 04 | Comptime & Metaprogramming | 194/200 | A |
| 05 | Idioms & Design Patterns | 198/200 | A |
| 06 | Concurrency & Threading | 199/200 | A |
| 07 | Hex Dump | 58/60 | A |
| 08 | Huffman Compression | 58/60 | A |
| 09 | Stream Editor | 58/60 | A |
| 10 | HTTP Server | 59/60 | A |
| 11 | Load Balancer | 58/60 | A |
| 12 | Git Internals | 57/60 | A |
| **Total** | | **1513/1560** | **97%** |

225 exercises. 15 compile failures. 4 known-pitfall repeats across the full run. The agent reads what it wrote and makes fewer mistakes because of it.

## How It Works

An orchestrator launches lesson subagents in two modes:

1. **Exercise** — The agent reads the quiz and the skill file, works through exercises under a grading rubric, writes grade records, and returns. No reflection yet.
2. **Self-assessment** — The orchestrator provides cost data and resumes the same agent. The agent identifies patterns behind compile failures, checks whether the skill already covers them, updates the skill, and commits.

The grading rubric drives the incentives. Every failed compilation costs 1 point. Repeating a mistake the skill file already documents costs 2 — double penalty for ignoring your own notes. This pressure forces the agent to consult the skill, not just iterate through trial and error.

Three RAG collections back the agent: hand-written reference docs, curated stdlib source, and exercise code — all tree-sitter parsed for Zig-aware chunking.

Cost grows O(n^2) with tool round-trips (every call replays the full conversation), so the agent batches aggressively: multiple solutions per turn, all reads front-loaded, verbose output piped through `head`. Applied lessons cost $3.67-$6.79 each.

## Future Direction

The current system improves *what the agent knows*. The next step: improve *how it teaches*. An OODA-loop architecture where the agent observes its own performance telemetry, proposes atomic mutations to its teaching strategy, and verifies predictions against subsequent lessons. See [WHITEPAPER.md](WHITEPAPER.md) for the full design.

## Getting Started

**Prerequisites:** [Nix](https://nixos.org/) with flakes, [direnv](https://direnv.net/), [Ollama](https://ollama.com/) with `bge-m3`, [Claude Code](https://claude.ai/code)

```bash
git clone --recurse-submodules git@github.com:stvhay/zig-learner.git
cd zig-learner
direnv allow    # loads Nix flake, starts Ollama, sets up RAG
```

Claude Code connects to the RAG server automatically via `.mcp.json`.

## License

[MIT](LICENSE)
