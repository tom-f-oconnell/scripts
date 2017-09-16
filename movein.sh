#!/bin/bash

sudo apt install vim-nox
sudo add apt-repository ppa:eugenesan/ppa
sudo apt update
sudo apt install keepassx

# TODO install dotfiles from github thing
# TODO install conda in a way that won't conflict with ROS?

# missing:
# arduino

# change setting for multiple workspaces, only current icons visible,


# make Amazon application icon hidden in dashboard search
# can't install package that contains it (unity-webapps-common)
# because it has other important stuff
cp /usr/share/applications/ubuntu-amazon-default.desktop ~/.local/share/applications/ubuntu-amazon-default.desktop
echo Hidden=true >> ~/.local/share/applications/ubuntu-amazon-default.desktop

mkdir ~/src
mkdir -p ~/catkin/src

# TODO alt-j / k volume shortcuts
