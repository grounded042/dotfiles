# Path to your oh-my-zsh installation.
export ZSH=/Users/jcarl/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="grounded042"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git golang history history-substring-search)

# User configuration

export PATH="/Users/jcarl/.bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

# aliases
alias vd='vagrant destroy --force'
alias eev='export $(cat .env | xargs)'

# go stuff
export GOPATH=$HOME/gocode
export PATH=$GOPATH/bin:$PATH

source $ZSH/oh-my-zsh.sh
source /usr/local/opt/autoenv/activate.sh
source $ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval $(/usr/libexec/path_helper -s)
