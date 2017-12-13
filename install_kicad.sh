#!/bin/bash

sudo apt update
sudo apt install -y libgtk-3-dev python-wxgtk3.0 python-wxtools libwxgtk3.0-dev python-wxgtk3.0 python-wxgtk3.0-dev libglew-dev libglm-dev swig
# also necessary?: freeglut3, libcairo2-dev, libgtk-3-dev, gstreamer1.0
# (might not be valid packages, taken from ~/.bash_history)

# see also install_ngspice.sh script to install ngspice
# or find a package that includes the shared library in the apt repos

cd ~/src
git clone -b master git://git.launchpad.net/kicad
cd kicad

mkdir -p build/release
mkdir build/debug

# i needed this for some reason
# sudo ldconfig

cd build/release

cmake -DCMAKE_BUILD_TYPE=Release -DKICAD_SCRIPTING=ON -DKICAD_SCRIPTING_MODULES=ON -DKICAD_SCRIPTING_WXPYTHON=ON -DKICAD_SPICE=ON ../../
make -j8
sudo make install

# include KiBoM too
cd ~/src
git clone git://github.com/SchrodingersGat/KiBoM

# TODO test, then uncomment

# add plugin, as done w/ GUI in Kicad
# TODO check this file is created at this point (might need to run kicad?)
# creating it before default are populated might be a bad thing...
#EESCHEMA_CONFIG="~/.config/kicad/eeschema"

# TODO can i just append to the end or does order matter?
#echo 'bom_plugins=(plugins  (plugin KiBOM_CLI (cmd "python \\"/home/tom/src/KiBoM/KiBOM_CLI.py\\" \\"%I\\" \\"%O\\"")))' >> ${EESCHEMA_CONFIG}
#echo 'bom_plugin_selected=KiBOM_CLI' >> ${EESCHEMA_CONFIG}
