#!/bin/bash

## liftoff on all the contigs (including unplaced)
## paths
HD_genome="/scratch/skc49482/HD_assembly/scripts/functional_annotation/ncbi_submission_sept/H_dim.fasta"
Nowak_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_genome.fasta"
Nowak_gff3="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_no_Mito_tRNA.gff3"

# load module 
module load Liftoff/1.6.3

liftoff $HD_genome $Nowak_genome -g $Nowak_gff3 -o Nowak_on_Hdim_all.gff3
