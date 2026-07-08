#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=gfastats
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

#outdir
output_dir="/scratch/skc49482/HD_assembly/results/gfastats"
mkdir -p "$output_dir"

# load module
source ~/.bashrc
conda activate gfastats
gfastats --version

#Assembly paths
HD_genome="/scratch/skc49482/HD_assembly/resources/HD_genome/H_dim_7.fasta"
Nowak_genome="/scratch/skc49482/HD_assembly/resources/Nowak_genome/Nowak_WB_genome.fasta"
HM_genome="/scratch/skc49482/HD_assembly/resources/HM_genome/HM_NCBI_genome.fasta"

# Assembly 
assemblies=("$HD_genome" "$Nowak_genome" "$HM_genome")

# Loop through assemblies
for assembly in "${assemblies[@]}"; do
    base_name=$(basename "$assembly" .fasta)
    echo "Processing $assembly"

    gfastats -f "$assembly" --stats > "$output_dir/${base_name}_stats.txt"
    gfastats -f "$assembly" --segment-report > "$output_dir/${base_name}_segment_report.txt"
    gfastats -f "$assembly" --path-report > "$output_dir/${base_name}_path_report.txt"

    echo "Finished processing $assembly"
done

echo "Finished processing all the assemblies"

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"

