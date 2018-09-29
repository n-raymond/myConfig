#!/usr/bin/env bash

installer="yaourt"

function sysout() {
        printf "\n===> $1\n\n"
}       



sysout "Installing .yaourtrc in \$HOME"

cp yaourtrc ~/.yaourtrc

sysout "Installing .bash_local in \$HOME"

cp bash_local ~/.bash_local

sysout "Installing yaourt"

sudo pacman -S yaourt

sysout "Updating yaourt"

$installer -Syu

sysout "Installing tig"

$installer -S tig

sysout "Installing gitkraken"

$installer -S gitkraken

sysout "Installing scala"

$installer -S scala

sysout "Installing sbt"

$installer -S sbt

sysout "Installing postman"

$installer -S postman

sysout "Installing chromium"

$installer -S chromium

sysout "Installing slack"

$installer -S slack-desktop

sysout "Installing printer utilities"

$installer -S manjaro-printer

sysout "Installing tilix"

$installer -S tilix

sysout "Installing Intellij"

$installer -S intellij-idea-ultimate-edition

sysout "Installing Redshift"

$installer -S redshift

