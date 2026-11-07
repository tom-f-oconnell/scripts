#!/usr/bin/env python3

from pathlib import Path
from argparse import ArgumentParser


def main():
    parser = ArgumentParser()
    parser.add_argument('tex_path', type=Path)
    args = parser.parse_args()
    tex_path = args.tex_path

    # TODO really need to specify encoding like this?
    all_lines = Path(tex_path).read_text(encoding='utf-8').splitlines()

    # TODO strip whitespace (/comment/etc) lines before documentclass?

    #in_iffalse = False
    iffalse_depth = 0
    lines = []
    prev_line_empty = False
    prev_line_usepackage = False
    for line in all_lines:
        line = line.strip()

        if line.startswith('%'):
            continue

        iffalse = '\\iffalse'
        #if in_iffalse:
        if iffalse_depth > 0:
            # would just need to keep track of counts
            #assert not line.startswith(iffalse), 'nested iffalse not supported'
            if line.startswith('\\fi'):
                #in_iffalse = False
                iffalse_depth -= 1
            else:
                continue

        elif line.startswith(iffalse):
            #in_iffalse = True
            iffalse_depth += 1
            continue

        # important this is after this continue statements above
        if prev_line_empty:
            if line == '':
                continue
            else:
                prev_line_empty = False

        if prev_line_usepackage and line == '':
            continue

        if line == '':
            prev_line_empty = True

        if line.startswith('\\usepackage'):
            prev_line_usepackage = True
        else:
            prev_line_usepackage = False

        lines.append(line)
        if line.startswith('\\end{document}'):
            break

    print('\n'.join(lines))


if __name__ == '__main__':
    main()

