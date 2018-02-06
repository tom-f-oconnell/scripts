#!/usr/bin/env bash

# mostly from http://wiki.slimdevices.com/index.php/DebianPackage
sudo apt-get install libio-socket-ssl-perl
os=$(dpkg --print-architecture)
if [ "$os" = "armhf" ]; then os=arm; fi
# TODO actually make it get latest automatically
url="http://www.mysqueezebox.com/update/?version=7.9.1&revision=1&geturl=1&os=deb$os"
latest_lms=$(wget -q -O - "$url")
mkdir -p ~/src/squeezebox_sources
cd ~/src/squeezebox_sources
wget $latest_lms
lms_deb=${latest_lms##*/}
sudo dpkg -i $lms_deb

# TODO will it start automatically? if not, make it
sudo service logitechmediaserver start


sudo usermod -aG audio squeezeboxserver

sudo addgroup lms
sudo usermod -aG lms squeezeboxserver
# TODO autodetect and use current (non-root) username
sudo usermod -aG audio tom
# prompt for path?
#sudo chown -R tom:lms ~/music
