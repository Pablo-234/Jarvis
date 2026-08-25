"""Very small local router for Jarvis hybrid inference.

The router itself always runs on the local Ollama model. It returns only
LOCAL or STRATEGIC so routing does not consume OpenAI tokens.
"""

from __future__ import annotations

import os

import httpx


prompt = os.environ.get("JARVIS_ROUTER_PROMPT", "").strip()
model = os.environ.get("JARVIS_LOCAL_MODEL", "qwen3.5:9b").strip() or "qwen3.5:9b"

system = """You are a routing classifier for an AI agent.
Return exactly one word: LOCAL or STRATEGIC.

Choose LOCAL for routine execution: simple questions, summaries, formatting,
straightforward file work, repetitive tasks, simple coding and ordinary tool use.

Choose STRATEGIC when the task materially benefits from a frontier model:
complex architecture, difficult debugging, ambiguous multi-step planning,
important business/financial strategy, difficult research synthesis, novel
reasoning, security-sensitive design, or a task where a wrong plan would waste
substantial time or money.

When uncertain, choose LOCAL. Do not answer the task itself."""

if not prompt:
    print("LOCAL")
    raise SystemExit(0)

payload = {
    "model": model,
    "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": prompt},
    ],
    "stream": False,
    "think": False,
    "options": {"temperature": 0.0, "num_predict": 8},
}

try:
    response = httpx.post("http://ollama:11434/api/chat", json=payload, timeout=90)
    response.raise_for_status()
    answer = response.json().get("message", {}).get("content", "").upper()
    print("STRATEGIC" if "STRATEGIC" in answer else "LOCAL")
except Exception:
    # Routing failure must never prevent Jarvis from working.
    print("LOCAL")
