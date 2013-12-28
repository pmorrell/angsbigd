#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J angsdo
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt
#SBATCH -c 4 

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

#(estimate an SFS)
#NB this TRIP file is a temporary file based on one BAM. Do not use for real stuff.
angsd -bam data/BKN_list.txt -out temp/BKN_pest -doSaf 1 -uniqueOnly 1 -fold 1 -anc temp/TRIP_try.fa.gz -minMapQ 20 -minQ 1 -GL 1 -r 10:
emOptim2 temp/BKN_pest.saf 8 > temp/BKN_pest.em.ml -nSites 10000

#(calculate thetas)
angsd -bam data/BKN_list.txt -out results/BKN_thetas -doThetas 1 -doSaf 1 -pest temp/BKN_pest.saf 

#(calculate Tajimas.)
#../angsd0.551/misc/bgid make_bed bongo.thetas.gz 
#../angsd0.551/misc/bgid do_stat bongo.thetas.gz -nChr 40
