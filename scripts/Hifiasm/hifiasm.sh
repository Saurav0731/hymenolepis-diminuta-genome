#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=hifiasm
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --mem=50G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
start_time=`date +%s`

ml Hifiasm/0.19.4-r575-foss-2019b
hifiasm -o HD.asm -t 32  m64313e_230307_012355.hifi_reads.fastq.gz

end_time=`date +%s`
runtime=$((end_time-start_time))
runtimeM=$((runtime/60))
echo "Duration: $runtime seconds"
echo "Duration: $runtimeM minutes"
