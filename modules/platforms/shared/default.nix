{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  programs.zsh.enable = true;

  # Temporary defense-in-depth for the October 2026 eMudhra intermediate CA
  # compromise. Remove this only after every TLS client has an upstream fix.
  # https://emudhra.we-have-a-problem.com/
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];

  nix = lib.mkIf config.nix.enable {
    settings = {
      allowed-users = [username];
      experimental-features = ["nix-command" "flakes"];
      max-jobs = "auto";
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  users = {
    users = {
      ${username} = {
        description = "Jon Carl";
        shell = pkgs.zsh;
      };
    };
  };
}
