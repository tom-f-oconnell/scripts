#!/bin/bash

sudo apt update
sudo apt install -y libreadline-dev
sudo apt install -y automake
sudo apt install -y bison flex libx11-dev

cd ~/src
git clone git://git.code.sf.net/p/ngspice/ngspice
cd ~/src/ngspice
./autogen.sh
mkdir release
cd release
../configure --with-ngshared --enable-xspice --enable-cider --enable-openmp --with-readline=yes
make -j8
sudo make install
