# dotfiles
the dotfiles of Jon Carl

## Installation

### Prerequisites
1. **Install Nix** - Choose your preferred installation method (there are several options available)
2. **Install Ghostty** - Download from [ghostty.org](https://ghostty.org)
3. **Install SF Symbols** - Download from [Apple Developer](https://developer.apple.com/sf-symbols/)
4. **Required Permissions** - Terminal (or your terminal app) needs **Full Disk Access** permission to modify system preferences:
   - Go to **System Preferences** > **Privacy & Security** > **Full Disk Access**
   - Add your terminal application (Terminal.app, iTerm2, etc.)
   - Restart your terminal

   Without this permission, you'll get errors like:
   ```
   Could not write domain /Users/.../Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari; exiting
   ```

### Installation
Run the following command from the repository root:
```bash
sudo darwin-rebuild switch --flake ~/code/dotfiles#joncarl-macbook
```

