#!/bin/bash

VERSION=2023.4a

###############################################################################
##   .-""-.     __  __        __        __      ___  __  ___   __            ##
##  / _  _ \   |_  |  )  /\  | _  |\/| |_  |\ |  |  |__   |   |_   |  |\ |   ##
##  |/_)(_\|   |   | \  /^^\ |__| |  | |__ | \|  |   __|  |   |__  |  | \|   ##
##  (_ /\ _)                                                                 ##
##   |mmmm|     Resurrecting alignment files from non-sensitive fragment     ##
##   '-..-'              information for cell-free DNA analysis              ##
###############################################################################

usage()
{
  echo -e "Fragmentstein v${VERSION}\n"
  echo -e "Create a BAM file out of insensitive fragments data (i.e. FinaleDB frag.tsv.bgz file) including sequences extracted from a reference genome.\n"
  echo -e "Usage: $0 [options]\n"
  echo -e "Options:\n"
  echo -e "\t required:\n"
  echo -e "\t-i, --input FILEPATH\t\tInput finaleDB frag.tsv.bgz file or BED file.\n"
  echo -e "\t-o, --output FILEPATH\t\tOutput BAM file. Default: \${INPUT/.tsv.bgz/.bam}.\n"
  echo -e "\t-g, --genome FILEPATH\Reference genome fasta file.\n"
  echo -e "\t-c, --chrom_sizes FILEPATH\tChromosome sizes file.\n"
  echo -e "\t optional:\n"
  echo -e "\t-r, --read_length NUMBER\t\tRead length. Default: 101\n"
  echo -e "\t-qf, --map_quality_filter NUMBER\t\tMinimum mapping quality. Setting it to '0' accepts all fragments.  Default: 30.\n"
  echo -e "\t-qd, --map_quality_default NUMBER\t\tMapping quality if missing in the finaleDB frag.tsv file. Default: 60\n"
  echo -e "\t-bq, --base_quality CHAR\tASCII of Phred-scaled base QUALity+33. Default: F (quality: 37).\n"
  echo -e "\t-N, --replace_incomplete_nucleotides \t\tReplace all incompletely specified nucleotide bases with N.\n"
  echo -e "\t-s, --sort \t\tSort the output BAM file by coordinate.\n"
	echo -e "\t-t, --threads NUMBER\t\t\tNumber of parallel threads to be used when possible. Default: 1\n"
	echo -e "\t--temp FILEPATH\t\tTemp folder where to store intermediate temporary files. Default:  same folder as the output file\n"
}

READ_LENGTH=101
MAP_QUALITY_FILTER=30
MAP_QUALITY_DEFAULT=60
BASE_QUALITY="F"
SORT=false
INCOMPLETE_N=false
THREADS=1
TEMP=
INPUTBEDPE=

while [[ "$1" != "" ]]
do
    PARAM=$(echo $1)
    VALUE=$(echo $2)
    case ${PARAM} in
        -h|--help)
            usage
            exit
            ;;
        -i|--input)
            INPUT="${VALUE}"
            shift 2
            ;;
        -o|--output)
            OUTPUT="${VALUE}"
            shift 2
            ;;
        -g|--genome)
            GENOME="${VALUE}"
            shift 2
            ;;
        -c|--chrom_sizes)
            CHROM_SIZES="${VALUE}"
            shift 2
            ;;
        -r|--read_length)
            READ_LENGTH="${VALUE}"
            shift 2
            ;;
        -qf|--map_quality_filter)
            MAP_QUALITY_FILTER="${VALUE}"
            shift 2
            ;;
        -qd|--map_quality_default)
            MAP_QUALITY_DEFAULT="${VALUE}"
            shift 2
            ;;
        -bq|--base_quality)
            BASE_QUALITY="${VALUE}"
            shift 2
            ;;
        -s|--sort)
            SORT=true
            shift 1
            ;;
        -N|--replace_incomplete_nucleotides)
            INCOMPLETE_N=true
            shift 1
            ;;
        -t|--threads)
            THREADS=${VALUE}
            shift 2
            ;;
        --temp)
            TEMP=${VALUE}
            shift 2
          ;;
        -*|--*)
          echo -e "\nERROR:$0: unknown parameter \"$PARAM\"\n"
          usage
          exit 1
          ;;
        *)  # position arguments
          echo -e "\nERROR:$0: not accepting position arguments \"$PARAM\"\n"
          usage
          exit 1
          ;;
    esac
