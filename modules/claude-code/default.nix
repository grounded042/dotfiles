{
  config,
  pkgs,
  lib,
  ...
}: let
  # Statusline script with jq in PATH
  statusLineScript = pkgs.writeShellScript "claude-statusline" ''
    export PATH="${pkgs.jq}/bin:$PATH"
    ${builtins.readFile ./statusline.sh}
  '';

  # Hook to block reading sensitive files
  blockSensitiveFilesHook = pkgs.writeShellScript "block-sensitive-files" ''
    export PATH="${pkgs.jq}/bin:$PATH"
    FILE_PATH=$(jq -r '.tool_input.file_path // ""' )
    BASENAME=$(basename "$FILE_PATH")

    # .env files
    if [[ "$FILE_PATH" =~ \.env$ ]] || \
       [[ "$FILE_PATH" =~ \.env\. ]] || \
       [[ "$BASENAME" =~ ^\.?env$ ]]; then
      echo "Blocked: Cannot read sensitive file: $FILE_PATH"
      exit 2
    fi

    # Secrets by extension
    if [[ "$FILE_PATH" =~ \.(secret|key|pem|p12|pfx|jks|credentials|keystore)$ ]]; then
      echo "Blocked: Cannot read sensitive file: $FILE_PATH"
      exit 2
    fi

    # SSH private keys by name pattern
    if [[ "$BASENAME" =~ ^id_(rsa|ed25519|ecdsa|dsa)$ ]] || \
       [[ "$FILE_PATH" =~ _rsa$ ]] || \
       [[ "$FILE_PATH" =~ _ed25519$ ]] || \
       [[ "$FILE_PATH" =~ _ecdsa$ ]]; then
      echo "Blocked: Cannot read private key: $FILE_PATH"
      exit 2
    fi

    # Sensitive directories and files
    if [[ "$FILE_PATH" =~ /\.ssh/ ]] || \
       [[ "$FILE_PATH" =~ /\.gnupg/ ]] || \
       [[ "$FILE_PATH" =~ /\.aws/credentials ]] || \
       [[ "$FILE_PATH" =~ /\.aws/config ]] || \
       [[ "$FILE_PATH" =~ /\.kube/config ]] || \
       [[ "$FILE_PATH" =~ /\.docker/config\.json ]] || \
       [[ "$BASENAME" == ".netrc" ]]; then
      echo "Blocked: Cannot read sensitive file: $FILE_PATH"
      exit 2
    fi
  '';

  # Fetch ast-grep skill from upstream (pinned)
  astGrepSkill = pkgs.fetchFromGitHub {
    owner = "ast-grep";
    repo = "claude-skill";
    rev = "d46b7d0cd238000e35bfcd57aa95edb3ed6a573c";
    sha256 = "sha256-LCI06qz9skVqSsXc88djK6YixABB+GnvoZcSce1m5Aw=";
  };

  # Main settings configuration
  settings = {
    # Model configuration
    model = "sonnet";

    # Always use extended thinking
    alwaysThinkingEnabled = true;

    # Status line using our Nix-managed script
    statusLine = {
      type = "command";
      command = "${statusLineScript}";
    };

    # Enabled plugins/MCP servers
    enabledPlugins = {
      "gopls-lsp@claude-plugins-official" = true;
      "compound-engineering@every-marketplace" = true;
    };

    # Environment variables for Claude Code sessions
    env = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };

    # Hooks - run scripts before/after tool execution
    hooks = {
      PreToolUse = [
        {
          matcher = "Read";
          hooks = [
            {
              type = "command";
              command = "${blockSensitiveFilesHook}";
            }
          ];
        }
      ];
    };
  };
in {
  # Install claude-code package
  home.packages = [pkgs.claude-code];

  # Create ~/.claude directory and settings
  home.file = {
    ".claude/settings.json".text = builtins.toJSON settings;

    # Global instructions (applies to all projects)
    ".claude/CLAUDE.md".source = ./CLAUDE.md;

    # ast-grep skill from upstream repo
    ".claude/skills/ast-grep".source = "${astGrepSkill}/ast-grep/skills/ast-grep";

    # Config viewer script
    ".local/bin/claude-config" = {
      executable = true;
      source = ./claude-config.sh;
    };
  };

  # Shell aliases for Claude Code
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    cr = "claude --resume";
    cn = "claude --new";
    cconfig = "claude-config";
  };
}
