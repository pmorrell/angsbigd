#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J abba-baba
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt
#SBATCH -c 8


# script to run ANGSD on hapmap2 bam files
module load angsd

angsdir=/home/jri/src/angsd0.577/
taxon=$1
windowsize=1000
step=500
n=$( expr 2 \* $( wc -l data/"$taxon"_list.txt | cut -f 1 -d " " ))
range=""
glikehood=1

echo "taxon: $taxon n: $n range: $range" 1>&2

echo "$angsdir/angsd  -out temp/"$taxon" -doAbbababa 1 -bam data/"$taxon"_list.txt -doCounts 1 -anc  data/TRIP.fa.gz  -minMapQ 40 -minQ 20 -setMaxDepth 20  -baq 1 -GL $glikehood $range -P 8" 1>&2
$angsdir/angsd  -out temp/"$taxon" -doAbbababa 0 -bam data/"$taxon"_list.txt -doCounts 1 -anc  data/TRIP.fa.gz  -P 8
#-minMapQ 40 -minQ 20 -setMaxDepth 20  -baq 1 -GL $glikehood $range -P 8
echo "Rscript $angsdir/R/jackKnife.R file=temp/"$taxon".abbababa indNames=data/"$taxon"_list.txt outfile=results/"$taxon".abba.baba" 1>&2
Rscript $angsdir/R/jackKnife.R file=temp/"$taxon".abbababa indNames=data/"$taxon"_list.txt outfile=results/"$taxon".abba.baba
