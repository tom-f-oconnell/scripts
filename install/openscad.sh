#!/bin/bash

sudo apt update

cd ~/src
git clone git://github.com/openscad/openscad

cd openscad
sudo ./scripts/uni-get-dependencies.sh

# TODO does the exit code here depend on any failures? maybe run + check it?
#./scripts/check-dependencies.sh

qmake openscad.pro

make -j4
sudo make install
