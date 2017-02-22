#!/bin/bash

if [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then


    printf "\n\n*********************"
    printf "\n* SETTING Docker... *\n"
    printf "*********************\n\n"

    sudo apt-get update

    sudo apt-get install -y --no-install-recommends \
        linux-image-extra-$(uname -r) \
        linux-image-extra-virtual

    sudo apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -

    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D

    sudo add-apt-repository \
        "deb https://apt.dockerproject.org/repo/ \
        ubuntu-$(lsb_release -cs) \
        main"

    sudo apt-get update

    sudo apt-get -y install docker-engine

    sudo groupadd docker

    sudo usermod -aG docker $USER

    docker run hello-world
fi

