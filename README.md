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

## <a name="installation"></a>Installation
Clone the repository.
```sh
git clone https://github.com/uzh-dqbm-cmi/fragmentstein
cd fragmentstein
chmod 755 fragmentstein
```

## <a name="usage"></a>Test usage
The following examples will show you how to do a test run
```sh
fragmentstein test
```

## <a name="arguments"></a>Arguments
Required arguments

`-i` or `--input` Path to finaleDB `frag.tsv.bgz` file or `.bed`  or `.bedpe` file. Expected are either a 6-column BED file or a 10-column paired-end BEDPE file.

`-g` or `--genome` Path to the reference genome fasta file.

`-c` or `--chrom_sizes` Chromosome sizes file.
Optional arguments

`-o` or `--output` path to and name of the output BAM file. Default is to substitute the `.tsv.gz` part of the extension with `.bam`.

`-r` or `--read_length` Read length. Default: 101. Both reverse and forward reads of a fragment will have this length unless the fragment is shorter than the read length.

`-qf` or `--map_quality_filter` Minimum mapping quality. Setting it to '0' accepts all fragments.  Default: 30.

`-qd` or `--map_quality_default` Mapping quality to set for example if missing from the input files or if you want to change it for downstream analyses. Default: 60.

`-bq` or `--base_quality` ASCII of [Phred]-scaled base QUALity+33. Default: F (quality: 37).

`-N` or `--replace_incomplete_nucleotides` Replace all [incompletely specified nucleotides] with N.

`-s` or `--sort` Sort the output BAM file by coordinate.

`-t` or `--threads` Number of parallel threads to be used when possible. Default: 1.

`--temp` Temporary folder where to store intermediate temporary files. Default:  same folder as the output file.


## <a name="credits"></a>Credits
Fragmentstein is developed and maintained by Zsolt Balázs and Todor Gitchev.
[Phred]: https://en.wikipedia.org/wiki/Phred_quality_score
[incompletely specified nucleotides]: https://en.wikipedia.org/wiki/Nucleic_acid_sequence
[Wiki]: https://github.com/uzh-dqbm-cmi/fragmentstein/wiki

