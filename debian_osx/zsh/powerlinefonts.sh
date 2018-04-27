#!/bin/bash

GITDIR=/tmp/powerlinefonts

echo "\nInstalling Powerline Fonts\n"
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-\n\n"

git clone https://github.com/powerline/fonts.git $GITDIR
$GITDIR/install.sh
rm -Rf $GITDIR

