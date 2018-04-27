#!/usr/bin/env bash

if [ "$(uname)" = Darwin ]; then

    printf "\nUpdating brew\n"
    printf "=-=-=-=-=-=-\n\n"

    brew update

    printf "\nInstalling vim\n"
    printf "=-=-=-=-=-=-=-\n\n"

    brew install vim --override-system-vi

    printf "\nInstalling tig\n"
    printf "=-=-=-=-=-=-=-\n\n"

    brew install tig

    printf "\nInstalling maven\n"
    printf "=-=-=-=-=-=-=-=-\n\n"

    brew install maven

    printf "\nInstalling scala\n"
    printf "=-=-=-=-=-=-=-=-\n\n"

    brew install scala

    printf "\nInstalling sbt\n"
    printf "=-=-=-=-=-=-=-\n\n"

    brew install sbt

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    printf "\nUpdating aptitude\n"
    printf "=-=-=-=-=-=-=-=-=\n\n"

    sudo apt-get update -y && sudo apt-get upgrade -y

    printf "\nInstalling curl\n"
    printf "=-=-=-=-=-=-=-=\n\n"

    sudo apt-get install -y curl

    printf "\nInstalling vim\n"
    printf "=-=-=-=-=-=-=-\n\n"

    sudo apt-get install -y vim

    printf "\nInstalling tig\n"
    printf "=-=-=-=-=-=-=-\n\n"

    sudo apt-get install -y tig

    printf "\nInstalling maven\n"
    printf "=-=-=-=-=-=-=-=-\n\n"

    sudo apt-get install -y maven

    printf "\nInstalling scala\n"
    printf "=-=-=-=-=-=-=-=-\n\n"

    wget -c www.scala-lang.org/files/archive/scala-2.11.7.deb
    sudo dpkg -i scala-2.11.7.deb
    wget -c https://bintray.com/artifact/download/sbt/debian/sbt-0.13.9.deb
    sudo dpkg -i sbt-0.13.9.deb
    sudo apt-get update -y
    sudo apt-get install -y scala


    printf "\nInstalling sbt\n"
    printf "=-=-=-=-=-=-=-=-\n\n"

    sudo apt-get install -y sbt

fi

