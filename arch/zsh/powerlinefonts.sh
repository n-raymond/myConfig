#!/bin/bash

GITDIR=/tmp/powerlinefonts

printf "\n===> Installing Powerline Fonts\n\n"

git clone https://github.com/powerline/fonts.git $GITDIR
$GITDIR/install.sh
rm -Rf $GITDIR

