#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=repeatMM_HM
#SBATCH --gres=lscratch:200
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=3-00:00:00
#SBATCH --mem=500G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# define path
output_dir="/scratch/skc49482/HD_assembly/results/HM/RepeatMM"
HM_genome="/scratch/skc49482/HD_assembly/resources/HM_genome/HM_NCBI_genome.fasta"

mkdir -p /lscratch/${USER}/${SLURM_JOB_ID}

cp $HM_genome /lscratch/${USER}/${SLURM_JOB_ID}
cd /lscratch/${USER}/${SLURM_JOB_ID}

# load modules
module load RepeatModeler/2.0.3-foss-2022a
module load RepeatMasker/4.1.4-foss-2022a

# names
genome=HM_NCBI_genome.fasta
DB=H_microstoma

BuildDatabase -name ${DB} ${genome}
RepeatModeler -database ${DB} -LTRStruct -pa 16
RepeatMasker -pa 16 -lib ${DB}-families.fa -xsmall ${genome}

rsync -avx /lscratch/${USER}/${SLURM_JOB_ID}/ $output_dir
rm -rf /lscratch/${USER}/${SLURM_JOB_ID}

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
