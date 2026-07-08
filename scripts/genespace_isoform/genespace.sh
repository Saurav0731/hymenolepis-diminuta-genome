#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=HM_HD
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

## load all the modules
module load MCScanX/1.0.0-GCC-12.3.0
module load OrthoFinder/2.5.5-foss-2023a
module load DIAMOND/2.1.8-GCC-12.3.0
module load GENESPACE/1.2.3-foss-2023a-R-4.3.2


## input files
input_dir="/scratch/skc49482/HD_assembly/scripts/genespace/synteny_analysis/Isoform/HM_HD/"
peptide="$input_dir/peptide"
orthofinder="$input_dir/orthofinder"

echo -e "\n Running orthofinder \n"
orthofinder -f $peptide -t 16 -a 1 -X -o $orthofinder

echo -e "\n running genespace \n"

## genespace
cat > genespace_run_HM_HD.R << 'EOF'
library(GENESPACE)

## define wd here again
wd <- "/scratch/skc49482/HD_assembly/scripts/genespace/synteny_analysis/Isoform/HM_HD/"
path2mcscanx <- "/apps/eb/MCScanX/1.0.0-GCC-12.3.0/"

gpar <- init_genespace(wd = wd, path2mcscanx = path2mcscanx)
out <- run_genespace(gpar, overwrite = T)

ripd <- plot_riparian(gsParam=out,refGenome="HM", genomeIDs= c("HM","HD"),useRegions= FALSE)
pdf("riparian_HD_HM.pdf", width = 10, height = 6)
print(ripd)
dev.off()
EOF

Rscript genespace_run_HM_HD.R

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"
