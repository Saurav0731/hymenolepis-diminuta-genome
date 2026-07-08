#!/bin/bash
#SBATCH --partition=iob_batch
#SBATCH --job-name=HM_RNA_3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=4-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

## Braker3 script to get the gene models - RNA rep_3
# Define path
HM_genome="/scratch/skc49482/HD_assembly/results/HM/RepeatMM/HM_NCBI_genome.masked.fasta"
bam_file="/scratch/skc49482/HD_assembly/results/HM/Braker_Odb12/STAR/bam_files"
output_dir="/scratch/skc49482/HD_assembly/results/Braker_GFF/HM/RNA/rep_3"

# Getting all bam file names
bam_names=$(ls $bam_file/*_sorted.bam | tr '\n' ',')
bam_names=${bam_names%,} #remove coma

echo -e "\n Names of Bam files :- \n"
echo $bam_names


#load module
module load BRAKER/3.0.3-foss-2022a

cd $output_dir
#run Braker
braker.pl --genome=$HM_genome \
--bam=$bam_names \
--species=HM_RNA_rep3_gff \
--gff3 \
--nocleanup \
--threads 16

cut -f3 braker/braker.gtf | sort | uniq -c > braker_run.txt
cut -f3 braker/augustus.hints.gtf | sort | uniq -c > augustus_run.txt

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
