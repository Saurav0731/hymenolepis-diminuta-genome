#!/bin/bash
#SBATCH --partition=iob_p 
#SBATCH --job-name=ragtag_rHM_qHD_RC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --mem=100G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=skc49482@uga.edu

start_time=`date +%s`

# Paths
outdir="/scratch/skc49482/HD_assembly/results/ragtag/ragtag_filtered_reverse_complement"
HM_reference="/scratch/skc49482/HD_assembly/resources/HM_genome/HM_NCBI_genome.fasta"
hifiasm_output="/home/skc49482/genome_assembly/kmer_files/primary.p_ctg.fa"
mummer_output="/scratch/skc49482/HD_assembly/results/ragtag/mummerplots"

# remove mtDNA from HM genome
module load SeqKit/2.9.0
seqkit grep -v -p "LR215992.1" $HM_reference > $outdir/HM_6Chr_genome.fasta

echo "Chromosome length of HM genome"
seqkit fx2tab -nl $outdir/HM_6Chr_genome.fasta

## reverse complement some contigs
seqkit grep -p 'ptg000001l,ptg000015l,ptg000006l,ptg000005l,ptg000002l,ptg000017l' $hifiasm_output | seqkit seq -r -p > $outdir/HD6_reverse_complemented.fasta
seqkit grep -v -p 'ptg000001l,ptg000015l,ptg000006l,ptg000005l,ptg000002l,ptg000017l' $hifiasm_output >>  $outdir/HD6_reverse_complemented.fasta


# running ragtag with only 6 chromosomes of HM as reference and output of Hifiasm (reverse complemented) as input
# ragtag.py scaffold <reference.fa> <query.fa>
module load RagTag/2.1.0
ragtag.py scaffold $outdir/HM_6Chr_genome.fasta $outdir/HD6_reverse_complemented.fasta -o $outdir -t 16

# remove unplaced contigs (extracting only contigs which has "Ragtag" prefix with it)
seqkit grep -r -p "RagTag" $outdir/ragtag.scaffold.fasta > $outdir/HD_6_Chromosome.fasta

echo "Chromosome length of HD genome"
echo""

seqkit fx2tab -nl $outdir/HD_6_Chromosome.fasta

### plotting mummerplot
cd $mummer_output

module load MUMmer/4.0.0rc1-GCCcore-11.3.0

nucmer -t 16 $outdir/HM_6Chr_genome.fasta $outdir/HD_6_Chromosome.fasta -p HM6_HD6_RC
delta-filter -1 HM6_HD6_RC.delta > HM6_HD6_RC_filter.delta
mummerplot --size large --color -f --png HM6_HD6_RC_filter.delta -p HM6_HD6_RC

end_time=`date +%s`
runtime=$((end_time-start_time))
runtimeM=$((runtime/60))
echo "Duration: $runtime seconds"
echo "Duration: $runtimeM minutes"
