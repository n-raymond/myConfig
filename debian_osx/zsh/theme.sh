#!/bin/bash



###########################################################
#                                                         #
# This script will install the agnoster-newline zsh theme #
# and will setup zsh to use it.                           #
# See: https://gist.github.com/e456229c0a773c32d37b.git   #
#                                                         #
###########################################################



# Uncoment the theme you are currently using
#SOURCE_THEME=robbyrussell
SOURCE_THEME=robbyrussell

REPO_URL=https://gist.github.com/e456229c0a773c32d37b.git
REPO_DIR=/tmp/agnoster-repo

THEMES_DIR=~/.oh-my-zsh/themes
ZSHRC=~/.zshrc

TMP_FILE=/tmp/zshrc.temp



# Install Theme

echo "\nInstall ZSH Theme\n"
echo "=-=-=-=-=-=-=-=-=\n\n"


git clone $REPO_URL $REPO_DIR
cp $REPO_DIR/*.zsh-theme $THEMES_DIR
rm -Rf $REPO_DIR



# Write Configuration

echo "\nSetting Theme as default zsh theme\n"
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n\n"

sed -e "s/$SOURCE_THEME/agnoster-newline/" $ZSHRC > $TMP_FILE
mv $TMP_FILE $ZSHRC


