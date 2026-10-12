#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  worktree.sh prepare REPO [BRANCH] [--base REF] [--no-setup] [--no-open]
  worktree.sh remove REPO [BRANCH] [--force]

REPO is one of:
  repo                  uses default_org from the config
  org/repo
  org/repo#123          a pull request
  https://HOST/org/repo[/pull/123]

Layout under the configured root:
  <org>/<repo>/main/      main checkout, cloned on demand
  <org>/<repo>/<slug>/    one worktree per branch, slug = branch with / -> -

Config ($PREPARE_WORKTREE_CONFIG, default ~/.config/prepare-worktree/config.sh)
is a bash file setting:
  root=~/code/repos                    required
  default_org=my-org                   optional
  setup_dir=~/code/worktree-setup      optional, default: <root>/../worktree-setup

prepare  Clones the repo if needed, fetches, and returns the worktree for the
         branch (or the PR's head branch). Reuses an existing checkout of that
         branch and fast-forwards it when it has no local changes. A branch that
         doesn't exist locally or on origin is created from --base (default: the
         remote default branch). Without a branch, prepares the main checkout.
         A new worktree gets the repo's setup from <setup_dir>/<org>/<repo>.sh,
         if there is one (skip with --no-setup). The checkout opens in VS Code
         and Fork (skip with --no-open).
remove   Removes the branch's worktree, then deletes the local branch if it is
         fully merged or pushed. --force also discards local changes.
EOF
}

main() {
  [ "$#" -ge 1 ] || { usage >&2; exit 2; }
  local cmd="$1"
  shift
  case "$cmd" in
    prepare) load_config; cmd_prepare "$@" ;;
    remove) load_config; cmd_remove "$@" ;;
    -h | --help) usage ;;
    *) usage >&2; exit 2 ;;
  esac
}

cmd_prepare() {
  local base="" setup=1 open=1 args=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --base) [ "$#" -ge 2 ] || die "--base requires a ref"; base="$2"; shift 2 ;;
      --no-setup) setup=""; shift ;;
      --no-open) open=""; shift ;;
      -*) die "unknown option: $1" ;;
      *) args+=("$1"); shift ;;
    esac
  done
  [ "${#args[@]}" -ge 1 ] && [ "${#args[@]}" -le 2 ] || { usage >&2; exit 2; }

  parse_repo_spec "${args[0]}"
  ensure_main_checkout
  log "fetching origin"
  git -C "$main_dir" fetch --quiet origin

  local branch="${args[1]:-}"
  if [ -n "$pr" ]; then
    [ -z "$branch" ] || die "pass either a PR or a branch, not both"
    branch="$(pr_head_branch)"
  fi

  local dir created=""
  if [ -z "$branch" ]; then
    # No branch: the caller wants the repo itself.
    dir="$main_dir"
  else
    git check-ref-format --branch "$branch" >/dev/null 2>&1 || die "invalid branch: $branch"
    dir="$(worktree_for_branch "$branch")"
    if [ -n "$dir" ]; then
      log "reusing existing checkout of $branch"
    else
      dir="$repo_dir/$(slugify "$branch")"
      add_worktree "$branch" "$dir" "$base"
      created=1
    fi
  fi

  sync_checkout "$dir"
  if [ -n "$created" ] && [ -n "$setup" ]; then
    run_setup "$dir"
  fi
  report "$dir"
  if [ -n "$open" ]; then
    open_checkout "$dir"
  fi
}

cmd_remove() {
  local force="" args=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force) force="--force"; shift ;;
      -*) die "unknown option: $1" ;;
      *) args+=("$1"); shift ;;
    esac
  done
  [ "${#args[@]}" -ge 1 ] && [ "${#args[@]}" -le 2 ] || { usage >&2; exit 2; }

  parse_repo_spec "${args[0]}"
  [ -d "$main_dir" ] || die "$main_dir not found"

  local branch="${args[1]:-}"
  if [ -n "$pr" ]; then
    [ -z "$branch" ] || die "pass either a PR or a branch, not both"
    branch="$(pr_head_branch)"
  fi
  [ -n "$branch" ] || die "remove needs a branch or a PR"

  local path
  path="$(worktree_for_branch "$branch")"
  [ -n "$path" ] || die "no worktree has $branch checked out"
  [ "$path" != "$main_dir" ] || die "$branch is checked out in the main checkout; not removing it"

  git -C "$main_dir" worktree remove $force "$path"
  log "removed $path"

  # Delete the branch only when its commits also exist elsewhere: in its
  # upstream (what `branch -d` checks) or in the remote default branch.
  if git -C "$main_dir" branch -d "$branch" >/dev/null 2>&1; then
    log "deleted local branch $branch"
  elif git -C "$main_dir" merge-base --is-ancestor "refs/heads/$branch" "$(default_remote_branch)"; then
    git -C "$main_dir" branch -D "$branch" >/dev/null
    log "deleted local branch $branch"
  else
    log "kept local branch $branch: it has commits that aren't merged or pushed"
  fi
}

