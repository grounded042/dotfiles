# Darwin-specific overlay - adds darwin packages to platformPackages
final: prev: {
  platformPackages = (prev.platformPackages or {}) // {
    # Darwin-specific packages
    swiftlint = prev.swiftlint;
  };
}