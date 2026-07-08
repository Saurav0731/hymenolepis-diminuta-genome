#!/bin/bash
#SBATCH --partition=iob_p 
#SBATCH --job-name=ragtag_rHM1_6_qHD_RC
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
outdir="/scratch/skc49482/HD_assembly/results/ragtag/ragtag_updatedHeader_RC"
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


# change the header of HM genome sequence to plot the mummerplot
## HM information
#LR215989.1 Hymenolepis microstoma genome assembly, chromosome: 1        43032016
#LR215990.1 Hymenolepis microstoma genome assembly, chromosome: 2        31583181
#LR215991.1 Hymenolepis microstoma genome assembly, chromosome: 3        25815276
#LR215995.1 Hymenolepis microstoma genome assembly, chromosome: 4        25589455
#LR215993.1 Hymenolepis microstoma genome assembly, chromosome: 5        25362425
#LR215994.1 Hymenolepis microstoma genome assembly, chromosome: 6        17546944
##

sed -E 's/^([^ ]+) Hymenolepis microstoma genome assembly, chromosome: ([0-9]+)/>HM_\2/' $outdir/HM_6Chr_genome.fasta > $outdir/HM_Chr1_6.fasta

echo "Chromosome details of HM genome"
seqkit fx2tab -nl $outdir/HM_Chr1_6.fasta

# running ragtag with only 6 chromosomes of HM as reference and output of Hifiasm (reverse complemented) as input
# ragtag.py scaffold <reference.fa> <query.fa>
module load RagTag/2.1.0
ragtag.py scaffold $outdir/HM_Chr1_6.fasta $outdir/HD6_reverse_complemented.fasta -o $outdir -t 16

# remove unplaced contigs (extracting only contigs which has "Ragtag" prefix with it)
seqkit grep -r -p "RagTag" $outdir/ragtag.scaffold.fasta > $outdir/HD_6_Chromosome.fasta

echo "Chromosome length of HD genome"
echo""

seqkit fx2tab -nl $outdir/HD_6_Chromosome.fasta

### plotting mummerplot
cd $mummer_output

module load MUMmer/4.0.0rc1-GCCcore-11.3.0

nucmer -t 16 $outdir/HM_Chr1_6.fasta $outdir/HD_6_Chromosome.fasta -p HM1_6_HD1_6_RC
delta-filter -1 HM1_6_HD1_6_RC.delta > HM1_6_HD1_6_RC_filter.delta
mummerplot --size large --color -f --png HM1_6_HD1_6_RC_filter.delta -p HM1_6_HD1_6_RC

end_time=`date +%s`
runtime=$((end_time-start_time))
runtimeM=$((runtime/60))
echo "Duration: $runtime seconds"
echo "Duration: $runtimeM minutes"
