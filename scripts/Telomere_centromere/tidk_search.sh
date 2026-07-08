# activate conda env
module load Miniforge3/24.11.3-0
source /apps/eb/Miniforge3/24.11.3-0/etc/profile.d/conda.sh
conda activate tidk_env

## version 
tidk --version

## path 
HD_genome="/scratch/skc49482/HD_assembly/scripts/functional_annotation/ncbi_submission_sept/H_dim.fasta"

## running tidk
for m in TTAGGG ; do  
        tidk search -s $m -o all_contig_${m} --log -d . $HD_genome ; 
        tidk plot -t all_contig_${m}_telomeric_repeat_windows.tsv -o all_contig_${m} --fontsize 20 --strokewidth 5;
done
