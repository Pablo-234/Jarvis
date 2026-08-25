# Jarvis

Jarvis uses [OpenJarvis](https://github.com/open-jarvis/OpenJarvis) as its foundation and adds a persistent persona, private runtime memory, a protected local runtime, a local dashboard and an owner-only GitHub control plane.

The upstream project is pinned in the `OpenJarvis/` submodule, while this repository contains the runtime and safety layer around it.

## One-click run on Windows

The simplest way to start everything is to double-click:

```text
run.cmd
```

`run.cmd` launches `run.ps1`, which:

1. checks Docker Desktop,
2. creates `.env` if necessary,
3. generates a strong private OpenJarvis API key on first run,
4. migrates the old project default `qwen3.5:2b` to the local default `qwen3.5:9b` while preserving custom model choices,
5. starts Ollama, OpenJarvis and the dashboard with Docker Compose,
6. waits for the dashboard,
7. opens it automatically in the browser.

Dashboard: `http://127.0.0.1:8765`

OpenJarvis API docs: `http://127.0.0.1:8000/docs`

Useful local files:

```text
run.cmd               # double-click: start everything
run.ps1               # PowerShell one-click launcher
start-jarvis.ps1      # start stack without opening dashboard
status-jarvis.ps1     # container status
stop-jarvis.ps1       # stop Jarvis
```

## Local dashboard

The dashboard is a tiny nginx container with no Node.js/Python requirement on the host. It shows:

- Jarvis API online/offline state,
- Ollama online/offline state,
- detected local model,
- all models currently available in Ollama,
- shortcuts to OpenJarvis API docs, GitHub Jarvis Console and the repository.

It binds only to `127.0.0.1` by default and does not store the OpenJarvis API key.

## What is included

- OpenJarvis pinned to commit `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- local Ollama runtime with `qwen3.5:9b`
- persistent Jarvis persona (`SOUL.md`, `USER.md`, `MEMORY.md` seed)
- private SQLite memory persisted between GitHub Actions runs
- Docker/Compose local runtime with a durable data volume
- local Jarvis dashboard on port 8765
- one-click Windows launcher
- protected OpenJarvis API launcher
- owner-only GitHub Actions console
- safe development mode that can prepare code changes as reviewable pull requests

## Remote Jarvis Console

Issue #1 is the remote console. Only commands posted by repository owner `Pablo-234` are accepted.

### Normal mode

```text
/jarvis <prompt>
```

This starts an isolated GitHub Actions runner, restores Jarvis's private runtime memory, boots Ollama, runs the real OpenJarvis CLI and posts the answer back to the issue.

Normal mode can reason, calculate, search the web, make protected HTTP requests, read files and use long-term memory.

### Development mode

```text
/jarvis-dev <task>
```

Development mode additionally gives Jarvis an ephemeral repository workspace with file editing, patching, git inspection, Python execution and shell access. The model itself receives no GitHub token.

After Jarvis finishes, a separate trusted workflow step:

1. restores protected automation files,
2. resets the upstream `OpenJarvis` submodule,
3. excludes `.env`, runtime memory and protected paths,
4. commits remaining changes to a new branch,
5. opens a pull request for human review.

Jarvis DEV never merges its own work into `main`.

## Memory model

Jarvis has two memory layers:

- **Persona:** public, version-controlled seed files under `jarvis/` that define behaviour and non-sensitive context.
- **Private runtime memory:** OpenJarvis SQLite memory under `.jarvis-runtime/`, restored and saved through GitHub Actions cache between invocations. It is ignored by git and is never added to automated PRs.

Do not store passwords, API keys, access tokens or other secrets in Jarvis memory.

## Local Docker runtime

Manual start is still available:

```powershell
.\start-jarvis.ps1
```

or:

```bash
docker compose up --build -d
```

The stack starts Ollama, downloads the configured local model, starts OpenJarvis on port 8000 and the dashboard on port 8765. The Jarvis persona/config is copied into the durable `jarvis-data` volume, so local memory survives container restarts.

## Clone for development

```bash
git clone --recurse-submodules https://github.com/Pablo-234/Jarvis.git
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

## Security boundaries

- Commands from GitHub users other than `Pablo-234` are ignored.
- `actions/checkout` uses `persist-credentials: false` before the model runs.
- Jarvis never receives `GITHUB_TOKEN` in its inference/tool step.
- DEV changes cannot persist `.github/workflows`, `.gitmodules`, `.env`, `.jarvis-runtime` or edits inside the upstream submodule.
- Repository edits are proposed through a PR rather than merged automatically.
- Local API access requires `OPENJARVIS_API_KEY`.
- Local API and dashboard are bound to loopback (`127.0.0.1`) by default.

## Upstream and license

- Project: `open-jarvis/OpenJarvis`
- Pinned commit: `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- License: Apache License 2.0 (`OpenJarvis/LICENSE`)

Orbit remains a separate repository and is not part of this project.
