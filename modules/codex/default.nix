{
  pkgs,
  lib,
  currentSystem,
  ...
}: let
  enabled = currentSystem.enableCodex or false;

  tomlFormat = pkgs.formats.toml {};

  settings = {
    # Always reason deeply, mirrors Claude Code's alwaysThinkingEnabled
    model_reasoning_effort = "high";
    # Terse responses by default, mirrors Claude Code's outputStyle = Concise
    model_verbosity = "low";
    # Fall back to a repo's CLAUDE.md when there's no AGENTS.md
    project_doc_fallback_filenames = ["CLAUDE.md"];
  };
in {
  # System-level defaults (lowest config precedence). Codex writes per-project trust
  # decisions into ~/.codex/config.toml, so a Nix-managed symlink can't live there;
  # /etc/codex/config.toml is never written to by codex itself.
  environment.etc."codex/config.toml" = lib.mkIf enabled {
    source = tomlFormat.generate "codex-config.toml" settings;
  };

  home-manager.sharedModules = [
    ({
      config,
      pkgs,
      lib,
      agentInstructions,
      ...
    }: {
      home.packages = lib.mkIf enabled [pkgs.codex];

      # Global instructions (applies to all projects), shared with Claude Code's CLAUDE.md
      home.file.".codex/AGENTS.md" = lib.mkIf enabled {
        text = agentInstructions;
      };

      # Run codex inside nono's kernel-enforced sandbox
      programs.zsh.shellAliases = lib.mkIf (enabled && config.programs.zsh.enable && (currentSystem.enableNono or false)) {
        scodex = "nono run --profile nolabs-ai/codex -- codex";
      };
    })
  ];
}
