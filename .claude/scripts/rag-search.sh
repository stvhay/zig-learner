#!/usr/bin/env bash
# Usage: rag-search.sh <query> [--collection <name>] [--top <k>]
# Wraps: ragling search with project config
# For background agents that can't use MCP tools.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec uv run --directory "$PROJECT_ROOT/opt/local-rag" \
  ragling --config "$PROJECT_ROOT/.claude/skills/zig-expert/ragling.json" \
  search "$@"
