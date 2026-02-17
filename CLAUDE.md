# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

Jon Carl's personal dotfiles repository managing system configuration for two machines using Nix:
- **Nix/nix-darwin**: macOS system and package management
- **NixOS**: Linux system configuration
- **Home Manager**: User environment and application configuration
- **Agenix**: Secrets management

All applications and system settings are declaratively managed through Nix flake.

## Hosts

- `joncarl-macbook`: Apple Silicon (aarch64-darwin) macOS machine
- `pollux`: x86_64-linux NixOS machine

## Key Commands

### System Management
- `sudo darwin-rebuild switch --flake .#joncarl-macbook`: Rebuild macOS system
- `sudo nixos-rebuild switch --flake .#pollux`: Rebuild NixOS system
- **Yabai restart**: `sudo launchctl kickstart -k "gui/$(id -u)/org.nixos.yabai"` (service managed by Nix)

### Development
- `nvim`: Neovim editor (aliased from `vim`)
- `tmux`: Terminal multiplexer with custom prefix `C-s`
- `alejandra`: Nix code formatter

## Architecture Overview

### Top-Level Structure
- `flake.nix`: Inputs, outputs, overlays, and host definitions
- `configuration.nix`: Shared system-level configuration
- `home.nix`: User environment via Home Manager (packages, session vars, module imports)
- `current_system.nix`: Per-machine overrides (username, etc.)
- `hosts/<hostname>/`: Host-specific configuration
- `modules/`: Reusable configuration modules
- `packages/`: Custom Nix package definitions

### Module Structure

```
modules/
├── platforms/
│   ├── darwin/         # macOS-specific (yabai, sketchybar, system-settings, user-defaults)
│   ├── nixos/          # NixOS-specific (hyprland, pipewire, greetd, 1password, docker, steam)
│   └── shared/         # Common to both platforms (zsh, nix settings, gc, users)
├── claude-code/        # Claude Code config, hooks, statusline, skills
├── git/                # Git config with 1Password SSH signing
├── ghostty-shader/     # cursor.glsl shader symlink
├── neovim/             # Full Neovim config with plugins and ftplugins
├── quickshell/         # QML desktop shell config and wallpaper
├── ghostty.nix         # Ghostty terminal with custom color scheme
├── hyprland.nix        # Hyprland WM (Linux)
├── quickshell.nix      # Quickshell module
├── tmux.nix            # Tmux config (prefix C-s, vim pane nav, true color)
├── waybar.nix          # Wayland status bar (Linux)
└── zsh.nix             # Zsh with zinit, pure prompt, k8s helpers

packages/
└── opencode/           # opencode AI coding agent (prebuilt Darwin arm64)
```

### Overlays
- `git`: Disables macOS keychain support
- `claude-code`: Sourced from `github:sadjow/claude-code-nix` (hourly updates)
- `direnv`: Patches to skip checks
- Platform overlays add platform-specific packages (e.g., swiftlint on Darwin)

### Application Configurations
- **Neovim**: `modules/neovim/` — LSP, treesitter, telescope, copilot, lightline
- **Tmux**: `modules/tmux.nix` — vim pane navigation, true color, graphics passthrough
- **Zsh**: `modules/zsh.nix` — zinit (dynamically installed), pure prompt, vi mode, k8s helpers (`kc`, `kn`)
- **Window Management (macOS)**: `modules/platforms/darwin/yabai.nix`, `sketchybar.nix`
- **Window Management (Linux)**: `modules/hyprland.nix`, `modules/waybar.nix`
- **Ghostty**: `modules/ghostty.nix` — Monaco 12pt, dark theme, cursor shader
- **Git**: `modules/git/` — SSH signing via 1Password, 60+ aliases
- **Claude Code**: `modules/claude-code/` — settings, plugins, pre-read hooks, statusline, ast-grep skill

### Key Features
- Kubernetes helpers (`kc`, `kn`) for context/namespace switching in zsh
- Pre-read hooks blocking access to `.env`, `.key`, `.pem`, and other sensitive files
- Claude Code plugins: gopls-lsp, compound-engineering
- macOS system preferences declaratively set via `modules/platforms/darwin/system-settings.nix`
- Automatic Nix garbage collection (Sunday 2 AM, 7-day retention)
- Work-specific configuration sourced from `~/.work_profile`
- Alejandra used for Nix formatting

## Important Notes

- Modifying darwin-specific settings: edit under `modules/platforms/darwin/`
- Modifying nixos-specific settings: edit under `modules/platforms/nixos/`
- `configuration.nix` is shared; host-specific config goes in `hosts/<hostname>/`
- Claude Code source is `github:sadjow/claude-code-nix`, not nixpkgs
