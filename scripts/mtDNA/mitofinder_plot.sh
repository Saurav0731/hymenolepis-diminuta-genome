#!/bin/bash

# This script is to generate the genBank file for the modified mitogenome file (used seqkit to move the location of COX1 at the begining) using mitofinder.
# Later plot the annotations using  genbank file

## this is the command used by mitohifi.py for annotation (/scratch/skc49482/HD_assembly/results/MitoHifi/mitohifi_results/potential_contigs/atg000001l)
# Command line: /opt/MitoFinder/mitofinder --new-genes --max-contig-size 69500 -j atg000001l.annotation -a atg000001l.mitogenome.fa -r /scratch/skc49482/HD_assembly/results/MitoHifi/ref_download/NC_002767.1.gb -o 9 -p 1 --circular-size 8000
#### 

# paths
mitofinder_output="/scratch/skc49482/HD_assembly/results/MitoHifi/mitofinder"
mod_HD_mito="/scratch/skc49482/HD_assembly/results/MitoHifi/seqkit_result/rearranged_HD_genome.fasta"
ref_gb="/scratch/skc49482/HD_assembly/results/MitoHifi/ref_download/NC_002767.1.gb"

# running mitofinder
cd $mitofinder_output 
singularity exec /apps/singularity-images/mitofinder_v1.4.1.sif mitofinder --new-genes -j HD_mito -a $mod_HD_mito -r $ref_gb -o 9 

## running plot_annotation.py of mitohifi 
## it requires just the input genbank filename
module load Python/3.11.3-GCCcore-12.3.0

# path of genbank file created by mitofinder
HD_mito_gb="HD_mito/HD_mito_MitoFinder_mitfi_Final_Results/HD_mito_mtDNA_contig.gb"

singularity exec /apps/singularity-images/mitohifi-3.2.1.sif python3 /opt/MitoHiFi/src/plot_annotation.py $HD_mito_gb

echo "Finished!!!"



