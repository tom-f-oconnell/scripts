"""
Convenience function for making Python scripts to provide bash completions
"""

import sys


def complete(str_list):
    """For bash tab completion of strings in input list.

    Add something like the following to your bash config:
    complete -o nosort -C <your-script-calling-this>.py <function/alias/etc to complete>

    The above may require some extra completion thing to be enabled or installed, I
    forget.
    """
    if len(sys.argv) != 4:
        raise ValueError('expected length 4 sys.argv (bash completion inputs)')

    # When used as completion script, there should be 4 elements in sys.argv:
    # script name, command being completed, partial word being typed, previous word
    being_typed = sys.argv[2]
    for x in str_list:
        if x.startswith(being_typed):
            print(x)
        else:
            continue

