# `zoxide query -l` is already ordered by score; no extra sort is needed.
function _zoxide_candidates() {
  local filter=${1:-} only_git=${2:-false} dir
  while IFS= read -r dir; do
    [[ -n $dir ]] || continue
    if [[ -n $filter && ${(L)dir} != *${(L)filter}* ]]; then
      continue
    fi
    if [[ $only_git == true && ! -d $dir/.git ]]; then
      continue
    fi
    print -r -- "$dir"
  done < <(command zoxide query -l 2>/dev/null)
}

function _zoxide_pick() {
  local filter=${1:-} only_git=${2:-false} prompt=${3:-'dir> '} dir
  command -v fzf >/dev/null 2>&1 || { print -ru2 -- 'fzf is required'; return 1; }
  dir=$(_zoxide_candidates "$filter" "$only_git" | fzf --prompt="$prompt") || return $?
  [[ -n $dir ]] || return 1
  print -r -- "$dir"
}

function _zoxide_jump() {
  local dir
  dir=$(_zoxide_pick "$@") || return
  z "$dir"
}

function _zoxide_jump_edit() {
  local -a editor
  _zoxide_jump "$@" || return
  editor=(${(z)${EDITOR:-nvim}})
  "${editor[@]}"
}

function zf()  { _zoxide_jump '' false 'zoxide> ' }
function zgf() { _zoxide_jump '' true 'git> ' }
function zpf() { _zoxide_jump personal false 'personal> ' }
function zwf() { _zoxide_jump work false 'work> ' }

function zfv()  { _zoxide_jump_edit '' false 'zoxide> ' }
function zgfv() { _zoxide_jump_edit '' true 'git> ' }
function zpfv() { _zoxide_jump_edit personal false 'personal> ' }
function zwfv() { _zoxide_jump_edit work false 'work> ' }
