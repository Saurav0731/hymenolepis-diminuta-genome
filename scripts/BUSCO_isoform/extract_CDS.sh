#!/bin/bash

## script to extract CDS seq for the longest isoform 
# path to genome 
HD_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_6Chr.fasta"
HD_Nowak_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_genome.fasta"
HM_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_6Chr.fasta"

# load module
module load gffread/0.12.7-GCCcore-12.3.0
module load SeqKit/2.8.2

# running gffread to extract the CDS of longest isoform 
gffread H_dim_no_Mito_tRNA_isoform_fixed.gff3 -g $HD_genome -x HD_longest_isoform_CDS.fa
gffread HM_WB_no_Mito_tRNA_isoform.gff3 -g $HM_genome -x HM_longest_isoform_CDS.fa
gffread Nowak_WB_no_Mito_tRNA_isoform.gff3 -g $HD_Nowak_genome -x Nowak_longest_isoform_CDS.fa 

## check stats 
seqkit stats HD_longest_isoform_CDS.fa HM_longest_isoform_CDS.fa Nowak_longest_isoform_CDS.fa



