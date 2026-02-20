# zig-learner

A Claude Code skill for learning Zig through structured lessons, graded exercises, and iterative self-improvement. The real deliverable isn't a Zig program — it's accumulated Zig expertise encoded as a reusable Claude skill.

## What's Here

- **Claude skill** (`.claude/skills/zig-expert/`) — a skill definition that teaches Claude to write idiomatic Zig 0.15.2 code, with decision frameworks, API corrections, and pitfall references
- **Graded exercises** — 17 lessons covering core language, stdlib, error handling, comptime, idioms, concurrency, and tool-building (HTTP server, load balancer, sed/git/xxd clones, IRC client, LSP server, and more)
- **Quiz specifications** — structured exercise definitions used by the agent to generate and grade its own tests
- **Local RAG** — semantic search over Zig references and exercise code via [ragling](https://github.com/stvhay/local-rag), with tree-sitter Zig parsing

## How It Works

An agent invoked with `CLAUDE.md` autonomously:
1. Evaluates its current Zig knowledge (via the skill)
2. Creates a learning plan for the session
3. Takes graded exercises (200 points each, compiled and tested)
4. Self-evaluates: compilation failures, code quality, token efficiency
5. Updates the skill to capture what it learned
6. Commits results with grade records

Grades are tracked in `GRADES.md`. The agent loses points for compilation failures and code quality issues, incentivizing it to internalize patterns rather than iterate through trial and error.

## Prerequisites

- [Nix](https://nixos.org/) with flakes (provides Zig 0.15.2)
- [direnv](https://direnv.net/) (auto-loads the Nix environment)
- [Ollama](https://ollama.com/) with `bge-m3` model (for RAG embeddings)
- [Claude Code](https://claude.ai/code)

## Quick Start

```bash
git clone --recurse-submodules git@github.com:stvhay/zig-learner.git
cd zig-learner
direnv allow    # loads Nix flake, starts Ollama, creates RAG symlinks
```

Claude Code will automatically connect to the ragling MCP server on launch (configured in `.mcp.json`).

## License

[MIT](LICENSE)
