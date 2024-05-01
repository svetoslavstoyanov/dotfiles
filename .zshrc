source ~/.antigen.zsh
antigen init ~/.antigenrc

[[ -f "$HOME/.dotfiles/.aliases" ]] && source "$HOME/.dotfiles/.aliases"

[[ -f "$HOME/.dotfiles/.functions" ]] && source "$HOME/.dotfiles/.functions"

eval "$(starship init zsh)"

# fnm
export PATH="/home/svetoslav/.local/share/fnm:$PATH"
eval "`fnm env`"


export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="|"
  --layout="reverse" --info="right"'

