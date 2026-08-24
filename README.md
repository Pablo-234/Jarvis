# Jarvis

Jarvis uses [OpenJarvis](https://github.com/open-jarvis/OpenJarvis) as its foundation and adds a persistent persona, private runtime memory, a protected local runtime and an owner-only GitHub control plane.

The upstream project is pinned in the `OpenJarvis/` submodule, while this repository contains the runtime and safety layer around it.

## What is included

- OpenJarvis pinned to commit `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- local Ollama runtime with `qwen3.5:2b`
- persistent Jarvis persona (`SOUL.md`, `USER.md`, `MEMORY.md` seed)
- private SQLite memory persisted between GitHub Actions runs
- Docker/Compose local runtime with a durable data volume
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

Create `.env` from `.env.example`, replace `OPENJARVIS_API_KEY` with a long random secret, then run:

```bash
docker compose up --build
```

Or on Windows run:

```powershell
.\start-jarvis.ps1
```

The stack starts Ollama, downloads the configured local model and starts the OpenJarvis API on port 8000. The same Jarvis persona/config is copied into the durable `jarvis-data` volume, so local memory survives container restarts.

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

## Upstream and license

- Project: `open-jarvis/OpenJarvis`
- Pinned commit: `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- License: Apache License 2.0 (`OpenJarvis/LICENSE`)

Orbit remains a separate repository and is not part of this project.
