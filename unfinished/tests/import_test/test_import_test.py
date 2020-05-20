#!/usr/bin/env python3

import glob
from os.path import realpath, dirname, split, join, exists

# pytest can figure out how to import this, despite this being a couple
# levels up.
import import_test


curr_dir = dirname(realpath(__file__))
def abs_script_path(script):
    abs_script = join(curr_dir, script)
    assert exists(abs_script)
    print('abs_script:', abs_script)
    return abs_script

def test_just_builtins():
    script = abs_script_path('just_builtins.py')
    sw = import_test.imports_should_work(script)
    assert sw

def test_nonexistant_module():
    script = abs_script_path('nonexistant_module.py')
    sw = import_test.imports_should_work(script)
    assert not sw

def test_nonexistant_in_recursion():
    script = abs_script_path('nonexistant_in_recursion.py')
    sw = import_test.imports_should_work(script)
    assert not sw

# TODO some tests to ensure there are no side effects of the imports_should_work
# fn

if __name__ == '__main__':
    test_just_builtins()
    #test_nonexistant_module()
    #test_nonexistant_in_recursion()

