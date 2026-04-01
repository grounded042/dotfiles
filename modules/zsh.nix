{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;

    defaultKeymap = "viins";

    history = {
      extended = true;
      ignorePatterns = [
        "ls"
        "ll"
        "cd"
        "cd -"
        "pwd"
        "exit"
        "date"
        "* --help"
        "clear"
      ];
      path = "${config.xdg.stateHome}/.zsh_history";
      save = 100000;
      size = 100000;
    };

    autocd = true;

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "pure-async";
        src = pkgs.pure-prompt;
        file = "share/zsh/site-functions/async";
      }
      {
        name = "pure";
        src = pkgs.pure-prompt;
        file = "share/zsh/site-functions/prompt_pure_setup";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        export DISABLE_AUTO_UPDATE=true
        export HISTDUP=erase        # Erase duplicates in the history file

        export KEYTIMEOUT=1

        export PURE_CMD_MAX_EXEC_TIME=0
        export PURE_PROMPT_SYMBOL=→
        export PURE_GIT_PULL=0

        autoload -U select-word-style
        select-word-style bash

        export PATH=/etc/profiles/per-user/${config.home.username}/bin:$PATH
      '')
      (lib.mkOrder 550 ''
        bindkey '^P' up-history
        bindkey '^N' down-history
        bindkey '^?' backward-delete-char
        bindkey '^h' backward-delete-char
        bindkey '^w' backward-kill-word

        bindkey '^[[1~' beginning-of-line
        bindkey '^[[4~' end-of-line
        bindkey '^[[3~' delete-char
      '')
      ''
        # Append wall clock start→end times next to pure's duration display
        _wall_clock_start=""

        preexec() {
          _wall_clock_start=$(date '+%H:%M:%S')
        }

        # Wrap pure's exec time check to append our wall clock times
        functions[_orig_prompt_pure_check_cmd_exec_time]=$functions[prompt_pure_check_cmd_exec_time]
        prompt_pure_check_cmd_exec_time() {
          _orig_prompt_pure_check_cmd_exec_time
          if [[ -n $_wall_clock_start && -n $prompt_pure_cmd_exec_time ]]; then
            local end_time=$(date '+%H:%M:%S')
            prompt_pure_cmd_exec_time+=" ($_wall_clock_start → $end_time)"
          fi
          _wall_clock_start=""
        }

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
        zstyle ':completion:*' group-name ' ' # group results by category
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

        if [ -f $HOME/.work_profile ]; then
          source $HOME/.work_profile
        fi
      ''
    ];

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
      dd = "docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)";
      k = "kubectl";
      gs = "git status";
      cdgb = "cd $(git rev-parse --show-toplevel)";
      vim = "nvim";
    };
  };
}
