#!/usr/bin/env python3

"""
Repeatedly measures folder size to calculate growth rate.

For monitoring rsync progress at the destination.

Uses Linux specific means of measuring folder size, so this is not cross
platform.
"""

import argparse
import time
from subprocess import check_output


def dir_size_kb(d):
    # TODO du output has 1MB = 1000KB, and so on, right? (no 1024 stuff...)
    return int(check_output(f'du -s {d}'.split()).decode().split()[0])


def monitor_dir_growth(monitor_dir, interval_s, count=None):
    if count is not None:
        if type(count) is not int:
            raise ValueError('count must be an int')
        if count <= 0:
            raise ValueError('count must be positive')

        # To convert number of differences to report into number of timepoints
        # we need to measure to do that.
        count = count + 1

    last_kb = None
    while True:
        if count is not None:
            count -= 1
            if count <= 0:
                break

        # TODO maybe i should correct the time so it's half of the below call,
        # or something like that?
        curr_time_s = time.time()
        curr_kb = dir_size_kb(monitor_dir)

        if last_kb is not None:
            kb_diff = curr_kb - last_kb
            kb_rate = kb_diff / (curr_time_s - last_time_s)
            # TODO maybe auto scale to biggest prefix where we get at least one
            # digit to the left of the decimal
            # TODO opt to print over same line? and how to achieve that again?

            # TODO option to print some shorter version of this in a parenthical
            # bit at end of line
            #gb = curr_kb / 1e6
            #print(f'total size: {gb} GB')

            # TODO TODO provide option to list the total files size when the
            # copy is done, so that we can calculate an estimated time here

            # TODO TODO compute running average of the transfer rate (could just
            # use very beginning start time + size maybe, diffed against latst?)
            # (probably better for ETA)

            mb_rate = kb_rate / 1000.0
            print(f'~{mb_rate:.1f} MB/s')

        time.sleep(interval_s)

        last_time_s = curr_time_s
        last_kb = curr_kb


def main():
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument('-d', '--dir', default='.',
        help='directory to monitor growth of'
    )
    # TODO test that rates don't depend on this
    parser.add_argument('-i', '--interval-secs', default=10.0, help='how long '
        'to pause between the end of one size check and the start of the next '
        '(seconds)'
    )
    parser.add_argument('-c', '--count', default=None,
        help='how many times to report growth (no limit by default)'
    )
    args = parser.parse_args()

    monitor_dir = args.dir
    interval_s = float(args.interval_secs)
    count = args.count

    monitor_dir_growth(monitor_dir, interval_s, count)


if __name__ == '__main__':
    main()

