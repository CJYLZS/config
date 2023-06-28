#!/usr/bin/python3
from os import system
from os.path import dirname, realpath, join
import sys
system('python3 -m pip install trzsz')
bin_path = dirname(realpath(sys.executable))
trz = join(bin_path, 'trz')
tsz = join(bin_path, 'tsz')

system(f'rm -f /usr/bin/trz')
system(f'ln -s {trz} /usr/bin/trz')
system(f'rm -f /usr/bin/tsz')
system(f'ln -s {tsz} /usr/bin/tsz')
