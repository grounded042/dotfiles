
export PATH="/opt/local/bin:/opt/local/sbin:$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin:$(brew --prefix coreutils)/libexec/gnubin"
export GOPATH="$HOME/go"
export HOMEBREW_NO_AUTO_UPDATE=1

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

alias k="kubectl"

# git aliases
alias gs="git status"
alias cdgb='cd $(git rev-parse --show-toplevel)'

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

source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
export KUBE_PS1_SYMBOL_ENABLE="false"
# PS1='$(kube_ps1)'$PS1

source $HOME/.work_profile
