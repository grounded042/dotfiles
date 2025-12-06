# NixOS-specific overlay - adds nixos packages to platformPackages  
final: prev: {
  platformPackages = (prev.platformPackages or {}) // {
    # GUI applications (manually installed via Homebrew/App Store on macOS)
    inherit (prev) firefox ghostty wofi;
  };
}