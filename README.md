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
./setup.sh install-packages
./setup.sh link-config
./setup.sh link-home
./setup.sh git-config
```

`update` and `create-user` require root. Run `install-packages` as the target
user so AUR packages are built without root; it uses sudo for pacman and
system configuration. The link and Git stages run as the account that owns
the target home directory.
