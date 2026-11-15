# -F (--classify) takes an optional value, so it must come before any path argument.
alias ll="eza -F --long --header --icons --group-directories-first --sort=ext"  # long listing with icons, dirs grouped first, sorted by extension
alias lla="ll -aDf"  # all entries incl. hidden (-D and -f cancel each other out)
alias lld="ll -D"  # directories only
alias llda="lld -a"  # directories only, incl. hidden
alias llf="ll -f"  # files only
alias llfa="ll -af"  # files only, incl. hidden
alias glogdp="git log --stat --patch --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\''"  # git log graph with stat+patch, colored hash, refs, date and author
alias y="xclip -selection clipboard"  # copy stdin to the X clipboard (echo hi | y)
alias p="xclip -selection clipboard -o"  # print the X clipboard contents
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'  # open ranger, cd to last visited dir on exit
alias v="nvim"  # open Neovim
alias cat="bat"  # view files with bat (syntax highlighting, paging)
alias lg="lazygit"  # open lazygit TUI
alias ld="lazydocker"  # open lazydocker TUI
# --- .NET ---
alias dn='dotnet new'  # dotnet new - create a project or item
alias dr='dotnet run'  # dotnet run - build and run
alias dt='dotnet test'  # dotnet test - run tests
alias dw='dotnet watch'  # dotnet watch - rebuild on changes
alias dwr='dotnet watch run'  # dotnet watch run
alias dwt='dotnet watch test'  # dotnet watch test
alias ds='dotnet sln'  # dotnet sln - manage solution files
alias da='dotnet add'  # dotnet add - add package or reference
alias dp='dotnet pack'  # dotnet pack - create a NuGet package
alias dng='dotnet nuget'  # dotnet nuget - NuGet tooling
alias db='dotnet build'  # dotnet build
alias dres='dotnet restore'  # dotnet restore
alias update='sudo pacman -Syu'  # full system upgrade (pacman -Syu)
# --- GIT ---
alias gstpi='git_stash_pick'  # interactively pick changed files to stash
alias gra='git restore --staged --worktree . && git clean -fd'  # discard all changes and delete untracked files (destructive)
alias gcu='git reset HEAD~1'  # undo last commit, keep changes
