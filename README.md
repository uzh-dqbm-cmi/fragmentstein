# Fragmentstein
version 2023.04
Creating a BAM files from non-sensitive fragments data (i.e. FinaleDB frag.tsv.bgz file) using sequences extracted from a reference genome.

## Contents

- [Dependencies](#dependencies)
- [Installation](#installation)
- [Usage](#usage)
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

## <a name="credits"></a>Credits
Fragmentstein is developed and maintained by Zsolt Balázs and Todor Gitchev.

[Wiki]: https://github.com/uzh-dqbm-cmi/fragmentstein/wiki

