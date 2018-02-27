#!/usr/bin/env bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

# TODO anaconda
# TODO ros + tracking + choice stuff?

# TODO maybe check for conflicting versions of all of the below?
./librecad.sh
./freecad.sh
./kicad.sh

sudo -u $USER ./arduino.sh

./ssh_server.sh

./mendeley.sh

# TODO add extra desktop icons to launcher (may need to generate some)
# like, why does kicad seem to get an icon vi source install but freecad not?
# and librecad via source?
