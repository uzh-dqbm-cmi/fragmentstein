#! /usr/bin/env python

import os.path
import filecmp
import subprocess
import os.path
import shutil
import time


def run_cmd(cmd):
    print(f'run_cmd: {cmd}')
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print("stdout:", result.stdout)
    print("stderr:", result.stderr)


def test_help():
    run_cmd("fragmentstein -h")


def test_finale_db_tsv():
    cmd = "fragmentstein -i tests/data/test_sample1.tsv.bgz -o results/test_sample1.bam " \
          "-g tests/data/resources/test_ref_hg38.fna -c tests/data/resources/test_ref.chrom.sizes"
    run_cmd(cmd)


if __name__ == '__main__':
    test_help()
    test_finale_db_tsv()
