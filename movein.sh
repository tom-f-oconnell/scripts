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
    # This script must be run as "sudo" (which all calls in this script are
    # by default), though it currently doesn't check that itself.
    ${SCRIPTPATH}/mk_key.sh
else
    echo "SSH key found. Not generating for Github. See ~/src/scripts/mk_key.sh"
fi

# TODO need something like a -y flag here?
snap install hub --classic

# (seems to move them to incorrect places, AT LEAST if run when the
# windows are already open, though it doesn't seem to open new windows,
# which is nice. might not work at all w/ like multiple firefox after
# closing...)
# TODO try the python script from the same SO post though:
# https://askubuntu.com/questions/193569
# TODO maybe add some hacks that read window names to distinguish firefox
# windows? or firefox specific hacks loading some data firefox uses
# (maybe even reading some of firefox's memory in the extreme)?

# TODO delete if this thing i install w/ npm doesn't end up being useful
#apt install -y npm
# This does also need to be sudo (as all things in this script are by default)
# TODO note the deprecation warning on uuid dep i got when installing this.
# may matter...
#npm install -g linux-window-session-manager
#

# TODO install virtualbox for vagrant
# TODO automate vagrant install? it seems it might be best to download installer
# from their website...