done

if [[ -f "$OUTUPT" ]]; then
  # default
  OUTPUT=${INPUT/.tsv.bgz/.bam}
fi

if [[ "${INPUT: -4}" == ".bed" ]]; then
  INPUTBED="$INPUT"
elif [[ "${INPUT: -8}" == ".tsv.bgz" ]]; then
  INPUTBED=${INPUT/.tsv.bgz/.bed}
elif [[ "${INPUT: -6}" == ".bedpe" ]]; then
  INPUTBEDPE="${INPUT}"
else
  echo "ERROR: Unsupported input file format ${INPUT}!"
  usage
  exit 1
fi

if [[ -z "$TEMP" ]]; then
  INPUTBED2=${OUTPUT}.tmp.bed
else
  INPUTBED2="${TEMP}/$(basename -- $OUTPUT).tmp.bed"
fi

if [[ -f "$INPUTBEDPE" ]]; then
    awk -F"\t" '{print $1"\t"$2"\t"$3"\t"$7"\t"$8"\t"$9"\n"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$10}' "$INPUTBEDPE" > "${INPUTBED2}"
elif [[ -f "$INPUTBED" ]]; then
  echo "Using input BED file ${INPUTBED}."
  awk -v r="${READ_LENGTH}" 'BEGIN{FS=OFS="\t"}
      { x= $3; f= $3-$2;
        if ($2+r < $3) $3= $2+r;
        $6= "+";
        $7= f;
      }
      {print}
      { if (x-r > $2) $2= x-r;
        $3= x;
        $6= "-";
        $7= f;
      }
      {print}' "${INPUTBED}" > "${INPUTBED2}"
else
  echo "Unzipping, converting FinaleDB file ${INPUT} and accepting mapping quality>${MAP_QUALITY_FILTER} to BED file format ..."
  echo "Creating paired reads and add fragments length into a temp BED file ${INPUTBED2} ..."
   # TODO support for non-gzip input data
    gunzip -c "$INPUT" | \
    awk -v mqf=${MAP_QUALITY_FILTER} '$4>mqf' | \
    awk -F"\t" -v OFS="\t" '{{k=$4; l=$5; $4="F"++i; $5=k; $6=l}}1' | \
    awk -v r="${READ_LENGTH}" 'BEGIN{FS=OFS="\t"}
      { x= $3; f= $3-$2;
        if ($2+r < $3) $3= $2+r;
        $6= "+";
        $7= f;
      }
      {print}
      { if (x-r > $2) $2= x-r;
        $3= x;
        $6= "-";
        $7= f;
      }
      {print}' > "${INPUTBED2}"
fi

TMPSAM=${INPUTBED2/.bed/.sam}
echo "Create intermediate SAM file ${TMPSAM} from ${INPUTBED2} for chromosome_sizes:${CHROM_SIZES} and default map quality: ${MAP_QUALITY_DEFAULT} ..."
bedToBam -i "${INPUTBED2}" -mapq "${MAP_QUALITY_DEFAULT}" -g "${CHROM_SIZES}" | \
  samtools view -@ ${THREADS} - | cut -f-8 | \
  paste - <(cut -f5,7 "${INPUTBED2}") | \
  awk 'BEGIN{FS=OFS="\t"} { print $1,$2,$3,$4,$9,$6,$7,$8,$10 }' > "${TMPSAM}" \

# extract header, add fragmentstein info
HEADER_INFO="@PG	ID:fragmentstein	PN:fragmentstein	VN:${VERSION}	CL:$0 -i ${INPUT} -o ${OUTPUT} -g ${GENOME} -c ${CHROM_SIZES} -r ${READ_LENGTH} -qf ${MAP_QUALITY_FILTER} -qd ${MAP_QUALITY_DEFAULT} -s ${SORT} -t ${THREADS}"
bedToBam -i "${INPUTBED2}" -mapq "${MAP_QUALITY_DEFAULT}" -g "${CHROM_SIZES}" | \
  samtools view -H - | \
  awk -v hi="${HEADER_INFO}" 'NR==2 {print hi}1' > "${TMPSAM}.header"

