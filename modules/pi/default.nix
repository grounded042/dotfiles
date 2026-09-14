{
  config,
  pkgs,
  lib,
  currentSystem,
  ...
}: let
  enabled = currentSystem.enablePi or false;
  apiKey = currentSystem.omlxApiKey or null;

  settingsConfig = {
    defaultProvider = "omlx";
    defaultModel = "qwen3.8-27b-q4";
    compaction = {
      enabled = true;
      reserveTokens = 16384;
      keepRecentTokens = 12000;
    };
  };

  modelsConfig = {
    providers = {
      omlx =
        {
          baseUrl = "http://172.28.1.240:8000/v1";
          api = "openai-completions";
          models = [
            {
              id = "ornith";
              name = "Ornith 1.0 35B";
              contextWindow = 131072;
              maxTokens = 16384;
            }
            {
              id = "qwen3.8-8b";
              name = "Qwen3.8-8b";
              contextWindow = 131072;
              maxTokens = 16384;
            }
            {
              id = "qwen3.8-27b-q4";
              name = "qwen3.8-27b-q4";
              contextWindow = 65536;
              maxTokens = 8192;
            }
          ];
        }
        // lib.optionalAttrs (apiKey != null) {inherit apiKey;};
    };
  };
in {
  home.packages = lib.mkIf enabled [pkgs.pi];

  home.file."${config.home.homeDirectory}/.pi/agent/settings.json" = lib.mkIf enabled {
    text = builtins.toJSON settingsConfig;
  };

  home.file."${config.home.homeDirectory}/.pi/agent/models.json" = lib.mkIf enabled {
    text = builtins.toJSON modelsConfig;
  };

  # Run pi inside nono's kernel-enforced sandbox
  programs.zsh.shellAliases = lib.mkIf (enabled && config.programs.zsh.enable && (currentSystem.enableNono or false)) {
    spi = "nono run --profile nolabs-ai/pi -- pi";
  };
}
