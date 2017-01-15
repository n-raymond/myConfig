#!/bin/bash

GITDIR=/tmp/powerlinefonts


git clone https://github.com/powerline/fonts.git $GITDIR
$GITDIR/install.sh
rm -Rf $GITDIR

