#!/bin/bash

# this script is to change the header of scaffolded HD genome and to add the mtDNA seqeunce to it to make the final assembly file

# path
scaffolded_HD="/scratch/skc49482/HD_assembly/results/ragtag/ragtag_updatedHeader_RC/HD_6_Chromosome.fasta"
HD_mitoDNA="/scratch/skc49482/HD_assembly/results/MitoHifi/seqkit_result/rearranged_HD_genome.fasta"
output="/scratch/skc49482/HD_assembly/results/ragtag/"

# change the header of HD_6_Chromosome.fasta
module load SeqKit/2.9.0
echo "HD header before editing"
seqkit fx2tab -nl $scaffolded_HD

sed -E 's/^>HM_([0-9]+)_RagTag/>HD_\1/' $scaffolded_HD >> $output/HD_genome.fasta

echo ""

# adding mitoDNA to this file to get the complete genome -- editing the header too.
sed '1s/.*/>HD_Mito/' $HD_mitoDNA >> $output/HD_genome.fasta

echo "HD headers after adding mtDNA"

seqkit fx2tab -nl $output/HD_genome.fasta

echo ""
echo "Final genome statistics"
seqkit stats $output/HD_genome.fasta