echo "Get sequences from reference fasta ${GENOME} with read length ${READ_LENGTH} for intermediate files ${INPUTBED2} and ${TMPSAM} ... "
echo "if read fwd->flag=99, if read rev -> flag=147, set mate start, set mate chr to same as this read and set base quality to F ... "
# log command: for debug
# echo "bedtools getfasta -name -fi \"${GENOME}\" -bed \"${INPUTBED2}\" | grep -v \">\" | tr '[:lower:]' '[:upper:]' | paste \"${TMPSAM}\" - | awk -v r=\"${READ_LENGTH}\" 'BEGIN{FS=OFS=\"\t\"} {if (\$2==0) {\$2=99; \$8=\$4+\$9-r} else {\$2=147; \$8=\$4-\$9+r; \$9=\$9*-1}} {\$7=\"=\"} {\$11=\$10} {gsub(/./, \"F\", \$11)}{print}' | cat \"${TMPSAM}.header\" - | samtools view -@ ${THREADS} -bo \"${OUTPUT}\""

bedtools getfasta -name -fi "${GENOME}" -bed "${INPUTBED2}" | grep -v ">" | tr '[:lower:]' '[:upper:]' | \
  paste "${TMPSAM}" - | \
  awk -v r="${READ_LENGTH}" -v n="${INCOMPLETE_N}" -v bq="${BASE_QUALITY}" 'BEGIN{FS=OFS="\t"} {
          if ($2 == 0) {
              $2= 99;
              if ($4+$9-r > $4) $8= $4+$9-r; else $8= $4;
          } else {
              $2= 147;
              if ($4-$9+r < $4) $8= $4-$9+r; else $8= $4;
              $9= -$9;
          }
          $7= "="; $11= $10;
      } n=="true" {gsub(/B|R|S|W|K|M|Y|H|V|D/, "N", $10)} {gsub(/./, bq, $11)} {print}' | \
  cat "${TMPSAM}.header" - | \
  samtools view -@ ${THREADS} -bo "${OUTPUT}" - \
  && rm "${INPUTBED2}" && rm "${TMPSAM}" && rm "${TMPSAM}.header"

if [[ -f "${TMPSAM}" ]]; then
  echo "ERROR: Something went wrong while converting ${INPUTBED2} and ${TMPSAM} to the final ${OUTPUT} SAM file"
  echo "Investigate the intermediate file with this commands:"
  echo "bedtools getfasta -name -fi \"${GENOME}\" -bed \"${INPUTBED2}\" | grep -v \">\" | tr '[:lower:]' '[:upper:]' | paste \"${TMPSAM}\" - | awk -v r=\"${READ_LENGTH}\" -v n=\"$INCOMPLETE_N\" 'BEGIN{FS=OFS=\"\\t\"} { if (\$2 == 0) { \$2= 99; if (\$4+\$9-r > \$4) \$8= \$4+\$9-r; else \$8= \$4; } else { \$2= 147; if (\$4-\$9+r < \$4) \$8= \$4-\$9+r; else \$8= \$4; \$9= -\$9; }; \$7= \"=\"; \$11= \$10; } n==\"true\" {gsub(/B|R|S|W|K|M|Y|H|V|D/, \"N\", \$10)} {gsub(/./, \"F\", \$11)} {print}' | cat \"${TMPSAM}.header\" - > ${TMPSAM}2"
  echo "samtools view -@ ${THREADS} -bo ${OUTPUT} ${TMPSAM}2"
  exit 1
fi

# Sorting can be done additionally
if [[ $SORT == true ]]; then
  UNSORTED=${OUTPUT/.bam/.unsorted.bam}
  mv "${OUTPUT}" "${UNSORTED}"
  samtools sort -@ ${THREADS} "${UNSORTED}" -o "${OUTPUT}"
  samtools index -@ ${THREADS} "${OUTPUT}"
  rm "${UNSORTED}"
fi

echo "Finished ${OUTPUT}"
