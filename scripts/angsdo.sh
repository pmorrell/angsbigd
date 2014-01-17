#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J angsdo
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt
#SBATCH -c 8


# script to run ANGSD on hapmap2 bam files
module load angsd

taxon=$1
windowsize=100
step=100
n=$( expr 2 \* $( wc -l data/"$taxon"_list.txt | cut -f 1 -d " " ))
range="10:1-"
echo "taxon: $taxon n: $n" range: $range 1>&2

#(estimate an SFS)

echo CMD angsd -bam data/"$taxon"_list.txt -out temp/"$taxon"_pest -doSaf 1 -uniqueOnly 1 -anc data/TRIP.fa.gz -minMapQ 40 -minQ 20 -setMaxDepth 20 -uniqueOnly 1 -baq 1 -GL 1 -r $range -P 8 1>&2
angsd -bam data/"$taxon"_list.txt -out temp/"$taxon"_pest -doSaf 1 -uniqueOnly 1 -anc data/TRIP.fa.gz -minMapQ 40 -minQ 20 -setMaxDepth 20 -uniqueOnly 1 -baq 1 -GL 1 -r $range -P 8

# num chromes should = n for folded and 2n for unfolded
echo CMD emOptim2 temp/"$taxon"_pest.saf $n -P 8 > results/"$taxon"_pest.em.ml 1>&2
emOptim2 temp/"$taxon"_pest.saf $n -P 8 > results/"$taxon"_pest.em.ml


#(calculate thetas)
echo CMD angsd -bam data/"$taxon"_list.txt -out results/"$taxon" -doThetas 1 -doSaf 1 -GL 1 -pest results/"$taxon"_pest.em.ml -anc data/TRIP.fa.gz -r $range -P 8 1>&2
angsd -bam data/"$taxon"_list.txt -out results/"$taxon" -doThetas 1 -doSaf 1 -GL 1 -pest results/"$taxon"_pest.em.ml -anc data/TRIP.fa.gz -r $range -P 8

#(calculate Tajimas.)
echo CMD thetaStat make_bed results/"$taxon".thetas.gz results/"$taxon" 1>&2
thetaStat make_bed results/"$taxon".thetas.gz results/"$taxon"
echo CMD thetaStat do_stat results/"$taxon" -nChr $n -win $windowsize -step $step 1>&2
thetaStat do_stat results/"$taxon" -nChr $n -win $windowsize -step $step
