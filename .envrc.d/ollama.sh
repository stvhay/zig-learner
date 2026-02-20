# Ensure Ollama is running (needed for ragling embeddings)
if ! curl -sf http://localhost:11434 >/dev/null 2>&1; then
    echo "direnv: starting Ollama in background..."
    ollama serve >/dev/null 2>&1 &
    disown
fi
