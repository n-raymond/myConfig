#!/bin/bash

set -e

CURRENT_DIR=$PWD

printf "\n\n******************\n"
printf "* SETTING ENV... *\n"
printf "******************\n\n"

cd $CURRENT_DIR/env  && ./install.sh

printf "\n\n******************\n"
printf "* SETTING VIM... *\n"
printf "******************\n\n"

cd $CURRENT_DIR/vim  && ./install.sh

printf "\n\n******************\n"
printf "* SETTING ZSH... *\n"
printf "******************\n\n"

cd $CURRENT_DIR/zsh  && ./install.sh

printf "\n\n*********************\n"
printf "* SETTING DOCKER... *\n"
printf "*********************\n\n"

cd $CURRENT_DIR/docker && ./install.sh

printf "\n\n********************\n"
printf "* SETTING SPARK... *\n"
printf "********************\n\n"

cd $CURRENT_DIR/spark && ./install.sh


printf "\n\nInstallation Succed !\n\n"

