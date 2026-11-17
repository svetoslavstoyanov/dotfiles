# Interactive Git helpers.
# `%(refname:lstrip=2)` gives clean names (`main`, `origin/main`) without a
# leading `*` or the `remotes/` prefix, so there is no output to reformat later.
# Plain global on purpose: other rc files may (re)assign it during startup.
REMOTES_ORIGIN_PREFIX='origin/'

# True when $1 is an origin-tracked ref (legacy remotes/origin/* accepted too).
function isOrigin() {
  [[ ${1:-} == "$REMOTES_ORIGIN_PREFIX"* || ${1:-} == remotes/origin/* ]]
}

# Strip the remote prefix so `git switch --guess` creates a local tracking
# branch for branches that only exist on origin.
function getBranchName() {
  local branch=${1:-}
  branch=${branch#remotes/origin/}
  branch=${branch#"$REMOTES_ORIGIN_PREFIX"}
  print -r -- "$branch"
}

# Read one fzf selection from stdin; fail cleanly on cancel or empty input.
function _git_pick() {
  local prompt=$1 selected
  command -v fzf >/dev/null 2>&1 || { print -ru2 -- 'fzf is required'; return 1; }
  selected=$(fzf --prompt="$prompt") || return $?
  [[ -n $selected ]] || return 1
  print -r -- "$selected"
}

function _git_branches() {
  local ref
  command git for-each-ref --sort=-committerdate \
    --format='%(refname:lstrip=2)' refs/heads refs/remotes 2>/dev/null |
    while IFS= read -r ref; do
      [[ $ref == origin/HEAD ]] || print -r -- "$ref"
    done
}

function _select_branch() {
  _git_branches | _git_pick 'branch> '
}

function _select_tag() {
  command git tag -l --sort=-v:refname 2>/dev/null | _git_pick 'tag> '
}

function gitSwitchFuzzy() {
  local branch
  branch=$(_select_branch) || return
  command git switch --guess "$(getBranchName "$branch")"
}

function gitSwitchTagFuzzy() {
  local tag
  tag=$(_select_tag) || return
  command git switch --detach "$tag"
}

function gitPullFuzzy() {
  local branch target
  branch=$(_select_branch) || return
  target=$(getBranchName "$branch")
  if isOrigin "$branch"; then
    command git pull origin "$target"
  else
    command git merge "$target"
  fi
}

function gitRebaseFuzzy() {
  local branch target
  branch=$(_select_branch) || return
  target=$(getBranchName "$branch")
  if isOrigin "$branch"; then
    command git pull --rebase origin "$target"
  else
    command git rebase "$target"
  fi
}

# Only local branches are offered: deleting a remote ref needs an explicit push.
function gitBranchDeleteFuzzy() {
  local branch
  branch=$(
    command git for-each-ref --sort=-committerdate \
      --format='%(refname:lstrip=2)' refs/heads 2>/dev/null |
      _git_pick 'delete branch> '
  ) || return
  command git branch -D "$branch"
}

gitStashPickFuzzy() {
  local files selected line msg fz_exit
  local -a pick args
  emulate -L zsh

  command -v fzf >/dev/null 2>&1 || { print -ru2 -- 'gitStashPickFuzzy: fzf is required'; return 1; }

  files=$(
    {
      command git diff --name-only
      command git diff --cached --name-only
      command git ls-files --others --exclude-standard
    } | sort -u
  )

  [[ -n "$files" ]] || { print -ru2 -- "Nothing stashable."; return 1 }

  selected=$(
    printf '%s\n' "$files" | fzf \
      --multi \
      --prompt='stash files > ' \
      --preview-window='right:65%:wrap' \
      --bind='space:toggle+down' \
      --bind='s:accept' \
      --preview '
        if git ls-files --error-unmatch -- {} >/dev/null 2>&1; then
          git diff HEAD --color=always -- {} 2>/dev/null | sed -n "1,400p"
        else
          if [[ -f {} ]]; then sed -n "1,400p" -- {}; else echo "(skip preview)"; fi
        fi
      '
  )
  fz_exit=$?
  [[ $fz_exit == 130 ]] && return 130

  pick=()
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -n "$line" ]] || continue
    pick+=( "$line" )
  done <<< "$selected"

  (( ${#pick[@]} )) || { print -ru2 -- "No files selected."; return 1 }

  local needs_u=false p
  for p in "${pick[@]}"; do
    command git ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || needs_u=true
  done

  printf 'Stash message (optional): '
  IFS= read -r msg

  args=( stash push )
  [[ -n "$msg" ]] && args+=( -m "$msg" )
  [[ "$needs_u" == true ]] && args+=( -u )
  args+=( -- "${pick[@]}" )

  command git "${args[@]}"
}

function getStashIndex() {
  local stash rest index
  command -v fzf >/dev/null 2>&1 || { print -ru2 -- 'fzf is required'; return 1; }
  stash=$(command git stash list 2>/dev/null | fzf --prompt='stash> ') || return $?
  [[ $stash == stash@\{*\}* ]] || return 1
  rest=${stash#stash@\{}
  index=${rest%%\}*}
  [[ -n $index ]] || return 1
  print -r -- "$index"
}

function _git_stash_action() {
  local index
  index=$(getStashIndex) || return
  command git stash "$@" "stash@{$index}"
}

function gitStashApplyFuzzy() { _git_stash_action apply }
function gitStashDropFuzzy() { _git_stash_action drop }
function gitStashShowFuzzy() { _git_stash_action show -p }

function gitStashClear() {
  local answer stashes
  stashes=$(command git stash list 2>/dev/null) || return $?
  [[ -n $stashes ]] || { print -ru2 -- 'No stashes to clear.'; return 1; }

  while true; do
    read -r "answer?Do you want to clear the stashes? [y/N] " || return 1
    case $answer in
      [yY]|[yY][eE][sS]) command git stash clear; return $? ;;
      ''|[nN]|[nN][oO]) return 0 ;;
      *) print -ru2 -- 'Please answer y or n.' ;;
    esac
  done
}
