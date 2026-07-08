#!/bin/bash

# This script to get the COX1 gene at the start of HD mito genome (previous HD genomes has COX1 at the starting position)

# load module 
module load SeqKit/2.9.0 

# location of HD mitogenome
HD_mito="/scratch/skc49482/HD_assembly/results/MitoHifi/mitohifi_results/final_mitogenome.fasta"
output="/scratch/skc49482/HD_assembly/results/MitoHifi/seqkit_result"

# print the stats of HD mito genome before the modification
echo "HD_mito statistics before the modification"
echo ""

seqkit stats $HD_mito

# get the start postion of COX1 from genbank file
COX1_start=3408
Total_length=14523 #HD_mitogenome

# get the sequence from start of COX1 to end of HD_mitogenome
seqkit subseq -r ${COX1_start}:${Total_length} $HD_mito -o $output/part1.fasta

# get the sequence form start of HD_mito to start of COX1
seqkit subseq -r 1:$((COX1_start-1)) $HD_mito -o $output/part2.fasta

# Concatenate these two to make the complete genome 
seqkit concat $output/part1.fasta $output/part2.fasta -o $output/rearranged_HD_genome.fasta

# Verify the stats again
seqkit stats $output/rearranged_HD_genome.fasta

echo "Seqkit part finished!!!"
echo""
###########Mummerplot##############

# different paths for mummerplot
ref_file="/scratch/skc49482/HD_assembly/results/MitoHifi/ref_download/NC_002767.1.fasta"
output_mummer="/scratch/skc49482/HD_assembly/results/MitoHifi/mummerplot"

cd $output_mummer

# Runner mummerplot to compare with NC_002767
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
nucmer -t 16 $ref_file $output/rearranged_HD_genome.fasta -p rearranged_NC
delta-filter -1 rearranged_NC.delta > rearranged_NC_filter.delta
mummerplot --size large -layout --color -f --png rearranged_NC_filter.delta -p rearranged_mummer

echo "Mummer run finished !!!"


