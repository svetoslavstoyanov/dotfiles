function runPackageJsonScript() {
  local pm=$1 tool scripts line script

  [[ -n $pm ]] || { print -ru2 -- 'usage: runPackageJsonScript <package-manager>'; return 1; }
  [[ -f package.json ]] || { print -ru2 -- 'package.json not found'; return 1; }
  for tool in jq fzf; do
    command -v "$tool" >/dev/null 2>&1 || { print -ru2 -- "$tool is required"; return 1; }
  done

  scripts=$(command jq -r '.scripts | to_entries[] | "\(.key)\t=> \(.value)"' package.json 2>/dev/null) || return $?
  [[ -n $scripts ]] || { print -ru2 -- 'No scripts defined in package.json'; return 1; }

  line=$(printf '%s\n' "$scripts" | fzf --prompt='script> ') || return $?
  script=${line%%$'\t'*}
  [[ -n $script ]] || return 1

  "$pm" run "$script" || return $?
  print -s -- "$pm run $script"
  fc -W
}

function npmRunFuzzy() {
  runPackageJsonScript npm
}

function pnpmRunFuzzy() {
  runPackageJsonScript pnpm
}
