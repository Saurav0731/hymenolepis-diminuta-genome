#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HM_sorting
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=4-00:00:00
#SBATCH --mem=400G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu
start_time=`date +%s`
T=16

# define path 
bam_file="/scratch/skc49482/HD_assembly/results/HM/Braker_Odb12/STAR/bam_files"

# load module
module load SAMtools/1.14-GCC-11.2.0

# run
for file in $bam_file/*_Aligned.out.bam; do
    # Extract the base name without extension
    base_name=$(basename "$file" _Aligned.out.bam)
    
    # Define output sorted BAM file name
    sorted_bam="${bam_file}/${base_name}_sorted.bam"
    
    # Sort the BAM file
    samtools sort -@ 32 -o "$sorted_bam" "$file"
    
    echo "Sorted BAM file created: $sorted_bam"
done

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
