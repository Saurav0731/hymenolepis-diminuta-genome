#!/bin/bash
#SBATCH --partition=iob_p
#SBATCH --job-name=busco_isoform 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1-00:00:00
#SBATCH --mem=100G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu
start_time=`date +%s`

# load module
source ~/.bashrc
mamba activate busco583
busco --version

# output dir
output_dir_lz="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/isoform_AGAT/lophotrochozoa_odb12"
busco_plot="$output_dir_lz/busco_plot"
mkdir -p $output_dir_lz
mkdir -p $output_dir_lz/busco_plot

# path to transcriptome file
HD_Nowak="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/isoform_AGAT/Nowak_longest_isoform_CDS.fa"
HM="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/isoform_AGAT/HM_longest_isoform_CDS.fa"
HD="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/isoform_AGAT/HD_longest_isoform_CDS.fa"

#################  BUSCO run for lophotrochozoa_odb12 ###################
cd $output_dir_lz

busco -i $HD_Nowak -l lophotrochozoa_odb12 -o HD_Nowak -m transcriptome -c 16
busco -i $HM -l lophotrochozoa_odb12 -o HM_Olson -m transcriptome -c 16
busco -i $HD -l lophotrochozoa_odb12 -o HD_this_study -m transcriptome -c 16


## copy all the txt file and rename it for ordering 
cp HD_this_study/short_summary.*.txt $busco_plot/short_summary.specific.lophotrochozoa_odb12.01_HD_this_study.txt
cp HD_Nowak/short_summary.*.txt $busco_plot/short_summary.specific.lophotrochozoa_odb12.02_HD_Nowak.txt
cp HM_Olson/short_summary.*.txt $busco_plot/short_summary.specific.lophotrochozoa_odb12.03_HM_Olson.txt

## plot 
generate_plot.py -wd "$busco_plot"

end_time=`date +%s`
runtime=$((end_time - start_time))
runtimeH=$((runtime / 3600))
runtimeM=$(((runtime % 3600) / 60))
runtimeS=$((runtime % 60))

echo "Duration: $runtime seconds"
echo "Duration: $runtimeH hours, $runtimeM minutes, $runtimeS seconds"

