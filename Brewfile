
# tap 
tap "crisidev/chunkwm"
tap "homebrew/cask"
tap "homebrew/cask-versions"
tap "homebrew/core"
tap "homebrew/services"
tap "koekeishiya/formulae"

# Install GNU core utilities (those that come with OS X are outdated)
brew "coreutils"

# Install some other useful utilities like `sponge`
brew "moreutils"

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew "findutils"

# Install other useful stuff
brew "ack"
cask "aws-vault"
brew "caddy" # local web server 
brew "cmake" # cross platform make 
brew "exa" # newer ls
brew "git"
brew "gnu-sed", args: ["with-default-names"]
brew "libffi"
brew "gnupg" # pretty good privacy
brew "go" # golang
brew "jq" # json on the command line

# kubernetes
brew "kubernetes-cli"
brew "kops"

brew "nmap" # port scanning
brew "nvm" # manage node versions
brew "python"
brew "sshuttle" # poor mans VPN
brew "terraform"
brew "tmux"
brew "vim", args: ["with-luajit", "with-override-system-vi"]
brew "watch"
brew "yadm"
brew "yq" # yaml on the command line
brew "zsh"
brew "zsh-syntax-highlighting"
brew "crisidev/chunkwm/chunkwm", args: ["with-tmp-logging"]
brew "koekeishiya/formulae/skhd"

# GUI
cask "diffmerge"
cask "iterm2"
cask "keybase" # manage PGP real nice
cask "vagrant"
cask "virtualbox"
cask "vlc"

brew cleanup > /dev/null 2>&1
