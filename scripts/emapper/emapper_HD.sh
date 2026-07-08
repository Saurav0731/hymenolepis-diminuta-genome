#!/bin/bash
#SBATCH --partition=iob_batch
#SBATCH --job-name=eggNOG_HD
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=4-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# load module
module load eggnog-mapper/2.1.9-foss-2022a

# paths
protein_file="/scratch/skc49482/HD_assembly/scripts/functional_annotation/emapper/braker.aa"
data_dir="/apps/db2/eggnog-mapper/2.1.9-foss-2022a-version_5.0"
gff3_file="/scratch/skc49482/HD_assembly/scripts/functional_annotation/emapper/braker.gff3"
outdir="/scratch/skc49482/HD_assembly/results/functional_annotation/emapper"

##command
emapper.py -i $protein_file -o eggnog_mapper_HD --data_dir $data_dir --cpu 16 --usemem --itype proteins -m diamond --output_dir $outdir --report_orthologs --decorate_gff $gff3_file --decorate_gff_ID_field ID

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
