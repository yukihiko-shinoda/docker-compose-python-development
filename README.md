# docker-compose-python-development

A Docker Compose development environment for multiple Python projects, with persistent virtual environments and pre-configured VS Code tooling.

## Advantage

Standard Docker dev setups lose virtual environments every time you rebuild the container image. This environment avoids that by storing each project's `.venv` in a named Docker volume — rebuilds are fast and your dependencies stay intact.

It also solves the linter resolution problem that affects VS Code in multi-project workspaces. Extensions like Bandit rely on the `ms-python.python` API to discover interpreters, but that API returns too slowly for them to pick up the right `.venv` automatically. Per-project workspace files bypass this by pinning the interpreter path explicitly.

Key benefits:

- Virtual environments survive container rebuilds via Docker volumes
- Pre-configured linting stack: Ruff, Pylint, mypy, Flake8, Bandit, Semgrep, Dodgy
- On-save formatting: Ruff (format + organize imports) and docformatter
- Each child project is fully isolated with its own `uv`-managed venv
- Claude Code configuration mounted into the container from `~/.claude`

## Quickstart

**Prerequisites**: Docker, VS Code, [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

1. Clone this repository:

   ```bash
   git clone https://github.com/yukihiko-shinoda/docker-compose-python-development
   cd docker-compose-python-development
   ```

2. Clone or create your Python project(s) as subdirectories (each needs a `pyproject.toml`):

   ```bash
   git clone https://github.com/your-org/my-project
   ```

3. Open in VS Code and reopen in the Dev Container:

   - Press **F1** → **Dev Containers: Reopen in Container**

4. Open the project workspace for correct linter settings (from the container terminal):

   ```bash
   ./open-project.sh my-project
   ```

5. Develop your project and run your tasks:

   ```bash
   uv run invoke test
   ```

**Without VS Code:**

```bash
docker compose up -d
docker compose exec python-development bash
```

<!-- markdownlint-disable-next-line no-trailing-punctuation -->
## How do I...

### How do I open a specific project with correct linter settings?

Use `open-project.sh` to generate a per-project workspace file and open it in VS Code:

```bash
./open-project.sh my-project
```

This generates `my-project.code-workspace` from `workspace-template.code-workspace`. The workspace pins `python.defaultInterpreterPath` and `bandit.interpreter` to the project's `.venv`, so Bandit and mypy resolve the correct interpreter without relying on the slow `ms-python.python` API.

### How do I add a new Python project?

Place the project directory in the workspace root with a `pyproject.toml`. The `entrypoint.sh` script runs at container start and automatically symlinks `<project>/.venv` → `/workspace/venvs/<project>/` so the venv lands on the persistent volume.

### How do I rebuild the container without losing virtual environments?

Virtual environments live in the `venvs` named Docker volume, not inside the container image. Rebuilding the image does not touch the volume:

```bash
docker compose build
docker compose up -d
```

## API

### `open-project.sh <project-name>`

Generates `<project-name>.code-workspace` by substituting `__PROJECT__` in `workspace-template.code-workspace`, then opens it with `code`. The generated workspace file:

- Sets the integrated terminal CWD to the project folder
- Pins `python.defaultInterpreterPath` to `<project>/.venv/bin/python`
- Sets `bandit.importStrategy: fromEnvironment` and pins `bandit.interpreter`
- Runs `uv sync` automatically when the workspace folder opens

### Volumes

| Volume | Purpose |
| --- | --- |
| `venvs` | Persists each project's virtual environment across container rebuilds |
| `uv-cache` | Caches uv package downloads |
| `uv-python` | Persists uv-managed Python runtimes |
