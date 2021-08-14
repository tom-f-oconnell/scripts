#!/usr/bin/env bash

# NOTE: to find out if a package is installed in a fresh version of an Ubuntu release,
# you can check the appropriate *.manifest file from the download page for the
# particular release. For example, for 18.04.5 desktop:
# http://releases.ubuntu.com/bionic/ubuntu-18.04.5-desktop-amd64.manifest
# Got this tip from: https://askubuntu.com/questions/48886

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
# TODO maybe consider replacing w/ ubuntuhandbook1/keepass2 (if compatible /
# migration available), or see if other ppas are more active / more recommended
#add-apt-repository -y ppa:eugenesan/ppa

add-apt-repository -y ppa:deadsnakes/ppa

# TODO TODO add ppa for unity [unity7 (suffix/prefix?) was it?] + install
# (i'm not sure why i thought this was from a ppa. i just installed it via:
# `sudo apt install ubuntu-unity-desktop` this time, in fresh 18.04.
# was there something else i got from a ppa like this?)
# keep indicator-multiload with unity cause it won't work with default gnome.

# TODO TODO did i end up getting latest git from a ppa (to get version
# sufficient for 3rd party filter-repo)? if so, add that

# not compiled w/ python supported needed for python YCM to work it seems
#add-apt-repository -y ppa:jonathonf/vim

apt update

# TODO maybe install dbus-x11 to get vim-gtk to work w/ wsl?
# https://vi.stackexchange.com/questions/20107
# (or is that literally just for the GUI version that maybe also comes w/ that
# package?)

# NOTE: indicator-multiload will only work with unity, not the default gnome in >=18.04
apt install -y indicator-multiload

# TODO check whether the vim from this is also compiled w/ clipboard support.
# the `vim-gtk` i used previously was.
# TODO TODO maybe also install vim-youtcompleteme (+ ycmd ?) from the same vim
# ppa, rather than building them from source as my
# dotfiles/install_vim_extensions.sh attempted to (and may or may not still
# successfully) do
# NOTE: unfortunately this vim doesn't seem to be compiled w/ the python3.6+
# support seemingly necessary for YCM to work correctly (w/ python at least?).
# I get: `YouCompleteMe unavailable: invalid syntax (vimsupport.py, line 184)`
# But I was only using this ppa to try to get YCM to work, cause now it needs
# VIM >=8.2.something, so my options seem to be either compiling VIM myself,
# finding another ppa, or manually checking out (maybe just via forking, and
# then just changing Vundle to point to my github account?) an
# older version of YCM and using that one.
#apt install -y vim vim-youcompleteme
apt install -y vim-gtk

# TODO install wmctrl?

# TODO `direnv allow` on home directory? (maybe in dotbot stuff, if it needs to copy /
# link some files there first?)

apt install -y curl git xclip gparted nfs-common xdotool direnv chrony smartmontools
apt install -y tree autofs

# Mainly just for `aptitude why <x>` (says which package triggered installation via
# dependency / whether package was manually installed, though the former doesn't
# recurse to the manually installed packages [/ seem to have options to]).
apt install -y aptitude

# TODO maybe warn about / don't install the ssh server by default?
# (or configure to disable it?)
apt install -y openssh-server

apt install -y python3-pip python3-venv

# All from deadsnakes PPA
apt install -y python3.8 python3.8-dev python3.8-venv python3.8-tk

# TODO TODO at least install conda behind prompt (maybe in separate script that gets
# called here, but skipped if non-interactive, and include instructions on how to
# use that script separately in README)
# TODO add automation/instructions for installing mamba (via conda) after
# https://mamba.readthedocs.io/en/latest/installation.html

apt install -y tmux smartmontools iotop htop

# TODO remove if this is installed in stock ubuntu >=18.04 by default.
# For https://github.com/cykerway/complete-alias
apt install -y bash-completion

# TODO install black python formatter (snap seemed to be best / only option for
# 16.04, but is that also the case for 18.04+?)

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

# TODO install firefox w/ settings (vim keybinds, etc)
# TODO how to configure tridactyl
# (only that works for newest firefox as of late 2017)
# to have ":bind i tabclose"?
# also:
# :bind h tableft -1
# :bind l tableft

# TODO TODO update to new name github has in their instructions (the ecdsa or
# whatever algorithm rather than rsa) (+ probably refactor check for the key into
# mk_key.sh)
# TODO get path to this script first? (to not use relative)
if [ ! -e ~/.ssh/id_rsa.pub ]; then
    # This script must be run as "sudo" (which all calls in this script are
    # by default), though it currently doesn't check that itself.
    ${SCRIPTPATH}/mk_key.sh
else
    echo "SSH key found. Not generating for Github. See ~/src/scripts/mk_key.sh"
fi

# TODO install inkscape via snap (from default channel)

# TODO need something like a -y flag here?
snap install hub --classic

# not sure whether maven already include something that would make default-jdk
# irrelevant
# for https://github.com/hoijui/ReZipDoc
# TODO automate rest of setup of ReZipDoc (if it works for me...)
# (just trying their non-dev-install for now)
#apt install maven default-jdk

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
