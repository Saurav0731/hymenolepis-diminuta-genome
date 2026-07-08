#!/bin/bash
#SBATCH --partition=iob_batch
#SBATCH --job-name=HM_protein_5
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

## Braker3 script to get the gene models - Protein rep_5
# Define path
HM_genome="/scratch/skc49482/HD_assembly/results/HM/RepeatMM/HM_NCBI_genome.masked.fasta"
protein_file="/scratch/skc49482/HD_assembly/resources/Metazoa_odb12.fasta"
output_dir="/scratch/skc49482/HD_assembly/results/Braker_GFF/HM/Protein/rep_5"

#load module
module load BRAKER/3.0.3-foss-2022a

cd $output_dir

#run Braker
braker.pl --genome=$HM_genome \
--prot_seq=$protein_file \
--species=HM_Protein_rep5_gff \
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
