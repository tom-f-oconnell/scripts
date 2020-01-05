#!/usr/bin/env bash

# TODO TODO TODO figure out what is preventing this from working as a bound
# hotkey (same hotkey can launch a terminal, and copying the full path of the
# command to another terminal also works)
# TODO is it a user thing? log stuff to see what's going on?
# is it just failing somewhere?

# TODO TODO make something like this that, if Ctrl-t is pressed in terminal,
# (usually happens b/c I have terminals + a browser, and I meant to open
# a tab, but the wrong thing was selected) switches to the last open browser
# window (in current workspace? whatever's easier...) and then sends the
# Ctrl-t

# delete. for testing manually (but not useful when this is triggered as
# a hotkey)
sleep 2

# TODO what is the difference between focused and active window?
focused_window_id=$(xdotool getwindowfocus)
focused_window_pid=$(xdotool getwindowpid "$focused_window_id")
active_window_id=$(xdotool getactivewindow)
#active_window_pid=$(xdotool getwindowpid "$active_window_id")

#echo "focused window id: $focused_window_id"
#echo "active window id: $active_window_id"
#echo "focused window pid: $focused_window_pid"
#echo "active window pid: $active_window_pid"

if [[ "$active_window_id" != "$focused_window_id" ]]; then
    echo "active window id != focused window id. not sure which to use"
    return 1
fi

# TODO TODO since gnome-terminal only has one PID across all windows, we 
# somehow need to find which child bash process belongs to the active
# window. XID (=window id?) useful for that? other info xprop / xdotool
# returns?

# This helper must then also be on the path (or would need to find it's
# abs path, indep of where this script is called).
vi_ppid=`xprop -id "$focused_window_id" | ctrl_q_hotkey_helper.py`
if [[ -n "$vi_ppid" ]]; then
    xdotool windowactivate "$focused_window_id"
    # Twice, in case we are visual mode. Some modes (Ex:) may still not get
    # closed with what I'm sending now.
    xdotool key "Escape"
    xdotool key "Escape"
    xdotool type "ZZ"
    sleep 0.5
    xdotool key "ctrl+d"
fi
# Could forward Ctrl-Q through if VIM not detected, but I previously had that
# hotkey disabled anyway (mapped to /bin/false), so that Firefox would never
# close all windows on me, so I won't.

