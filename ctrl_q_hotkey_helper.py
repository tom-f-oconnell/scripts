#!/usr/bin/env python3

"""
Parses xprop output to determine if the window under the cursor is running VIM.
Outputs the parent PID of this VIM instance.
"""

import sys
import re
import os
from os.path import expanduser, isdir, isfile, exists, join
from subprocess import check_output
import warnings


def main():
    found_window_name = False
    wname_line_prefix = 'WM_NAME(STRING) = "'
    for line in sys.stdin:
        if line.startswith(wname_line_prefix):
            found_window_name = True
            window_name = line[len(wname_line_prefix):].strip()[:-1]
            # TODO if not just using this as bool (and parsing file and dir from
            # it), more likely intervening parentheses could cause matches i
            # don't want, yielding wrong files / dirs. test if assertions on
            # their existence / ps existance fail.
            match = re.match('(.+) \((.+)\) - VIM$', window_name)
            if match:
                vi_file = match.group(1)
                vi_dir = expanduser(match.group(2))
                assert isdir(vi_dir)
                break
            else:
                sys.exit()
    assert found_window_name

    vi_abs_file = join(vi_dir, vi_file)
    if not exists(vi_abs_file):
        # though this warning won't really get any screen time if the terminal
        # is being closed anyway... log?
        warnings.warn(f'vi file {vi_abs_file} did not exist! OK if this VIM was'
            ' editing an empty file.'
        )
    del vi_abs_file

    # Can set to False if your config stores VIM's .swp files in some other
    # directory (might want to input / find that directory then).
    ASSUME_SWP_IN_SAME_DIR = True
    if ASSUME_SWP_IN_SAME_DIR:
        swp_file = join(vi_dir, f'.{vi_file}.swp')
    else:
        raise NotImplementedError
    assert isfile(swp_file)

    # Not sure how to get lsof to match command name exactly (-c, as I'm using
    # it, matches common prefixes, though man page makes it seem like more may
    # be possible...). For now, I'm just checking the commands that matched
    # exactly here in Python.
    lsof_out = check_output(f'lsof -w -a -c vi -f -- {swp_file}'.split())
    lines = lsof_out.splitlines()
    # could first filter out non-vi (vi...) commands and then assert...
    assert len(lines) == 2, 'expected header and exactly on process'
    line = lines[1].decode('utf-8')

    parts = line.split()
    cmd = parts[0]
    assert cmd == 'vi'
    vi_pid = parts[1]

    ps_lines = check_output(f'ps -o ppid= {vi_pid}'.split()).splitlines()
    assert len(ps_lines) == 1
    # This should be the PID of the shell this VIM instance is running in.
    parent_pid = ps_lines[0].decode('utf-8').strip()
    print(parent_pid)


if __name__ == '__main__':
    main()

