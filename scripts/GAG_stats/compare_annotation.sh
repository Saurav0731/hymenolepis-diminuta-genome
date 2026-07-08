#!/bin/bash

## script to compare annotations (genome level and isoform level)

# load module
module load AGAT/1.4.2

## path to files
HD_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_no_Mito_tRNA.gff3"
Nowak_lifted_genome="/scratch/skc49482/HD_assembly/scripts/GAG_stats/annotation_stats/Nowak_on_Hdim_all_Chr1_6_phaseFix.gff3"

HD_isoform="/scratch/skc49482/HD_assembly/scripts/GAG_stats/isoforms/H_dim_no_Mito_tRNA_isoform_fixed.gff3"
Nowak_lifted_isoform="/scratch/skc49482/HD_assembly/scripts/GAG_stats/annotation_stats/Nowak_on_Hdim_all_Chr1_6_phaseFix_isoform.gff3"

## run AGAT
agat_sp_compare_two_annotations.pl -gff1 $HD_genome -gff2 $Nowak_lifted_genome -o Compare_anno_genome
agat_sp_compare_two_annotations.pl -gff1 $HD_isoform -gff2 $Nowak_lifted_isoform -o Compare_anno_isoform
