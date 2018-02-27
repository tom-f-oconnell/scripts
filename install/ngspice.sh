#!/bin/bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

apt update
apt install -y libreadline-dev libtool automake bison flex libx11-dev

# only necessary for compiling (GUI? CLI?) without --with-ngshared option
# (with this option, CLI / GUI is not compiled / installed)
apt install -y libxaw7-dev

cd ~/src
sudo -u $USER git clone git://git.code.sf.net/p/ngspice/ngspice
cd ~/src/ngspice
sudo -u $USER ./autogen.sh
sudo -u $USER mkdir -p release
cd release

# the way to compile both the command line tool and the shared library seems to
# be by running the whole compilation process twice...
# https://sourceforge.net/p/ngspice/discussion/120973/thread/5e12915e/
# can't find (but would like) to do it in one go, assuming some potential
# overrun and work saving.

# TODO try shared library options plus --with-tcl=tcldir option?
# (to install "tclspice" interface, which should have same functionality? not
# sure...) most references to tclspice seem pretty old, so I'm going to avoid
# this for now.

# once for the shared library
sudo -u $USER ../configure --with-ngshared --enable-xspice --enable-cider \
    --enable-openmp --with-readline=yes
sudo -u $USER make -j8
make install

# once for the command line tool
sudo -u $USER ../configure --with-x --enable-xspice --enable-cider \
    --enable-openmp --with-readline=yes
sudo -u $USER make -j8
make install
