#!/usr/bin/env bash
# Usage: rag-collections.sh [list|info <name>]
# Wraps: ragling collections with project config
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec uv run --directory "$PROJECT_ROOT/opt/local-rag" \
  ragling --config "$PROJECT_ROOT/.claude/skills/zig-expert/ragling.json" \
  collections "$@"
