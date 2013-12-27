#!/bin/bash -l
#SBATCH -D /home/jri/projects/genomesize
#SBATCH -J jellyfish
#SBATCH -o outs/out-%j.txt
#SBATCH -p serial
#SBATCH -e errors/error-%j.txt

# script to run jellyfish on paul's files

/home/jri/src/angsd0.570/angsd -bam TIL09_FC61694AAXX_2.ba
