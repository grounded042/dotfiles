
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin:$(brew --prefix coreutils)/libexec/gnubin"

# aliases
alias vd='vagrant destroy --force'
alias eev='export $(cat .env | xargs)'
alias lla='ll -A'
alias dd='docker stop $(docker ps -a -q); docker rm $(docker ps -a -q)'

alias ls='exa'
alias ll='exa -l'

alias today="icalbuddy -f -eep notes eventsToday"

# git aliases
alias gs="git status"

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

source $HOME/.work_profile
