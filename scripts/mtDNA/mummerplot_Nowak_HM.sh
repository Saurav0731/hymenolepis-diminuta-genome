#!/bin/bash

# script to get mummerplot for Nowak mtgenome vs HD_rearranged mt genome

# path
Nowak_mtgenome="/scratch/skc49482/HD_assembly/resources/Nowak_genome/LR536429.1.fasta"
HD_mtgenome="/scratch/skc49482/HD_assembly/results/MitoHifi/seqkit_result/rearranged_HD_genome.fasta"
HM_mtgenome="/scratch/skc49482/HD_assembly/resources/HM_genome/LR215992.1.fasta"
output_mummer="/scratch/skc49482/HD_assembly/results/MitoHifi/mummerplot"


cd $output_mummer
# running mummerplot Nowak vs HD_rearr
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
nucmer -t 16 $Nowak_mtgenome $HD_mtgenome -p Nowak_rearr
delta-filter -1 Nowak_rearr.delta > Nowak_rearr_filter.delta
mummerplot --size large -layout --color -f --png Nowak_rearr_filter.delta -p Nowak_rearr_mummer

echo "Finished running mummerplot Nowak vs HD_rearr"
echo ""

# running mummerplot HM vs HD_rearr
module load MUMmer/4.0.0rc1-GCCcore-11.3.0
nucmer -t 16 $HM_mtgenome $HD_mtgenome -p HM_rearr    
delta-filter -1 HM_rearr.delta > HM_rearr_filter.delta
mummerplot --size large -layout --color -f --png HM_rearr_filter.delta -p HM_rearr_mummer


echo "Finished running mummerplot HM vs HD_rearr"
echo ""
