#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HD_alignment
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=4-00:00:00
#SBATCH --mem=400G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# script to get the genome index for HD genome and then map RNA-seq files to get BAM files for Braker3

# Define paths
HD_genome="/scratch/skc49482/HD_assembly/results/RepeatMM/HD_genome.fasta.masked"
genome_dir="/scratch/skc49482/HD_assembly/results/Braker/STAR/HD_genome_index"
output_dir="/scratch/skc49482/HD_assembly/results/Braker/STAR/bam_files"
fastq_dir="/scratch/skc49482/HD_assembly/scripts/Braker/RNA_sample"

# Load module
module load STAR/2.7.10b-GCC-11.3.0

# Genome Indexing
STAR --runThreadN 32 \
    --runMode genomeGenerate \
    --genomeDir $genome_dir \
    --genomeFastaFiles $HD_genome

echo -e "\nGenome Indexing done!!\n"
echo -e "\nStarting with mapping...\n"

# change directory
cd $output_dir

# Loop through all R1 FASTQ files
for r1 in $fastq_dir/*_R1_001.fastq.gz; do
    # Extract the base filename without the directory path
    base_name=$(basename "$r1")
    sample="${base_name%_R1_001.fastq.gz}"

    # Get corresponding R2 file
    r2="$fastq_dir/${sample}_R2_001.fastq.gz"

    # Check if the R2 file exists before running STAR
    if [[ -f "$r2" ]]; then
        STAR --runThreadN 32 \
            --genomeDir $genome_dir \
            --readFilesIn "$r1" "$r2" \
            --readFilesCommand zcat \
            --outFileNamePrefix "${sample}_" \
            --outSAMstrandField intronMotif \
            --outSAMtype BAM SortedByCoordinate

        echo "Finished processing: $sample"
    else
        echo "Warning: Matching R2 file not found for $sample. Skipping..."
    fi
done

echo "All samples processed successfully!"

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"

