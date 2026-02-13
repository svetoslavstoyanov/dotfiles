#!/usr/bin/env bash

alias ll="exa --long --header --icons --group-directories-first --sort=ext -F"
alias lla="ll -aDf"
alias lld="ll -D"
alias llda="lld -a"
alias llf="ll -f"
alias llfa="ll -af"
alias glogdp="git log --stat --patch --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'"
alias y="xclip"
alias p="xclip -o"
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
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
