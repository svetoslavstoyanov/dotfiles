# The dotnet CLI takes ~150ms just to start, so generating completions on every
# shell startup is expensive. Cache the script and regenerate only when the
# dotnet binary changes (i.e. after an upgrade).
if (( $+commands[dotnet] )); then
  _dotnet_completions="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/dotnet-completions.zsh"

  if [[ ! -s "$_dotnet_completions" || "$_dotnet_completions" -ot "$commands[dotnet]" ]]; then
    mkdir -p -- "${_dotnet_completions:h}"
    _dotnet_tmp="${_dotnet_completions}.$$"

    if dotnet completions script zsh >| "$_dotnet_tmp" 2>/dev/null && [[ -s "$_dotnet_tmp" ]]; then
      mv -f -- "$_dotnet_tmp" "$_dotnet_completions"
    else
      rm -f -- "$_dotnet_tmp"
    fi
  fi

  [[ -s "$_dotnet_completions" ]] && source "$_dotnet_completions"
  unset _dotnet_completions _dotnet_tmp
fi
