# Load Oh My Zsh directly instead of going through Antigen.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME=""

# zsh-completions keeps its completion functions in src/. Oh My Zsh runs
# compinit before plugins are sourced, so add that directory to fpath first.
if [[ -d "$ZSH_CUSTOM/plugins/zsh-completions/src" ]]; then
  fpath=("$ZSH_CUSTOM/plugins/zsh-completions/src" $fpath)
fi

plugins=(git command-not-found docker)
for _plugin in zsh-completions zsh-autosuggestions zsh-syntax-highlighting; do
  [[ -d "$ZSH_CUSTOM/plugins/$_plugin" ]] && plugins+=("$_plugin")
done
unset _plugin

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 "Oh My Zsh not found at $ZSH; run ./setup.sh"
fi
