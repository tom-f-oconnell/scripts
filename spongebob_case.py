#!/usr/bin/env python3

import argparse
import random

import pyperclip


def main():
    parser = argparse.ArgumentParser()
    #parser.add_argument('string', help='string to fuck up the case of')
    parser.add_argument('-a', '--alternate', default=False, action='store_true', help='alternate cases of '
        'characters, rather than randomly picking case of each'
    )
    args = parser.parse_args()

    #string = args.string
    alternate = args.alternate

    string = pyperclip.paste()
    print(f'got input {string} from clipboard')

    out = ''
    if alternate:
        # TODO randomly pick case of first character (and alternate from there)
        for i, c in enumerate(string):
            if i % 2:
                out += c.upper()
            else:
                out += c.lower()
    else:
        for c in string:
            if random.choice([True, False]):
                out += c.upper()
            else:
                out += c.lower()

    pyperclip.copy(out)
    print(f'copied output {out} to clipboard')

    import ipdb; ipdb.set_trace()


if __name__ == '__main__':
    main()
