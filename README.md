# Jarvis

Jarvis uses [OpenJarvis](https://github.com/open-jarvis/OpenJarvis) as its foundation.

The upstream project is pinned in the `OpenJarvis/` submodule, while this repository adds the runtime and control layer around it.

## What is included

- OpenJarvis pinned to commit `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- local Ollama runtime with `qwen3.5:2b`
- Docker/Compose launcher
- protected OpenJarvis API launcher
- owner-only GitHub Actions remote console

## Remote Jarvis Console

Issue #1 is the remote console. A comment from repository owner `Pablo-234` beginning with:

```text
/jarvis <prompt>
```

starts an isolated GitHub Actions runner, boots Ollama, runs the real OpenJarvis CLI and posts the answer back to the issue. Commands from other GitHub users are ignored by the workflow.

This gives Jarvis an on-demand remote execution path without exposing an unauthenticated public agent server.

## Local Docker runtime

Create `.env` from `.env.example`, replace `OPENJARVIS_API_KEY` with a long random secret, then run:

```bash
docker compose up --build
```

The stack starts Ollama, downloads the configured local model and starts the OpenJarvis API on port 8000.

## Clone for development

```bash
git clone --recurse-submodules https://github.com/Pablo-234/Jarvis.git
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

## Security

Do not commit API keys or credentials. The local launcher refuses to expose Jarvis on a non-loopback address unless `OPENJARVIS_API_KEY` is configured. The GitHub remote console intentionally enables only a small baseline tool set.

## Upstream and license

- Project: `open-jarvis/OpenJarvis`
- Pinned commit: `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- License: Apache License 2.0 (`OpenJarvis/LICENSE`)

Orbit remains a separate repository and is not part of this project.
