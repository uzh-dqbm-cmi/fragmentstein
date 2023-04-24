#! /usr/bin/env python

import os
from importlib import resources
# import subprocess
import sys


def run():
    cmd = "bash " + str(resources.path('scripts', 'fragmentstein.sh')) + " " + " ".join(sys.argv[1:])
    print(f'cmd: {cmd}')
    os.system(cmd)


if __name__ == '__main__':
    run()
