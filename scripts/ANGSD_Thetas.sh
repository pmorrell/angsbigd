#!/bin/sh
#PBS -l mem=16gb,nodes=1,ppn=1,walltime=72:00:00
#PBS -m abe
#PBS -M konox006@umn.edu
#PBS -q lab

#   This is the ANGSD script from RILab's BigD study,
#   modified for running on MSI by TomJKono.

#   Last Modified: 2014-06-11
#   CHANGES
#       2014-06-11
#           - Cleaned uop the script, fixed some directory names for pointing
#             to directories in our MSI shared space.

#   First we specify values for all of our ANGSD analyses
#   The directory of our reference sequence
REF_DIR=/home/morrellp/shared/References/Reference_Sequences/Barley/Morex/
#   This sequence is the pseudo-scaffolds from Martin
REF_SEQ=131012_morex_pseudoscaffolds.fasta
#   Since ANGSD's version is in the directory name, we reference them both
#   in this way
ANGSD_VERSION=0.602
ANGSD_DIR=/home/morrellp/shared/Software/angsd${ANGSD_VERSION}
#   Variable stores the division of the data we are looking at
#   e.g., wild, landrace or cultivar
#   We have a separate directory for associated data files
#   In this case, the TAXON_LIST variable contains the bam filelist file for
#   all the samples we are analyzing
TAXON=cultivar
TAXON_LIST=data/${TAXON}_samples.txt
TAXON_INBREEDING=data/${TAXON}_F.txt
#   The number of individuals in the taxon we are analyzing
#   We use an embedded command to do this
#   ( wc -l < FILE will return just the line count of FILE,
#   rather than the line count and the filename. More efficient than piping
#   to a separate 'cut' process!)
N_IND=`wc -l < ${TAXON_LIST}`
#   For ANGSD, the actual sample size is twice the number of individuals, since
#   each individual has two chromosomes. The individual inbreeding coefficents
#   take care of the mismatch between these two numbers
N_CHROM=`expr 2 \* ${N_IND}`

#   Next, use the SFS to calculate various diversity stats
#   Options:
#       -doThetas [0|1]
#           0: Do not estimate diversity
#           1: Calculate nucleotide diversity, thetaH, thetaL, wattersons theta
#       -pest [FILE]
#           Use the esitmated SFS in [FILE]
#           This is the output file from the above command
#
#   The .thetas output file will have seven columns, and contain data for every
#   site in the input, including monomorphic sites. The values in the columns
#   are powers of 10 for the estimate of diverstiy at that site
#   Example output from JRI:
#
#Chromo Pos    Watterson  Pairwise    thetaSingleton  thetaH      thetaL
#10     3370   -8.664392  -10.223986  -7.289949       -13.844801  -10.890724
#10     3371   -8.822116  -10.395367  -7.431857       -14.041094  -11.062746
#10     3372   -8.840759  -10.415518  -7.448764       -14.064022  -11.082968
#10     26926  -1.480456  -0.671793   -211.328599     -0.694813   -0.683237
#
#   In this case, the first site is probably not polymorphic; the estimate of
#   theta is ~10^(-10). The last site is probably polymorphic; the estimate of
#   theta is about 10^(-0.67) ~ 0.22. This should be similar to the MAF at that
#   position, too.
#   I think for getting a locus average, we can just sum the values and divide
#   by the locus length?
#   It's also odd that there are no variances for these estimates - again
#   perhaps we can do that on a per-locus basis?

#   Set some operation-specific parameters here
DO_THETAS=1
PEST=${TAXON}_DerivedSFS

#   And actually run the command
${ANGSD_DIR}/angsd\
    -bam ${TAXON_LIST}\
    -out ${TAXON}_Divsersity\
    -indF ${TAXON_INBREEDING}\
    -doSaf ${DO_SAF}\
    -doThetas ${DO_THETAS}\
    -uniqueOnly ${UNIQUE_ONLY}\
    -anc ${ANCESTRAL}\
    -minMapQ ${MIN_MAPQ}\
    -minQ ${MIN_BASEQUAL}\
    -nInd ${N_IND}\
    -minInd ${MIN_IND}\
    -baq ${BAQ}\
    -ref ${REF_DIR}/${REF_SEQ}\
    -GL ${GT)LIKELIHOOD}\
    -P ${N_CORES}\
    -pest ${PEST}\
    -doCounts\
    -doDepth\
    -dumpCounts\
    ${REGIONS}

#   Next is to calculate Tajima's estimator
#   This makes a somewhat bedfile-like output including Tajima's D and others
${ANGSD_DIR}/misc/thetaStat make_bed\
    ${TAXON}_Diversity.thetas.gz\
    ${TAXON}_Tajimas