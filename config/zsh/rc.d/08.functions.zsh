#!/usr/bin/env bash

REMOTES_ORIGIN_PREFIX="remotes/origin/"

function mkd() {
    mkdir -p "$@" && cd "$_"
}

function gcof() {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    git checkout $(getBranchName $BRANCH)
}

function gcotf() {
    local TAG=$(git tag -l --sort=-v:refname | fzf | awk '{$1=$1};1')

    git checkout $TAG
}

function glf() {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    if [[ $(isOrigin $BRANCH) == true ]]; then
        git pull origin $(getBranchName $BRANCH)
    else
        git merge $(getBranchName $BRANCH)
    fi
}

function gbdf {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    git branch -D $(getBranchName $BRANCH)
}


function gstaaf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash apply $STASH_INDEX
}

function gstadf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash drop $STASH_INDEX
}

function gstasf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash show -p $STASH_INDEX
}

function getStashIndex() {
    local STASH=$(git stash list | fzf | awk '{$1=$1};1')
    echo $STASH | grep -oP '(?<=stash@{).*(?=})'
}

function isOrigin() {
    if [[ "$1" == *"$REMOTES_ORIGIN_PREFIX"* ]]; then
        echo true
    else
        echo false
    fi
}

function getBranchName() {
    local BRANCH=$1
    if [[ $(isOrigin $BRANCH) == true ]]; then
        echo ${BRANCH#"$REMOTES_ORIGIN_PREFIX"}
    else
        echo $BRANCH
    fi
}

function runPackageJsonScript() {
    local pm="$1"
    local command

    [[ -f package.json ]] || { echo "File does not exist."; return 1; }

    command=$(
        jq -r '.scripts | to_entries[] | "\(.key)\t=> \(.value)"' package.json |
        fzf |
        cut -f1
    ) || return

    [[ $? -eq 0 && -n "$command" ]] || return

    "$pm" run "$command"
    print -s "$pm run $command"
    fc -W
}

function npmr() {
    runPackageJsonScript npm
}

function pnpmr() {
    runPackageJsonScript pnpm
}

function zf() {
 local dir
 dir=$(zoxide query -l | sort -k2 -rn | fzf)
 [ -n "$dir" ] && z "$dir"
}

function zgf() {
 local dir
 dir=$(zoxide query -l | xargs -I {} sh -c 'test -d {}/.git && echo {}' | fzf)
 [ -n "$dir" ] && z "$dir"
}

function zpf() {
  local dir
  dir=$(zoxide query -l | sort -k2 -rn | grep -i personal | fzf)
  [ -n "$dir" ] && z "$dir"
 }

function zwf() {
  local dir
  dir=$(zoxide query -l | grep -i work | fzf)
  [ -n "$dir" ] && z "$dir"
 }

function zfv() {
  zf && "$EDITOR"
}

function zgfv() {
  zgf && "$EDITOR"
}

function zpfv() {
  zpf && "$EDITOR"
}

function zwfv() {
  zwf && "$EDITOR"
}

function kpp() {
  local PORT="$1"

  if [[ -z "$PORT" ]]; then
    echo "Usage: kpp <port>"
    return 1
  fi

  local PIDS
  PIDS=$(lsof -t -i :"$PORT" 2>/dev/null)

  if [[ -z "$PIDS" ]]; then
    echo "Nothing is running on port $PORT"
    return 0
  fi

  echo "Killing process(es) on port $PORT: $PIDS"
  kill -9 $PIDS
}

git_stash_pick() {
  local files selected line msg fz_exit
  local -a pick args
  emulate -L zsh 2>/dev/null || setopt local_options 2>/dev/null || true

  files=$(
    {
      git diff --name-only
      git diff --cached --name-only
      git ls-files --others --exclude-standard
    } | sort -u
  )

  [[ -n "$files" ]] || { print -r -- "Nothing stashable." >&2; return 1 }

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
          if [[ -f {} ]]; then sed -n "1,400p" {}; else echo "(skip preview)"; fi
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

  (( ${#pick[@]} )) || { print -r -- "No files selected." >&2; return 1 }

  local needs_u=false p
  for p in "${pick[@]}"; do
    git ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || needs_u=true
  done

  printf 'Stash message (optional): '
  IFS= read -r msg

  args=( stash push )
  [[ -n "$msg" ]] && args+=( -m "$msg" )
  [[ "$needs_u" == true ]] && args+=( -u )
  args+=( -- "${pick[@]}" )

  command git "${args[@]}"
}

