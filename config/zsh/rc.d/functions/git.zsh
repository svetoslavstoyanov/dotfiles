REMOTES_ORIGIN_PREFIX="remotes/origin/"



function gcof() {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    git checkout $(getBranchName $BRANCH)
}

function gcotf() {
    local TAG=$(git tag -l --sort=-v:refname | fzf | awk '{$1=$1};1')

    git checkout $TAG
}

function glf() {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    if [[ $(isOrigin $BRANCH) == true ]]; then
        git pull origin $(getBranchName $BRANCH)
    else
        git merge $(getBranchName $BRANCH)
    fi
}

function gbdf {
    local BRANCH=$(git branch -a --sort=-committerdate | fzf | awk '{$1=$1};1')

    git branch -D $(getBranchName $BRANCH)
}

function gstaaf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash apply $STASH_INDEX
}

function gstadf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash drop $STASH_INDEX
}

function gstasf() {
    local STASH_INDEX=$(getStashIndex)

    if [ -z "$STASH_INDEX" ]; then
        return
    fi

    git stash show -p $STASH_INDEX
}

function getStashIndex() {
    local STASH=$(git stash list | fzf | awk '{$1=$1};1')
    echo $STASH | grep -oP '(?<=stash@{).*(?=})'
}

function isOrigin() {
    if [[ "$1" == *"$REMOTES_ORIGIN_PREFIX"* ]]; then
        echo true
    else
        echo false
    fi
}

function getBranchName() {
    local BRANCH=$1
    if [[ $(isOrigin $BRANCH) == true ]]; then
        echo ${BRANCH#"$REMOTES_ORIGIN_PREFIX"}
    else
        echo $BRANCH
    fi
}
