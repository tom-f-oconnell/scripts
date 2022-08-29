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

from subprocess import check_output
import json
from os.path import split

from bash_completion import complete


def list_conda_envs():
    out = check_output(['conda', 'env', 'list', '--json', '--quiet'])
    data = json.loads(out.decode())
    envs = data['envs']
    # In the two installs I've checked so far, the first element in this seems to just
    # be the path to the conda install root (and is the prefix of all the remaining
    # ones).
    # This actually corresponds to the 'base' environment though, so unless that changes
    # I think it's fine to just hardcode that in here.
    return ['base'] + [split(env_name)[1] for env_name in envs[1:]]


def main():
    env_names = list_conda_envs()
    complete(env_names)


if __name__ == '__main__':
    main()

