{
  config,
  pkgs,
  lib,
  ...
}: {
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
}
