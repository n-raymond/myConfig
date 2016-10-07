#!/bin/bash


# Uncoment the theme you are currently using

SOURCE_THEME=robbyrussell
#SOURCE_THEME=agnoster



REPO_URL=https://gist.github.com/e456229c0a773c32d37b.git
REPO_DIR=/tmp/agnoster-repo

THEMES_DIR=~/.oh-my-zsh/themes
ZSHRC=~/.zshrc

TMP_FILE=/tmp/temp



# Install Theme

git clone $REPO_URL $REPO_DIR
cp $REPO_DIR/*.zsh-theme $THEMES_DIR
rm -Rf $REPO_DIR



# Write Configuration

sed -e "s/$SOURCE_THEME/agnoster-newline/" $ZSHRC > $TMP_FILE
mv $TMP_FILE $ZSHRC


# Rerun zsh

zsh
