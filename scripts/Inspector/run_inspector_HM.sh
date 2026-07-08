#!/bin/bash
#SBATCH --job-name=Ins_HM_wb
#SBATCH --partition=highmem_p
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=350gb
#SBATCH --time=120:00:00
#SBATCH --error=Ins_HM_wb.%j.err
#SBATCH --output=Ins_HM_wb.%j.out
#SBATCH --mail-user=nbs53763@uga.edu
#SBATCH --mail-type=ALL

cd /work/cbcg/nbs53763/Rozario_Choudhary/ValidateInversionBreakPoints/HM

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate tapeworm  

inspector.py -c /scratch/skc49482/HD_assembly/resources/HM_genome/HM_WB_genome.fasta -r /work/cbcg/nbs53763/Rozario_Choudhary/ValidateInversionBreakPoints/HM/HM_raw_read_SAMEA103949020/readFiles/SAMEA103949020.fastq.gz -o HM_inspector_out-wb/ --datatype hifi
