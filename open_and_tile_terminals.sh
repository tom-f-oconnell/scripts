#!/usr/bin/env bash
# This script currently requires `xdotool` to be installed in order to (via the
# Unity keyboard shortcuts) resize the opened terminals to tile the screen.

# `getopts` use in here adapted from this example:
# https://stackoverflow.com/questions/16483119

# For implementing a boolean flag specifically:
# https://stackoverflow.com/questions/31974550

# I initially wanted to use --prompt-for-path rather than -p, but it seems
# getopts only supports single character options?
# https://stackoverflow.com/questions/12022592

# How many seconds to sleep between switching workspaces and trying to open
# `gnome-terminal` instances in that workspaces. Only relevant in `-n 4` case,
# as in the `-n 2` case, the current workspace is used to open the terminals.
WORKSPACE_SWITCH_TO_TERM_SLEEP_S=0.05

# How many seconds to sleep between opening an instance of `gnome-terminal` and
# attempting to resize the window.
# Seems to work with 0.0 here, but it seems risky.
TERM_TO_RESIZE_SLEEP_S=0.05

# TODO TODO incorporate automated setup of the shortcuts i use to trigger this
# (Ctrl-Alt-2/4 for path prompt case, Ctrl-Shift-[2/4] for home case) into
# relevant setup scripts in this repo/dotfiles

# TODO TODO TODO detect whether we have two monitors and use the two monitors
# rather than multiple workspaces in `-n 4` case!!

# TODO maybe add argument to specify an ssh command (could prompt as i do for
# path?), and then run that in all opened terminals? or an arbitrary command,
# and wrap that for ssh case? for ssh specifically, might need to consider order
# in which i do things (maybe make one call first?) so that ~cached
# authentication can be used from first login if possible?

usage_str="Usage: $0 [-p] [-n <x>]\n\
-p       Prompt for path to start terminals in\n\
-n <x>   How many terminals to start (default=2). Can be 2 or 4.\n"

function usage() {
    printf "${usage_str}" 1>&2;
    exit 1;
}

opt_prompt_for_path='false'
opt_n=2
while getopts ":pn:" o; do
    case "${o}" in
        p)
            opt_prompt_for_path='true'
            ;;
        n)
            opt_n=${o}
            ((opt_n == 2 || opt_n == 4)) || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
# TODO most getopts examples don't seem to have this second line which the SO
# post with the boolean flag example had. what is its purpose? is it the 
# "for dealing with ... post-getopts command line arguments" he mentions?
#[[ "${1}" == "--" ]] && shift

