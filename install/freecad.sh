#!/bin/bash

# Last updated / tested 2020-12-06 on my home Ubuntu 18.04 desktop.

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
# consider removing or somehow not installing. also the executable this installs
# is called "freecad-daily", so it shouldn't really conflict.
apt install -y freecad-daily

cd ~/src
sudo -u $USER git clone git://github.com/FreeCAD/FreeCAD freecad
cd freecad

sudo -u $USER mkdir build
cd build

# optional stuff
sudo apt install -y libsimage-dev
# there was an error output when installing this, but it didn't indicate failure
# (also didn't seem to be detected / enabled in cmake though...)
sudo apt install -y libcoin-doc
sudo apt install -y checkinstall

# still listed as disabled in cmake output, and might want to configure it to be
# enabled, but just installing this explicitly cause otherwise the python3
# version of pybind11 doesn't seem to be installed
sudo apt install -y python3-pybind11

# TODO is this how to configure this flag? ./configure scripts above?
# https://www.freecadweb.org/wiki/CompileOnUnix#Compile_FreeCAD
# "For Debian based systems this option is not needed when using the pre-built
# OpenCASCADE packages because these ones set the proper CXXFLAGS internally."
#sudo -u $USER cmake -DCXXFLAGS="-D_OCC64" ../

sudo -u $USER cmake .. -DBUILD_QT5=ON -DPYTHON_EXECUTABLE=/usr/bin/python3

sudo -u $USER make -j$(nproc --ignore=2)
# why was this commented?
make install
