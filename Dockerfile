FROM python:3.11-slim

ARG OPENJARVIS_COMMIT=daf5027ab3491e8d519fd80b8ceeac381ba3f93e

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OPENJARVIS_HOME=/data/openjarvis

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv

RUN git clone https://github.com/open-jarvis/OpenJarvis.git /opt/openjarvis \
    && cd /opt/openjarvis \
    && git checkout "$OPENJARVIS_COMMIT" \
    && uv sync --extra server --extra inference-cloud --extra inference-google

WORKDIR /opt/openjarvis
VOLUME ["/data/openjarvis"]
EXPOSE 8000

CMD ["sh", "-c", "uv run jarvis serve --host 0.0.0.0 --port ${PORT:-8000} --engine ollama --model ${JARVIS_MODEL:-qwen3.5:2b} --agent orchestrator"]
