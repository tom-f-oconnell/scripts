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

# Last checked against Ubuntu 26.04 (2026-11-13): every package installed below has an
# install candidate there, and none needs a PPA.

# TODO put some stuff behind option for my personal vs work computers?

# not compiled w/ python supported needed for python YCM to work it seems
#add-apt-repository -y ppa:jonathonf/vim

apt update

# TODO maybe install dbus-x11 to get vim-gtk to work w/ wsl?
# https://vi.stackexchange.com/questions/20107
# (or is that literally just for the GUI version that maybe also comes w/ that
# package?)

# All remaining apt packages are collected in this array, then installed with one
# `apt install` (no -y, so it shows what it will do and asks once) below.
PACKAGES=()

# Replaces keepass2 / keepassx
PACKAGES+=(keepassxc)

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
# vim-gtk was renamed vim-gtk3 (which has clipboard and python3 support)
PACKAGES+=(vim-gtk3)

# TODO install wmctrl?

# TODO `direnv allow` on home directory? (maybe in dotbot stuff, if it needs to copy /
# link some files there first?)

# NOTE: xclip, xdotool and wmctrl only work in X11 sessions (and XWayland windows).
# wl-clipboard (wl-copy / wl-paste) is the xclip equivalent for Wayland sessions.
PACKAGES+=(curl git xclip wl-clipboard gparted nfs-common xdotool wmctrl direnv chrony)
PACKAGES+=(tree autofs)

# jq: for dotfiles (Claude Code status line, and the git filter on claude_settings.json).
# gh: GitHub CLI, replaces the `hub` snap this script used to install.
# libnotify-bin: notify-send
PACKAGES+=(jq gh libnotify-bin)

# Mainly just for `aptitude why <x>` (says which package triggered installation via
# dependency / whether package was manually installed, though the former doesn't
# recurse to the manually installed packages [/ seem to have options to]).
PACKAGES+=(aptitude)

# TODO maybe warn about / don't install the ssh server by default?
# (or configure to disable it?)
PACKAGES+=(openssh-server)

# NOTE: since 23.04, pip refuses to install outside a venv (PEP 668), `--user` included.
PACKAGES+=(python3-pip python3-venv python3-dev python3-tk)

# No longer supported: python3.8 is not in 26.04.
# The unversioned packages above are the system python (3.14) equivalents.
#apt install -y python3.8 python3.8-dev python3.8-venv python3.8-tk

# TODO TODO at least install conda behind prompt (maybe in separate script that gets
# called here, but skipped if non-interactive, and include instructions on how to
# use that script separately in README)
# TODO add automation/instructions for installing mamba (via conda) after
# https://mamba.readthedocs.io/en/latest/installation.html

PACKAGES+=(tmux smartmontools iotop htop)

# TODO remove if this is installed in stock ubuntu >=18.04 by default.
# For https://github.com/cykerway/complete-alias
PACKAGES+=(bash-completion)

# For building omrijarel/deej. Not installed by default anymore (none of these were on
# atlas as of 2026-11). golang is 1.26 in 26.04. libwebkit2gtk-4.0-dev is not in 26.04:
# 4.1 is its replacement, but deej may need changes to build against it.
#PACKAGES+=(libgtk-3-dev libappindicator3-dev libwebkit2gtk-4.1-dev golang)

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

# TODO install firefox w/ settings (vim keybinds, etc)
# TODO how to configure tridactyl
# (only that works for newest firefox as of late 2017)
# to have ":bind i tabclose"?
# also:
# :bind h tableft -1
# :bind l tableft

# TODO fix cause it doesn't seem to be detecting keys correctly (had copied dir w/
# id_rsa* files from a backup and it still decided to run. maybe `-e` isn't the right
# test?)
# TODO TODO update to new name github has in their instructions (the ecdsa or
# whatever algorithm rather than rsa) (+ probably refactor check for the key into
# mk_key.sh)
# TODO get path to this script first? (to not use relative)
if ! ls ~/.ssh/id_*.pub > /dev/null 2>&1; then
    # This script must be run as "sudo" (which all calls in this script are
    # by default), though it currently doesn't check that itself.
    ${SCRIPTPATH}/mk_key.sh
else
    echo "SSH key found. Not generating for Github. See ~/src/scripts/mk_key.sh"
fi

# TODO install inkscape via snap (from default channel)

# No longer used: `gh` (installed via apt above) replaces `hub`.
#snap install hub --classic

# grip (GitHub README preview) is packaged in 26.04. `pip install grip` outside a venv no
# longer works (PEP 668).
PACKAGES+=(grip)

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

# for Dropbox
PACKAGES+=(python3-gpg)

apt install "${PACKAGES[@]}"
# TODO TODO figure out a way to do this all as `sudo -u $USER`
#cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
