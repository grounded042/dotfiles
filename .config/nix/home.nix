# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
# https://github.com/simonrw/nix-config/blob/d0fafa870138b94da5e41286a58a8bd3cb0d0ed2/home/packages/simon.nix

{ config, pkgs, lib, colmena, username, ... }:
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
          black =   "#292929";
          red =     "#fc2c1d";
          green =   "#2fcc70";
          yellow =  "#f1c40c";
          blue =    "#3398db";
          magenta = "#6170c4";
          cyan =    "#0095de";
          white =   "#dee2ea";
        };

        bright = {
          black =   "#494949";
          red =     "#e74b3b";
          green =   "#07d773";
          yellow =  "#f6c700";
          blue =    "#0095de";
          magenta = "#6667c6";
          cyan =    "#0092e2";
          white =   "#feffff";
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
  ];

  # TODO: programs.ssh

  programs.tmux = {
    enable = true;

    # to work around tmux not using the correct shell
    # https://github.com/nix-community/home-manager/issues/5952
    sensibleOnTop = false;

    # so that escapes register immidiately in vim
    escapeTime = 0;

    # start window numbering at 1 for easier switching
    baseIndex = 1;

    clock24 = true;

    prefix = "C-s";

    terminal = "screen-256color";

    # scroll back farther
    historyLimit = 30000;

    extraConfig = ''
bind-key -n C-h select-pane -L
bind-key -n C-j select-pane -D
bind-key -n C-k select-pane -U
bind-key -n C-l select-pane -R

bind -n M-Left resize-pane -L 2
bind -n M-Right resize-pane -R 2
bind -n M-Down resize-pane -D 2
bind -n M-Up resize-pane -U 2

bind -n C-Left resize-pane -L 10
bind -n C-Right resize-pane -R 10
bind -n C-Down resize-pane -D 5
bind -n C-Up resize-pane -U 5

# split panes with | and - and open the new panes at the current path
bind-key - split-window -v  -c '#{pane_current_path}'
bind-key \\ split-window -h  -c '#{pane_current_path}'

bind c new-window -c '#{pane_current_path}'

set-option -g renumber-windows on

bind-key b break-pane -d

bind-key C-j choose-tree

# styling
set -g status-bg "#191919"
set -g status-fg white

set-option -g status-left-length 50

set -g status-justify centre

set -g status-right "#[fg=white,bg=#191919] %H:%M %d-%b-%y "
set -g status-left "#[fg=white,bg=#191919] #(layer0 profile current | tr '[:lower:]' '[:upper:]')"
set -g window-status-separator "#[fg=white,bg=#191919]|"
set -g window-status-current-format "#[fg=white,bg=#191919] #I #W #F "
set -g window-status-format "#[fg=white,bg=#191919] #I #W #F "

set -ga terminal-features "*:hyperlinks"
'';


  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;

    defaultKeymap = "viins";

    history = {
      extended = true;
      ignorePatterns = [
        "ls" "ll" "cd" "cd -" "pwd" "exit" "date" "* --help" "clear"
      ];
      path = "${config.xdg.stateHome}/.zsh_history";
      save = 100000;
      size = 100000;
    };

    autocd = true;

    # before compinit
    initExtraFirst = ''
ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing zinit…%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
        print -P "%F{160}▓▒░ The clone has failed.%F"
fi

# use zinit
source "''${ZINIT_HOME}/zinit.zsh"

export DISABLE_AUTO_UPDATE=true
export HISTDUP=erase        # Erase duplicates in the history file

export KEYTIMEOUT=1

autoload -U select-word-style
select-word-style bash

export PATH=/etc/profiles/per-user/${config.home.username}/bin:$PATH
'';

    initExtraBeforeCompInit = ''
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
'';

    # after compinit
    initExtra = ''
# load plugins
zinit load zdharma-continuum/fast-syntax-highlighting

export PURE_CMD_MAX_EXEC_TIME=0
export PURE_PROMPT_SYMBOL=→
export PURE_GIT_PULL=0
export RPROMPT=""
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# fuzzy find
# if [ -n "''${commands[fzf-share]}" ]; then
#   source "$(fzf-share)/key-bindings.zsh"
#   source "$(fzf-share)/completion.zsh"
# fi

setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '''''' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

# kubernetes stuff
kc() {
    if [[ -z "$1" ]]; then
      echo "$(tput bold)Available contexts:"
      echo "$(tput sgr0)`kubectl config view -o jsonpath='{.contexts[*].name}' | tr ' ' '\n'`"
      echo "$(tput bold)Current context:"
      echo "$(tput sgr0)`kubectl config current-context`"
    else
      kubectl config use-context $1
    fi
  }

kn() {
  if [[ -z "$1" ]]; then
    echo "$(tput bold)Namespaces:"
    echo "$(tput sgr0)$(kubectl get namespaces)"
    echo "$(tput bold)Current namespace:$(tput sgr0)"

    kubectl config view -o json | jq -r ".contexts[] | select(.name == \"$(kubectl config current-context)\") | .context.namespace"
  else
    kubectl config set-context $(kubectl config current-context) --namespace=$1
    echo "Namespace set to \"$1\""
  fi
}

nix-rebuild() {
  pushd ~/.config/nix
  darwin-rebuild switch --flake .#joncarl-macbook
  popd
}

source $HOME/.work_profile
'';

    sessionVariables = {
      HOMEBREW_NO_AUTO_UPDATE = 1;
      PATH = "$PATH:$(brew --prefix coreutils)/libexec/gnubin";
      GPG_TTY = "$(tty)";
      VISUAL = "nvim";
      EDITOR = "nvim";
    };

    shellAliases = {
      vd = "vagrant destroy --force";
      vu = "vagrant up";
      vs = "vagrant ssh";
      eev = "export $(cat .env | xargs)";
      dd = "docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)";
      k = "kubectl";
      gs = "git status";
      cdgb = "cd $(git rev-parse --show-toplevel)";
      vim = "nvim";
    };
  };

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
    (lua.withPackages (ps: with ps; [luacheck cjson basexx]))
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
