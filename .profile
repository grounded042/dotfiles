
export PATH="/opt/local/bin:/opt/local/sbin:$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH:$HOME/go/bin:$(brew --prefix coreutils)/libexec/gnubin"
export HOMEBREW_NO_AUTO_UPDATE=1
export GPG_TTY=$(tty)
export VISUAL=nvim
export EDITOR="$VISUAL"

## direnv.net
eval "$(direnv hook zsh)"

# aliases
alias vd='vagrant destroy --force'
alias vu='vagrant up'
alias vs='vagrant ssh'
alias eev='export $(cat .env | xargs)'
alias lla='ll -A'
alias dd='docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)'

alias ls='exa'
alias ll='exa -l'

alias today="icalbuddy -f -eep notes eventsToday"

alias kubectl='kubectl ${KUBECTL_ARGS}'
alias k="kubectl"

# git aliases
alias gs="git status"
alias cdgb='cd $(git rev-parse --show-toplevel)'

# vim
alias vim="nvim"

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

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
