#!/usr/bin/env bash

# TODO TODO eventually, probably refactor this to dotfiles?
# (though a few dependencies do seem to be in here)
# maybe merge the two?

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi
# TODO way to make it just prompt for password if run as non-root?

# for keepassx
# TODO put some stuff behind option for my personal vs work computers?
#add apt-repository -y ppa:eugenesan/ppa
apt update

# TODO maybe install dbus-x11 to get vim-gtk to work w/ wsl?
# https://vi.stackexchange.com/questions/20107
# (or is that literally just for the GUI version that maybe also comes w/ that
# package?)

# vim-gtk was compiled with system clipboard support, unlike vim-nox
apt install -y vim-gtk git xclip

# TODO maybe install conda instead?
# https://www.digitalocean.com/community/tutorials/
# how-to-install-the-anaconda-python-distribution-on-ubuntu-16-04
apt install -y python3-pip python3-venv direnv

#apt install -y keepassx

# TODO install dotfiles from github thing (if not going to always do the install
# from the other direction...)
# TODO install conda in a way that won't conflict with ROS?

# missing:
# arduino

# change setting for multiple workspaces, only current icons visible,

# TODO redshift?
# vlc?

sudo -u $USER mkdir -p ~/src

# No need to make this catkin dir on WSL, as no plans to develop ROS there.
# https://stackoverflow.com/questions/38859145
if ! grep -q Microsoft /proc/version; then
    sudo -u $USER mkdir -p ~/catkin/src
fi

# TODO install mendeley?
# TODO same shortcuts in mendeley
# TODO install firefox w/ settings (vim keybinds, etc)
# TODO how to configure tridactyl 
# (only that works for newest firefox as of late 2017)
# to have ":bind i tabclose"?
# also:
# :bind h tableft -1
# :bind l tableft

# TODO get path to this script first? (to not use relative)
if [ ! -e ~/.ssh/id_rsa.pub ]; then
    ${SCRIPTPATH}/mk_key.sh
else
    echo "SSH key found. Not generating for Github. See ~/src/scripts/mk_key.sh"
fi

sudo snap install hub --classic

