#!/bin/bash

sudo apt update
sudo apt install -y g++ gcc make git-core qtbase5-dev libqt5svg5-dev \
qttools5-dev qtchooser qttools5-dev-tools libmuparser-dev librsvg2-bin \
libboost-dev libfreetype6-dev libicu-dev pkg-config

cd ~/src
git clone git://github.com/LibreCAD/LibreCAD.git

cd ~/src/LibreCAD
qmake -r
make -j8

# TODO install? build in separate directory hierarchy?
