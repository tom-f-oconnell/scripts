#!/bin/bash

sudo add apt-repository -y ppa:eugenesan/ppa
sudo apt update
# vim-gtk was compiled with system clipboard support, unlike vim-nox
sudo apt install -y vim-gtk
sudo apt install -y keepassx

# TODO install dotfiles from github thing
# TODO install conda in a way that won't conflict with ROS?

# missing:
# arduino

# change setting for multiple workspaces, only current icons visible,

# TODO redshift?

# make Amazon application icon hidden in dashboard search
# can't install package that contains it (unity-webapps-common)
# because it has other important stuff
cp /usr/share/applications/ubuntu-amazon-default.desktop ~/.local/share/applications/ubuntu-amazon-default.desktop
echo Hidden=true >> ~/.local/share/applications/ubuntu-amazon-default.desktop

mkdir ~/src
mkdir -p ~/catkin/src

# TODO alt-j / k volume shortcuts
# TODO install mendeley?
# TODO same shortcuts in mendeley
# TODO install firefox w/ settings (vim keybinds, etc)
# TODO how to configure tridactyl (only that works for newest firefox as of late 2017)
# to have ":bind i tabclose"?
# also:
# :bind h tableft -1
# :bind l tableft
