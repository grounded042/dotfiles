# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/simonrw/nix-config/blob/d0fafa870138b94da5e41286a58a8bd3cb0d0ed2/home/packages/simon.nix
{
  config,
  pkgs,
  lib,
  colmena,
  username,
  ...
}: let
  # Import system-specific configuration
  currentSystem = import ./current_system.nix;
  # for some reason we cannot do an overlay of curl so we do this instead
  custom-curl = pkgs.curl.override {
    c-aresSupport = true;
  };
  custom-colmena = colmena.packages.${pkgs.system}.colmena;

  # Platform detection
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.username = username;
  home.homeDirectory =
    if isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  xdg.enable = true;

  home.stateVersion = "22.11";

  home.pointerCursor = lib.mkIf isLinux {
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  manual.manpages.enable = false;

  home.sessionPath =
    [
      "$GOBIN"
      "$HOME/.npm-packages/bin"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ]
    ++ lib.optionals isDarwin [
      "/opt/local/bin"
      "/opt/local/sbin"
      "/opt/homebrew/bin"
    ];

  home.file.".npmrc".text = lib.mkDefault ''
    prefix=~/.npm-packages
    registry=https://registry.npmjs.org/
    ignore-scripts=true
    min-release-age=7d
    strict-ssl=true
    audit=true
    engine-strict=true
    prefer-offline=true
    fund=false
  '';

  programs.alacritty = {
    enable = true;

    settings = {
      env = {
        TERM = "xterm-256color";
      };

      window = {
        decorations = "buttonless";
        startup_mode = "Windowed";
        title = "Alacritty";
        dynamic_title = true;
        padding = {
          x = 8;
          y = 8;
        };
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "Monaco";
          style = "Regular";
        };
        size = 12.0;
      };

      colors = {
        draw_bold_text_with_bright_colors = true;

        primary = {
          background = "#292929";
          foreground = "#dee2ea";
        };

        cursor = {
          text = "#131313";
          cursor = "#c5c5c5";
        };

        selection = {
          text = "#dee2ea";
          background = "#fc2c1d";
        };

        normal = {
          black = "#292929";
          red = "#fc2c1d";
          green = "#2fcc70";
          yellow = "#f1c40c";
          blue = "#3398db";
          magenta = "#6170c4";
          cyan = "#0095de";
          white = "#dee2ea";
        };

        bright = {
          black = "#494949";
          red = "#e74b3b";
          green = "#07d773";
          yellow = "#f6c700";
          blue = "#0095de";
          magenta = "#6667c6";
          cyan = "#0092e2";
          white = "#feffff";
        };
      };

      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };

      selection = {
        save_to_clipboard = true;
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
      };

      live_config_reload = true;
    };
  };

  programs.bat = {
    enable = true;
    # TODO: look at config!
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.eza = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    package = pkgs.go;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };
  };

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
  };

  programs.jq.enable = true;

  imports = [
    currentSystem.home
    ./modules/neovim
    ./modules/git
    ./modules/tmux.nix
    ./modules/zsh.nix
    ./modules/ghostty.nix
    ./modules/ghostty-shader
    ./modules/claude-code
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityAgent = "~/.1password/agent.sock";
      extraOptions = {
        UserKnownHostsFile = "~/.ssh/known_hosts.d/pinned ~/.ssh/known_hosts";
      };
    };
  };

  home.file.".ssh/known_hosts.d/pinned".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  '';

  # Create symlink for 1Password SSH agent socket on macOS
  home.file.".1password/agent.sock" = lib.mkIf isDarwin {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  home.file.".config/pip/pip.conf".text = ''
    [global]
    index-url = https://pypi.org/simple/
    require-hashes = true
  '';

  home.file.".digrc".text = "@1.1.1.1";
  home.file.".curlrc".text = ''--doh-url "https://1.1.1.1/dns-query"'';

  # TODO: services.gpg-agent
  # TODO: xdg

  home.packages = with pkgs;
    [
      ack
      autoconf
      automake
      awscli2
      btop
      cargo
      cmake
      custom-colmena
      custom-curl
      opencode
      c-ares
      delta
      difftastic
      dig
      duckdb
      dyff
      exiftool
      findutils
      gh
      git
      gnugrep
      gnumake
      gnupg
      gnused
      gofumpt
      gopls
      graphviz
      grpcurl
      html-tidy
      htop
      hugo
      hurl
      hwatch
      imagemagick
      kind
      iperf
      # kcat  # Temporarily disabled due to avro-c++ build issue
      kubectl
      ldns
      libtool
      (lua.withPackages (
        ps:
          with ps; [
            luacheck
            cjson
            basexx
          ]
      ))
      lua-language-server
      lynx
      miller
      moreutils
      nginx
      niv
      nixd
      alejandra
      nmap
      openssl
      pkg-config
      protobuf
      # putty  # Temporarily disabled due to gtk+3 build issue
      pyenv
      nodejs_24
      postgresql
      redis
      ripgrep
      rustc
      rust-analyzer
      shellcheck
      sipcalc
      tailwindcss_4
      templ
      tmux
      tree-sitter
      typescript-language-server
      unbound
      vegeta
      wakeonlan
      yadm
      yarn
      yq-go
      zola
    ]
    ++ lib.attrValues (pkgs.platformPackages or {});
}
