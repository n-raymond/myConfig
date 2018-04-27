#!/bin/bash


# Setup environment

echo "\nCopy of vim presets\n"
echo "=-=-=-=-=-=-=-=-=-=\n\n"

cp .vimrc ~/.vimrc
mkdir -p ~/.vim/
cp -R colors ~/.vim/colors



# Intall Vundle


echo "\nInstalling vundle\n"
echo "=-=-=-=-=-=-=-=-=\n\n"

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim



# Install Plugins

vim +PluginInstall +qall


