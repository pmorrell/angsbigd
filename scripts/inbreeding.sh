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

#   Call the genotype likelihoods
#   Notes from JRI:
#       -C 50 has unknown function
#       -ref also doesn't have effect?
#       minLRT is p<10^-4, assuming a chi-square
#       doZ gives gzipped output
#   Options - Most of these are the same as in the main angsdo.sh script
#   Different ones here:
#       -doMajorMinor [0|1]
#           0: Do not infer the major and minor alleles
#           1: Infer major and minor alleles
#       -doGlf [0|1|2|3|4]
#           0: Do not output genotype likelihoods
#           1: Print likelihoods for all 10 genotypes (AA, AT, AC, AG etc...)
#              These are printed in log 10 format, as binary
#           2: Beagle genotype likelihood format
#           3: beagle binary
#           4: Same as (1), but as text instead of binary
#       -doPost [1|2]
#           1: Estimate posterior genotype probability using the allele
#              frequency as a prior
#           2: Estimate posterior genotype probability using a uniform
#              prior
#       -doMaf [0|1|2|4||8]
#           0: Calculate per-site frequency
#           1: Assume known major and minor alleles. Estimation of allele
#              frequencies is done as in Kim et al 2011, but with an EM
#              algorithm. Publication:
#              http://www.biomedcentral.com/1471-2105/12/231
#           2: Known major allele and unknown minor alleles. Sums over the
#              probabilities of the three possible minor alleles. Uses the same
#              EM algorithm from (1).
#           4: Estimate frequencies from posterior genotype probabilities
#           8: Estimate frequencies directly from base counts. This method is 
#              used in Li et al 2010:
#              http://www.nature.com/ng/journal/v42/n11/abs/ng.680.html
#       -doSNP, -minLRT are deprecated as of 0.576, use -SNP_pval
#       -SNP_pval [FLOAT]
#           Only work with SNPs that have a p-value less than [FLOAT] of
#           being polymorphic? Requires -doMaf

#   Set some operation-specific options
MIN_MAPQ=40
MIN_BASEQUAL=20
BAQ=1
GT_LIKELIHOOD=1
DO_MAJOR_MINOR=1
DO_GLF=3
DO_POST=1
DO_MAF=2
#   JRI originally had -doSNP 1 and -minLRT 15.1366
#   those values were from a chi-square dist (df?) for p<10^-4
#   just throwing that p-value in here, but should investigate the right
#   value
SNP_PVAL="1e-4"
#   And run it
${ANGSD_DIR}/angsd\
    -bam ${TAXON_LIST}\
    -out ${TAXON}_GT_Likelihoods\
    -minMapQ ${MIN_MAPQ}\
    -minQ ${MIN_BASEQUAL}\
    -baq ${BAQ}\
    -GL ${GT_LIKELIHOOD}\
    -doMajorMinor ${DO_MAJOR_MINOR}\
    -doGlf ${DO_GLF}\
    -doPost ${DO_POST}\
    -doMaf ${DO_MAF}\
    -SNP_pval ${SNP_PVAL}\
    -r ${REGION}

#   Infer the per-individual inbreeding coefficients
#   This requires the ngsTools package to be installed
#   You can get it at https://github.com/mfumagalli/ngsTools
#       First, we have to calculate the number of sites
#       Use the $() construct because we have to do a nested command sub.
gunzip ${TAXON}_GT_Likelihoods.glf.gz
N_SITES=$(expr `wc -l < ${TAXON}_GT_Likelihoods.glf` - 1)
#       Now that we have the number of sites, we can get the inbreeding
#       coefficient
#   Note here that the argument passed with -n_ind is the number of
#   _chromosomes_ in the sample, not the number of individuals.
${NGSTOOLS_DIR}/ngsF/ngsF\
    -out data/${TAXON_INBREEDING}\
    -n_ind ${N_CHROM}\
    -glf ${TAXON}_GT_Likelihoods.glf\
    -n_sites ${N_SITES}
