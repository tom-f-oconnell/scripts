#!/usr/bin/env python3

"""
Uses grep to search Python files in subdirectories that are Git repos I have
committed to.
"""

# TODO maybe generalize to my repos, but non-python files as well
# (maybe alias of 'grepm'?) also expose CLI flag for non_git_dirs?

import sys
import glob
from os.path import isfile, expanduser, normpath, basename
import subprocess as sp


def is_git_repo(d):
    """True if `d` is a Git repo, False otherwise.
    """
    # Could also use one of the git Python packges, but prefering not to
    # in my util scripts, for portability.
    # Note that this would also probably fail if git were not installed...
    # From MAChitgarha's answer @ https://stackoverflow.com/questions/2180270
    #p = sp.Popen('git tag > /dev/null 2>&1 && [ $? -eq 0 ]')
    p = sp.Popen(['git', 'tag'], cwd=d, stdout=sp.DEVNULL, stderr=sp.STDOUT)
    p.wait()
    #print(p.returncode)
    # Negation since shell exit codes are 0 if successful..
    return not bool(p.returncode)


def is_my_repo(d, me="Tom O'Connell"):
    """Takes a dir known to be a git repo and returns whether I've committed.
    """
    try:
        # The only lines that don't start with whitespace seem to begin
        # with commit author names, so I'm checking if any lines begin
        # with my name.
        out = sp.check_output('git shortlog | grep "^{}"'.format(me), cwd=d,
            shell=True
        )
        assert len(out) > 0
        return True

    except sp.CalledProcessError as e:
        # If grep didn't match anything, this should be the returncode.
        # This is the only error expected (though others may also throw
        # this returncode, I suppose).
        assert e.returncode == 1

    return False


def should_be_searched(d, non_git_dirs=False, hidden_dirs=False):
    if not hidden_dirs:
        if basename(normpath(d))[0] == '.':
            return False

    if not is_git_repo(d):
        if non_git_dirs:
            return True
        else:
            return False

    return is_my_repo(d)


def main():
    # Same as my alias def. Just here in case I have not yet setup my aliases.
    # Though if we do have the alias def, we will use that version, as it may
    # have been updated.
    # I've tested it, and grep DOES work with multiple --exclude-dir
    # definitions.
    grep_cmd = ('grep -R --exclude-dir=.direnv --exclude-dir=site-packages '
        '--include=\*.py'
    )

    # Testing for my grepy alias, to use that call if available.
    grepy_alias = 'grepy'
    # Searching alias defs to check, because we can't easily test the Bash way
    # from Python. See: https://stackoverflow.com/questions/12060863
    alias_file = expanduser('~/.bash_aliases')
    if isfile(alias_file):
        with open(alias_file, 'r') as f:
            lines = f.readlines()

        # Removing any end-of-line comments.
        lines = [x.split('#')[0].strip() for x in lines]

        # TODO also support ' character in prefix and suffix?
        prefix = 'alias {}="'.format(grepy_alias)
        matching_lines = [
            x for x in lines if x.startswith(prefix) and x[-1] == '"'
        ]
        if len(matching_lines) > 0:
            assert len(matching_lines) == 1, \
                'redefinition of {} alias'.format(grepy_alias)
            line = matching_lines[0]
            grep_cmd = line[len(prefix):-1]

    # No need to escape the asterisk, since not calling inside a shell that
    # would treat that specially. Leaving the slash breaks matching.
    grep_cmd = grep_cmd.replace('\*','*')

    # Since grep seems to not color output by default when called through Popen
    grep_cmd += ' --color=always'

    # Intentionally not searching recursively.
    subdirs = glob.glob('*/')

    # sys.argv[0] is just the name of the Python script.
    # Behavior in no-extra-args case is to show greps error message about lack
    # of pattern arg.
    args = sys.argv[1:]
    arg_str = ' ' + ' '.join(args)

    # Using negation since it seems grep might more easily support
    # excluding dirs than including them, and doing this is only one
    # subprocess seems ideal.
    exclude_dirs = [
        basename(normpath(d)) for d in subdirs if not should_be_searched(d)
    ]

    # Initially I tried this syntax, but it seems that w/o doing something else
    # `Popen` would not work w/ this command format, whether `shell` was True or
    # not.
    # https://unix.stackexchange.com/questions/282648
    #cmd = grep_cmd + ' --exclude-dir={{{}}}'.format(','.join(exclude_dirs))

    # On the other hand, this syntax works.
    cmd = grep_cmd + ''.join([' --exclude-dir=' + d for d in exclude_dirs])

    cmd += arg_str
    p = sp.Popen(cmd.split())

    # Without this wait, the next prompt is printed before the output of the
    # Popen call finishes.
    p.wait()


if __name__ == '__main__':
    main()

