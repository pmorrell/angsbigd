#!/bin/bash -l
#SBATCH -D /home/jri/projects/bigd/angsbigd/
#SBATCH -J angsdo
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

echo "taxon: $taxon n: $n" range: $range 1>&2

#(estimate an SFS)
# -bam list of paths to bamfiles you want to use
# -out output file (prior for SFS I believe)
# -doSaf estimates SFS
# -uniqueOnly 1=use only uniquely mapping reads
# -anc ancestral sequence (see trip.sh script for how this is generated)
# -minMapQ 40 minimum mapping quality of reads to accepy
# -minQ 20 minimum bp quality
# -setMaxDepth 20 sets max depth to accept -- useful to deal with highly repetitive regions
# -baq 1=realign locally (I think)
# -GL $glikehood 1 is samtools, 2 is GATK, 3 SOAPsnp 4 SYK
# -r 10:1- ony analyze this range (here all of chromosome 10)
# -P 8 use 8 threads
# -indF individiual inbreeding coefficient. for inbred lines just make a files of "1" on each line for each bamfile. otherwise use ngsF to estimate (see inbreeding.sh script)
echo CMD angsd -bam data/"$taxon"_list.txt -out temp/"$taxon"_pest -doSaf 1 -uniqueOnly 1 -anc data/TRIP.fa.gz -minMapQ 40 -minQ 20 -setMaxDepth 20  -baq 1 -GL $glikehood $range -P 8 1>&2
$angsdir/angsd -bam data/"$taxon"_list.txt -out temp/"$taxon"_pest -indF data/$taxon.indF -doSaf 1 -uniqueOnly 1 -anc data/TRIP.fa.gz -minMapQ 40 -minQ 20 -setMaxDepth 20 -baq 1 -GL $glikehood $range -P 8

# not clear to me how to run folded, as -fold option seems to be deprecated?
# temp/"$taxon"_pest.saf output file from above run; prior on SFS?
# $n number of chromosomes; 2 x number of inds for diploids
# results/"$taxon"_pest.em.ml This output is the final estimated SFS
	# the file will be nat. log probabilities of the value of the SFS from 0:n
	# so if n=10, there will be 11 numbers.  To plot the SFS for polymorphic sites only, ignore the first and last numbers. e.g. for teosinte I get:
	# -0.133730 -3.724029 -4.246469 -4.981319 -5.453217 -5.803669 -6.076224 -6.330416 -6.501992 -6.713127 -6.882129 -6.970549 -7.289374 -7.434923 -7.308903 -7.057695 -7.457825 -7.740251 -7.665521 -7.683324 -7.788163 -7.702094 -7.562837 -7.491339 -7.416449 -7.364919 -7.107873 -6.870063 -6.458559 -6.044445 -2.994086
	# which corresponds to exp(-0.13)~0.9 or 90% of sites are fixed for ancestral allele, and exp(-2.994086) or ~5% are fixed for derived allele. 
	# remaining 5% are polymorphic
echo CMD emOptim2 temp/"$taxon"_pest.saf $n -P 8 > results/"$taxon"_pest.em.ml 1>&2
$angsdir/misc/emOptim2 temp/"$taxon"_pest.saf $n -P 8 > results/"$taxon"_pest.em.ml

#(calculate thetas)
# this now uses the SFS to calculate stats
# -doThetas 1 : calculate nucleotide diversity, thetaH, thetaL, wattersons theta
# -doSaf Not sure if this is needed here again
# -GL also not sure this is needed again
# -pest this is the SFS estimated above
# output $taxon.thetas will look like and have data for EVERY bp, including ones where thera are no polymorphisms. 
# in example below it's estimating nucleotide diversity as 10^-10 for the first bp (probably not polymorphic)
# but at site 26926 the estimate is 0.21 for pairwise nucleotide diversity ( that's polymorphic )
#Chromo Pos     Watterson       Pairwise        thetaSingleton  thetaH  thetaL
#10      3370    -8.664392       -10.223986      -7.289949       -13.844801      -10.890724
#10      3371    -8.822116       -10.395367      -7.431857       -14.041094      -11.062746
#10      3372    -8.840759       -10.415518      -7.448764       -14.064022      -11.082968
#10	26926	-1.480456	-0.671793	-211.328599	-0.694813	-0.683237
echo CMD angsd -bam data/"$taxon"_list.txt -out results/"$taxon" -doThetas 1 -doSaf 1 -GL $glikehood -indF data/$taxon.indF -pest results/"$taxon"_pest.em.ml -anc data/TRIP.fa.gz  $range -P 8 1>&2
$angsdir/angsd -bam data/"$taxon"_list.txt -out results/"$taxon" -doThetas 1 -doSaf 1 -GL $glikehood -indF data/$taxon.indF -pest results/"$taxon"_pest.em.ml -anc data/TRIP.fa.gz  $range -P 8

#(calculate Tajimas.)
# this estiamtes TajD and other stats and makes a sortof bedfile output
echo CMD thetaStat make_bed results/"$taxon".thetas.gz results/"$taxon" 1>&2
$angsdir/misc/thetaStat make_bed results/"$taxon".thetas.gz results/"$taxon"

# this does a sliding window analysis
# -nChr number of chromosomes
# -step how many bp to step between windows
# -win window size
# output (in this case $taxon.pestPG will look like:
#(569,1175)(4000,5001)(4000,5000)        10      4500    4.536109        4.774793        1.392152        9.523595        7.149193        0.169980        1.0433
#(963,1565)(4706,5500)(4500,5500)        10      5000    2.850285        2.665415        1.624860        4.608032        3.636723        -0.196105       0.4532
# with information for each window (see ANGSD online documentation for some explanation of columns)
echo CMD thetaStat do_stat results/"$taxon" -nChr $n -win $windowsize -step $step 1>&2
$angsdir/misc/thetaStat do_stat results/"$taxon" -nChr $n -win $windowsize -step $step
