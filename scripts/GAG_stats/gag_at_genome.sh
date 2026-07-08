#!/bin/bash

## script to generate stats from gff3 file for HD HD_Nowak, HM and Nowak_lifted_HD

## gag path
gag="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/GAG/gag.py"

## HD file paths
HD_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_6Chr.fasta"
HD_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_no_Mito_tRNA.gff3"

## HD Nowak file paths
HD_Nowak_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_genome.fasta"
HD_Nowak_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_no_Mito_tRNA.gff3"

## HM file paths
HM_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_6Chr.fasta"
HM_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_no_Mito_tRNA.gff3"

## Nowak lifted (6 Chromosomes)
Nowak_lifted_6Chr="/scratch/skc49482/HD_assembly/scripts/GAG_stats/annotation_stats/Nowak_on_Hdim_all_Chr1_6_phaseFix.gff3"

## load python version
module load Python/2.7

python2.7 $gag --version

## run GAG
echo -e "Generating stats for HD .. \n"
python2.7 $gag -f $HD_genome -g $HD_gff3 -o HD_stats

echo -e "Generating stats for HD_Nowak .. \n"
python2.7 $gag -f $HD_Nowak_genome -g $HD_Nowak_gff3 -o HD_Nowak_stats

echo -e "Generating stats for HM .. \n"
python2.7 $gag -f $HM_genome -g $HM_gff3 -o HM_stats

echo -e "Generating stats for Nowak_lifted_6Chr .. \n"
python2.7 $gag -f $HD_genome -g $Nowak_lifted_6Chr -o Nowak_lifted_6Chr
