#!/bin/bash

# TODO getopts flag to suppress update / alternative

apt update
apt install openssh-server
systemctl restart sshd.service
