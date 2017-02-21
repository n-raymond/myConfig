#!/usr/bin/env bash

# This script will install zsh and set it as main shell


if [ "$(uname)" = Darwin ]; then

    echo "\nInstalling zsh\n"
    echo "=-=-=-=-=-=-=-\n\n"

    brew install zsh zsh-completions
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    printf "\n\nsource ~/.bash_local\n" >> ~/.zshrc

    echo "\nChanging default shell to zsh\n"
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"

    chsh -s /usr/local/bin/zsh


elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    echo "\nInstalling zsh\n"
    echo "=-=-=-=-=-=-=-\n\n"

    sudo apt-get install -y zsh
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    printf "\n\nsource ~/.bash_local\n" >> ~/.zshrc

    echo "\nChanging default shell to zsh\n"
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"

    chsh -s /usr/bin/zsh

fi




