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
# --- DOCKER (all aliases start with dc) ---
alias dcbl='docker build'  # build an image from a Dockerfile
alias dcin='docker container inspect'  # show detailed information on containers
alias dcls='docker container ls'  # list running containers
alias dclsa='docker container ls -a'  # list running and stopped containers
alias dcprune='docker container prune'  # remove all stopped containers
alias dcib='docker image build'  # build an image from a Dockerfile (same as docker build)
alias dcii='docker image inspect'  # show detailed information on images
alias dcils='docker image ls'  # list images
alias dcipu='docker image push'  # push an image to a registry
alias dcipru='docker image prune -a'  # remove all images not used by a container
alias dcirm='docker image rm'  # remove one or more images
alias dcit='docker image tag'  # tag an image with a name and tag
alias dclo='docker container logs'  # fetch the logs of a container
alias dcnc='docker network create'  # create a network
alias dcncn='docker network connect'  # connect a container to a network
alias dcndcn='docker network disconnect'  # disconnect a container from a network
alias dcni='docker network inspect'  # show detailed information on networks
alias dcnls='docker network ls'  # list networks
alias dcnprune='docker network prune'  # remove all unused networks
alias dcnrm='docker network rm'  # remove one or more networks
alias dcpo='docker container port'  # list port mappings for a container
alias dcps='docker ps'  # list running containers
alias dcpsa='docker ps -a'  # list running and stopped containers
alias dcpu='docker pull'  # pull an image from a registry
alias dcr='docker container run'  # create and start a container
alias dcrit='docker container run -it'  # create and start a container in an interactive shell
alias dcrm='docker container rm'  # remove one or more containers
alias 'dcrm!'='docker container rm -f'  # force-remove a running container (SIGKILL)
alias dcsprune='docker system prune'  # remove unused data
alias dcst='docker container start'  # start one or more stopped containers
alias dcrs='docker container restart'  # restart one or more containers
alias dcsta='docker stop $(docker ps -q)'  # stop all running containers
alias dcstp='docker container stop'  # stop one or more running containers
alias dcsts='docker stats'  # live resource usage statistics for containers
alias dctop='docker top'  # list the running processes of a container
alias dcvi='docker volume inspect'  # show detailed information on volumes
alias dcvls='docker volume ls'  # list volumes
alias dcvprune='docker volume prune'  # remove unused volumes
alias dcxc='docker container exec'  # run a command in a running container
alias dcxcit='docker container exec -it'  # run a command in a running container interactively
