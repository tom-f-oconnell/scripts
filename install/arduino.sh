#!/bin/bash

# TODO does this work if called w/ sudo -u? ~ resolve correctly?

# TODO update existing versions to this? (preserving libraries?)
VERSION="1.8.5"
# some versions before seem to have been .tgz
FILE="arduino-${VERSION}-linux64.tar.xz"
cd ~
# TODO way to delete if terminated w/ ctrl-c, etc?
wget -O $FILE http://arduino.cc/download.php?f=/$FILE

# modern tar should recognize any supported format w/ xf flags
# z is for gzip, and this file is actually in "XZ" format
tar xvf $FILE
rm $FILE

