#!/usr/bin/env bash

# Prints the keys of LS_COLORS in the colors their values specify..
# https://unix.stackexchange.com/questions/52659

( # Run in a subshell so it won't crash current color settings
    dircolors -b >/dev/null
    IFS=:
    for ls_color in ${LS_COLORS[@]}; do # For all colors
        color=${ls_color##*=}
        ext=${ls_color%%=*}
        echo -en "\E[${color}m${ext}\E[0m " # echo color and extension
    done
    echo
)
