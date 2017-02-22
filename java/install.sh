#!/bin/bash

if [ "$(uname)" = Darwin  ]; then

    brew tap caskroom/cask
    brew install Caskroom/cask/java

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then

    sudo add-apt-repository ppa:openjdk-r/ppa

    sudo apt-get update
    sudo apt-get install openjdk-8-jdk

    sudo update-alternatives --config java

    sudo update-alternatives --config javac

    java -version

fi

