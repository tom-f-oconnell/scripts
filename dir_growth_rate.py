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
import os
import warnings
from datetime import timedelta


# By comparing output of 'du -s' and 'du -sh' on a large directory,
# it seems 1024 is correct, and not 1000.
kb_per_mb = 1024

def dir_size_kb(d):
    return int(check_output(f'du -s {d}'.split()).decode().split()[0])

def monitor_dir_growth(monitor_dir, interval_s, count=None, total_kb=None):
    if not os.path.exists(monitor_dir):
        raise IOError(f'{monitor_dir} does not exist!')

    if count is not None:
        if type(count) is not int:
            raise ValueError('count must be an int or None')
        if count <= 0:
            raise ValueError('count must be positive or None')

        # To convert number of differences to report into number of timepoints
        # we need to measure to do that.
        count = count + 1

    if type(interval_s) not in (int, float):
        raise ValueError('interval_s must be an int or float')

    if total_kb is not None:
        if type(total_kb) not in (int, float):
            raise ValueError('total_kb must be an int, float, or None')
        if total_kb <= 0:
            raise ValueError('total_kb must be positive if not None')

    warned_over_total = False
    last_kb = None
    while True:
        if count is not None:
            count -= 1
            if count <= 0:
                break

        # TODO maybe i should correct the time so it's half of the below call,
        # or something like that?
        # (cause presumably it undercounts by about half, in expectation?)
        curr_time_s = time.time()
        curr_kb = dir_size_kb(monitor_dir)

        if last_kb is None:
            first_time_s = curr_time_s
            first_kb = curr_kb
        else:
            # TODO maybe add an option to exit whenever the numerator is exactly
            # zero? (or after a certain amount of time too?)
            kb_rate = (curr_kb - last_kb) / (curr_time_s - last_time_s)
            mb_rate = kb_rate / kb_per_mb

            kb_rate_fromstart = \
                (curr_kb - first_kb) / (curr_time_s - first_time_s)
            mb_rate_fromstart = kb_rate_fromstart / kb_per_mb

            # TODO maybe auto scale to biggest prefix where we get at least one
            # digit to the left of the decimal
            # TODO opt to print over same line? and how to achieve that again?

            # TODO option to print some shorter version of this in a parenthical
            # bit at end of line?
            #gb = curr_kb / kb_per_mb**2
            #print(f'total size: {gb} GB')

            line_out = f'{mb_rate:.1f} (avg. {mb_rate_fromstart:.1f}) MB/s'
            if total_kb is not None:
                remaining_kb = total_kb - curr_kb
                # -1 just to avoid false positives for rounding errors
                if remaining_kb < -1:
                    if not warned_over_total:
                        warnings.warn('size passed expected total!')
                        warned_over_total = True
                else:
                    eta_s = total_kb / kb_rate_fromstart
                    eta_str = str(timedelta(seconds=eta_s)).split('.')[0]
                    line_out += f' (ETA {eta_str})'
            print(line_out)

        time.sleep(interval_s)

        last_time_s = curr_time_s
        last_kb = curr_kb


def main():
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument('-d', '--dir', default='.',
        help='directory to monitor growth of'
    )
    # TODO test that rates don't depend on this (in expectation...)
    # (test in both cases where du call is slow and fast)
    parser.add_argument('-i', '--interval-secs', default=10.0, help='how long '
        'to pause between the end of one size check and the start of the next '
        '(seconds)'
    )
    parser.add_argument('-c', '--count', default=None,
        help='how many times to report growth (no limit by default)'
    )
    parser.add_argument('-t', '--total-kb', default=None,
        help='total size (KB) directory should have after transfer is complete '
        "(from 'du -s' in source directory)"
    )
    args = parser.parse_args()

    monitor_dir = args.dir
    interval_s = float(args.interval_secs)
    count = args.count
    total_kb = args.total_kb
    if total_kb is not None:
        total_kb = float(total_kb)

    monitor_dir_growth(monitor_dir, interval_s, count=count, total_kb=total_kb)


if __name__ == '__main__':
    main()

