source ~/.antigen.zsh
antigen init ~/.antigenrc

[[ -f "$HOME/.dotfiles/.aliases" ]] && source "$HOME/.dotfiles/.aliases"

[[ -f "$HOME/.dotfiles/.functions" ]] && source "$HOME/.dotfiles/.functions"

eval "$(starship init zsh)"

# fnm
export PATH="/home/svetoslav/.local/share/fnm:$PATH"
eval "`fnm env`"
