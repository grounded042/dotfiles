# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/simonrw/nix-config/blob/d0fafa870138b94da5e41286a58a8bd3cb0d0ed2/home/packages/simon.nix

{
  config,
  pkgs,
  lib,
  colmena,
  username,
  ...
}:
let
  # for some reason we cannot do an overlay of curl so we do this instead
  custom-curl = pkgs.curl.override {
    c-aresSupport = true;
  };
  custom-colmena = colmena.packages.${pkgs.system}.colmena;
in
{
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

  home.file.".config/ghostty/config".text = ''
    # The syntax is "key = value". The whitespace around the equals doesn't matter.

    # make alt work for tmux
    keybind = alt+left=unbind
    keybind = alt+right=unbind

    font-family = "Monaco"
    font-style = "Regular"
    font-size = 12

    background = 292929
    foreground = dee2ea

    selection-foreground = dee2ea
    selection-background = fc2c1d

    cursor-color = c5c5c5
    cursor-text = 131313

    title = " "
    macos-titlebar-proxy-icon = hidden
    macos-icon = xray

    # Colors can be changed by setting the 16 colors of `palette`, which each color
    # being defined as regular and bold.
    #
    # black
    palette = 0=#292929
    palette = 8=#494949
    # red
    palette = 1=#fc2c1d
    palette = 9=#e74b3b
    # green
    palette = 2=#2fcc70
    palette = 10=#07d773
    # yellow
    palette = 3=#f1c40c
    palette = 11=#f6c700
    # blue
    palette = 4=#3398db
    palette = 12=#0095de
    # purple
    palette = 5=#6170c4
    palette = 13=#6667c6
    # aqua
    palette = 6=#0095de
    palette = 14=#0092e2
    # white
    palette = 7=#b9b9b9
    palette = 15=#d9d9d9

    window-padding-x = 8
    window-padding-y = 8
    window-theme = dark

    copy-on-select = clipboard

    window-padding-x = 2
    window-padding-y = 2
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
  };

  programs.eza = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # TODO: programs.git

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
  ];

  # TODO: programs.ssh

  home.file.".digrc".text = "@1.1.1.1";
  # home.file.".curlrc".text = "--doh-url \"https://1.1.1.1/dns-query\"\n--capath /Users/${config.home.username}/.config/certs";

  # TODO: services.gpg-agent
  # TODO: targets.darwin.defaults
  # TODO: xdg

  home.packages = with pkgs; [
    ack
    autoconf
    automake
    awscli2
    btop
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
      ps: with ps; [
        luacheck
        cjson
        basexx
      ]
    ))
    lua-language-server
    lynx
    miller
    moreutils
    # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
    # https://github.com/fricklerhandwerk/settings/blob/561f33f8b49690b619349c3950c5129876c00504/user/profiles/darwin/nixos-rebuild.nix
    # (pkgs.callPackage ./nixos-rebuild.nix {})
    nginx
    niv
    nixd
    nixfmt-rfc-style
    nmap
    openssl
    pkg-config
    protobuf
    nodejs_24
    redis
    ripgrep
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

    #yabai
    #skhd
    #spacebar
  ];
}
