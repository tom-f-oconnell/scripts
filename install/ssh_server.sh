#!/bin/bash

sudo apt update
sudo apt install openssh-server
sudo systemctl restart sshd.service
