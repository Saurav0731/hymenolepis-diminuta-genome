#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HD_tRNA_E
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=2-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# define paths
HD_genome="/scratch/skc49482/HD_assembly/results/RepeatMM/HD_genome.fasta.masked"
output_dir="/scratch/skc49482/HD_assembly/results/tRNAscan"

# running tRNAscan-SE
module load tRNAscan-SE/2.0.12-foss-2022a

cd $output_dir

tRNAscan-SE -E \
	-o HD_tRNA_E.txt \
	-f HD_tRNA_ss_E.txt \
	-s HD_tRNA_isotype_E.txt \
	-m HD_tRNA_stats_E.txt \
	-b HD_tRNA_E.bed \
	-j HD_tRNA_E.gff3 \
	-a HD_tRNA_E.fasta \
	-l HD_tRNA_E.log \
	--thread 16 \
	$HD_genome 

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
