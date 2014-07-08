#!/bin/sh
#PBS -l mem=16gb,nodes=1,ppn=1,walltime=72:00:00
#PBS -m abe
#PBS -M konox006@umn.edu
#PBS -q lab

#   Modified from the Ross-Ibarra GitHub BigD repository
#   TomJKono
#   Last Modified: 2014-06-11
#   Changes:
#       2014-06-11
#           - Cleanup of script, modification of directories for UMN MSI

#   This script requires R
module load R

#   First specifiy some broad values
#   The directory and name of the reference sequence
REF_DIR=/home/morrellp/shared/References/Reference_Sequences/Barley/Morex
REF_SEQ=131012_morex_pseudoscaffolds.fasta
#   The ANGSD version and root directory of the software
ANGSD_VERSION=0.602
ANGSD_DIR=/home/morrellp/shared/Software/angsd${ANGSD_VERSION}
#   And the same for ngsTools
NGSTOOLS_DIR=/home/morrellp/shared/Software/ngsTools
#   The division of the data we are considering
#   e.g., wild, cultivated or landrace
TAXON=cultivar
TAXON_LIST=data/${TAXON}_samples.txt
TAXON_INBREEDING=data/${TAXON}_F.txt
#   The number of individuals in the taxon
N_IND=`wc -l < ${TAXON_LIST}`
#   The number of chromosomes
N_CHROM=`expr 2 \* ${N_IND}`
#   The region over which we want to operate
#   This value is yanked from the JRI script, we will have to edit this to
#   suit our analysis
REGION="10:1-"

#   Do an ABBA-BABA test
#   Options for this analysis
#       -doAbbababa [0|1]
#           0: Do not perform test
#           1: Do ABBA-BABA test with a random base at each position
#       -rmTrans [0|1]
#           0: Use all reads (Default)
#           1: Remove transition sites, mostly for ancient DNA studies
#       -blockSize [INT]
#           Use [INT] basepairs in a single block. This number should be
#           "larger than LD in populations" (longer than the distance over
#           which LD decays to half the adjacent site LD?) Default value is
#           5,000,000 (5Mb)
#       -anc [FILE]
#           Ancestral sequence located in [FILE], in FASTA format.
#       -doCounts [0|1]
#           0: Do not count sites
#           1: Count the number of A,T,C,G over all sites and all samples
#   This analysis also has the standard options listed in the angsdo.sh script
GT_LIKELIHOOD=1
WINDOW_SIZE=1000
WINDOW_STEP=500
DO_COUNTS=1
#   Bulbosum sequence for ancestral state
ANCESTRAL=data/Bulbosum.fa.gz
MIN_BASEQUAL=20
BAQ=1
MIN_MAPQ=30
MAX_DEPTH=20
N_CORES=8
#   And run the analysis
${ANGSD_DIR}/angsd\
    -bam ${TAXON_LIST}\
    -out ${TAXON}_ABBA-BABA\
    -doAbbababa 1\
    -doCounts ${DO_COUNTS}\
    -anc ${ANCESTRAL}\
    -minMapQ ${MIN_MAPQ}\
    -minQ ${MIN_BASEQUAL}\
    -setMaxDepth ${MAX_DEPTH}\
    -baq ${BAQ}\
    -GL ${GT_LIKELIHOOD}\
    -P ${N_CORES}\
    ${REGION}

#   Next, we jackknife the analysis
#   This requires R
Rscript ${ANGSD_DIR}/R/jackKnife.R\
    file=${TAXON}_ABBA-BABA.abbababa\
    indNames=${TAXON_LIST}\
    outfile=${TAXON}_JackKnifed_ABBA-BABA
