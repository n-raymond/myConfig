#!/usr/bin/env bash

if [ "$(uname)" = Darwin ]; then

    brew update

    brew install vim --override-system-vi

    brew install tig

    brew install maven

    brew install scala
    brew install sbt

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    sudo apt-get update -y && sudo apt-get upgrade -y

    sudo apt-get install -y curl
    sudo apt-get install -y vim

    sudo apt-get install -y tig

    sudo apt-get install -y maven

    #Scala
    wget -c www.scala-lang.org/files/archive/scala-2.11.7.deb
    sudo dpkg -i scala-2.11.7.deb
    wget -c https://bintray.com/artifact/download/sbt/debian/sbt-0.13.9.deb
    sudo dpkg -i sbt-0.13.9.deb
    sudo apt-get update -y
    sudo apt-get install -y scala
    sudo apt-get install -y sbt

fi

