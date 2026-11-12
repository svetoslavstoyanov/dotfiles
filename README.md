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
├── install.sh  # one-command installer
├── setup.sh    # main setup entry point
└── README.md
```

## 🚀 Quick start

For a one-command install from the temporary `optimize-repo` test branch:

```bash
( tmp="$(mktemp)" && trap 'rm -f "$tmp"' EXIT && \
  curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/optimize-repo/install.sh \
    -o "$tmp" && bash "$tmp" )
```

The installer updates Arch, ensures Git is installed, checks out
`optimize-repo`, and runs the full setup. The checkout line in `install.sh` is
temporary and should be removed after testing.

Run the following commands on a fresh system by invoking the script with
sudo. The setup updates Arch, creates a sudo-enabled user, and runs the
personal setup stages as that user. If the current checkout is not readable
by the new user, the script copies it to `~/dev/personal/dotfiles` first.

```bash
mkdir -p ~/dev/personal
git clone https://github.com/svetoslavstoyanov/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
chmod +x ./setup.sh
sudo ./setup.sh
```

## Run an individual stage

Each stage can also be run separately:

```bash
sudo ./setup.sh update
sudo ./setup.sh create-user
# Log in as the created user, then run:
./setup.sh link-config
./setup.sh link-home
./setup.sh install-packages
./setup.sh git-config
```

`update` and `create-user` require root. Run the remaining stages as the
created user; `install-packages` uses sudo for pacman and system configuration
while building AUR packages without root.
