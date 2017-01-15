#!/bin/bash


CURRENT_DIR=$PWD

cd $CURRENT_DIR/java && ./install.sh
cd $CURRENT_DIR/env  && ./install.sh
cd $CURRENT_DIR/vim  && ./install.sh
cd $CURRENT_DIR/zsh  && ./install.sh

echo "Installation Succed !\n\n"

echo "Remainings installations:

        - Docker:
            OSX: https://docs.docker.com/docker-for-mac/
            Linux: https://docs.docker.com/engine/installation/linux/ubuntulinux/
            Debian: https://docs.docker.com/engine/installation/linux/debian/

        - Intellij IDEA

        - Postman"

