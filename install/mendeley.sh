#!/usr/bin/env bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

wget_savingto_line=$(sudo -u $USER wget --content-disposition \
https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest \
    2>&1 | grep 'Saving to: ')

deb_plus_chars=$(echo $wget_savingto_line | sed 's/Saving to: //g')
# https://askubuntu.com/questions/89995/\
# bash-remove-first-and-last-characters-from-a-string
deb="${deb_plus_chars:1:${#deb_plus_chars}-2}"
echo $deb

dpkg -i $deb

rm $deb
