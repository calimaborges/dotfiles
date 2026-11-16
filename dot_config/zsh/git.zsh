_git_worktree_container() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  if [[ "${common:t}" == ".bare" ]]; then
    print -r -- "${common:h}"
  else
    print -r -- "$common"
  fi
}

gwtc() {
  if [[ $# -lt 1 ]]; then
    print -u2 "usage: gwtc <url> [directory]"
    return 1
  fi

  local url=$1
  local name=${2:-${${url:t}%.git}}

  mkdir "$name" || return 1
  cd "$name" || return 1

  git clone --bare "$url" .bare || return 1
  print -r -- 'gitdir: ./.bare' > .git
  git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git fetch origin || return 1

  local default
  default=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -z "$default" ]]; then
    default=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ { print $NF; exit }')
  fi
  if [[ -z "$default" ]]; then
    print -u2 "could not detect default branch"
    return 1
  fi

  git worktree add "$default" "$default" || return 1
  cd "$default"
}

gwt() {
  if [[ $# -lt 1 ]]; then
    print -u2 "usage: gwt <branch> [start-point]"
    return 1
  fi

  local branch=$1
  local start=${2:-}
  local container path
  container=$(_git_worktree_container) || return 1
  path="$container/$branch"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$path" "$branch" || return 1
  elif [[ -n "$start" ]]; then
    git worktree add -b "$branch" "$path" "$start" || return 1
  elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git worktree add --track -b "$branch" "$path" "origin/$branch" || return 1
  else
    git worktree add -b "$branch" "$path" || return 1
  fi

  cd "$path"
}

gwtl() {
  git worktree list "$@"
}

gwtr() {
  if [[ $# -lt 1 ]]; then
    print -u2 "usage: gwtr <branch-or-path> [--force]"
    return 1
  fi

  local target=$1
  shift
  local container path
  if [[ -d "$target" ]]; then
    path=$target
  else
    container=$(_git_worktree_container) || return 1
    path="$container/$target"
  fi

  git worktree remove "$path" "$@" || return 1
}

gwto() {
  if [[ $# -lt 1 ]]; then
    print -u2 "usage: gwto <branch>"
    return 1
  fi

  local branch=$1
  local path
  path=$(
    git worktree list --porcelain |
      awk -v branch="$branch" '
        $1 == "worktree" { path = substr($0, 10) }
        $1 == "branch" && $2 == "refs/heads/" branch { print path; exit }
      '
  )

  if [[ -z "$path" ]]; then
    print -u2 "no worktree for branch: $branch"
    return 1
  fi

  cd "$path"
}
