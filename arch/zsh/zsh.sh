#!/usr/bin/env bash

# This script will install zsh and set it as main shell

printf "\n===> Installing zsh\n\n"

yaourt -S zsh



printf "\n===> Installing oh-my-zsh\n\n"

curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
printf "\n\nsource ~/.bash_local\n" >> ~/.zshrc



printf "\n===> Changing default shell to zsh\n\n"

chsh -s /usr/local/bin/zsh

