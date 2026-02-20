# Initialize local-rag submodule if not already present.
if [[ ! -f "$PWD/opt/local-rag/pyproject.toml" ]]; then
    echo "direnv: initializing local-rag submodule..."
    git submodule update --init opt/local-rag
fi

# Apply Zig tree-sitter support patch if not already applied.
if ! grep -q '".zig"' "$PWD/opt/local-rag/src/ragling/parsers/code.py" 2>/dev/null; then
    echo "direnv: applying Zig support patch to local-rag..."
    git -C "$PWD/opt/local-rag" am "$PWD/patches/0001-feat-add-Zig-tree-sitter-support-for-code-indexing.patch"
fi

# Create stable symlinks for ragling indexing.
# Ragling rejects paths with dot-prefixed components, so rag/ provides clean paths.
mkdir -p "$PWD/rag"
ln -sfn "$PWD/.claude/skills/zig-expert/references" "$PWD/rag/references"
ln -sfn "$PWD/.claude/skills/zig-expert/src"        "$PWD/rag/src"

# Ensure skill src/ is a git repo with at least one commit.
# Ragling's GitRepoIndexer requires a valid HEAD.
_zig_src="$PWD/.claude/skills/zig-expert/src"
if [[ ! -d "$_zig_src/.git" ]]; then
    git -C "$_zig_src" init -b main
    git -C "$_zig_src" add -A
    git -C "$_zig_src" commit -m "Initial commit" --allow-empty
elif ! git -C "$_zig_src" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$_zig_src" add -A
    git -C "$_zig_src" commit -m "Initial commit" --allow-empty
fi
