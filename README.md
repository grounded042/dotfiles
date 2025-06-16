# dotfiles
the dotfiles of Jon Carl

## installation
1. Install yadm `sudo curl -fLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && sudo chmod a+x /usr/local/bin/yadm`
1. Pull the dotfiles `yadm clone git@github.com:grounded042/dotfiles.git`
1. Install via `./install.sh`

## nix-darwin setup
This repository uses nix-darwin for system configuration management.

### Required Permissions
**Important**: Terminal (or your terminal app) needs **Full Disk Access** permission to modify system preferences.

1. Go to **System Preferences** > **Privacy & Security** > **Full Disk Access**
2. Add your terminal application (Terminal.app, iTerm2, etc.)
3. Restart your terminal

Without this permission, you'll get errors like:
```
Could not write domain /Users/.../Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari; exiting
```

### Building the Configuration
```bash
sudo darwin-rebuild switch --flake ~/code/dotfiles/.config/nix#joncarl-macbook
```

