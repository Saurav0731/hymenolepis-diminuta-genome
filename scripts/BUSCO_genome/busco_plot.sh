# load module
source ~/.bashrc
mamba activate busco583
busco --version

## path to store all the txt file (genome)
busco_plot_genome="/scratch/skc49482/HD_assembly/scripts/gfstats/Annotation_stats/annotation_table/BUSCO_analysis/genome/lophotrochozoa_odb12/busco_plot_genome"

## copy all the txt file and rename it for ordering 
cp HD_this_study/short_summary.*.txt $busco_plot_genome/short_summary.specific.lophotrochozoa_odb12.01_HD_this_study.txt
cp HD_Nowak/short_summary.*.txt $busco_plot_genome/short_summary.specific.lophotrochozoa_odb12.02_HD_Nowak.txt
cp HM_Olson/short_summary.*.txt $busco_plot_genome/short_summary.specific.lophotrochozoa_odb12.03_HM_Olson.txt

## plot 
generate_plot.py  -wd $busco_plot_genome

echo "Finished plotting"
