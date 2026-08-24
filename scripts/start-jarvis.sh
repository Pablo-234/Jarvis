#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

git submodule update --init --recursive

if ! command -v uv >/dev/null 2>&1; then
  python3 -m pip install --user uv
  export PATH="$HOME/.local/bin:$PATH"
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
JARVIS_MODEL="${JARVIS_MODEL:-qwen3.5:2b}"
OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
export OLLAMA_HOST

if [[ "$HOST" != "127.0.0.1" && "$HOST" != "localhost" && -z "${OPENJARVIS_API_KEY:-}" ]]; then
  echo "Refusing to expose Jarvis without OPENJARVIS_API_KEY." >&2
  exit 2
fi

cd OpenJarvis
uv sync --extra server --extra inference-cloud --extra inference-google

ARGS=(serve --host "$HOST" --port "$PORT" --agent orchestrator)

if curl -fsS "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  ARGS+=(--engine ollama --model "$JARVIS_MODEL")
fi

exec uv run jarvis "${ARGS[@]}"
