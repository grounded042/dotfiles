#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# Copied from Adam Eivy
# @author Jon Carl
###########################


# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh

running "adding oh my zsh"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

bot "setting up go"
mkdir ~/gocode

./osx.sh

bot "Woot! All done."
