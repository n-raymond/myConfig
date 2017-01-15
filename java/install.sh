#!/bin/bash

if [ "$(uname)" = Darwin  ]; then

    brew tap caskroom/cask
    brew install Caskroom/cask/java

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux"  ]; then

    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
    deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> test.txt

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886

    sudo apt-get update
    sudo apt-get install oracle-java8-installer

fi

