#!/bin/bash

# script to extract longest isoform from gff3 file using AGAT

## load module 
module load AGAT/1.4.2

## gff3 files
HD_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_no_Mito_tRNA.gff3"
HD_Nowak_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_no_Mito_tRNA.gff3"
HM_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_no_Mito_tRNA.gff3"
Nowak_lifted_all="/scratch/skc49482/HD_assembly/scripts/GAG_stats/liftoff/all_contigs/Nowak_on_Hdim_all_phaseFix.gff3"
Nowak_lifted_6Chr="/scratch/skc49482/HD_assembly/scripts/GAG_stats/liftoff/Chromosomes/Nowak_on_Hdim_6Chr_phaseFix.gff3"

## agat
agat_sp_keep_longest_isoform.pl -gff $HD_gff3 -o H_dim_no_Mito_tRNA_isoform.gff3
agat_sp_keep_longest_isoform.pl -gff $HD_Nowak_gff3 -o Nowak_WB_no_Mito_tRNA_isoform.gff3
agat_sp_keep_longest_isoform.pl -gff $HM_gff3 -o HM_WB_no_Mito_tRNA_isoform.gff3
agat_sp_keep_longest_isoform.pl -gff $Nowak_lifted_all -o Nowak_on_Hdim_all_phaseFix_isoform.gff3
agat_sp_keep_longest_isoform.pl -gff $Nowak_lifted_6Chr -o Nowak_on_Hdim_6Chr_phaseFix_isoform.gff3


