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


#   This calculates Tajima's D (And other statistics) in sliding windows
#   Options:
#       -nChr [INT]
#           [INT] number of chromosomes
#       -step [INT]
#           Step [INT] basepairs between windows
#       -win [INT]
#           Windows are [INT] basepairs wide
#   This will output a .pestPG file which will contain 14 column file
#   The columns are
#       1: (indexStart,indexStop)(posStart,posStop)(regStat,regStop)
#       2: chrname - chromosome name
#       3: wincenter - center of window
#       4: tW - Watterson's Theta
#       5: tP - Pairwise Theta (pi?)
#       6: tF - Fu and Li?
#       7: tH - Fay?
#       8: tL - Fay?
#       9: tajD - Tajima's D
#       10: fulif - Fu and Li's F
#       11: fuliD - Fu and Li's D
#       12: fayH - Fay and Wu?
#       13: zengsE - Zheng's E
#       14: numSites - Number of sites in window
#   There will be one row per window
#   For more information see:
#       http://popgen.dk/angsd/index.php/Tajima#.thetas.gz.pestPG

#   Set some operation-specific parameters
WINDOW_SIZE=1000
WINDOW_STEP=500

#   And run the analysis!
${ANGSD_DIR}/misc/thetaStat do_stat\
    ${TAXON}_Tajimas\
    -nChr ${N_CHROM}\
    -win ${WINDOW_SIZE}\
    -step ${WINDOW_STEP}
