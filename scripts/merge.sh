#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J bam_merge
#SBATCH -o outs/out-%j.txt
#SBATCH -p bigmem
#SBATCH -e errors/error-%j.txt

# merge bam files to single individuals 

for i in $( ls /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/ | cut -f 1 -d "_" | sort -n | uniq ); do

#merge >1 bam files
if [ $( ls -1 /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/$i* | wc -l ) -gt 1 ]
then

	samtools merge -r /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/"$i"_merged.bam $( ls /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/$i* | perl -ne '{BEGIN} chomp; print "$_\t"; while(<>){ chomp; print "$_\t";}; {END} chomp; print $_;')

#rename if only 1
elif [ ! -f /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/"$i"_merged.bam ]
then

	mv $( ls -1 /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/$i*  ) /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/"$i"_merged.bam;
	echo "renamed $i!"

#already renamed
else
	echo "$i already merged!"
fi;

done;
