#!/usr/bin/env python3
"""
From Jacob Vlijm's answer here: https://askubuntu.com/questions/702071

To get dependencies:
sudo apt-get install xdotool wmctrl

Usage:
move_wclass.py <WM_CLASS> <targeted_screen>

Examples:
move_wclass.py gnome-terminal VGA-1
move_wclass.py gnome-terminal left
move_wclass.py gnome-terminal right

In the example above, VGA-1 was taken from xrandr output like:
VGA-1 connected 1280x1024+1680+0
"""

import subprocess
import sys


# TODO also add option to tile window to a certain position after moving it to a certain
# screen?

# just a helper function, to reduce the amount of code
get = lambda cmd: subprocess.check_output(cmd).decode("utf-8")


def get_class(classname):
    # function to get all windows that belong to a specific window class (application)
    w_list = [l.split()[0] for l in get(["wmctrl", "-l"]).splitlines()]
    return [w for w in w_list if classname in get(["xprop", "-id", w])]


def is_resolution_and_offset_str(x):
    """Returns True for strings like '1920x1080+1920+0'
    """
    if x.count('x') == 1 and x.count('+') == 2:
        return True
    return False


def get_resolution_and_offset_str(xrandr_line_parts):
    for x in xrandr_line_parts:
        if is_resolution_and_offset_str(x):
            return x

    raise ValueError('no resolution string found')



def side2screen_name(side, split_xrandr_lines):

    if len(split_xrandr_lines) != 2:
        raise NotImplementedError('only support side2screen name w/ two monitors')

    if side not in ('left', 'right'):
        raise ValueError("side must be either 'left' or 'right'")

    if side == 'left':
        target_offset_zero_coords = (True, True)

    elif side == 'right':
        target_offset_zero_coords = (False, True)

    for xrandr_line_parts in split_xrandr_lines:
        res_and_offset_str = get_resolution_and_offset_str(xrandr_line_parts)
        x_offset, y_offset = [int(x) for x in res_and_offset_str.split('+')[1:]]

        offset_zero_coords = (x_offset == 0, y_offset == 0)

        if offset_zero_coords == target_offset_zero_coords:
            name = xrandr_line_parts[0]
            return name

    raise ValueError("no monitor seemed to match side '{}'".format(side))


def main():
    # get the data on all currently connected screens, their x-resolution
    screendata = [l.split() for l in get(["xrandr"]).splitlines() if " connected" in l]

    screen_name = sys.argv[2]

    # Otherwise, `screen_name` should match the first part in one of the lines in
    # `screendata` exactly (from `xrandr` output).
    if screen_name in ('left', 'right'):
        side = screen_name
        screen_name = side2screen_name(side, screendata)

    # In format like: [[('HDMI-2', '1920')], [('DP-1', '0')]]
    screennames_and_x_offsets = sum(
        [[(w[0], s.split("+")[-2]) for s in w if s.count("+") == 2]
         for w in screendata
        ],
        []
    )

    try:
        # determine the left position of the targeted screen (x)
        pos = [sc for sc in screennames_and_x_offsets if sc[0] == screen_name][0]

    except IndexError:
        # TODO list valid screen IDs that are connected in this case
        # warning if the screen's name is incorrect (does not exist)
        print(screen_name, "does not exist. Check the screen name")

    else:
        # TODO error message if window class is wrong / instructions for finding it
        for w in get_class(sys.argv[1]):
            # first move and resize the window, to make sure it fits completely inside
            # the targeted screen, else the next command will fail...
            subprocess.Popen(["wmctrl", "-ir", w, "-e",
                "0,"+str(int(pos[1])+100)+",100,300,300"
            ])
            # maximize the window on its new screen
            subprocess.Popen(["xdotool", "windowsize", "-sync", w, "100%", "100%"])


if __name__ == '__main__':
    main()

