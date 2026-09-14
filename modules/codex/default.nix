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

      # Shared global instructions plus Codex-specific Pi delegation guidance.
      home.file.".codex/AGENTS.md" = lib.mkIf enabled {
        text =
          agentInstructions
          + lib.optionalString (currentSystem.enablePi or false) ''

            ## Local Pi worker

            A local coding agent is available through the `pi` CLI.

            Use Pi as a focused implementer or second set of eyes, not as the coordinator
            for a multi-tool task. Give it narrow, self-contained work.

            For read-only work:

                pi --no-session --tools read,grep,find,ls -p "<task>"

            For implementation:

                pi --no-session --tools read,grep,find,ls,bash,edit,write -p "<task>"

            Let Pi edit, but have Codex review every diff, handle staging, and run final
            validation. Do not assign long Nix builds unless that is Pi's sole task.
            Require command evidence for version claims.

            For long calls, use a PTY/session and poll. Keep correction prompts short and
            self-contained because `--no-session` forgets prior runs. If Pi reports "No API
            key found," check access to `~/.pi` before assuming credentials are missing.

            Keep the tree stable during reviews and never edit it concurrently with Pi.
            Use a separate worktree for experimental or messy changes. Request concise
            results with exact paths and lines, then independently verify them.
          '';
      };

      # Run codex inside nono's kernel-enforced sandbox
      programs.zsh.shellAliases = lib.mkIf (enabled && config.programs.zsh.enable && (currentSystem.enableNono or false)) {
        scodex = "nono run --profile nolabs-ai/codex -- codex";
      };
    })
  ];
}
