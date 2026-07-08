#!/bin/bash

## script to extract peptide seq for the longest isoform
# path to genome
HD_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_6Chr.fasta"
HD_gff3="/scratch/skc49482/HD_assembly/scripts/GAG_stats/isoforms/H_dim_no_Mito_tRNA_isoform_fixed.gff3"
HM_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_6Chr.fasta"
HM_gff3="/scratch/skc49482/HD_assembly/scripts/GAG_stats/isoforms/HM_WB_no_Mito_tRNA_isoform.gff3"
outdir="/scratch/skc49482/HD_assembly/scripts/genespace/synteny_analysis/Isoform/HM_HD/peptide"

# load module
module load gffread/0.12.7-GCCcore-12.3.0
module load SeqKit/2.8.2

# running gffread to extract the pep seq of longest isoform
gffread $HD_gff3 -g $HD_genome -S -y $outdir/HD.fa
gffread $HM_gff3 -g $HM_genome -S -y $outdir/HM_temp.fa

seqkit replace -p '^transcript:' -r '' $outdir/HM_temp.fa > $outdir/HM.fa
rm $outdir/HM_temp.fa

## check stats
seqkit stats $outdir/HD.fa $outdir/HM.fa 
