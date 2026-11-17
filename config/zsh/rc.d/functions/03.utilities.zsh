if [[ ${(t)ALIASES_FILE:-} != *readonly* ]]; then
  ALIASES_FILE="${${(%):-%x}:A:h:h}/07.aliases.zsh"
  typeset -gr ALIASES_FILE
fi

function mkd() {
  (( $# )) || { print -ru2 -- 'usage: mkd <directory>...'; return 1; }
  mkdir -p -- "$@" || return
  cd -- "${@[-1]}"
}

function kpp() {
  local port=$1
  local -a pids

  [[ -n $port ]] || { print -ru2 -- 'usage: kpp <port>'; return 1; }

  pids=("${(@f)$(command lsof -t -i :"$port" 2>/dev/null)}")
  (( ${#pids[@]} )) || { print -r -- "Nothing is running on port $port"; return 0; }

  print -r -- "Killing process(es) on port $port: ${pids[*]}"
  kill -9 "${pids[@]}"
}

git_stash_pick() {
  local files selected line msg fz_exit
  local -a pick args
  emulate -L zsh

  command -v fzf >/dev/null 2>&1 || { print -ru2 -- 'git_stash_pick: fzf is required'; return 1; }

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

runf() {
  local recursive=false

  case "${1:-}" in
    -r|--recursive) recursive=true ;;
    "") ;;
    *)
      print -ru2 -- "Usage: runf [-r|--recursive]"
      return 1
      ;;
  esac

  if ! command -v fzf &>/dev/null; then
    print -ru2 -- "fzf is required but not installed"
    return 1
  fi

  local -a find_args files
  find_args=(. -type f -executable)

  if [[ "$recursive" == true ]]; then
    find_args+=(-not -path './.git/*')
  else
    find_args+=(-maxdepth 1)
  fi

  files=("${(@f)$(command find "${find_args[@]}" -printf '%P\n' 2>/dev/null | sort)}")

  if (( ${#files[@]} == 0 )); then
    print -r -- "No executable files found in $PWD"
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
  local line name desc rest selected
  local -a entries

  if ! command -v fzf >/dev/null 2>&1; then
    print -ru2 -- "aliasf: fzf is required"
    return 1
  fi

  if [[ ! -r $ALIASES_FILE ]]; then
    print -ru2 -- "aliasf: cannot read $ALIASES_FILE"
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
  done < "$ALIASES_FILE"

  if (( ${#entries[@]} == 0 )); then
    print -ru2 -- "aliasf: no aliases found in $ALIASES_FILE"
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
