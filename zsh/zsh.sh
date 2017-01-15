#!/usr/bin/env bash

# This script will install zsh and set it as main shell

if [ "$(uname)" = Darwin ]; then

    brew install zsh zsh-completions
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    chsh -s /usr/local/bin/zsh
    zsh

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    sudo apt-get install -y zsh
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    chsh -s /usr/bin/zsh
    zsh

fi




