#!/bin/bash
#SBATCH --job-name=Ins_HD
#SBATCH --partition=highmem_p
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=350gb
#SBATCH --time=120:00:00
#SBATCH --error=Ins_HD.%j.err
#SBATCH --output=Ins_HD.%j.out
#SBATCH --mail-user=nbs53763@uga.edu
#SBATCH --mail-type=ALL

cd /work/cbcg/nbs53763/Rozario_Choudhary/ValidateInversionBreakPoints/HD

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate tapeworm  

inspector.py -c H_dim_chr1-6.fasta -r /scratch/skc49482/HD_assembly/resources/HD_genome/m64313e_230307_012355.hifi_reads.fastq.gz -o HD_inspector_out/ --datatype hifi
