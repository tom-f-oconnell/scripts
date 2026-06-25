#!/usr/bin/env python3
"""
Example output:
0: (Wed Apr 16 18:14:21 2025) ~/src/al_analysis  vi (plot_roi_util.py)
1: (Wed Apr 16 18:14:33 2025) ~/src/imagej_macros  vi (overlay_rois_in_curr_z.py)
2: (Wed Apr 16 19:05:09 2025) ~/src/olfsysm/libolfsysm/src  vi (olfsysm.cpp)
3: (Wed Apr 16 19:15:40 2025) ~/src/al_analysis  bash
4: (Fri Apr 25 16:41:14 2025) ~/src/anoop_vcf_embedding  python3
5: (Fri Apr 25 17:26:07 2025) ~/src/anoop_vcf_embedding  vi (large_scale_fits.py)
6: (Thu May  1 14:30:48 2025) ~/src/al_analysis  bash
7: (Thu May  1 14:31:17 2025) ~/src/natmix_data  python3
8: (Thu May  1 14:31:30 2025) ~/src/natmix_data  vi (analysis.py)
9: (Thu May  1 17:07:19 2025) ~/src/al_analysis/test  vi (test_mb_model.py)
10: (Thu May  1 17:07:42 2025) ~/src/al_analysis  bash
11: (Thu May  1 17:43:28 2025) ~/src/al_analysis  vi (mb_model.py)
12: (Thu May  1 17:51:28 2025) ~/src/al_analysis  vi (al_analysis.py)
"""

from pathlib import Path
import re
from subprocess import check_output


def format_files_being_edited_under_pid(parent_pid: int) -> str:
    # NOTE: check_output will currently raise if command exits w/ non-zero exit status
    lines = check_output(['ps', '-o', 'pid,cmd', '-g', f'{parent_pid}']).decode(
        ).splitlines()

    # TODO move this to module-level and only call this fn if the cmd portion of
    # `tmux list-sessions` ouput matches one?
    #
    # should be the name of the executable used to open the file. expecting that the
    # command was run as: `<editor_cmd> <name_of_file_to_open>`
    editor_cmds = {'vi', 'vim'}

    filenames_being_edited = []
    # example output lines: ['    PID CMD', '3098466 bash', '3098553 vi al_analysis.py']
    for line in lines[1:]:
        parts = line.split()
        cmd = parts[1]
        if cmd not in editor_cmds:
            continue

        # TODO instead of assuming command references name of edited file (which it
        # might not if, once in editor, then the file is opened; or if the file(s)
        # opened change after starting editor), get editor PIDs, then use
        # editor-specific methods to tell which file they have open (e.g. using lsof to
        # find swap file, in case of vi)?
        #pid = int(parts[0])

        # would need to support other ways of getting open file if it wasn't the
        # (currently assumed to be single) file specified as argument to cmd
        assert len(parts) == 3

        # this will typically be a path relative to where editor is started, and
        # although we could get cwd of editor, i'm not sure if we can get where it was
        # started from (cwd may have changed). may not need full path to file anyway
        # though.
        filename_in_cmd = parts[2]

        filenames_being_edited.append(filename_in_cmd)

    # TODO want a separate output if no editor processes found? currently will return an
    # empty line
    return ','.join(filenames_being_edited)


def main():
    # just assuming active pane (for each session) is what we care about.  otherwise
    # would be more complicated. not sure if list-sessions alone can give me a list of
    # all pane PIDs (or otherwise all PIDs under that session).
    #
    # NOTE: pane_pid must be alone as the last part of the line (stripped out and used
    # below)
    ls_format = (
        '#{session_name}: #{pane_current_path} #{pane_current_command} '
        # TODO shorten date format? doesn't nicely fit on a half screen now
        '(#{t:session_created}) #{pane_pid}'
    )
    lines = check_output(['tmux', 'list-sessions', '-F', ls_format]).decode(
        ).splitlines()

    def sort_key(line):
        session_name = line.split(':')[0]
        # .isdigit() True if only numeric characters in session_name
        # (as is True for default session_names)
        if session_name.isdigit():
            return int(session_name)

        return session_name

    # similar to piping `tmux ls` output to `sort -t ':' -k 1 -n` (at least for numeric
    # session_names)
    lines = sorted(lines, key=sort_key)

    home_str = re.escape(f"{Path('~').expanduser()}/")

    for line in lines:
        pane_pid_part = line.split()[-1]
        pane_pid = int(pane_pid_part)

        line_without_pane_pid = line[:-len(pane_pid_part)].strip()

        # should be at start of date part, and only there
        #delim = ' ('
        delim = ': '
        assert line_without_pane_pid.count(delim) == 1, ('need to find some other way '
            'to split rigfht after <session_name>: '
        )
        edited_files_str = format_files_being_edited_under_pid(pane_pid)
        if len(edited_files_str) > 0:
            before, after = line_without_pane_pid.split(delim)
            line_without_pane_pid = (
                # TODO delete. harder to read than i thought
                # inserting this after pane_current_command, and right before
                # t:session_created
                # works if trying to insert right before date part
                #before + delim.join([f' ({edited_files_str})', after])

                # should work to insert right after session ID (at start of line)
                delim.join([before, f'({edited_files_str}) ']) + after
            )

        # to shorten paths with '/home/<user>/' in them, replacing that part with '~/'
        line_without_pane_pid = re.sub(f'\s{home_str}', ' ~/', line_without_pane_pid)

        # TODO change output so each field is justified (padding between as needed)?
        # (would prob be a bit complicated...). can i configure list-sessions to do that
        # for me? somewhat doubt it...

        print(line_without_pane_pid)


if __name__ == '__main__':
    main()

