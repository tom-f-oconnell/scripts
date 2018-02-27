#!/bin/bash

# TODO getopts based flag for whether or not this script should call update
# is there some other idiom people use to not repeat update on nested install
# scripts? or something to supercede nested install scripts?

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

apt update
apt install -y g++ gcc make git-core qtbase5-dev libqt5svg5-dev \
qttools5-dev qtchooser qttools5-dev-tools libmuparser-dev librsvg2-bin \
libboost-dev libfreetype6-dev libicu-dev pkg-config

cd ~/src
sudo -u $USER git clone git://github.com/LibreCAD/LibreCAD.git

cd ~/src/LibreCAD
sudo -u $USER qmake -r librecad.pro
sudo -u $USER make -j8

# TODO install? build in separate directory hierarchy?
# TODO at least symlink this into / put it on path?

