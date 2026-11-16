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
