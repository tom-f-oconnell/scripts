#!/bin/bash

# TODO check for existing keys first
DEFAULT_EMAIL="toconnel@caltech.edu"
read -p "Email (default $DEFAULT_EMAIL)" email
email=${email:-$DEFAULT_EMAIL}
ssh-keygen -t rsa -b 4096 -C \"$email\"
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_rsa
sudo apt-get install xclip
xclip -sel clip < $HOME/.ssh/id_rsa.pub
echo "SSH public key copied to your clipboard. Paste into box under https://github.com/settings/keys"
