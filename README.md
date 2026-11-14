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
├── config/          # files copied into ~/.config
├── home/            # files copied directly into $HOME
├── scripts/         # helper and bootstrap scripts
│   ├── installer/        # standalone installer helpers
│   │   └── create-user.sh # creates the initial sudo user
│   ├── git/              # split Git configuration steps
│   └── install-packages/ # split package installation steps
├── install.sh       # bootstrap installer for a fresh Arch install
├── setup.sh         # main setup entry point
├── copy-conf.sh     # copies configuration without running the full setup
├── clean-backups.sh # removes backups created by copy-conf.sh
└── README.md
```

## 🚀 Bootstrap install (fresh Arch)

On a fresh Arch install, log in as **root** (sudo does not exist yet) and run:

```bash
curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/master/install.sh | sh
```

The installer:

- installs `sudo`, `git` and `curl`
- prompts for a username and password, then creates a `wheel` user with sudo
  access
- clones this repository to `~/dev/personal/dotfiles`
- runs `setup.sh` as the new user

Notes:

- Run it inside the installed system, not the live ISO. From the ISO, use
  `arch-chroot` first.
- A real terminal is required because the scripts prompt for input.
- `curl` must already be available to download the installer.
- Piping a remote script into `sh` trusts that URL; review `install.sh` first
  if you prefer.

## 🚀 Manual quick start

Run the following commands on a fresh system:

```bash
mkdir -p ~/dev/personal
git clone https://github.com/svetoslavstoyanov/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles
chmod +x ./setup.sh
./setup.sh
```

To only copy the configuration (without installing packages or running the
full setup), run:

```bash
./copy-conf.sh
```

When a destination file differs, the script backs it up as
`.bak.<timestamp>` and copies the new version into place. To overwrite
without creating backups, use:

```bash
./copy-conf.sh --no-backup
```

To remove the `.bak.*` files created by the copy script, run:

```bash
./clean-backups.sh        # lists and asks for confirmation
./clean-backups.sh --yes  # deletes without prompting
```
