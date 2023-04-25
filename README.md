# Fragmentstein
version 2023.04
Creating a BAM files from non-sensitive fragments data (i.e. FinaleDB frag.tsv.bgz file) using sequences extracted from a reference genome.

## Contents

- [Dependencies](#dependencies)
- [Installation](#installation)
- [Test usage](#usage)
- [Arguments](#arguments)
- [Credits](#credits)

Make sure you have all the dependencies and you will be able to run the program.
## <a name="dependencies"></a>Dependencies

- **samtools** version 1.7 or higher;
- **bedtools** version v2.30.0 or higher;
- **awk** version 20200816 or higher;
- **gunzip** (gzip) version 1.6 or higher;
- **Python** version 3.10 or higher, only if you install it as a Python package;

## <a name="installation"></a>Installation

For installing fragmentstein from the Python PyPi repository:
```sh
pip install fragmentstein
```

Optional, you can install it in a dedicated Python environment:
```sh
conda create -n fragmentstein python=3.10 samtools bedtools -c bioconda
conda activate fragmentstein
pip install fragmentstein
```
The same you can do using the _Mamba_ package manager:
```sh
mamba create -n fragmentstein python=3.10 samtools bedtools -c bioconda
mamba activate fragmentstein
pip install fragmentstein
```

Afterwards, you can use fragmentstein directly from your shell:
```sh
fragmentstein -h
```
Alternatively, you can install it from sources:

Clone the repository.
```sh
git clone https://github.com/uzh-dqbm-cmi/fragmentstein
cd fragmentstein
```

Add the path of the _'./scripts/fragmentstein.sh'_ into your PATH, best in your ~/.bashrc or ~/.zshrc using the following command:
```sh
echo 'export PATH=$(pwd)/scripts/fragmentstein.sh:$PATH' >> ~/.bashrc
```

The _fragmentstein.sh_ script should be available in your shell:
```sh
fragmentstein.sh -h
```

## <a name="usage"></a>Test usage
The following examples will show you how to do a test run
```sh
mkdir results
fragmentstein.sh -i -i tests/data/test_sample1.tsv.bgz -o results/test_sample1.bam \
    -g tests/data/resources/test_ref_hg38.fna -c tests/data/resources/test_ref.chrom.sizes
```

You can install the Python wrapper also from sources as follows:
First install the Python dependency management and packaging tool called Poetry: 
```sh
curl -sSL https://install.python-poetry.org | python3 -
```
Followed by installing the fragmentstein Python wrapper from the root of the cloned repository:
```sh
poetry install
```

To run tests use the following command:
```sh
poetry run pytest
```

## <a name="arguments"></a>Arguments
Required arguments

`-i` or `--input`                           Path to finaleDB `frag.tsv.bgz` file or `.bed`  or `.bedpe` file. Expected are either a 6-column BED file or a 10-column paired-end BEDPE file.

`-g` or `--genome`                          Path to the reference genome fasta file.

`-c` or `--chrom_sizes`                     Chromosome sizes file.
Optional arguments

`-o` or `--output`                          Path to and name of the output BAM file. Default is to substitute the `.tsv.gz` part of the extension with `.bam`.

`-r` or `--read_length`                     Both reverse and forward reads of a fragment will have this length unless the fragment is shorter than the read length. Default: 101.

`-qf` or `--map_quality_filter`             Minimum mapping quality. Setting it to '0' accepts all fragments.  Default: 30.

`-qd` or `--map_quality_default`            Mapping quality to set for example if missing from the input files or if you want to change it for downstream analyses. Default: 60.

`-bq` or `--base_quality`                   ASCII of [Phred]-scaled base QUALity+33. Default: F (quality: 37).

`-N` or `--replace_incomplete_nucleotides`  Replace all [incompletely specified nucleotides] with N.

`-s` or `--sort`                            Sort the output BAM file by coordinate. No value has to be specified, just type `-s` for sorting.

`-t` or `--threads`                         Number of parallel threads to be used when possible. Default: 1.

`--temp`                                    Temporary folder where to store intermediate temporary files. Default:  same folder as the output file.


## <a name="credits"></a>Credits
Fragmentstein is developed and maintained by Zsolt Balázs and Todor Gitchev.

[Phred]: https://en.wikipedia.org/wiki/Phred_quality_score
[incompletely specified nucleotides]: https://en.wikipedia.org/wiki/Nucleic_acid_sequence

