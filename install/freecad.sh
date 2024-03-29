#!/bin/bash

# Last updated / tested 2020-12-06 on my home Ubuntu 18.04 desktop.

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi
# TODO TODO this (and other scripts like it) should exit here if not run as root, w/
# message

add-apt-repository -y --enable-source ppa:freecad-maintainers/freecad-daily
apt update

apt build-dep -y freecad-daily
# also installs a copy of freecad, but we just want the runtime dependencies
# consider removing or somehow not installing. also the executable this installs
# is called "freecad-daily", so it shouldn't really conflict.
apt install -y freecad-daily

# TODO add some convenience fn / util to clone or cd-to-and-pull (if can w/o
# intervention), and use that here
cd ~/src
sudo -u $USER git clone git://github.com/FreeCAD/FreeCAD
cd FreeCAD

sudo -u $USER mkdir build
cd build

# For some reason I also needed to install this in order for this script to work on my
# latest (and still relatively fresh) Ubuntu 18.04 install on 'atlas' in lab.
# libboost-mpi-python-dev is also installed on blackbox (and seems to have been
# installed via libboost-all-dev), but it may not be necessary.
apt install -y libboost-python-dev

# optional stuff
apt install -y libsimage-dev
# there was an error output when installing this, but it didn't indicate failure
# (also didn't seem to be detected / enabled in cmake though...)
apt install -y libcoin-doc
apt install -y checkinstall

# still listed as disabled in cmake output, and might want to configure it to be
# enabled, but just installing this explicitly cause otherwise the python3
# version of pybind11 doesn't seem to be installed
apt install -y python3-pybind11

# Didn't seem to need to install this for either older version of FreeCAD ~2021 or
# before upgrading to 20.04
# https://stackoverflow.com/questions/61754702
apt install -y python3-vtk7
# Not actually sure python3-vtk7 is needed at all
# https://forum.freecadweb.org/viewtopic.php?style=5&f=4&t=60368
apt install -y libvtk7-dev

# Draft workbench stuff / stuff that uses it err's if this isn't installed.
apt install -y python3-pivy

# From leohecks May 02, 2020 comment here:
# https://forum.freecadweb.org/viewtopic.php?f=4&t=45413&start=20#p395462
# "In addition, I had to add set(Boost_NO_BOOST_CMAKE ON) to SetupBoost.cmake"
# (I did not find I had to do the above step, at least to get compile to work, though I
# haven't tested features of software much at all yet)
apt install -y pyqt5-dev-tools
# TODO only do in 20.04 / as needed + fail if link targets exist and are not links
ln -s /usr/bin/pyrcc5 /usr/bin/pyside2-rcc
ln -s /usr/bin/pyuic5 /usr/bin/pyside2-uic

# At output of 2022-02-25 compilation in 20.04, I'm also getting a warning telling me to
# install python3-pyside2.qtnetwork
apt install -y python3-pyside2.qtnetwork python3-pyside2.qtwebengine* python3-pyside2.qtwebchannel

# TODO is this how to configure this flag? ./configure scripts above?
# https://www.freecadweb.org/wiki/CompileOnUnix#Compile_FreeCAD
# "For Debian based systems this option is not needed when using the pre-built
# OpenCASCADE packages because these ones set the proper CXXFLAGS internally."
#sudo -u $USER cmake -DCXXFLAGS="-D_OCC64" ../

sudo -u $USER cmake .. -DBUILD_QT5=ON -DPYTHON_EXECUTABLE=/usr/bin/python3

sudo -u $USER make -j$(nproc --ignore=2)
# why was this commented? i guess it doesn't seem to actually put the main
# executable on the path, but it does install other stuff...
make install

# TODO maybe either setup *.desktop files, starting with that from
# FreeCAD/src/XDGData (.svg icon also there), adding absolute paths to
# executable / icon (or maybe just using those and adding build/bin to PATH?)
# (for now, can just drag the .desktop file i manually modified and added to
# this repo to the launcher bar. assumes particular paths.)
# (currently as long as username is tom and FreeCAD installed in same ~/src/FreeCAD
# directory, and the files in XDGData don't change name or something, can just drag
# the .desktop file in this directory onto the launcher, at least in 18.04)

