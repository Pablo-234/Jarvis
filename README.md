# Jarvis

Jarvis uses [OpenJarvis](https://github.com/open-jarvis/OpenJarvis) as its foundation.

The upstream project is pinned in the `OpenJarvis/` submodule, so Jarvis can evolve independently while keeping the upstream source easy to update or compare.

## Clone

```bash
git clone --recurse-submodules https://github.com/Pablo-234/Jarvis.git
```

If you already cloned the repository without submodules:

```bash
git submodule update --init --recursive
```

## Upstream

- Project: `open-jarvis/OpenJarvis`
- Pinned commit: `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`
- License: Apache License 2.0 (`OpenJarvis/LICENSE`)

Orbit is a separate repository and is not part of this project.
