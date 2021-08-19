"""
Convenience function for making Python scripts to provide bash completions
"""

import sys


def list_or_complete(str_list):

    # Case where this script is explicitly called as `list_conda_envs.py`
    if len(sys.argv) == 1:
        for x in str_list:
            print(x)

    elif len(sys.argv) == 4:
        # When used as completion script, there should be 4 elements in sys.argv:
        # script name, command being completed, partial word being typed, previous word
        being_typed = sys.argv[2]
        for x in str_list:
            if x.startswith(being_typed):
                print(x)
            else:
                continue
    else:
        raise ValueError('expected length 1 or 4 sys.argv (manual / completion-script '
            'usage, respectively)'
        )

