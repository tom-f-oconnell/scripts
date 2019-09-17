#!/usr/bin/env python3

"""
Takes piped output of git remote -v and returns one line with remote changed
to desired authentication type.
"""

import sys

if __name__ == '__main__':
    valid_auth_types = ('g','h','s')
    if len(sys.argv) != 2:
        raise ValueError('one required argument (g/h/s) to specify auth type')

    target_auth_type = sys.argv[1]
    assert target_auth_type in valid_auth_types, \
        'valid auth types are {}'.format(valid_auth_types)

    # TODO in general, can i get a sequence of pipes (with this in the middle)
    # to stop early somehow (e.g. if this script only cares about the first
    # line)
    prefix2auth_type = {
        'git@': 's',
        'https://': 'h',
        'git://': 'g'
    }
    for line in sys.stdin:
        url = line.split()[1]
        for prefix, auth_type in prefix2auth_type.items():
            if url.startswith(prefix):
                curr_prefix = prefix
                current_auth_type = auth_type

            if auth_type == target_auth_type:
                target_prefix =  prefix

        if current_auth_type == target_auth_type:
            break

        if current_auth_type == 's':
            url = url.replace(':', '/')

        elif target_auth_type == 's':
            parts = url.split('/')
            colon_part = parts[2] + ':' + parts[3]
            del parts[3]
            del parts[2]
            parts.insert(2, colon_part)
            url = '/'.join(parts)

        sys.stdout.write(url.replace(curr_prefix, target_prefix))
        break

