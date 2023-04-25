#! /usr/bin/env python

import os.path
import filecmp
import subprocess
import os.path
import shutil
import glob


def run_cmd(cmd):
    print(f'run_cmd: {cmd}')
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print("stdout:", result.stdout)
    print("stderr:", result.stderr)


def assure_folder(folder_name):
    if not os.path.exists(folder_name):  # or not os.path.isdir(folder_name):
        try:
            os.makedirs(folder_name)
        except:
            print(f'Folder {folder_name} was created by other thread.')


def cleanup_files(file_dir_wildcards):
    for file_dir_wildcard in file_dir_wildcards:
        file_dir_list = glob.glob(file_dir_wildcard)
        for file_dir in file_dir_list:
            if os.path.exists(file_dir):
                if os.path.isdir(file_dir):
                    shutil.rmtree(file_dir)
                else:
                    os.remove(file_dir)


def test_help():
    run_cmd("fragmentstein -h")


def test_finale_db_tsv():
    assure_folder('results')
    cleanup_files(['results/*'])
    cmd = "fragmentstein -i tests/data/test_sample1.tsv.bgz -o results/test_sample1.bam -g tests/data/resources/test_ref_hg38.fna -c tests/data/resources/test_ref.chrom.sizes"
    result = 'results/test_sample1.bam'
    run_cmd(cmd)
    expected = f'tests/expected/test_sample1.bam'
    assert filecmp.cmp(result,  expected, shallow=False)


def test_bed():
    assure_folder('results')
    cleanup_files(['results/*'])
    cmd = "fragmentstein -i tests/data/test_sample1.bed -o results/test_sample1.bam -g tests/data/resources/test_ref_hg38.fna -c tests/data/resources/test_ref.chrom.sizes"
    result = 'results/test_sample1.bam'
    run_cmd(cmd)
    os.path.isfile(result)
    # expected = f'tests/expected/test_sample1.bam'
    # assert filecmp.cmp(result,  expected, shallow=False) # TODO


def skip_test_bedpe():
    assure_folder('results')
    cleanup_files(['results/*'])
    cmd = "fragmentstein -i tests/data/test_sample1.bedpe -o results/test_sample1.bam -g tests/data/resources/test_ref_hg38.fna -c tests/data/resources/test_ref.chrom.sizes"
    result = 'results/test_sample1.bam'
    run_cmd(cmd)
    os.path.isfile(result)
    expected = f'tests/expected/test_sample1.bam'
    assert filecmp.cmp(result,  expected, shallow=False)


if __name__ == '__main__':
    test_help()
    test_finale_db_tsv()
