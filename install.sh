#!/bin/bash

set -e

CURRENT_DIR=$PWD


printf "\n\n*******************\n"
printf "* SETTING JAVA... *\n"
printf "*******************\n\n"

cd $CURRENT_DIR/java && ./install.sh

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



printf "\n\nInstallation Succed !\n\n"

printf "Remainings installations:\n\n

        - Docker:\n
            OSX: https://docs.docker.com/docker-for-mac/\n
            Linux: https://docs.docker.com/engine/installation/linux/ubuntulinux/\n
            Debian: https://docs.docker.com/engine/installation/linux/debian/\n

        - Intellij IDEA\n

        - Postman\n"

