# Angsd redo of bigd windowed popgen stats

## Files

Assumes you have folder of bam files. In my case, these are on Farm at:

/group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/

and are all named as LineName_LaneInfo.bam, e.g.

W22_FC6162CAAXX_4.bam

To run on different folder or different naming convention scripts will need to be modified.

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

