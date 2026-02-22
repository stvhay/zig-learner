#!/usr/bin/env bash
# Usage: rag-index.sh <subcommand> [args...]
# Examples:
#   rag-index.sh project zig-references /path/to/references/
#   rag-index.sh group zig-src
# Runs SYNCHRONOUSLY (blocks until done). For async: run in background Bash task.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec uv run --directory "$PROJECT_ROOT/opt/local-rag" \
  ragling --config "$PROJECT_ROOT/.claude/skills/zig-expert/ragling.json" \
  index "$@"
