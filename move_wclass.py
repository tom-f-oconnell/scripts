#!/usr/bin/env python3
"""
From Jacob Vlijm's answer here: https://askubuntu.com/questions/702071

To get dependencies:
sudo apt-get install xdotool wmctrl

Usage:
move_wclass.py <WM_CLASS> <targeted_screen>

Example:
move_wclass.py gnome-terminal VGA-1

In the example above, VGA-1 was taken from xrandr output like:
VGA-1 connected 1280x1024+1680+0
"""

import subprocess
import sys


# TODO TODO modify to automatically figure out which monitor is on right / left, and
# refer to them that way?
# TODO also add option to tile window to a certain position after moving it to a certain
# screen?

# just a helper function, to reduce the amount of code
get = lambda cmd: subprocess.check_output(cmd).decode("utf-8")


def get_class(classname):
    # function to get all windows that belong to a specific window class (application)
    w_list = [l.split()[0] for l in get(["wmctrl", "-l"]).splitlines()]
    return [w for w in w_list if classname in get(["xprop", "-id", w])]


def main():
    # get the data on all currently connected screens, their x-resolution
    screendata = [l.split() for l in get(["xrandr"]).splitlines() if " connected" in l]
    screendata = sum(
        [[(w[0], s.split("+")[-2]) for s in w if s.count("+") == 2]
         for w in screendata
        ],
        []
    )

    scr = sys.argv[2]

    try:
        # determine the left position of the targeted screen (x)
        pos = [sc for sc in screendata if sc[0] == scr][0]
    except IndexError:
        # TODO list valid screen IDs that are connected in this case
        # warning if the screen's name is incorrect (does not exist)
        print(scr, "does not exist. Check the screen name")
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

