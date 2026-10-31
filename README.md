# Dotfiles

Personal dotfiles and setup scripts for a fresh Arch Linux system.

This repository contains:

- zsh, git, lazygit and starship configuration
- setup scripts for initial installation

---

## Structure

```bash
dotfiles/
├── config/     # ~/.config symlink targets
├── home/       # files symlinked directly into $HOME
├── scripts/    # helper and bootstrap scripts
├── setup.sh    # main setup entry point
└── README.md
```

## Requirements

- Arch Linux (the setup uses `pacman` and `yay`)
- A non-root user with `sudo` access
- Network access for package and plugin downloads

## 🚀 Quick start

```bash
mkdir -p ~/dev/personal
git clone https://github.com/svetoslavstoyanov/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
./setup.sh
```

The script can be run from any directory: it resolves the repository root itself.
It links `config/` and `home/`, installs packages, configures the locale, Git
identities/hooks, Oh My Zsh with its plugins, LazyVim and .NET, then switches
the default shell to zsh.

## Notes

- Existing files in `~/.config` are not overwritten; only missing entries are
  symlinked, and stale symlinks pointing at another checkout are relinked.
- An existing `~/.config/nvim` is left untouched, so LazyVim is only installed
  on a fresh setup.
- The shell configuration loads Oh My Zsh directly; Antigen is no longer used.
