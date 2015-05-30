#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# Copied from Adam Eivy
# @author Jon Carl
###########################


# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh

# make a backup directory for overwritten dotfiles
if [[ ! -e ~/.dotfiles_backup ]]; then
    mkdir ~/.dotfiles_backup
fi

bot "Hi. I'm going to make your OSX system better. But first, I need to configure this project based on your info so you don't check in files to github as Adam Eivy from here on out :)"

fullname=`osascript -e "long user name of (system info)"`
me=`dscl . -read /Users/$(whoami)`

lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

if [[ ! "$firstname" ]];then
  response='n'
else
  echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
  read -r -p "Is this correct? [Y|n] " response
fi

if [[ $response =~ ^(no|n|N) ]];then
	read -r -p "What is your first name? " firstname
	read -r -p "What is your last name? " lastname
fi
fullname="$firstname $lastname"

bot "Great $fullname, "

if [[ ! $email ]];then
  response='n'
else
  echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
  read -r -p "Is this correct? [Y|n] " response
fi

if [[ $response =~ ^(no|n|N) ]];then
	read -r -p "What is your email? " email
fi

read -r -p "What is your github.com username? " githubuser

running "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

# test if gnu-sed or osx sed

sed -i 's/Jon Carl/'$firstname' '$lastname'/' .gitconfig > /dev/null 2>&1 | true
if [[ ${PIPESTATUS[0]} != 0 ]]; then
  echo
  running "looks like you are using OSX sed rather than gnu-sed, accommodating"
  sed -i '' 's/Jon Carl/'$firstname' '$lastname'/' .gitconfig;
  sed -i '' 's/joncarl42@gmail.com/'$email'/' .gitconfig;
  sed -i '' 's/grounded042/'$githubuser'/' .gitconfig;
  sed -i '' 's/joncarl/'$(whoami)'/g' .zshrc;ok
else
  echo
  bot "looks like you are already using gnu-sed. woot!"
  sed -i 's/joncarl42@gmail.com/'$email'/' .gitconfig;
  sed -i 's/grounded042/'$githubuser'/' .gitconfig;
  sed -i 's/joncarl/'$(whoami)'/g' .zshrc;ok
fi

echo $0 | grep zsh > /dev/null 2>&1 | true
if [[ ${PIPESTATUS[0]} != 0 ]]; then
	running "changing your login shell to zsh"
	chsh -s $(which zsh);ok
else
	bot "looks like you are already using zsh. woot!"
fi

running "adding oh my zsh"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

pushd ~ > /dev/null 2>&1

# function symlinkifne {
#     running "$1"

#     if [[ -e $1 ]]; then
#         # file exists
#         if [[ -L $1 ]]; then
#             # it's already a simlink (could have come from this project)
#             echo -en '\tsimlink exists, skipped\t';ok
#             return
#         fi
#         # backup file does not exist yet
#         if [[ ! -e ~/.dotfiles_backup/$1 ]];then
#             mv $1 ~/.dotfiles_backup/
#             echo -en 'backed up saved...';
#         fi
#     fi
#     # create the link
#     ln -s ~/$1 $1
#     echo -en 'linked';ok
# }

# bot "creating symlinks for project dotfiles..."

# # copy the .gitconfig to resolve symlink loop
# cp .gitconfig ~/
# symlinkifne .gitignore
# symlinkifne .vim
# symlinkifne .vimrc
# symlinkifne .zprofile
# symlinkifne .zshrc

bot "copying dotfiles..."

./bootstrap.sh

bot "copying theme"
cp themes/grounded042.zsh-theme ~/.oh-my-zsh/themes

bot "setting up go"
mkdir ~/gocode

popd > /dev/null 2>&1

./osx.sh

bot "Woot! All done."