# --- Repo resolution ---------------------------------------------------------

config_file="${PREPARE_WORKTREE_CONFIG:-$HOME/.config/prepare-worktree/config.sh}"

load_config() {
  root="" default_org="" setup_dir=""
  [ -f "$config_file" ] || die "no config at $config_file; create it with at least root=<folder for checkouts>"
  # shellcheck source=/dev/null
  source "$config_file"
  [ -n "$root" ] || die "root is not set in $config_file"
  root="${root%/}"
  setup_dir="${setup_dir:-$(dirname "$root")/worktree-setup}"
}

# Sets org, repo, pr, url_host, repo_dir, main_dir.
parse_repo_spec() {
  local spec="$1" path
  pr="" url_host=""
  case "$spec" in
    https://* | http://*)
      path="${spec#*://}"
      url_host="${path%%/*}"
      path="${path#*/}"
      org="${path%%/*}"
      path="${path#*/}"
      repo="${path%%/*}"
      repo="${repo%.git}"
      case "$path" in
        */pull/*) pr="${path#*/pull/}"; pr="${pr%%/*}" ;;
      esac
      ;;
    *)
      case "$spec" in
        *#*) pr="${spec##*#}"; spec="${spec%#*}" ;;
      esac
      case "$spec" in
        */*/*) die "invalid repository: $spec" ;;
        */*) org="${spec%%/*}"; repo="${spec#*/}" ;;
        *)
          [ -n "$default_org" ] || die "no default_org configured; use org/repo"
          org="$default_org"; repo="$spec"
          ;;
      esac
      ;;
  esac
  validate_name "$org"
  validate_name "$repo"
  case "$pr" in
    "" | *[!0-9]*) [ -z "$pr" ] || die "invalid PR number: $pr" ;;
  esac
  repo_dir="$root/$org/$repo"
  main_dir="$repo_dir/main"
}

ensure_main_checkout() {
  if [ -d "$main_dir" ]; then
    return
  fi
  if [ -e "$repo_dir/.git" ]; then
    die "$repo_dir is a checkout in the old layout; move it to $main_dir first"
  fi
  local url
  url="$(clone_url)"
  log "cloning $url into $main_dir"
  mkdir -p "$repo_dir"
  git clone --quiet "$url" "$main_dir" || { rmdir "$repo_dir" 2>/dev/null; die "couldn't clone $url"; }
}

