#!/bin/bash

sudo apt install -y cmake ffmpeg pkg-config qtbase5-dev libqt5opengl5-dev libassimp-dev libpython3.5-dev libboost-python-dev libtinyxml-dev

cd $HOME/src

ROBOSCHOOL_PATH=$HOME/src/roboschool
git clone git://github.com/openai/roboschool $ROBOSCHOOL_PATH

# install some version of bullet 3
git clone git://github.com/olegklimov/bullet3 -b roboschool_self_collision
mkdir bullet3/build
cd bullet3/build
cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 -DCMAKE_INSTALL_PREFIX:PATH=$ROBOSCHOOL_PATH/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF ..
make -j4
sudo make install
cd ../..

sudo pip3 install -e $ROBOSCHOOL_PATH