if ${opt_prompt_for_path}; then
    # NOTE: if calling this script from a keyboard shortcut, enter the command
    # as `gnome-terminal -- bash -c "<full-path-to-this-script>"` rather than
    # just `<full-path-to-this-script>`, so that there is a terminal that opens
    # to accept this input. Could use something like `zenity` to get a GUI
    # prompt if this was ever an issue. This link describes both ways of doing
    # it: https://unix.stackexchange.com/questions/25109
    # -e/-x options in gnome-terminal help are deprecated in favor of this
    # '-- bash -c "<command>" syntax. Use "<command>; exec bash", if you want to
    # keep this initial terminal open after this script finishes.
    # https://askubuntu.com/questions/974756

    # Since this will be where the terminal starts when launched from a keyboard
    # shortcut, explicitly cd-ing there here to keep behavior consistent when
    # testing by invoking in another terminal.
    cd ~

    printf "Enter directory to open (${opt_n}) terminals in (do not use ~):\n"

    # Wanted the `read` prompt to include the evaluated regular $PS1, but I'm
    # not sure that will be possible within bash -c, as that precludes -i, and 
    # -i or something related to it might be required for $PS1 to be evaluated
    # as it might usually be. Not sure. This seems to basically evaluate as the
    # empty string in the `bash -c ...` context. Echoing this in a regular
    # terminal does produce weird characters before and after what I'd expect...
    #https://stackoverflow.com/questions/22322879
    #echo "${PS1@P} cd "

    # https://stackoverflow.com/questions/5947742
    ANSI_ESC_PREFIX="\033["
    LIGHT_GREEN="${ANSI_ESC_PREFIX}1;32m"
    LIGHT_BLUE="\033[1;34m"
    END_COLOR="\033[0m"
    # Printing before read call cause the colors weren't converted properly when
    # used directly inside the argument to -p there
    printf "${LIGHT_GREEN}${USER}@$(hostname)${END_COLOR}:${LIGHT_BLUE}~${END_COLOR}$ "

    # The -e enables readline completion, which seems to make it behave as
    # normal cd completion would
    # https://stackoverflow.com/questions/4819819
    read -e -p "cd " wd

    # Will be 1 if Ctrl+d was pressed, 0 if Enter was pressed (though output
    # seems to effectively be empty string in either case).
    ret_val=$?
    if [ ${ret_val} -ne 0 ]; then
        # Want to just abort if Ctrl+d pressed (though Ctrl+c would work by
        # default anyway)
        exit ${ret_val}
    fi

    # TODO maybe provide error message if ~ is path prefix, as readlink /
    # gnome-terminal invocation won't resolve that, and seeing as this script
    # should start in the home directory anyway, it is not really worth figuring
    # out how to manually resolve it.
    # https://stackoverflow.com/questions/3963716

    echo "wd: ${wd}"
    wd=`readlink -f ${wd}`
    # Using this might have some unintended consequences in terms of what path
    # the terminal displays if there is a symbolic link somewhere in the path,
    # but it should still work...
    echo "readlink -f \$wd: ${wd}"

    # (for testing. just to give you a change to see prints above when run from
    # keyboard shortcut, then exit w/o doing anything more)
    #read -t 2 -n 1
    #exit
else
    wd="$HOME"
fi
# Initially I thought I might want to find most recently active terminal and use
# the working directory of it (really the bash[/other shell] process inside of
# it) as the working directory of the new terminal(s). May still decide it's
# worth implementing this behind another command line flag / keyboard shortcut
# later. Some leads I found that would be useful:
# https://unix.stackexchange.com/questions/608457 (most useful)
# https://unix.stackexchange.com/questions/509420
# https://askubuntu.com/questions/775025

# TODO print error message in opened terminal(s) if $wd is not a directory
# (include case where ~ is used in path)

# Using the `xdotool` approach from https://askubuntu.com/questions/613973 to
# tile the windows. There are also other approaches listed there that use
# `wmctrl` (some that also use `xdotool` concurrently and some that do not).

# Opens two terminals in current workspace and tiles them left and right.
function open_and_tile_lr_terminals() {
    # Arguments to --working-directory must be absolute paths without ~.
    gnome-terminal --working-directory=${wd}
    sleep ${TERM_TO_RESIZE_SLEEP_S}
    xdotool key Ctrl+Super+Left

    gnome-terminal --working-directory=${wd}
    sleep ${TERM_TO_RESIZE_SLEEP_S}
    xdotool key Ctrl+Super+Right
}

# In `-n 4` case, we are assuming that we want the two workspaces to be used to
# be in workspaces separately vertically (at the same horizontal position in
# workspace grid). May need to adapt to handle multiple-monitor case if using
# that.
if [ ${opt_n} -eq 4 ]; then
    # To ensure that we are in the top workspace row (assuming 2 rows, as by
    # default and in my setup), so that subsequent move down is valid.
    xdotool Ctrl+Alt+Up
    sleep ${WORKSPACE_SWITCH_TO_TERM_SLEEP_S}
fi

open_and_tile_lr_terminals

if [ ${opt_n} -eq 4 ]; then
    xdotool Ctrl+Alt+Down
    sleep ${WORKSPACE_SWITCH_TO_TERM_SLEEP_S}

    open_and_tile_lr_terminals
fi
