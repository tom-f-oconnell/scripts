#!/bin/bash

sudo apt update
sudo apt install -y libreadline-dev
sudo apt install -y automake
sudo apt install -y bison flex libx11-dev

# only necessary for compiling (GUI? CLI?) without --with-ngshared option
# (with this option, CLI / GUI is not compiled / installed)
sudo apt install libxaw7-dev

cd ~/src
git clone git://git.code.sf.net/p/ngspice/ngspice
cd ~/src/ngspice
./autogen.sh
mkdir release
cd release

# the way to compile both the command line tool and the shared library seems to be
# by running the whole compilation process twice...
# https://sourceforge.net/p/ngspice/discussion/120973/thread/5e12915e/
# can't find (but would like) to do it in one go, assuming some potential overrun
# and work saving.

# TODO try shared library options plus --with-tcl=tcldir option?
# (to install "tclspice" interface, which should have same functionality? not sure...)
# most references to tclspice seem pretty old, so I'm going to avoid this for now.

# once for the shared library
../configure --with-ngshared --enable-xspice --enable-cider --enable-openmp --with-readline=yes
make -j8
sudo make install

# once for the command line tool
../configure --with-x --enable-xspice --enable-cider --enable-openmp --with-readline=yes
make -j8
sudo make install
