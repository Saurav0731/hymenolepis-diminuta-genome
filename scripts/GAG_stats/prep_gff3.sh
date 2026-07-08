#!/bin/bash

# keep features which landed on 6 chromosomes 
awk 'BEGIN{FS=OFS="\t"} /^#/ {print; next} $1 ~ /^[1-6]$/ {print}' Nowak_on_Hdim_all.gff3 > Nowak_on_Hdim_all_Chr1_6.gff3

# fix the phase issue with the gff3 file
module load AGAT/1.4.2
agat_sp_fix_cds_phases.pl -gff Nowak_on_Hdim_all_Chr1_6.gff3 -f /scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_6Chr.fasta -o Nowak_on_Hdim_all_Chr1_6_phaseFix.gff3 2> phase_fix_warnings.log
