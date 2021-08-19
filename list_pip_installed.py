#!/usr/bin/env python3
"""
Prints pip-installed package names one per line, without other information in `pip list`
output.

Can also be used for bash tab completion, such as:
```
alias pu='pip uninstall'
# Requires list_pip_installed.py to be on PATH
complete -o nosort -C list_pip_installed.py pu
```
"""

from subprocess import check_output
import json
from os.path import split

from bash_completion import list_or_complete


def list_pip_installed():
    try:
        out = check_output(['pip', 'list', '--format', 'json'])

    # Seems to happen when pip is not available in current environment.
    except FileNotFoundError:
        return []

    data = json.loads(out.decode())
    installed_pkg_names = [x['name'] for x in data]
    return installed_pkg_names


def main():
    installed_pkg_names = list_pip_installed()
    list_or_complete(installed_pkg_names)


if __name__ == '__main__':
    main()

