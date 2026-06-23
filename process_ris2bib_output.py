#!/usr/bin/env python3

import fileinput
from unicodedata import normalize


def main():
    started = False
    # this encoding (instead of default or  'utf-8' needed to remove some of the special
    # characters we otherwise get at the start and end of some lines (like \ufeff before
    # @Article)
    # https://stackoverflow.com/questions/24754861
    # TODO does this encoding not actually change things like i thought it did?
    for line in fileinput.input(openhook=fileinput.hook_encoded('utf-8-sig')):
        # still need to remove that weird \ufeff character actually, and this encoding
        # through ascii should strip all such special characters
        # https://stackoverflow.com/questions/37045192
        line = normalize('NFKD', line.strip()).encode('ascii', 'ignore').decode('utf-8')
        #print(f'{line=}')
        if not started and line.startswith('@Article'):
            started = True

        if not started:
            continue

        # last line before this should be a solitary '}'
        if started and line == '':
            break

        print(line)


if __name__ == '__main__':
    main()

