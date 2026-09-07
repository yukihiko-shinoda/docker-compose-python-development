# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker-based development environment (`docker-compose-python-development`) housing multiple Python projects. Each project lives in its own subdirectory with its own `pyproject.toml` and virtual environment managed by `uv`. The base Docker image is `futureys/claude-code-python-development`.

## Dev Container (VS Code)

Open this repository with **Dev Containers** (F1 → "Reopen in Container"). The configuration in [.devcontainer/](.devcontainer/) wires together:
- `../compose.yml` + `.devcontainer/compose.yml` — base service definition (mounts `/workspace`, `~/.claude`, uv cache)
- VS Code extensions auto-installed: Claude Code, Ruff, Pylint, mypy, Flake8, Bandit, Copilot, Code Spell Checker, Even Better TOML
- On-save hooks: Ruff (format + organize imports), docformatter (runs `uv run docformatter --in-place` on every `.py` save via RunOnSave extension)

To start without VS Code:
```bash
docker compose up -d
docker compose exec python-development bash
```

### venvs/ and Virtual Environment Persistence

Each project's `.venv` gets symlinked to `/workspace/venvs/<project>/` at container start, so virtual environments survive container rebuilds (`venvs/` is a named Docker volume). This symlinking script lives in the base image (`futureys/claude-code-python-development`), not in this repo — there is no `entrypoint.sh` or `Dockerfile` here to look for; both were removed from this repo (the "Simplify" commit) once the image started shipping the behavior itself. If `.venv` inside a project appears as a symlink rather than a real directory, this is expected behavior.

### Global Git Secret-Scanning Hooks

The `pre-commit`, `commit-msg`, and `prepare-commit-msg` hook scripts (git-secrets, plus
gitleaks in `pre-commit`) are baked into the base image at `/usr/local/share/git-hooks/`, with
`git config --system core.hooksPath` pointed directly at that directory and git-secrets' AWS
patterns registered in an included side file (`/etc/git-secrets-aws.gitconfig`). None of this
is defined in this repo: `compose.yml` pulls a pre-built `image:` tag rather than `build:`-ing
one, so there is no local `Dockerfile` or `distribution/` here to look for — that build
definition (and the `distribution/git-hooks/` source files it presumably copies in) lives in
the separate repository that produces the `futureys/claude-code-python-development` image.
Both hooks are deliberately kept out of `/root/.gitconfig`: VS Code Dev Containers only copies
the host's `~/.gitconfig` into the container when the container doesn't already have one, so
writing there would pre-empt that copy and silently drop the host's `user.name`/`user.email`.
git-secrets reads patterns via merged config with no scope flag, so the system-scoped patterns
still apply to every repo inside the container. Because `core.hooksPath` bypasses each repo's
own `.git/hooks/`, every global hook chains to a same-named repo-local hook via
`_local-hook-exec`; if a child project needs another hook type (e.g. `pre-push`), that stub
needs adding on the base-image side, not in this repo.

### Per-Project VS Code Workspaces

`open-project.sh <project-name>` generates `<project>.code-workspace` from `workspace-template.code-workspace` and opens it in VS Code. These workspace files are required to make Bandit and other linter extensions resolve the correct Python interpreter (the `ms-python.python` API returns too slowly for Bandit to pick it up automatically). Pre-generated workspaces (e.g. `invoke-lint.code-workspace`) exist for some projects already.

## Child Projects

Child project information (common dev stack, commands, code style, and project catalog) should be defined in `CLAUDE.local.md`. Add or update child project details there rather than in this file.
