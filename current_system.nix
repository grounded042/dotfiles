{
  # Set this to your system username
  username = "your-username";
  configuration = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Machine-specific system configuration goes here
  };
  home = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Machine-specific home-manager configuration goes here
  };
}
