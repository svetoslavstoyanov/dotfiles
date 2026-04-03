# Fish shell functions

set REMOTES_ORIGIN_PREFIX "remotes/origin/"

function mkd
    mkdir -p $argv && cd $argv[-1]
end

function gcof
    set BRANCH (git branch -a | fzf | awk '{$1=$1};1')
    git checkout (getBranchName $BRANCH)
end

function gcotf
    set TAG (git tag -l --sort=-v:refname | fzf | awk '{$1=$1};1')
    git checkout $TAG
end

function glf
    set BRANCH (git branch -a | fzf | awk '{$1=$1};1')
    if test (isOrigin $BRANCH) = true
        git pull origin (getBranchName $BRANCH)
    else
        git merge (getBranchName $BRANCH)
    end
end

function gbdf
    set BRANCH (git branch -a | fzf | awk '{$1=$1};1')
    git branch -D (getBranchName $BRANCH)
end

function gitcm
    set CURRENT_PATH (pwd)
    cd $CURRENT_PATH
    if test -z "$argv"
        echo ERROR: PROVIDE MESSAGE
        return 0
    end
    set PROJECT_TASK_PREFIX (git branch --show-current | grep -o '[^/]*-[0-9]\+')
    if test -z "$PROJECT_TASK_PREFIX"
        git commit -m "$argv"
    else
        git commit -m "[$PROJECT_TASK_PREFIX] - $argv"
    end
end

function gstaaf
    set STASH_INDEX (getStashIndex)
    if test -z "$STASH_INDEX"
        return
    end
    git stash apply $STASH_INDEX
end

function gstadf
    set STASH_INDEX (getStashIndex)
    if test -z "$STASH_INDEX"
        return
    end
    git stash drop $STASH_INDEX
end

function gstasf
    set STASH_INDEX (getStashIndex)
    if test -z "$STASH_INDEX"
        return
    end
    git stash show -p $STASH_INDEX
end

function getStashIndex
    set STASH (git stash list | fzf | awk '{$1=$1};1')
    echo $STASH | grep -o 'stash@{[0-9]*}' | grep -o '[0-9]*'
end

function isOrigin
    if string match -q "*$REMOTES_ORIGIN_PREFIX*" $argv[1]
        echo true
    else
        echo false
    end
end

function getBranchName
    set BRANCH $argv[1]
    if test (isOrigin $BRANCH) = true
        echo (string replace "$REMOTES_ORIGIN_PREFIX" "" $BRANCH)
    else
        echo $BRANCH
    end
end

function npmr
    set FILE 'package.json'
    if not test -f "$FILE"
        echo "File does not exist."
        return 0
    end
    set COMMAND (echo (jq .scripts package.json) | jq -r 'to_entries | sort_by(.key) | reverse | map(.key + " => " + .value) | join("\n")' | fzf | grep -o '^[^=]*')
    if test -z "$COMMAND"
        return
    end
    echo COMMAND: $COMMAND
    npm run $COMMAND
    # Note: Fish history is different, no direct equivalent
end

function zf
    set dir (zoxide query -l | sort -k2 -rn | fzf)
    if test -n "$dir"
        z "$dir"
    end
end

function zgf
    set dir (zoxide query -l | xargs -I {} sh -c 'test -d {}/.git && echo {}' | fzf)
    if test -n "$dir"
        z "$dir"
    end
end

function zpf
    set dir (zoxide query -l | sort -k2 -rn | grep -i personal | fzf)
    if test -n "$dir"
        z "$dir"
    end
end

function zwf
    set dir (zoxide query -l | grep -i work | fzf)
    if test -n "$dir"
        z "$dir"
    end
end
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

function kpp() {
  local PORT="$1"

  if [[ -z "$PORT" ]]; then
    echo "Usage: kpp <port>"
    return 1
  fi

  local PIDS
  PIDS=$(lsof -t -i :"$PORT" 2>/dev/null)

  if [[ -z "$PIDS" ]]; then
    echo "Nothing is running on port $PORT"
    return 0
  fi

  echo "Killing process(es) on port $PORT: $PIDS"
  kill -9 $PIDS
}

