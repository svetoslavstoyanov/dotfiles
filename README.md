# Dotfiles

Personal dotfiles and setup scripts for a fresh system.

This repository contains:
- shell configuration
- editor and terminal configs
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

## 🚀 Quick start

Run the following commands on a fresh system:

```bash
mkdir -p ~/dev/personal
git clone https://github.com/svetoslavstoyanov/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
chmod +x ./setup.sh
./setup.sh
```
