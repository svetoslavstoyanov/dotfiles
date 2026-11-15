# Docker ships its own zsh completion (`docker completion zsh`). Cache it in a
# directory on $fpath and refresh after a docker upgrade; compinit picks it up.
# This replaces oh-my-zsh's docker plugin, whose only non-alias job was this.
if (( $+commands[docker] )); then
  _docker_comp_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/completions"
  _docker_comp="$_docker_comp_dir/_docker"
  mkdir -p -- "$_docker_comp_dir"
  (( ${fpath[(Ie)$_docker_comp_dir]} )) || fpath=("$_docker_comp_dir" $fpath)

  if [[ ! -s $_docker_comp || $_docker_comp -ot $commands[docker] ]]; then
    docker completion zsh >| "$_docker_comp" 2>/dev/null || rm -f -- "$_docker_comp"
  fi

  unset _docker_comp _docker_comp_dir
fi
