#!/usr/bin/env bash
# Populate rag/zig-stdlib/ with curated Zig 0.15.2 stdlib source for RAG indexing.
# Creates a git repo that ragling's tree-sitter code indexer can parse.
#
# Usage: setup-stdlib-rag.sh [target-dir]
#   target-dir defaults to rag/zig-stdlib relative to the repo root.

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
TARGET="${1:-$REPO_ROOT/rag/zig-stdlib}"

# Find Zig stdlib path from zig env
ZIG_STD=$(zig env | grep 'std_dir' | sed 's/.*"\(.*\)".*/\1/')
if [[ -z "$ZIG_STD" || ! -d "$ZIG_STD" ]]; then
    echo "error: could not find Zig stdlib at: $ZIG_STD" >&2
    exit 1
fi

# Skip if already populated with the right version
if [[ -d "$TARGET/.git" ]]; then
    echo "zig-stdlib: already exists at $TARGET, skipping"
    exit 0
fi

echo "zig-stdlib: copying curated modules from $ZIG_STD ..."
mkdir -p "$TARGET"

# Curated top-level modules — the useful subset for RAG
MODULES=(
    # Core data structures
    array_list.zig hash_map.zig multi_array_list.zig sort.zig
    # Memory
    mem.zig heap.zig heap/
    # I/O and filesystem
    Io/ fs.zig fs/ net.zig posix.zig
    # Formats
    fmt.zig json.zig json/
    # Threading
    Thread.zig Thread/ atomic.zig
    # Compression and crypto
    compress/ crypto/Sha1.zig
    # Common utilities
    ascii.zig debug.zig enums.zig math.zig math/
    process.zig testing.zig time.zig unicode.zig
    # HTTP
    http/Client.zig http/Server.zig
    # Root
    std.zig
)

for mod in "${MODULES[@]}"; do
    src="$ZIG_STD/$mod"
    if [[ -d "$src" ]]; then
        mkdir -p "$TARGET/$mod"
        # Copy .zig files preserving directory structure
        find "$src" -name '*.zig' -print0 | while IFS= read -r -d '' f; do
            rel="${f#$ZIG_STD/}"
            mkdir -p "$TARGET/$(dirname "$rel")"
            cp "$f" "$TARGET/$rel"
        done
    elif [[ -f "$src" ]]; then
        mkdir -p "$TARGET/$(dirname "$mod")"
        cp "$src" "$TARGET/$mod"
    else
        echo "  warning: $mod not found in stdlib" >&2
    fi
done

FILE_COUNT=$(find "$TARGET" -name '*.zig' | wc -l | tr -d ' ')
echo "zig-stdlib: copied $FILE_COUNT files"

# Initialize as git repo (required for ragling code indexer)
git -C "$TARGET" init -b main
git -C "$TARGET" add -A
ZIG_VERSION=$(zig version 2>/dev/null || echo "unknown")
git -C "$TARGET" commit -m "Zig $ZIG_VERSION stdlib (curated for RAG)"

echo "zig-stdlib: ready at $TARGET"
