# uncomment for profiling
# zmodload zsh/zprof

# install zinit if not already installed
#

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d $ZINIT_HOME ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing zinit…%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
        print -P "%F{160}▓▒░ The clone has failed.%F"
fi

# use zinit
source "${ZINIT_HOME}/zinit.zsh"

export DISABLE_AUTO_UPDATE=true
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
export HISTIGNORE="ls:ll:cd:cd -:pwd:exit:date:* --help:clear"
export HISTDUP=erase        # Erase duplicates in the history file

bindkey -v # vi mode

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char

export KEYTIMEOUT=1

autoload -U select-word-style
select-word-style bash

autoload -U compinit
compinit
# load plugins
zinit load zsh-users/zsh-completions
zinit load zdharma-continuum/fast-syntax-highlighting
zinit load zsh-users/zsh-autosuggestions

export PURE_CMD_MAX_EXEC_TIME=0
export PURE_PROMPT_SYMBOL=→
export RPROMPT=""
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# fuzzy find
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances of the shell
setopt auto_cd # cd by typing directory name if it's not a command
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

source $HOME/.profile

# uncomment for profiling
# zprof

# so you can use gnu utils without their prefix
export XDG_CONFIG_HOME=~/.config

if [ -e /Users/joncarl/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/joncarl/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
