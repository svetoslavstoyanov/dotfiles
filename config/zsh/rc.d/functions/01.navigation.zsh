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

function zoxideFuzzy() { _zoxide_jump '' false 'zoxide> ' }
function zoxideGitFuzzy() { _zoxide_jump '' true 'git> ' }
function zoxidePersonalFuzzy() { _zoxide_jump personal false 'personal> ' }
function zoxideWorkFuzzy() { _zoxide_jump work false 'work> ' }

function zoxideFuzzyEdit() { _zoxide_jump_edit '' false 'zoxide> ' }
function zoxideGitFuzzyEdit() { _zoxide_jump_edit '' true 'git> ' }
function zoxidePersonalFuzzyEdit() { _zoxide_jump_edit personal false 'personal> ' }
function zoxideWorkFuzzyEdit() { _zoxide_jump_edit work false 'work> ' }
