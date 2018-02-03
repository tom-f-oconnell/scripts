#!/bin/bash

sudo add-apt-repository -y --enable-source ppa:freecad-maintainers/freecad-daily
sudo apt update

sudo apt build-dep -y freecad-daily
# also installs a copy of freecad, but we just want the runtime dependencies
# consider removing or somehow not installing
sudo apt install -y freecad-daily

cd ~/src
git clone git://github.com/FreeCAD/FreeCAD freecad
cd freecad

mkdir build
cd build

# TODO is this how to configure this flag? ./configure scripts above?
# https://www.freecadweb.org/wiki/CompileOnUnix#Compile_FreeCAD
cmake -DCXXFLAGS="-D_OCC64" ../

make -j$(nproc)
#sudo make install
