#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J inbreeding
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt
#SBATCH -c 8


# script to run ANGSD on hapmap2 bam files
module load angsd

taxon=$1
n=$( expr 2 \* $( wc -l data/"$taxon"_list.txt | cut -f 1 -d " " ))
range="10:1-"
echo "taxon: $taxon n: $n" range: $range 1>&2

# Call genotype likelihoods (had -C 50 but i don't know what that does, also -ref ref_seq.fas, minLRT is p<10^-4 assuming chi-squarei doZ outputs as gz)
echo "/home/jri/src/ngsTools/angsd/angsd -bam data/"$taxon"_list.txt  -minMapQ 40 -minQ 20 -baq 1 -out temp/$taxon -GL 1 -doMajorMinor 1 -doGlf 3 -doPost 1 -doMaf 2 -doSNP 1 -minLRT 15.1366 -r $range" 1>&2
#/home/jri/src/ngsTools/angsd/angsd -bam data/"$taxon"_list.txt  -minMapQ 40 -minQ 20 -baq 1 -out temp/$taxon -GL 1 -doMajorMinor 1 -doGlf 3 -doPost 1 -doMaf 2 -doSNP 1 -minLRT 15.1366 -r $range

#infer per individual inbreeding coefficient
#nsites=$( zgrep -cv position temp/"$taxon".mafs.gz)
gunzip temp/$taxon.glf.gz
nsites=$((`cat temp/$taxon.glf | wc -l`-1))
echo "/home/jri/src/ngsTools/ngsF/ngsF -n_ind $n -glf temp/$taxon.glf -out results/taxon.indF -n_sites $nsites" 1>&2
/home/jri/src/ngsTools/ngsF/ngsF -n_ind $n -glf temp/$taxon.glf -out results/$taxon.indF -n_sites $nsites

