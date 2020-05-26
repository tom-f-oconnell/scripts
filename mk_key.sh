#!/usr/bin/env bash

# get current user so we can explicitly run commands that don't require
# root privileges as that user
if [ $SUDO_USER ]; then
    USER=$SUDO_USER
else
    USER=`whoami`
fi

# TODO (reusing other code i have in here if possible) change this script so it
# fails if not called w/ sudo

# TODO check for existing keys first
# put email in envvar in movein? used elsewhere?
DEFAULT_EMAIL="toconnel@caltech.edu"

read -p "Email (default $DEFAULT_EMAIL)" email
email=${email:-$DEFAULT_EMAIL}
sudo -u $USER ssh-keygen -t rsa -b 4096 -C \"$email\"
sudo -u $USER eval "$(ssh-agent -s)"
sudo -u $USER ssh-add $HOME/.ssh/id_rsa

apt-get install xclip
sudo -u $USER xclip -sel clip < $HOME/.ssh/id_rsa.pub

cat <<EOF
SSH public key copied to your clipboard. Paste into the box under 
https://github.com/settings/keys.

If it is not on your clipboard, type:
xclip -sel clip < ~/.ssh/id_rsa.pub
EOF
