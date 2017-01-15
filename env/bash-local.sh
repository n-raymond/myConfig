#!/usr/bin/env bash


if [ "$(uname)" = Darwin ]; then

    cp osx-bash-local ~/.bash-local

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    cp linux-bash-local ~/.bash-local

fi
