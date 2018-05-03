#!/bin/bash

set -e

CURRENT_DIR=$PWD

function install() {
    printf "\n\n*****************\n"
    printf "* Setting $1... *\n"
    printf "*****************\n\n"

    cd $CURRENT_DIR/$1  && ./install.sh
}

install ssh
install env
install vim
install zsh
install docker
install spark

printf "\n\nInstallation Succed !\n\n"

