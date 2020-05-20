#!/usr/bin/env python3

# TODO -v necessary at input? matter one way or the other?
"""
Progress bar for rsync
========================

Shows file progress and total progress as a progress bar.

Usage
---------
Run rsync with -P and pipe into this program. Example::

    rsync -P -avz user@host:/onefolder otherfolder/ | python rsyncprogress.py

It will show something like this::

3%|1/9|## |ETA:0:04:20|File:100%|Illustris-3/...68/fname.hdf5|0:00:00|156.48kB/s

File progress, File name, ETA, Speed, Overall progress bar and ETA,...
Total number of files, files to be checked, Overall progress (?)

You need the progressbar package installed (see PyPI).

License
-----------
Copyright (c) 2015 Johannes Buchner

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

from __future__ import print_function

import os
import sys

import progressbar


def read_stdin():
    line = ''
    while sys.stdin:
        try:
            c = sys.stdin.read(1)
        except IOError as e:
            print(e)
            continue
        if c == '\r':
            # line is being updated
            yield line
            line = ''
        elif c == '\n':
            # line is done
            yield line
            line = ''
        elif c == '':
            break
        else:
            line += c


#def main():
first_update = None
widgets = [
    progressbar.Percentage(), None, progressbar.Bar(),
    progressbar.ETA(), None
]
pbar = None
debug = False
for line in read_stdin():
    if debug:
        print('Line on next line:')
        print(line)
    parts = line.split()
    '''
    if len(parts) > 3:
        print('parts:', parts)
        print('len(parts):', len(parts))
        print('should end w/ %:', parts[1][-1])
        print('should start w/ to-check:', parts[-1])
        print()
    '''

    check_prefix = None
    # TODO when is it to-check and ir-chk? in latter case, should anything else
    # be handled differently?
    if len(parts) == 6:
        for x in ('to-check=', 'ir-chk='):
            if parts[-1].startswith(x):
                check_prefix = x
                break

    if check_prefix is not None and parts[1].endswith('%'):
        if debug:
            print(1)

        # file progress -P
        file_progress = parts[1]
        file_speed = parts[2]
        file_eta = parts[3]
        istr, ntotalstr = parts[-1][len(check_prefix):-1].split('/')
        ntotal = int(ntotalstr)
        i = int(istr)
        j = ntotal - i
        total_progress = j * 100. / int(ntotal)
        widgets[1] = '|%s/%s' % (i, ntotal)
        widgets[-1] = '|File:%s|%s|%s|%s' % (
            file_progress, short_file_name, file_eta, file_speed.rjust(10)
        )

        if pbar is None:
            first_update = j
            pbar = progressbar.ProgressBar(
                widgets=widgets, maxval=ntotal - first_update
            ).start()

        pbar.maxval = ntotal - first_update
        pbar.update(j - first_update)

        #from pprint import pprint; pprint(dir(pbar))
        #sys.exit()

        #sys.stderr.write('Total:%.1f%%|File:%s|%s|%s|%s|\r' % (
        #    total_progress, file_progress, short_file_name, file_eta,
        #    file_speed
        #))
        #sys.stderr.flush()

    elif not line.startswith(' '):
        if debug:
            print(2)
        # total progress
        file_name = line
        if len(parts) == 6:
            # TODO this was replacing a python2 print call w/ a trailing ','
            # this correct?
            print(parts[1].endswith('%'), parts[-1].startswith('to-check='),
                end=''
            )

        if len(file_name) > 40:
            short_file_name = file_name[:12] + '...' + file_name[-(28-3):]
        else:
            short_file_name = file_name

    else:
        if debug:
            print(3)

if pbar is not None:
    pbar.finish()


#if __name__ == '__main__':
#    main()

