# ANGSD Analysis of Barley Exome Capture Data

This repository is modified from the Ross-Ibarra BigD ANGSD repository at https://github.com/rossibarra/angsbigd

## Inputs and Data

Required data:
- BAM files, sorted, indexed
- Reference assembly, as FASTA
- Outgroup sequence, as BAM
- Individual inbreeding coefficients for each sample

We have three datasets that we will operate on:
- Deleterious Mutations dataset (BAM files for the nine samples used in Deleterious Mutations)
- IPK BAMs (BAM files provided by M. Mascher from IPK)
- IPK Remapped (Re-mapping of reads from IPK samples, done by CL)

These, respecitively, are located in the following places on our MSI shared space:
- /home/morrellp/shared/Datasets/NGS/Alignments/Deleterious_Mutations
- /home/morrellp/shared/Datasets/NGS/Alignments/2014-03-07_IPK_BAMs
- /home/morrellp/shared/Datasets/NGS/Alignments/???

Our reference sequence directory is /home/morrellp/shared/References/Reference_Sequences/Barley/Morex/. There are both the puiblished version of the Morex assembly and the pseudo-scaffolds created by M. Mascher. 

Have yet to figure out where to store data during the analysis. In shared space, or in individual home directories?

## To Run

 * First, run merge.sh to merge bamfiles. This is because ANGSD treats each bamfile as an individual.
 * Run trip.sh to make ancestral pseudo-fasta from Tripsacum
 * run angsdo to generate sfs, bedfile of thetas, and windowed TajD and other stats across region. 
 
Angsdo is where you can modify things like min depth, uniqueness, base quality, but these are currently best guesses hardcoded into script.

## Files

#### data:

TRIP* <- these are the ancestral fasta files used for the SFS. Needed even if you choose folded (why?)

data/*_list.txt <- lists of bamfiles to run on

#### results:

BKN_pest.arg  <- arguments given to angsd
BKN_pest.em.ml <- ML SFS 
BKN.arg <- arguments given to angsd
BKN.bin  BKN.idx <- generally not needed, for internal use
BKN.pestPG <- theta values for each bp in genome 
BKN.thetas.gz <- theta values

#### temp:

 BKN_pest.saf  BKN_pest.saf.pos.gz <- not sure yet (priors for SFS etc.)

