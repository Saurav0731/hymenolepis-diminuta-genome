#!/bin/bash
#SBATCH --partition=iob_batch
#SBATCH --job-name=Mitohifi
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1-00:00:00
#SBATCH --mem=200G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu
start_time=`date +%s`
T=16


# input-output paths
ref_file="/scratch/skc49482/HD_assembly/results/MitoHifi/ref_download"
input="/scratch/skc49482/HD_assembly/resources/HD_genome/"
output="/scratch/skc49482/HD_assembly/results/MitoHifi/mitohifi_results"
mito_scripts="/scratch/skc49482/HD_assembly/scripts/mtDNA/MitoHiFi/src"


# This part runs the findMitoReference.py script from MitoHifi to get the reference fasta file and genbank file for HD
# We just need to provide species name and  minimum length of the reference mito genome

# running findMitoReference.py script 
singularity exec --env SSL_CERT_FILE=/home/skc49482/.local/lib/python3.11/site-packages/certifi/cacert.pem /apps/singularity-images/mitohifi-3.2.1.sif findMitoReference.py --species "Hymenolepis diminuta" --outfolder $ref_file --min_length 13000

echo "Downloaded the reference fasta and gb file"

# This part runs the mitohifi.py script from MitoHifi to get complete annotated mito genome
# We need to provide Hifi Reads, reference fasta and gbk file downloaded using findMitoReference.py, genetic code (here it is 9 - got this information from  https://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/index.cgi?chapter=cgencodes#SG9)

## change directory to save the output in different directory
cd $output

# running mitohifi.py script
singularity exec /apps/singularity-images/mitohifi-3.2.1.sif mitohifi.py -r $input/m64313e_230307_012355.hifi_reads.fasta -f $ref_file/*.fasta -g $ref_file/*.gb -t 32 -o 9

end_time=`date +%s`
runtime=$((end_time-start_time))
runtimeM=$((runtime/60))
echo "Duration: $runtime seconds"
echo "Duration: $runtimeM minutes"




