#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsdo/
#SBATCH -J angsdo
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt

# script to run ANGSD on hapmap2 bam files
module load angsd

angsd -do_stat outs/temp.thetas.gz -bam /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/TIL09_FC61694AAXX_2.bam -r chr1:1-100000 
