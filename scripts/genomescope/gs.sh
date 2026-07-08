#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=Genomescope
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=2-00:00:00
#SBATCH --mem=100G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu
start_time=`date +%s`

## path 
HD_fastq="/scratch/skc49482/HD_assembly/resources/HD_genome/m64313e_230307_012355.hifi_reads.fastq.gz"
genomescope="/scratch/skc49482/HD_assembly/scripts/Merqury/H_dim/genomescope2.0/genomescope.R"

## load modules
module purge
module load Merqury/1.3-foss-2023a-Java-11
module load Miniforge3/24.11.3-0
source /apps/eb/Miniforge3/24.11.3-0/etc/profile.d/conda.sh

## running meryl
meryl k=21 count output reads.meryl $HD_fastq

## generating histo file
meryl histogram reads.meryl > reads.histo

## running genomescope
conda activate r_env
echo "CONDA_PREFIX = $CONDA_PREFIX"

"$CONDA_PREFIX/bin/R" --version
"$CONDA_PREFIX/bin/Rscript" "$genomescope" --version

"$CONDA_PREFIX/bin/Rscript" "$genomescope" -i reads.histo -o H_dim_genome -k 21 -m 200

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
