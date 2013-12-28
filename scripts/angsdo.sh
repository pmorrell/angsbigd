#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J angsdo
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt

# script to run ANGSD on hapmap2 bam files
module load angsd

#(estimate an SFS)
#NB this TRIP file is a temporary file based on one BAM. Do not use for real stuff.
angsd -bam data/temp_merged_list.txt -out temp/temp_pest -doSaf 1 -uniqueOnly 1 -fold 1 -anc temp/TRIP_try.fa.gz -minMapQ 20 -minQ 1 -GL 1 -r 10:1-10000000

#(calculate thetas)
#angsd -bam data/temp_merged_list.txt -out outs/thetas -doThetas 1 -doSaf 1 -pest outs/temp_pest.saf 

#(calculate Tajimas.)
#../angsd0.551/misc/bgid make_bed bongo.thetas.gz 
#../angsd0.551/misc/bgid do_stat bongo.thetas.gz -nChr 40
