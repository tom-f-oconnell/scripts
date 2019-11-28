#!/usr/bin/env python3

import sys
from urllib.parse import urlparse
import subprocess as sp


url = sys.argv[1]
parts = urlparse(url)
domain = parts.netloc
cmd = ('wget --recursive --no-clobber --page-requisites --html-extension '
    f'--convert-links --restrict-file-names=windows --domains {domain} '
    f'--no-parent {url}'
)
args = cmd.split()
sp.Popen(args)

