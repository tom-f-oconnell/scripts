#!/bin/bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

KICAD_INSTALL_LOC="/usr/local/bin/kicad"
if [ ! -e $KICAD_INSTALL_LOC ]; then
    # will apt update
    # TODO only run this if missing the shared library
    ./ngspice.sh

    apt install -y libgtk-3-dev python-wxgtk3.0 python-wxtools \
        libwxgtk3.0-dev python-wxgtk3.0 python-wxgtk3.0-dev libglew-dev \
        libglm-dev swig
    # TODO find appropriate libcurl package for github plugin

    # also necessary?: freeglut3, libcairo2-dev, libgtk-3-dev, gstreamer1.0
    # (might not be valid packages, taken from ~/.bash_history)
    # i needed this for some reason
    # ldconfig

    # see also install_ngspice.sh script to install ngspice
    # or find a package that includes the shared library in the apt repos

    cd ~/src
    sudo -u $USER git clone -b master git://git.launchpad.net/kicad
    cd kicad

    sudo -u $USER mkdir -p build/release
    sudo -u $USER mkdir -p build/debug
else
    echo "KiCAD detected. Trying to update."
    # TODO also do some of above steps of those directories don't exist, etc
    cd ~/src/kicad
    sudo -u $USER git pull --rebase
fi

cd build/release

sudo -u $USER cmake -DCMAKE_BUILD_TYPE=Release -DKICAD_SCRIPTING=ON \
    -DKICAD_SCRIPTING_MODULES=ON -DKICAD_SCRIPTING_WXPYTHON=ON \
    -DKICAD_SPICE=ON ../../
sudo -u $USER make -j8
make install

# include KiBoM too
#cd ~/src
#sudo -u $USER git clone git://github.com/SchrodingersGat/KiBoM

# TODO test, then uncomment

# add plugin, as done w/ GUI in Kicad
# TODO check this file is created at this point (might need to run kicad?)
# creating it before default are populated might be a bad thing...
#EESCHEMA_CONFIG="~/.config/kicad/eeschema"

# TODO can i just append to the end or does order matter?
#sudo -u $USER echo 'bom_plugins=(plugins  (plugin KiBOM_CLI \
#    (cmd "python \\"/home/tom/src/KiBoM/KiBOM_CLI.py\\" \\"%I\\" \\"%O\\"")))'\
#    >> ${EESCHEMA_CONFIG}
#sudo -u $USER echo 'bom_plugin_selected=KiBOM_CLI' >> ${EESCHEMA_CONFIG}
