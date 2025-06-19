# dotfiles
the dotfiles of Jon Carl

## Installation

### Prerequisites
1. **Install Ghostty** - Download from [ghostty.org](https://ghostty.org)
1. **Install Homebrew** - https://brew.sh/
2. **Install Nix** - https://nixos.org/download/
3. **Install SF Symbols** - Download from [Apple Developer](https://developer.apple.com/sf-symbols/)
4. **Required Permissions** - Terminal (or your terminal app) needs **Full Disk Access** permission to modify system preferences:
   - Go to **System Settings** > **Privacy & Security** > **Full Disk Access**
   - Add your terminal application (Terminal.app, Ghostty, etc.)
   - Restart your terminal

   Without this permission, you'll get errors like:
   ```
   Could not write domain /Users/.../Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari; exiting
   ```

### Installation
1. **Install nix-darwin** - Run from the repository root:
   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/code/dotfiles#joncarl-macbook
   ```

2. **Apply future changes** - After initial setup, use:
   ```bash
   sudo darwin-rebuild switch --flake ~/code/dotfiles#joncarl-macbook
   ```

## Customization

### Overriding Username
To use these dotfiles with a different username, modify the username in `current_system.nix`:

### System-Specific Configuration
Use `current_system.nix` to add machine-specific configuration without modifying the main files:

```nix
{
  username = "joncarl";
  configuration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Add your system-specific configuration here
    environment.etc."pam.d/sudo_local".enable = lib.mkForce false;
  };
}
```

