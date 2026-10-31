alias ll="eza --long --header --icons --group-directories-first --sort=ext --classify=auto"
alias lla="ll -a"
alias lld="ll -D"
alias llda="lld -a"
alias llf="ll -f"
alias llfa="ll -af"
alias glogdp="git log --stat --patch --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias y="xclip"
alias p="xclip -o"
alias ranger='command ranger --choosedir="$HOME/.rangerdir" && cd -- "$(cat "$HOME/.rangerdir")"'
alias v=nvim
alias cat="bat"
alias lg="lazygit"
alias ld="lazydocker"
# --- .NET ---
alias dn='dotnet new'
alias dr='dotnet run'
alias dt='dotnet test'
alias dw='dotnet watch'
alias dwr='dotnet watch run'
alias dwt='dotnet watch test'
alias ds='dotnet sln'
alias da='dotnet add'
alias dp='dotnet pack'
alias dng='dotnet nuget'
alias db='dotnet build'
alias dres='dotnet restore'
alias update='sudo pacman -Syu'
# --- GIT ---
alias gstpi='git_stash_pick'
alias gra='git restore --staged --worktree . && git clean -fd'
alias gcu='git reset HEAD~1'
