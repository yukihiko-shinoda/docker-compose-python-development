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

`entrypoint.sh` runs at container start and symlinks each project's `.venv` → `/workspace/venvs/<project>/`. The `venvs/` directory is a named Docker volume, so virtual environments survive container rebuilds. If `.venv` inside a project appears as a symlink rather than a real directory, this is expected behavior.

### Per-Project VS Code Workspaces

`open-project.sh <project-name>` generates `<project>.code-workspace` from `workspace-template.code-workspace` and opens it in VS Code. These workspace files are required to make Bandit and other linter extensions resolve the correct Python interpreter (the `ms-python.python` API returns too slowly for Bandit to pick it up automatically). Pre-generated workspaces (e.g. `invoke-lint.code-workspace`) exist for some projects already.

## Child Projects

Child project information (common dev stack, commands, code style, and project catalog) should be defined in `CLAUDE.local.md`. Add or update child project details there rather than in this file.
