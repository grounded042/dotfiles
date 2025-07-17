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
  # for some reason we cannot do an overlay of curl so we do this instead
  custom-curl = pkgs.curl.override {
    c-aresSupport = true;
  };
  custom-colmena = colmena.packages.${pkgs.system}.colmena;
in {
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  xdg.enable = true;

  home.stateVersion = "22.11";

  manual.manpages.enable = false;

  home.sessionPath = [
    "$GOBIN"
    "/opt/local/bin"
    "/opt/local/sbin"
    "/opt/homebrew/bin"
    "$HOME/.npm-packages/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
  ];

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
    goPath = "go";
    goBin = "go/bin";
  };

  programs.jq.enable = true;

  imports = [
    ./modules/neovim
    ./modules/git
    ./modules/tmux.nix
    ./modules/zsh.nix
    ./modules/user-defaults.nix
    ./modules/ghostty.nix
  ];

  # TODO: programs.ssh

  home.file.".digrc".text = "@1.1.1.1";
  # home.file.".curlrc".text = "--doh-url \"https://1.1.1.1/dns-query\"\n--capath /Users/${config.home.username}/.config/certs";

  # TODO: services.gpg-agent
  # TODO: xdg

  home.packages = with pkgs; [
    ack
    autoconf
    automake
    awscli2
    btop
    cargo
    claude-code
    cmake
    custom-colmena
    custom-curl
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
    graphviz
    grpcurl
    htop
    hugo
    hurl
    hwatch
    imagemagick
    kind
    iperf
    kcat
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
    nodejs_24
    redis
    ripgrep
    rustc
    rust-analyzer
    shellcheck
    sipcalc
    swiftlint
    tailwindcss_4
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
    zsh-syntax-highlighting
  ];
}
