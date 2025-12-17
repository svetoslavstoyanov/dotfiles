source ~/.antigen.zsh
antigen init ~/.antigenrc

PATH_TO_DOT_FILES="$HOME/dev/personal/dotfiles"
FILES=(".aliases" ".functions")

for FILE in "${FILES[@]}"; do

  PATH_WITH_FILE="$PATH_TO_DOT_FILES/$FILE"
  if [[ -f "$PATH_WITH_FILE" ]]; then
    source "$PATH_WITH_FILE"
  else
    echo "Missing: $PATH_WITH_FILE"
  fi
done

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

