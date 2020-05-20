#!/usr/bin/env python3

"""
Takes the name of a Python file, and exits with code 0 if all imports seem
possible, 1 otherwise.
"""

import argparse
import sys
from os.path import split, normpath, splitext
import os
# TODO delete import for either of these not used
from modulefinder import ModuleFinder
import importlib

# Could try building off of one of these:
# https://stackoverflow.com/questions/14050281 (importlib)
# https://stackoverflow.com/questions/15200543 (modulefinder)

# TODO would factoring this into a fn that takes a str w/ source code + a fn
# that reads file and passes str source code make this easier to unit test?
# just use temp files?

# TODO test this works with top-level and nested modules, various import
# syntaxes, etc.
# TODO TODO TODO need to implement some kind of recursion?
def imports_should_work(script_path):
    """Returns True if all the imports in script at `script_path` should work"""
    script_path = normpath(script_path)

    _dir, basename = split(script_path)
    print('_DIR:', _dir)
    print('BASENAME:', basename)

    # TODO should i provide options to attempt the imports from various paths?
    # or maybe various levels above final dir?
    # TODO what does the path= kwarg here do? necessary to get proper output in
    # some cases?
    '''
    new_path = list(sys.path)
    new_path.insert(0, _dir)
    print('NEW_PATH[:3]:')
    from pprint import pprint
    pprint(new_path[:3])
    print()
    finder = ModuleFinder(path=new_path)
    '''
    """
    os.chdir(_dir)
    print('OS.GETCWD():', os.getcwd())
    finder = ModuleFinder()
    #import ipdb; ipdb.set_trace()

    '''
    module_name, suffix = splitext(basename)
    assert suffix == '.py'
    del suffix, basename
    print('MODULE_NAME:', module_name)
    '''

    # this preferable?
    #finder.load_file(basename)
    # could also try:
    # scan_code, import_module, find_all_submodules, find_module, load_tail,
    # load_module, load_file, etc

    # TODO test if this actually runs any parts...
    #finder.run_script(module_name)
    finder.run_script(basename)
    #finder.run_script(script_path)

    print()
    finder.report()
    print()

    '''
    print('Loaded modules:')
    for name, mod in finder.modules.items():
        # TODO can the key order really be relied on? what is [:3] doing?
        print(str(name) + ':', ','.join(list(mod.globalnames.keys())[:3]))
    '''
    print('-'*50)
    print('Modules not imported:')
    print('\n'.join(finder.badmodules.keys()))


    print()
    print(type(finder.badmodules))
    print(len(finder.badmodules))
    import ipdb; ipdb.set_trace()

    if len(finder.badmodules) > 0:
        # TODO use warnings to print the failing modules to stderr?
        return False
    else:
        return True

    """


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('script_path',
        help='Full path to script to test imports for.'
    )
    args = parser.parse_args()
    script_path = args.script_path

    success = imports_should_work(script_path)
    if success:
        sys.exit(0)
    else:
        sys.exit(1)

