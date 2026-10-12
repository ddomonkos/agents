---
name: prepare-worktree
description: Prepare a local checkout of a repository, branch, or pull request, cloning, creating a new branch, and creating a Git worktree as needed. Use when the user wants to set up, check out, start new work on a new branch, or start parallel work on a repo/branch/PR, or needs a local copy before reviewing a PR. Also removes worktrees that are no longer needed.
---

# Prepare worktree

Checkouts live under a root folder set in the machine config:

```text
<root>/<org>/<repo>/main/     main checkout
<root>/<org>/<repo>/<slug>/   one worktree per branch (davido/foo -> davido-foo)
```

Always use `scripts/worktree.sh` from this skill's directory; don't create checkouts elsewhere or by hand.

```bash
scripts/worktree.sh prepare <repo> [<branch>] [--base <ref>] [--no-setup] [--no-open]
scripts/worktree.sh remove <repo> [<branch>] [--force]
```

`<repo>` can be `repo` (uses the configured default org), `org/repo`, `org/repo#123` for a PR, or a GitHub URL, including PR URLs.

`prepare` clones the repo when it's missing, fetches, and prints the checkout's `path`, branch, upstream state, and number of local changes. It reuses a branch that's already checked out anywhere, including in `main/`. It fast-forwards a checkout only when it has no local changes. A branch that doesn't exist yet is created from `--base`, which defaults to the remote default branch. Without a branch it prepares just the main checkout.

By default `prepare` also opens the checkout in VS Code and in a Fork tab. Pass `--no-open` only when the user asks not to open anything.

## Config

The machine config is `~/.config/prepare-worktree/config.sh`, a bash file:

```bash
root=~/code/repos                     # required: folder for checkouts
default_org=my-org                    # optional: org for bare repo names
setup_dir=~/code/worktree-setup       # optional, default: <root>/../worktree-setup
```

If the script reports that the config is missing, ask the user where checkouts should live, then create the file.

## Repo setup

When `prepare` creates a new worktree, it runs `<setup_dir>/<org>/<repo>.sh` if that file exists. The script runs inside the new worktree and gets the main checkout path as `$1`. Skip it with `--no-setup`. Check the setup folder's own docs to see which repos have setup scripts.

## After preparing

- Work in the printed `path`. Read that repository's own `AGENTS.md` before changing anything there.
- If the repo has no setup script, the worktree has no installed dependencies. Install them only when the task needs to build, run, or test the code, following the repository's instructions.
- Report the path. For parallel work, tell the user they can start a new session with `cd <path>`.
- If the checkout has local changes or has diverged from its upstream, tell the user instead of resetting it.

## Removing

Use `remove` when the user is done with a branch, for example after a review. It refuses to touch the main checkout. It fails when the worktree has local changes; pass `--force` only after the user agrees to discard them. The local branch is deleted only when it holds no unmerged or unpushed commits.
