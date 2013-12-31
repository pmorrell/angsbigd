#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J angsdo
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt
#SBATCH -c 8

#while getopts "b:" opt; do
#case $opt in
#	b)
##		BAM_LIST=$OPTARG
#		echo $BAM_LIST
#		exit 1
 #     		;;
#	\?)
 #     		echo "Invalid option: -$OPTARG" >&2
  #    		exit 1
   #   		;;
   # 	:)
   #   		echo "Option -$OPTARG requires an argument." >&2
   #   		exit 1
  #    		;;
#	h)  
#		echo "usage:
#-h this help menu
#-b <bam_list> list of bam files to run, with full path
#-m <method> 
#esac
#done

# script to run ANGSD on hapmap2 bam files
module load angsd

taxon=$1
n=$( expr 2 \* $( wc -l data/"$taxon"_list.txt | cut -f 1 -d " " ))
echo "taxon: $taxon" 1>&2

#(estimate an SFS)
#NB this TRIP file is a temporary file based on one BAM. Do not use for real stuff.
echo "step 1 sfs" 1>&2

angsd -bam data/"$taxon"_list.txt -out temp/"$taxon"_pest -doSaf 1 -uniqueOnly 1 -anc data/TRIP.fa.gz -minMapQ 20 -minQ 1 -GL 1 -r 1: -P 8

echo "step 2 em stuff" 1>&2
# num chromes should = n for folded and 2n for unfolded
emOptim2 temp/"$taxon"_pest.saf $n -nSites 10000000 -P 8 > temp/"$taxon"_pest.em.ml


#(calculate thetas)
echo "step 3 thetas" 1>&2
angsd -bam data/"$taxon"_list.txt -out results/"$taxon" -doThetas 1 -doSaf 1 -GL 1 -pest temp/"$taxon"_pest.em.ml -anc data/TRIP.fa.gz -r 1: -P 8

#(calculate Tajimas.)
thetaStat make_bed results/"$taxon".thetas.gz results/$taxon 
thetaStat do_stat results/"$taxon" -nChr $n -win 50000 -step 10000 
