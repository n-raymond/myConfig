#!/bin/bash


# Setup environment

cp .vimrc ~/.vimrc
mkdir -p ~/.vim/
cp -R colors ~/.vim/colors



# Intall Vundle

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim



# Install Plugins

vim +PluginInstall +qall


