#!/usr/bin/env python3
"""
Prints conda envs one per line, without other garbage lines in output of the similar
conda command `conda env list`.

Can also be used for bash tab completion, such as:
```
alias cls='conda env list'
# Requires list_conda_envs.py to be on PATH
complete -o nosort -C list_conda_envs.py cls
```
"""

import sys
from subprocess import run
import json
from os.path import split


def list_conda_envs():
    p = run(['conda', 'env', 'list', '--json', '--quiet'], capture_output=True)
    data = json.loads(p.stdout.decode())
    envs = data['envs']
    # In the two installs I've checked so far, the first element in this seems to just
    # be the path to the conda install root (and is the prefix of all the remaining
    # ones)
    return [split(env_name)[1] for env_name in envs[1:]]


def main():
    envs = list_conda_envs()

    # Case where this script is explicitly called as `list_conda_envs.py`
    if len(sys.argv) == 1:
        for env_name in envs:
            print(env_name)

    elif len(sys.argv) == 4:
        # When used as completion script, there should be 4 elements in sys.argv:
        # script name, command being completed, partial word being typed, previous word
        being_typed = sys.argv[2]
        for env_name in envs:
            if env_name.startswith(being_typed):
                print(env_name)
            else:
                continue

    else:
        raise ValueError('expected length 1 or 4 sys.argv (manual / completion-script '
            'usage, respectively)'
        )


if __name__ == '__main__':
    main()

