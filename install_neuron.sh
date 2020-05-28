#!/usr/bin/env bash

sudo apt update
# also need c / c++ compiler, but assuming that's installed for now
sudo apt install -y bison flex

# I wasn't sure which way to install MPI, but I followed this:
# https://askubuntu.com/questions/1032568

# optional, but want to install
sudo apt install -y libblacs-mpi-dev

cd ~/src
git clone git@github.com:neuronsimulator/nrn

# Just needed for GUI, it seems.
#git clone git@github.com:neuronsimulator/iv

cd nrn

mkdir build
cd build

# might want to run this outside of a venv
python3 -m pip install cython pytest

# I looked at the "default" values for some of these cmake flags w/:
# cmake -LA | awk '{if(f)print} /-- Cache values/{f=1}'
# (from https://stackoverflow.com/questions/16851084)

# It *looks* like all the other python stuff is set correctly if I just specify
# the path to the python3 interpreter, but otherwise it picked python 2.
cmake .. -DNRN_ENABLE_INTERVIEWS=OFF -DNRN_ENABLE_TESTS=ON -DPYTHON_EXECUTABLE=`which python3`

make -j4

# This didn't work without sudo.
sudo make install
