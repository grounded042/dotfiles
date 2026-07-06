{
  pkgs,
  lib,
  currentSystem,
  ...
}: let
  enabled = currentSystem.enableOpencode or false;
  apiKey = currentSystem.opencodeApiKey or null;

  config = {
    "$schema" = "https://opencode.ai/config.json";
    # Plugins are installed declaratively via Nix into ~/.config/opencode/plugins/
    # (see xdg.configFile below); no `plugin` array so opencode never auto-installs.
    provider = {
      omlx = {
        npm = "@ai-sdk/openai-compatible";
        name = "oMLX";
        options =
          {
            baseURL = "http://172.28.1.240:8000/v1";
          }
          // lib.optionalAttrs (apiKey != null) {inherit apiKey;};
        models.ornith = {
          name = "Ornith 1.0 35B";
          limit = {
            context = 131072;
            output = 16384;
          };
        };
      };
    };
    model = "omlx/ornith";
    permission = {
      edit = "ask";
      bash = "ask";
      webfetch = "ask";
    };
    compaction.enabled = true;
    watcher.ignore = [
      "node_modules"
      ".git"
      "vendor"
      "dist"
      "build"
      "*.lock"
      ".next"
      "target"
    ];
  };

  # dcp plugin tuning, read from ~/.config/opencode/dcp.jsonc.
  # NOTE: dcp 3.1.x validates against a strict key allow-list. `summaryMinTokens`
  # and `prune.staleToolTurns` are not real keys; "prune stale tool outputs after
  # N turns" maps to turnProtection (protect last N turns, prune older).
  dcpConfig = {
    enabled = true;
    compress = {
      permission = "ask";
      minContextLimit = 64000;
      maxContextLimit = 96000;
    };
    turnProtection = {
      enabled = true;
      turns = 6;
    };
  };
in {
  home.packages = lib.mkIf enabled [pkgs.opencode];

  xdg.configFile."opencode/opencode.jsonc" = lib.mkIf enabled {
    text = builtins.toJSON config;
  };

  # Local plugins, managed by Nix instead of opencode's npm auto-install.
  # rtk: thin TS plugin that shells out to the `rtk` binary (already on PATH).
  xdg.configFile."opencode/plugins/rtk.ts" = lib.mkIf enabled {
    source = ./plugins/rtk.ts;
  };

  # dcp: vendored npm package + node_modules in the Nix store.
  xdg.configFile."opencode/plugins/dcp.js" = lib.mkIf enabled {
    source = "${pkgs.opencode-dcp}/lib/node_modules/@tarquinen/opencode-dcp/dist/index.js";
  };

  xdg.configFile."opencode/dcp.jsonc" = lib.mkIf enabled {
    text = builtins.toJSON dcpConfig;
  };
}
