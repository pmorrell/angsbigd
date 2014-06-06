#!/bin/bash -l
#PBS -l walltime=10:00:00,mem=4gb,nodes=4:ppn=1
#PBS -m abe -M pmorrell@umn.edu

ANGSD=~/Apps/ANGSD/angsd0.600/angsd

#angsd -i /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/TDD39103_ZEAHWCRAYDIAAPE_7.bam -doFasta 1 -out /home/jri/projects/bigd/angsbigd/outs/TRIP_try
#angsd -i /group/jrigrp/hapmap2_bam/Disk3CSHL_bams_bwamem/TDD39103_merged.bam -doFasta 1 -out /home/jri/projects/bigd/angsbigd/data/TRIP

$ANGSD -i ~/shared/Datasets/NGS/Alignments/2014-03-07_IPK_BAMs/Disk_3/bams/Sample_Bulbosum_UMN_rmdup.bam -doFasta 1 -out ~/shared/ANGSD/IPK/Hbulbosum_UMN
