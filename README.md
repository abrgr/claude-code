# Claude Code

A Docker-based wrapper for running the Claude CLI in an isolated, containerized environment.

## Features

- Runs Claude CLI inside a Docker container for isolation
- Automatically mounts the current git repository
- Handles git credentials, SSH keys, and configuration
- Supports mounting additional directories
- Runs as your user (UID/GID) for proper file permissions

## Installation

1. Build the Docker image:
   ```bash
   ./build.sh
   ```

2. Source the alias in your shell (add to `.bashrc` or `.zshrc`):
   ```bash
   source /path/to/claude-code/alias
   ```

## Usage

Run Claude CLI commands from within any git repository:

```bash
claude-code [claude-cli-args]
```

Mount additional directories:

```bash
claude-code --add-dir /path/to/extra/dir [claude-cli-args]
```

## How It Works

The `claude-code` function:
1. Detects your current git repository root
2. Mounts the repository with read-write access
3. Mounts credentials and config files from your home directory
4. Runs the Claude CLI inside the container with your user permissions
