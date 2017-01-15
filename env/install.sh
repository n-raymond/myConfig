#!/usr/bin/env bash


if [ "$(uname)" = Darwin ]; then

    brew install curl
    brew install vim --override-system-vi
    brew install git
    brew install tig

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    sudo apt-get install -y curl
    sudo apt-get install -y vim
    sudo apt-get install -y git
    sudo apt-get install -y tig

fi


