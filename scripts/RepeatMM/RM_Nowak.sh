#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=repeatMask_Nowak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=3-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# define paths
output_dir="/scratch/skc49482/HD_assembly/results/Nowak/RepeatMask"
nowak_genome="/scratch/skc49482/HD_assembly/resources/Nowak_genome/HD_Nowak.fasta"
DB="/scratch/skc49482/HD_assembly/results/RepeatMM/H_diminuta"

# load module
module load RepeatMasker/4.1.4-foss-2022a

# Masking
RepeatMasker -pa 16 -dir $output_dir -lib ${DB}-families.fa -xsmall $nowak_genome

end_time=`date +%s`
runtime=$((end_time-start_time))
runtimeM=$((runtime/60))
echo "Duration: $runtime seconds"
echo "Duration: $runtimeM minutes"
