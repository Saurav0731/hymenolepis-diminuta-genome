#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HD_RNA_protein_5
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

## Braker3 script to get the gene models - RNA+protein rep_5
# Define path
HD_genome="/scratch/skc49482/HD_assembly/results/RepeatMM/HD_genome.fasta.masked"
bam_file="/scratch/skc49482/HD_assembly/results/Braker/STAR/bam_files"
protein_file="/scratch/skc49482/HD_assembly/resources/Metazoa_odb12.fasta"
output_dir="/scratch/skc49482/HD_assembly/results/Braker_GFF/HD/RNA_protein/rep_5"
working_dir="$output_dir/Braker_files"

# Getting all bam file names
bam_names=$(ls $bam_file/*.bam | tr '\n' ',')
bam_names=${bam_names%,} #remove coma

echo -e "\n Names of Bam files :- \n"
echo $bam_names


#load module
module load BRAKER/3.0.3-foss-2022a

cd $output_dir
#run Braker
braker.pl --genome=$HD_genome \
--prot_seq=$protein_file \
--bam=$bam_names \
--species=HD_rnap_gff_rep5 \
--gff3 \
--workingdir $working_dir \
--nocleanup \
--threads 16

cut -f3 Braker_files/braker.gtf | sort | uniq -c > braker_run.txt
cut -f3 Braker_files/augustus.hints.gtf | sort | uniq -c > augustus_run.txt

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
