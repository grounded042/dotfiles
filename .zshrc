# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load from ~/.oh-my-zsh/themes/
ZSH_THEME="grounded042"

CASE_SENSITIVE="true"

plugins=(
	git 
	golang 
	history 
	history-substring-search
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

