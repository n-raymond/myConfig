#!/bin/bash


# Setup environment

printf "\n===> Copy of vim presets\n\n"

cp .vimrc ~/.vimrc
mkdir -p ~/.vim/
cp -R colors ~/.vim/colors



# Intall Vundle


printf "\n===> Installing vundle\n\n"

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim



# Install Plugins

vim +PluginInstall +qall


