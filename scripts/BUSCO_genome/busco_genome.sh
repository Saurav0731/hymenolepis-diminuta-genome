#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=busco_Updated_Genome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=2-00:00:00
#SBATCH --mem=400G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu
start_time=`date +%s`

# load module
source ~/.bashrc
mamba activate busco583
busco --version

# output dir
output_dir_lz="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/genome/lophotrochozoa_odb12"

# path to genome file
HD_Nowak="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/Nowak_WB_genome.fasta"
HM="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/HM_WB_6Chr.fasta"
HD="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/H_dim_6Chr.fasta"

################# run for lophotrochozoa_odb12 ###################
cd $output_dir_lz

busco -i $HD_Nowak -l lophotrochozoa_odb12 -o HD_Nowak -m genome -c 16
busco -i $HM -l lophotrochozoa_odb12 -o HM_Olson -m genome -c 16
busco -i $HD -l lophotrochozoa_odb12 -o HD_this_study -m genome -c 16



end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
