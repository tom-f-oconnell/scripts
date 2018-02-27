#!/bin/bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

add-apt-repository -y --enable-source ppa:freecad-maintainers/freecad-daily
apt update

apt build-dep -y freecad-daily
# also installs a copy of freecad, but we just want the runtime dependencies
# consider removing or somehow not installing
apt install -y freecad-daily

cd ~/src
sudo -u $USER git clone git://github.com/FreeCAD/FreeCAD freecad
cd freecad

sudo -u $USER mkdir build
cd build

# TODO is this how to configure this flag? ./configure scripts above?
# https://www.freecadweb.org/wiki/CompileOnUnix#Compile_FreeCAD
sudo -u $USER cmake -DCXXFLAGS="-D_OCC64" ../

sudo -u $USER make -j$(nproc)
# why was this commented?
make install
