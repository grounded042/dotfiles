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
    # CVE-2026-111943
    "Comodo AAA Services root"
    # https://hg-edge.mozilla.org/projects/nss/rev/26d38a0c3fb81e7fb2acedbaf4c42dd21dce0517
    "emSign ECC Root CA - G3"
    # https://hg-edge.mozilla.org/projects/nss/rev/8159223c48ceeb1273a1915bca95a517294ab0e0
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
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
