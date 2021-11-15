#!/usr/bin/env python3

import sys
from pathlib import Path


def main():
    template = Path(__file__).parent.resolve() / 'ycm_extra_conf.py.template'

    with open(template, 'r') as f:
        data = f.read()

    placeholder = '{{REPLACE_ME}}'
    assert placeholder in data

    ycm_conf_basename = '.ycm_extra_conf.py'
    new_ycm_conf = Path.cwd() / ycm_conf_basename
    if new_ycm_conf.exists():
        print(f'{ycm_conf_basename} already exists!')
        return

    curr_python = sys.executable
    print(f'Writing {ycm_conf_basename} pointing to python {curr_python}')
    with open(new_ycm_conf, 'w') as f:
        f.write(data.replace(placeholder, curr_python))


if __name__ == '__main__':
    main()

