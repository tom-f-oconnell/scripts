#!/usr/bin/env bash

# This script installs an executable named "acroread"

# https://linuxconfig.org/how-to-install-adobe-acrobat-reader-on-ubuntu-18-04-bionic-beaver-linux

# Just removed gdebi-core. Otherwise same as in link above.
apt install -y libxml2:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libatk-adaptor:i386

# As of when I installed this on atlas (2021-04-23), this file had not been updated
# since 2013-05-09, and 9.5.5 is still the most recent version under:
# ftp://ftp.adobe.com/pub/adobe/reader/unix (can open in a browser to navigate)
# TODO maybe do this in /tmp (and also maybe w/o elevated permissions)
wget ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb

dpkg -i AdbeRdr9.5.5-1_i386linux_enu.deb
