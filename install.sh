#!/bin/sh

# TODO: install SF Symbols
# TODO: autohide the menu bar

###############################################################################
# nix                                                                         #
###############################################################################

# install nix

NIX_SOURCE=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if test -e "$NIX_SOURCE"; then
    echo "$NIX_SOURCE exists - skipping setup."
else
    echo "$NIX_SOURCE does not exist - setting up nix."
    curl -L https://nixos.org/nix/install | sh
fi

# source nix
. $NIX_SOURCE

# if you hit:
# unable to download ... Problem with the SSL CA cert (path? access rights?) (77)
# then do the following:
# sudo launchctl setenv NIX_SSL_CERT_FILE $NIX_SSL_CERT_FILE
# sudo launchctl kickstart -k system/org.nixos.nix-daemon

pushd ~/.config/nix
nix run nix-darwin -- switch --flake .#joncarl-macbook
popd

###############################################################################
# Homebrew                                                                    #
###############################################################################

# ensuring build/install tools are available
if ! xcode-select --print-path &> /dev/null; then

    # Prompt user to install the XCode Command Line Tools
    xcode-select --install &> /dev/null

    # Wait until the XCode Command Line Tools are installed
    until xcode-select --print-path &> /dev/null; do
        sleep 5
    done

    # Prompt user to agree to the terms of the Xcode license
    # https://github.com/alrra/dotfiles/issues/10

    sudo xcodebuild -license
fi

brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $? != 0 ]]; then
    echo "unable to install homebrew, script $0 abort!"
    exit 2
  fi
  brew analytics off
else
  read -r -p "run brew update && upgrade? [y|N] " response
  if [[ $response =~ (y|yes|Y) ]]; then
    brew update
    brew upgrade
  fi
fi

eval "$(brew shellenv)"

# Just to avoid a potential bug
mkdir -p ~/Library/Caches/Homebrew/Formula
brew doctor

# Install other useful stuff
# brew install ack
# brew install antibody # zsh plugin manager
# brew install automake
# brew install awscli
# brew install bat
# brew install caddy # local web server
# brew install cmake # cross platform make
# brew install direnv
# brew install exa # newer ls
# brew install fzf
# brew install git
# brew install libffi
# brew install gnupg
# brew install go
# brew install jq
# brew install lua
# brew install nmap
# brew install python
# brew install tmux
# brew install watch
# brew install yadm
# brew install yq
# brew install zsh
# brew install zsh-syntax-highlighting

brew tap homebrew/cask-fonts
brew install font-fontawesome

# NOTE: macOS system configuration has been moved to nix-darwin configuration
# See .config/nix/configuration.nix for system defaults, Finder, Dock, Safari, etc.

###############################################################################
# Neovim                                                                      #
###############################################################################

mkdir -p ~/code

# setup neovim
# nvim_bin=$(which nvim) 2>&1 > /dev/null
# if [[ $? != 0 ]]; then
#   brew install ninja libtool automake cmake pkg-config gettext
#   cd ~/code
#   git clone git@github.com:neovim/neovim.git
#   cd neovim
#   sudo make install CMAKE_BUILD_TYPE=Release DEPS_CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=$(xcrun -find c++)"
# 
# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

nvim -c ":PlugInstall"
# fi

###############################################################################
# Finish up and kill affected applications                                    #
###############################################################################

echo '
===============================================================================

We need to kill apps in order to finish things off.'

read -n 1 -s -r -p "`echo $'\n'`Press any key to continue or ctrl+c to quit`echo $'\n'`"

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"Safari" \
	"SystemUIServer" \
	"Terminal" \
	"iCal"; do
	killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
