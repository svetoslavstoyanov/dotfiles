function runPackageJsonScript() {
    local pm="$1"
    local command

    [[ -f package.json ]] || { echo "File does not exist."; return 1; }

    command=$(
        jq -r '.scripts | to_entries[] | "\(.key)\t=> \(.value)"' package.json |
        fzf |
        cut -f1
    ) || return

    [[ $? -eq 0 && -n "$command" ]] || return

    "$pm" run "$command"
    print -s "$pm run $command"
    fc -W
}

function npmr() {
    runPackageJsonScript npm
}

function pnpmr() {
    runPackageJsonScript pnpm
}
