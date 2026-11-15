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

runf() {
  local recursive=false

  case "${1:-}" in
    -r|--recursive) recursive=true ;;
    "") ;;
    *)
      echo "Usage: runf [-r|--recursive]" >&2
      return 1
      ;;
  esac

  if ! command -v fzf &>/dev/null; then
    echo "fzf is required but not installed" >&2
    return 1
  fi

  local -a find_args files
  find_args=(. -type f -executable)

  if [[ "$recursive" == true ]]; then
    find_args+=(-not -path './.git/*')
  else
    find_args+=(-maxdepth 1)
  fi

  files=("${(@f)$(find "${find_args[@]}" -printf '%P\n' 2>/dev/null | sort)}")

  if (( ${#files[@]} == 0 )); then
    echo "No executable files found in $PWD"
    return 0
  fi

  local selected
  selected="$(printf '%s\n' "${files[@]}" | fzf \
    --prompt='run> ' \
    --preview 'if command -v bat >/dev/null 2>&1; then
        bat --paging=never --style=numbers --color=always --line-range=:200 -- {}
      else
        sed -n "1,200p" -- {}
      fi' \
    --preview-window='right:60%:wrap')" || return 0
  [[ -n "$selected" ]] || return 0

  ./"$selected"
}

# Browse the aliases defined in 07.aliases.zsh with fzf. Descriptions are read
# from the trailing comments. Enter inserts the selected alias into the prompt,
# ready for arguments (press Enter again to run it).
aliasf() {
  emulate -L zsh
  local aliases_file="${${(%):-%x}:A:h}/07.aliases.zsh"
  local line name desc rest selected
  local -a entries

  if ! command -v fzf >/dev/null 2>&1; then
    print -ru2 -- "aliasf: fzf is required"
    return 1
  fi

  if [[ ! -r $aliases_file ]]; then
    print -ru2 -- "aliasf: cannot read $aliases_file"
    return 1
  fi

  while IFS= read -r line; do
    [[ $line == "alias "* ]] || continue
    rest=${line#alias }
    name=${rest%%=*}
    name=${(Q)name}
    desc=
    [[ $rest == *" # "* ]] && desc=${rest##*" # "}
    entries+=("${name}"$'\t'"${desc}"$'\t'"${aliases[$name]}")
  done < "$aliases_file"

  if (( ${#entries[@]} == 0 )); then
    print -ru2 -- "aliasf: no aliases found in $aliases_file"
    return 1
  fi

  selected=$(printf '%s\n' "${entries[@]}" | LC_ALL=C sort | fzf \
    --delimiter=$'\t' \
    --with-nth=1,2 \
    --prompt='alias> ' \
    --query="$1" \
    --footer='Enter: insert into prompt | Ctrl-Y: copy definition' \
    --bind='ctrl-y:execute-silent(print -r -- {3} | xclip -selection clipboard)+abort') || return

  [[ -n $selected ]] || return
  print -z -- "${selected%%$'\t'*} "
}
