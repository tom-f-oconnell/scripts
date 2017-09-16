#!/bin/bash

VERSION="1.8.3"
# some versions before seem to have been .tgz
FILE="arduino-${VERSION}-linux64.tar.xz"
wget -O $FILE http://arduino.cc/download.php?f=/$FILE
tar zxvf $FILE
rm $FILE

