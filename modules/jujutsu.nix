{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.jujutsu;

  defaultSigningProgram =
    if pkgs.stdenv.isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else lib.getExe' pkgs._1password-gui "op-ssh-sign";
in {
  options.jujutsu = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Jon Carl";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "grounded042@joncarl.com";
    };

    signingKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKq+/aX9bH1PAyJXY9q1huLgPzQfkcokYryhiwMl6kw";
    };

    signingProgram = lib.mkOption {
      type = lib.types.str;
      default = defaultSigningProgram;
    };
  };

  config = {
    home.packages = [pkgs.jujutsu];

    xdg.configFile."jj/config.toml".text = ''
      [user]
      name = "${cfg.userName}"
      email = "${cfg.userEmail}"

      [signing]
      # Drop signatures on rewrite; re-sign only on push to avoid
      # 1Password prompts on every jj operation
      behavior = "drop"
      backend = "ssh"
      key = "${cfg.signingKey}"
      backends.ssh.program = "${cfg.signingProgram}"

      [git]
      sign-on-push = true
    '';
  };
}
