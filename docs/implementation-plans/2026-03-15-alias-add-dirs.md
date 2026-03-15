# Goal

Adjust the top-level `alias` wrapper so directory mounting is explicit and local to the caller's current working directory.

Specifically:
- add a `--add-dirs` flag that accepts a comma-separated list of directories to mount
- remove the current git-root and worktree discovery logic
- do not implicitly mount the current working directory
- keep the change scoped to `alias`

# Current Behavior

`claude-code` currently:
- parses `--add-dir <path>` into an extra mount list
- tries to detect the git repository root with `git rev-parse --show-toplevel`
- mounts that git root instead of the current working directory
- tries to detect a worktree and mounts the main repo root as an additional directory

This makes mount behavior depend on git layout rather than the shell location the caller invoked from.

# Intended Solution

## CLI contract

Keep `claude-code` as the entrypoint and update its flag parsing as follows:

- `--add-dirs <dir1,dir2,...>`
  - accepts one shell argument containing a comma-separated list
  - splits on commas and appends each non-empty segment to the extra mount list
- `--add-dir <path>`
  - preserve existing single-directory behavior for compatibility unless you want it removed
- all other arguments
  - pass through to `claude`

## Mount contract

- no implicit project mount
- container working directory: always `$(pwd)`
- no git root lookup
- no worktree detection
- extra mounts come only from explicit flags

This makes the wrapper purely argument-driven and avoids hidden behavior based on repository topology or shell location.

# Implementation Sketch

In `alias`:

1. Replace the `git_root` / `git_common_dir` / `main_repo_root` flow with:
   - `local work_dir=\"$(pwd)\"`
2. Extend argument parsing with a `--add-dirs` branch:
   - require a following argument
   - split it on commas in bash
   - append each non-empty directory to `extra_mounts`
3. Leave the existing volume assembly in place, but it will now:
   - omit any default workspace mount
   - mount explicit extras from `extra_mounts`
4. Do not touch other wrapper behavior such as credential mounts, docker socket, UID/GID handling, or forwarded Claude arguments.

# Edge Cases

- `--add-dirs \"\"` should error or no-op; my recommendation is to treat a missing value as an error and ignore empty segments created by stray commas
- whitespace inside the comma-separated value is ambiguous in bash; my assumption is that callers pass normalized paths without surrounding spaces
- duplicate directories are harmless and can be left as-is unless you want deduplication

# Test/Verification Plan

Because this wrapper is a shell function with no existing test harness in the repository, verification will be lightweight and focused on behavior:

- source `alias` in a shell
- invoke `claude-code --add-dirs /tmp/a,/tmp/b --help`
- confirm the produced `docker run` invocation succeeds in mounting:
  - `/tmp/a`
  - `/tmp/b`
- run from inside a git worktree and confirm there is no attempt to discover or mount repo roots
- invoke `claude-code --help` without any add-dir flags and confirm no project directory is mounted by default

If you want, I can also add a small shell test harness, but that would be beyond the “just changes to alias” scope you asked for.

# Assumptions To Confirm

1. `--add-dir <path>` should remain supported for backward compatibility.
2. The scope stays limited to `alias`; I will not update `README.md` unless you want the documentation refreshed in the same change.
