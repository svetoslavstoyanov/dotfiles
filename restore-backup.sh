#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [-a|--all]

Pick a .bak.<timestamp> file with fzf and move it over its original file.
  -a, --all   restore the newest backup of every file (no picker)
EOF
}

collect_backups() {
  local item name

  while IFS= read -r -d '' item; do
    name="${item##*/}"
    [[ "$name" =~ \.bak\.[0-9]{14}([0-9]{3})?$ ]] || continue
    printf '%s\0' "$item"
  done < <(
    find "$HOME" -maxdepth 1 -type f -print0 2>/dev/null
    if [[ -d "$HOME/.config" ]]; then
      find "$HOME/.config" -name .git -prune -o -type f -print0 2>/dev/null
    fi
  )
}

format_date() {
  local ts="$1"
  printf '%s-%s-%s %s:%s:%s' \
    "${ts:0:4}" "${ts:4:2}" "${ts:6:2}" "${ts:8:2}" "${ts:10:2}" "${ts:12:2}"
}

target_path() {
  printf '%s' "${1%\.bak.*}"
}

confirm() {
  local answer
  read -r -p "$1 [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

ALL=false

while (( $# > 0 )); do
  case "$1" in
    -a|--all) ALL=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
  shift
done

mapfile -d '' -t backups < <(collect_backups)

if (( ${#backups[@]} == 0 )); then
  echo "✔ No backups found"
  exit 0
fi

# Records are NUL-delimited "timestamp<TAB>path", sorted newest first.
mapfile -d '' -t entries < <(
  for backup in "${backups[@]}"; do
    name="${backup##*/}"
    timestamp="${name##*.bak.}"
    printf '%s\t%s\0' "$timestamp" "$backup"
  done | LC_ALL=C sort -z -t $'\t' -k1,1r -k2,2
)

if [[ "$ALL" == true ]]; then
  declare -A seen=()
  latest=()

  for entry in "${entries[@]}"; do
    backup="${entry#*$'\t'}"
    target="$(target_path "$backup")"
    [[ -n "${seen[$target]:-}" ]] && continue
    seen[$target]=1
    latest+=("$backup")
  done

  printf 'Newest backup per file (%d):\n' "${#latest[@]}"
  for backup in "${latest[@]}"; do
    printf '  %s -> %s\n' "$backup" "$(target_path "$backup")"
  done

  confirm "Restore ${#latest[@]} file(s)?" || { echo "Aborted"; exit 0; }

  for backup in "${latest[@]}"; do
    target="$(target_path "$backup")"
    mv -- "$backup" "$target"
    echo "✔ Restored $target"
  done
  exit 0
fi

command -v fzf >/dev/null 2>&1 || { echo "restore-backup: fzf is required" >&2; exit 1; }

lines=()
for entry in "${entries[@]}"; do
  timestamp="${entry%%$'\t'*}"
  backup="${entry#*$'\t'}"
  printf -v line '%s\t%s\t%s' "$(format_date "$timestamp")" "$(target_path "$backup")" "$backup"
  lines+=("$line")
done

selected="$(
  printf '%s\n' "${lines[@]}" | fzf \
    --delimiter=$'\t' \
    --with-nth=1,3 \
    --prompt='restore> ' \
    --header='Enter: restore | Esc: cancel' \
    --preview 'printf "Target: {2}\n\n"; if command -v bat >/dev/null 2>&1; then bat --paging=never --style=numbers --color=always --line-range=:200 -- {3}; else sed -n "1,200p" -- {3}; fi' \
    --preview-window='right:60%:wrap'
)" || { echo "Aborted"; exit 0; }

backup="${selected#*$'\t'}"
backup="${backup#*$'\t'}"
[[ -n "$backup" ]] || { echo "Aborted"; exit 0; }
target="$(target_path "$backup")"

printf '  %s\n-> %s\n' "$backup" "$target"
confirm "Replace the current file?" || { echo "Aborted"; exit 0; }
mv -- "$backup" "$target"
echo "✔ Restored $target"
