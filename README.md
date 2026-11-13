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
│   ├── git/         # split Git configuration steps
│   └── install-packages/ # split package installation steps
├── setup.sh         # main setup entry point
├── copy-conf.sh     # copies configuration without running the full setup
├── clean-backups.sh # removes backups created by copy-conf.sh
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

To only copy the configuration (without installing packages or running the
full setup), run:

```bash
./copy-conf.sh
```

When a destination file differs, the script merges it and backs it up as
`.bak.<timestamp>`. To overwrite without creating backups, use:

```bash
./copy-conf.sh --no-backup
```

To remove the `.bak.*` files created by the copy script, run:

```bash
./clean-backups.sh        # lists and asks for confirmation
./clean-backups.sh --yes  # deletes without prompting
```
