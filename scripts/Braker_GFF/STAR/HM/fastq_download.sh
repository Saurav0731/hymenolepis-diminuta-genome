#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HM_fileDownload
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=6-00:00:00
#SBATCH --mem=300G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

# Start time
start_time=`date +%s`

# Define path
output_dir="/scratch/skc49482/HD_assembly/resources/HM_genome/RNA_sample"

# load module
module load SRA-Toolkit/3.0.3-gompi-2022a

# Define an array of accessions
accessions=("ERR225728" "ERR225729" "ERR225730" "ERR225719" "ERR225720" "ERR225721" "ERR225722" "ERR225723" "ERR225724" "ERR225725" "ERR225726" "ERR225727" "ERR337915" "ERR337928" "ERR337940" "ERR337952" "ERR337964" "ERR337976")

# Loop through each accession
for id in "${accessions[@]}"; do
    echo -e "\n  Currently processing: ${id}\n"

    # Extract fastq files and gzip them
    fasterq-dump --split-files -O $output_dir $id

    gzip "$output_dir/${id}_1.fastq"
    gzip "$output_dir/${id}_2.fastq"

done

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
