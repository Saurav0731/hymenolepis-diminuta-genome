#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=centroAnno_HD_all
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

# Path to centroAnno
centroAnno="/scratch/skc49482/HD_assembly/scripts/centroanno/centroAnno/centroAnno"

# fasta file
HD_genome="/scratch/skc49482/HD_assembly/scripts/functional_annotation/ncbi_submission_sept/H_dim.fasta"
outdir="/scratch/skc49482/HD_assembly/scripts/centroanno/H_dim/centromere"
cautils="/scratch/skc49482/HD_assembly/scripts/centroanno/centroAnno/misc/misc/cautils.py"

mkdir -p $outdir

##version
$centroAnno --version

# run
$centroAnno $HD_genome -o $outdir -x anno-asm -t 16

## visulization
python --version
python $cautils $outdir $outdir/viz

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