# Prefer the remote prefix used by other repos of the same org. Orgs can need
# a specific SSH host alias or a non-github.com host.
clone_url() {
  local sibling remote
  for sibling in "$root/$org"/*/main; do
    [ -d "$sibling" ] || continue
    remote="$(git -C "$sibling" remote get-url origin 2>/dev/null || true)"
    case "$remote" in
      *"$org/"*)
        printf '%s%s/%s.git\n' "${remote%%"$org/"*}" "$org" "$repo"
        return
        ;;
    esac
  done
  printf 'git@%s:%s/%s.git\n' "${url_host:-github.com}" "$org" "$repo"
}

# Finds the PR's source branch with git, so it works with whatever credentials
# the repo's remote uses. GitHub exposes every PR as refs/pull/<N>/head, which
# points at the same commit as its source branch.
pr_head_branch() {
  local refs sha branches
  refs="$(git -C "$main_dir" ls-remote origin "refs/pull/$pr/head" 'refs/heads/*')" ||
    die "couldn't list refs on origin"
  sha="$(printf '%s\n' "$refs" | awk -v ref="refs/pull/$pr/head" '$2 == ref { print $1 }')"
  [ -n "$sha" ] || die "PR #$pr not found on origin"
  branches="$(printf '%s\n' "$refs" |
    awk -v sha="$sha" '$1 == sha && $2 ~ /^refs\/heads\// { print substr($2, 12) }')"
  case "$branches" in
    "") die "PR #$pr's source branch isn't on origin (fork PR or deleted branch)" ;;
    *$'\n'*) die "PR #$pr matches several branches; pass one of them instead: $(echo $branches)" ;;
  esac
  printf '%s\n' "$branches"
}

default_remote_branch() {
  if ! git -C "$main_dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null; then
    git -C "$main_dir" remote set-head origin --auto >/dev/null
    git -C "$main_dir" symbolic-ref --short refs/remotes/origin/HEAD
  fi
}

# --- Worktree helpers --------------------------------------------------------

worktree_for_branch() {
  git -C "$main_dir" worktree list --porcelain |
    awk -v ref="refs/heads/$1" '
      /^worktree / { path = substr($0, 10) }
      $0 == "branch " ref { print path; exit }
    '
}

add_worktree() {
  local branch="$1" dest="$2" base="$3"
  [ "$dest" != "$main_dir" ] || die "branch $branch maps to the main checkout folder; switch the main checkout to it instead"
  [ ! -e "$dest" ] || die "$dest already exists but doesn't have $branch checked out"

  if git -C "$main_dir" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$main_dir" worktree add --quiet "$dest" "$branch"
  elif git -C "$main_dir" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$main_dir" worktree add --quiet --track -b "$branch" "$dest" "origin/$branch"
  elif [ -n "$pr" ]; then
    die "PR head branch $branch not found on origin"
  else
    base="${base:-$(default_remote_branch)}"
    log "creating new branch $branch from $base"
    git -C "$main_dir" worktree add --quiet --no-track -b "$branch" "$dest" "$base"
  fi
  log "created worktree for $branch"
}

# Runs the repo's setup script inside a new worktree. A failed setup leaves
# the worktree in place so it can be fixed by hand.
run_setup() {
  local dir="$1" script="$setup_dir/$org/$repo.sh"
  [ -f "$script" ] || return 0
  log "running $script"
  if ! (cd "$dir" && bash "$script" "$main_dir") >&2; then
    log "warning: setup failed; the worktree is ready but may be incomplete"
  fi
}

open_checkout() {
  local app
  for app in "Visual Studio Code" Fork; do
    open -a "$app" -- "$1" 2>/dev/null || log "warning: couldn't open $app"
  done
}

# Fast-forwards a checkout to its upstream, but never touches local changes.
sync_checkout() {
  local dir="$1"
  git -C "$dir" rev-parse --quiet --verify '@{upstream}' >/dev/null 2>&1 || return 0
  if [ -n "$(git -C "$dir" status --porcelain)" ]; then
    log "has local changes; not updating"
    return 0
  fi
  if git -C "$dir" merge-base --is-ancestor HEAD '@{upstream}' 2>/dev/null; then
    git -C "$dir" merge --quiet --ff-only '@{upstream}'
  else
    log "branch has diverged from its upstream; not updating"
  fi
}

report() {
  local dir="$1" branch upstream=""
  branch="$(git -C "$dir" branch --show-current)"
  if [ -n "$branch" ]; then
    upstream="$(git -C "$dir" for-each-ref --format="$upstream_format" "refs/heads/$branch")"
  fi
  printf 'path: %s\n' "$dir"
  printf 'branch: %s\n' "${branch:-(detached)}"
  printf 'upstream: %s\n' "${upstream:-none}"
  printf 'local changes: %s\n' "$(git -C "$dir" status --porcelain | wc -l | tr -d ' ')"
}

# "origin/foo (up to date)", "origin/foo (ahead 1, behind 2)", "origin/foo (gone)"
upstream_format='%(if)%(upstream)%(then)%(upstream:short) (%(if)%(upstream:track)%(then)%(upstream:track,nobracket)%(else)up to date%(end))%(end)'

slugify() {
  printf '%s' "$1" | sed -E 's#[^A-Za-z0-9._-]+#-#g; s#-+#-#g; s#^-##; s#-$##'
}

validate_name() {
  case "$1" in
    "" | "." | ".." | *[!A-Za-z0-9._-]*) die "invalid name: $1" ;;
  esac
}

log() {
  printf '[worktree] %s\n' "$*" >&2
}

die() {
  printf '[worktree] error: %s\n' "$*" >&2
  exit 1
}

main "$@"
