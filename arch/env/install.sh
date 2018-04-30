#!/usr/bin/env bash


printf "\n===> Installing .yaourtrc in \$HOME\n\n"

cp yaourtrc ~/.yaourtrc

printf "\n===> Installing .bash_local in \$HOME\n\n"

cp bash_local ~/.bash_local

printf "\n===> Installing yaourt\n\n"

sudo pacman -S yaourt

printf "\n===> Updating yaourt\n\n"

yaourt -Syu

printf "\n===> Installing tig\n\n"

yaourt -S tig

printf "\n===> Installing gitkraken\n\n"

yaourt -S gitkraken

printf "\n===> Installing scala\n\n"

yaourt -S scala

printf "\n===> Installing sbt\n\n"

yaourt -S sbt

printf "\n===> Installing postman\n\n"

yaourt -S postman

printf "\n===> Installing chromium\n\n"

yaourt -S chromium

printf "\n===> Installing slack\n\n"

yaourt -S slack-desktop

printf "\n===> Installing printer utilities\n\n"

yaourt -S manjaro-printer

printf "\n===> Installing tilix\n\n"

yaourt -S tilix

printf "\n===> Installing Intellij\n\n"

yaourt -S intellij-idea-ultimate-edition

printf "\n===> Installing Redshift\n\n"

yaourt -S redshift

