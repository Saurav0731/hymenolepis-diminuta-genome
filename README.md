<div align="center">

# Assembly of a high-quality reference genome for the rat tapeworm _Hymenolepis diminuta_

[![bioRxiv](https://img.shields.io/badge/bioRxiv-preprint-b31b1b.svg)](https://www.biorxiv.org/content/10.64898/2026.06.23.734100v1.full)
[![NCBI Assembly](https://img.shields.io/badge/NCBI-GCA__056153285.1-1a6bab.svg)](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_056153285.1/)
[![HiFi reads](https://img.shields.io/badge/SRA-SRX28909596-2b7a3b.svg)](https://www.ncbi.nlm.nih.gov/sra/SRX28909596)
![Language](https://img.shields.io/badge/built%20with-Bash%20%7C%20Python%20%7C%20R-4c8cbf.svg)

</div>

This repository contains the scripts, figures/tables, and supplementary files used for the genome assembly, repeat analysis, structural annotation, functional annotation, and comparative genomics of _H. diminuta_.

> **Preprint:** Choudhary S.K., Sundaresha N., Ye K., Bergman C.M. _Assembly of a high-quality reference genome for the rat tapeworm Hymenolepis diminuta._ bioRxiv (2026). → **[Read the preprint](https://www.biorxiv.org/content/10.64898/2026.06.23.734100v1.full)**

***

#### Table of Contents
- [Data Availability](#data-availability)
- [Dependencies](#dependencies)
- [Data Sources](#data-sources)
- [Directory Structure](#directory-structure)
- [Pipeline Overview & Usage](#pipeline-overview--usage)
  - [Genome Assembly](#genome-assembly)
  - [Scaffolding](#scaffolding)
  - [Mitochondrial DNA](#mitochondrial-dna)
  - [Assembly Stats](#assembly-stats)
  - [Assembly Error Detection](#assembly-error-detection)
  - [BUSCO at Genome Level](#busco-at-genome-level)
  - [Repeat Analysis](#repeat-analysis)
  - [Structural Annotation](#structural-annotation)
  - [Functional Annotation](#functional-annotation)
  - [tRNA Prediction](#trna-prediction)
  - [BUSCO at Transcriptome Level](#busco-at-transcriptome-level)
  - [Synteny Analysis](#synteny-analysis)
  - [Telomere Search](#telomere-search)
  - [Centromere Search](#centromere-search)
  - [Annotation Stats Comparison](#annotation-stats-comparison)

***

#### Data Availability

| Resource | Accession / Link |
| :------- | :--------------- |
| Genome assembly | [GCA_056153285.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_056153285.1/) (JBVFLO000000000) |
| HiFi reads | [SRX28909596](https://www.ncbi.nlm.nih.gov/sra/SRX28909596) |
| Preprint | [bioRxiv](https://www.biorxiv.org/content/10.64898/2026.06.23.734100v1.full) |
| Archived scripts &amp; supplementary files | [Zenodo](https://doi.org/10.5281/zenodo.20737624) |

***

#### Dependencies

All tools were run on the Sapelo2 HPC cluster (GACRC, University of Georgia). Conda env files are provided in `scripts/envs/` for reproducibility.

| Tool | Version | Purpose |
|:------:| :------:| :------:|
| Hifiasm | 0.19.4 | HiFi read assembly |
| GenomeScope2 | 2.0 | Genome survey |
| Merqury | 1.3 | k-mer-based assembly evaluation |
| RagTag | 2.1.0 | Scaffolding |
| SeqKit | 2.9.0 | General purpose |
| MUMmer | 4.0.0rc1 | Mummerplot |
| MitoHiFi | 3.2.1 | mtDNA assembly |
| MitoFinder | 1.4.1 | mtDNA annotation |
| Python | 3.11.3 | General purpose |
| GFAstats | 1.3.11 | Assembly statistics |
| BUSCO | 5.8.3 | Completeness assessment (genome & transcriptome) |
| RepeatModeler | 2.0.3 | _de novo_ modeling of repeats |
| RepeatMasker | 4.1.4 | masking of repeats |
| STAR | STAR/2.7.10b | RNA-seq alignment |
| BRAKER3 | 3.0.3-foss-2022a | Structural annotation |
| eggnog-mapper | 2.1.9 | Functional annotation |
| tRNAscan-SE | 2.0.12 | tRNA detection |
| GAG | 2.0.1 | genome annotation stats |
| AGAT | 1.4.2 | longest isoform selection |
| gffread | 0.12.7 | GFF3/GTF conversion, sequence extraction |
| tidk | 0.2.65 | Telomeric repeat identification |
| centroAnno | 1.0.2 | Centromere annotation |
| Liftoff | 1.6.3 | Annotation lift-over between assemblies |
| Inspector | 1.3.1 | assembly evaluation |
| Miniforge3 | 24.11.3 | Managing conda env |
| Python | 3.11.3 and 2.7 | Scripting |
| R | 4.5.0 |  figure generation |


#### Data Sources

| Data type | Species | Accession | Source |
| :------: | :------: | :------: | :------:|
| HiFi reads | _H. diminuta_ | SRX28909596 | This study |
| RNA seq reads | _H. diminuta_ | SRR9295549-SRR9295553,SRR9275651-SRR9275655 | Rozario et al. (2019) |
| RNA seq reads | _H. microstoma_ | ERR225719-ERR225730, ERR337915, ERR337928, ERR337940, ERR337952, ERR337964, ERR337976 | Olson et al (2020) |
| Reference genome | _H. microstoma_ | GCA_000469805.3 (HMN_v3) | Olson et al (2020) |
| Reference genome | _H. diminuta_ | GCA_902177915.1 | Nowak et al. (2019) |
| Reference mt genome | _H. diminuta_ | NC_002767.1 | von Nickisch-Rosenegk et al (2001) |
| Protein evidence | Metazoa | OrthoDB v12 | Tegenfeldt et al (2024) |



#### Directory Structure
```
.
├── README.md
├── scripts/
│   ├── BUSCO_genome/
│   │   ├── busco_genome.sh
│   │   └── busco_plot.sh
│   ├── BUSCO_isoform/
│   │   ├── agat_isoform.sh
│   │   ├── busco_isoform.sh
│   │   └── extract_CDS.sh
│   ├── Braker_GFF/
│   │   ├── HD/
│   │   │   ├── Protein/
│   │   │   │   ├── protein_rep1.sh
│   │   │   │   ├── protein_rep2.sh
│   │   │   │   ├── protein_rep3.sh
│   │   │   │   ├── protein_rep4.sh
│   │   │   │   └── protein_rep5.sh
│   │   │   ├── RNA/
│   │   │   │   ├── rna_rep1.sh
│   │   │   │   ├── rna_rep2.sh
│   │   │   │   ├── rna_rep3.sh
│   │   │   │   ├── rna_rep4.sh
│   │   │   │   └── rna_rep5.sh
│   │   │   └── RNA_protein/
│   │   │       ├── rep1.sh
│   │   │       ├── rep2.sh
│   │   │       ├── rep3.sh
│   │   │       ├── rep4.sh
│   │   │       └── rep5.sh
│   │   ├── HD_Nowak/
│   │   │   ├── Protein/
│   │   │   │   ├── Nowak_protein_1.sh
│   │   │   │   ├── Nowak_protein_2.sh
│   │   │   │   ├── Nowak_protein_3.sh
│   │   │   │   ├── Nowak_protein_4.sh
│   │   │   │   └── Nowak_protein_5.sh
│   │   │   ├── RNA/
│   │   │   │   ├── Nowak_RNA_rep1.sh
│   │   │   │   ├── Nowak_RNA_rep2.sh
│   │   │   │   ├── Nowak_RNA_rep3.sh
│   │   │   │   ├── Nowak_RNA_rep4.sh
│   │   │   │   └── Nowak_RNA_rep5.sh
│   │   │   └── RNA_protein/
│   │   │       ├── rep1.sh
│   │   │       ├── rep2.sh
│   │   │       ├── rep3.sh
│   │   │       ├── rep4.sh
│   │   │       └── rep5.sh
│   │   ├── HM/
│   │   │   ├── Protein/
│   │   │   │   ├── rep1.sh
│   │   │   │   ├── rep2.sh
│   │   │   │   ├── rep3.sh
│   │   │   │   ├── rep4.sh
│   │   │   │   └── rep5.sh
│   │   │   ├── RNA/
│   │   │   │   ├── rep1.sh
│   │   │   │   ├── rep2.sh
│   │   │   │   ├── rep3.sh
│   │   │   │   ├── rep4.sh
│   │   │   │   └── rep5.sh
│   │   │   └── RNA_protein/
│   │   │       ├── rep1.sh
│   │   │       ├── rep2.sh
│   │   │       ├── rep3.sh
│   │   │       ├── rep4.sh
│   │   │       └── rep5.sh
│   │   ├── STAR/
│   │   │   ├── HM/
│   │   │   │   ├── STAR_index_map.sh
│   │   │   │   ├── fastq_download.sh
│   │   │   │   └── sorting.sh
│   │   │   ├── STAR_index_map.sh
│   │   │   └── index_map.sh
│   │   └── braker_summary.sh
│   ├── GAG_stats/
│   │   ├── compare_annotation.sh
│   │   ├── gag_at_genome.sh
│   │   ├── gag_isoform.sh
│   │   ├── liftoff_Nowak_on_HD.sh
│   │   ├── prep_gff3.sh
│   │   └── table.R
│   ├── Hifiasm/
│   │   └── hifiasm.sh
│   ├── Inspector/
│   │   ├── run_inspector_HD.sh
│   │   └── run_inspector_HM.sh
│   ├── RepeatMM/
│   │   ├── RM_HM.sh
│   │   ├── RM_Nowak.sh
│   │   └── Rm.sh
│   ├── Telomere_centromere/
│   │   ├── centroAnno_HD.sh
│   │   ├── centromere_telomere_plotting.py
│   │   └── tidk_search.sh
│   ├── emapper/
│   │   ├── emapper_HD.sh
│   │   ├── transfer_annotation.py
│   │   └── transfer_annotation.sh
│   ├── envs/
│   │   ├── busco583.yml
│   │   ├── gfastats.yml
│   │   ├── r_env.yml
│   │   └── tidk_env.yml
│   ├── genespace_isoform/
│   │   ├── extract_pep.sh
│   │   ├── genespace.sh
│   │   └── makeMappingccords.py
│   ├── genomescope/
│   │   └── gs.sh
│   ├── gfastats/
│   │   ├── gfastats.sh
│   │   └── gfastats_table.R
│   ├── mtDNA/
│   │   ├── mitofinder_plot.sh
│   │   ├── mitohifi.sh
│   │   ├── mummerplot_Nowak_HM.sh
│   │   └── seqkit_cox1.sh
│   ├── ragtag/
│   │   ├── mtDNA_header_HD.sh
│   │   ├── ragtag.sh
│   │   ├── ragtag_header_RC.sh
│   │   └── ragtag_rc.sh
│   └── tRNAscan-SE/
│       └── trna_Pred_E.sh
├── figures_tables/
│   ├── Annotation_stats_genome_level.csv
│   ├── Annotation_stats_isoform_level.csv
│   ├── Braker_gene_comparison.pdf
│   ├── Braker_transcript_comparison.pdf
│   ├── HD_Nowak.fasta.tbl
│   ├── HD_genome.fasta.tbl
│   ├── HD_vs_Nowak_genome.txt
│   ├── HD_vs_Nowak_isoform.txt
│   ├── HM1_6_HD1_6_RC.png
│   ├── HM_NCBI_genome.fasta.tbl
│   ├── Repeat_plot.pdf
│   ├── Repeat_table_stats.png
│   ├── braker_plotting.R
│   ├── braker_summary.txt
│   ├── busco_genome.png
│   ├── busco_isoform.png
│   ├── chrom_repeats_map.pdf
│   ├── contigs_full_genome.pdf
│   ├── genome_stats.csv
│   ├── linear_plot.png
│   ├── repeat_Stats_fig3A_B.R
│   └── riparian_HD_HM.pdf
└── supplementary_files/
    ├── Centromere_files/
    │   ├── all_monomerTemplates.fa
    │   ├── repeat_regions.bed
    │   └── top10_repeats.bed
    ├── Repeat_file/
    │   └── H_diminuta-families.fa
    ├── Synteny_files/
    │   ├── syntenicBlock_coordinates.csv
    │   └── syntenicRegion_coordinates.csv
    └── Telomere_files/
        └── all_contig_TTAGGG_telomeric_repeat_windows.tsv
```


#### Pipeline Overview & Usage
Each section below describes one stage of the pipeline. All SLURM batch scripts are submitted with `sbatch`; standalone scripts are run with `bash`, `python`, or `Rscript` as indicated. Scripts are located under `scripts/` following the directory structure above; generated figures and tables are written to `figures_tables/`. For example:
```
sbatch scripts/<dir>/script.sh    # SLURM job submission
bash scripts/<dir>/script.sh      # standalone bash script
python scripts/<dir>/script.py    # Python script
Rscript scripts/<dir>/script.R    # R script
```
##### Install conda env
Install the conda environments from the provided YAML files
```
conda env create -f scripts/envs/busco583.yml
conda env create -f scripts/envs/gfastats.yml
conda env create -f scripts/envs/r_env.yml
conda env create -f scripts/envs/tidk_env.yml
```
Activate the relevant environment before running each step:
```
conda activate <env-name>
```
Note: Some tools in this pipeline are loaded as modules on the GACRC Sapelo2 HPC cluster and do not require conda installation. See individual scripts for the module load commands used.

#### Genome Assembly
**Tool: GenomeScope2**
- Uses raw fastq file as input and estimates genome size and heterozygosity from raw HiFi reads.
- Note: The script uses the `r_env conda` environment.
```
sbatch scripts/genomescope/gs.sh
```
- Estimates genome size and heterozygosity.
```
GenomeScope 2.0
GenomeScope analyzing reads.histo p=2 k=21 outdir=H_dim_genome
aa:99.9% ab:0.0504%
Model converged het:0.000504 kcov:54.9 err:0.00197 model fit:0.522 len:190493799
```

**Tool:** **Hifiasm**
- Hifiasm assembles HiFi reads into primary and haplotype-resolved contigs.
```
sbatch scripts/Hifiasm/hifiasm.sh
```
- Output is converted from GFA to FASTA format. Followed the instructions mentioned here:- https://hifiasm.readthedocs.io/en/latest/faq.html 
```
awk '/^S/{print ">"$2;print $3}' HD.asm.bp.p_ctg.gfa > primary.p_ctg.fa
awk '/^S/{print ">"$2;print $3}' HD.asm.bp.hap1.p_ctg.gfa > hap1.p_ctg.fa
awk '/^S/{print ">"$2;print $3}' HD.asm.bp.hap2.p_ctg.gfa > h2.p_ctg.fa
```

#### Scaffolding
**Tool:** RagTag 
- RagTag performs reference-guided scaffolding against the _H. microstoma_ genome (GCA_000469805.3_HMN_v3). The script also handles contig orientation, header renaming, mtDNA exclusion from the reference, and MUMmerplot generation.
```
sbatch scripts/ragtag/ragtag_header_RC.sh
```
**Output:** `figures_tables/HM1_6_HD1_6_RC.png`

#### Mitochondrial DNA
**Tool:** MitoHifi
- Downloads mt reference genome (NC_002767.1) and performs reference-based mt genome assembly using the HiFi CCS reads.
```
sbatch scripts/mtDNA/mitohifi.sh
```
- make the COX1 as the starting point to make it comparable with the published mt seq.

```
bash scripts/mtDNA/seqkit_cox1.sh
```
- Running mitofinder for annotation of mitochondrial sequence 
```
bash scripts/mtDNA/mitofinder_plot.sh
```

#### Assembly Stats
**Tool:** GFAstats
- To compare statistics related to the genome for all three assemblies.
- Extracted chromosomes + mtDNA sequence
- Note: The script uses the `gfastats` conda environment.
```
module load SeqKit/2.9.0
seqkit head -n 7 H_dim.fasta > H_dim_7.fasta
grep ">" H_dim_7.fasta
>1 [organism=Hymenolepis diminuta][gcode=1]
>2 [organism=Hymenolepis diminuta][gcode=1]
>3 [organism=Hymenolepis diminuta][gcode=1]
>4 [organism=Hymenolepis diminuta][gcode=1]
>5 [organism=Hymenolepis diminuta][gcode=1]
>6 [organism=Hymenolepis diminuta][gcode=1]
>7 [organism=Hymenolepis diminuta][mgcode=9][location=mitochondrion]
```
- Run gfastats on all three assemblies to get the stats
```
sbatch scripts/gfastats/gfastats.sh
```
- R script to convert these stats into table
```
conda activate r_env
Rscript scripts/gfastats/gfastats_table.R genome_stats.csv  "HD (this study),HD (Nowak),HM (Olson)"  H_dim_7_stats.txt Nowak_WB_genome_stats.txt HM_NCBI_genome_stats.txt
```
#### Assembly error detection 
**Tool:** Inspector 
```
sbatch scripts/Inspector/run_inspector_HD.sh
sbatch scripts/Inspector/run_inspector_HM.sh
```

#### BUSCO at genome level
**Tool:** BUSCO
- Genomes -
  - _H.diminiuta_ ( Nowak et al. (2019)) - PRJEB30942
  - _H.microsotma_ (Olson et al. 2020) - PRJEB124
  - _H. diminiuta_ (This study)
- Selected the 6 chromosomes for _H.microsotma_ and _H. diminuta_
```
seqkit head -n 6 HM_WB_genome.fasta > HM_WB_6Chr.fasta
seqkit head -n 6 ./H_dim.fasta > H_dim_6Chr.fasta
```
- Running BUSCO and plotting the figure
- Note: The script uses the `busco583` conda environment.
```
sbatch scripts/BUSCO_genome/busco_genome.sh
bash scripts/BUSCO_genome/busco_plot.sh
```
**Output:** `figures_tables/busco_genome.png`

#### Repeat Analysis
Tools: RepeatModeler, RepeatMasker
```
sbatch scripts/RepeatMM/Rm.sh          # for H. dim (this study)
sbatch scripts/RepeatMM/RM_HM.sh       # for H. microstoma
sbatch scripts/RepeatMM/RM_Nowak.sh    # for H. dim (Nowak) (using de novo repeat database created in scripts/RepeatMM/Rm.sh)
```
- Repeat stats reported in the paper (used - `figures_tables/HD_Nowak.fasta.tbl`, `figures_tables/HD_genome.fasta.tbl`, `figures_tables/HM_NCBI_genome.fasta.tbl` )
```
Rscript figures_tables/repeat_Stats_fig3A_B.R
```
**Output:** `figures_tables/Repeat_plot.pdf`

#### Structural Annotation
**Tools:** STAR, BRAKER3
- Downloaded all RNA seq data (see [Data Sources](#data-sources) )
- RNA-seq reads were aligned to the soft-masked genome (generated after repeat annotation)
```
sbatch scripts/Braker_GFF/STAR/STAR_index_map.sh      # HD this study
sbatch scripts/Braker_GFF/STAR/index_map.sh           # Nowak
sbatch scripts/Braker_GFF/STAR/HM/fastq_download.sh   # for downloading HM RNA seq files
sbatch scripts/Braker_GFF/STAR/HM/STAR_index_map.sh   # alignment for HM
sbatch scripts/Braker_GFF/STAR/HM/sorting.sh          # sorting
```
- Used OrthoDB v12 Metazoa dataset as protein evidance for structural annotation (link used to downalod the dataset - https://bioinf.uni-greifswald.de/bioinf/partitioned_odb12/Metazoa.fa.gz)
- BRAKER3 — Run in three evidence modes (protein-only, RNA-only, RNA+protein), each with 5 replicates, across three assemblies (HD, HD-Nowak, HM).(3 assemblies × 3 modes × 5 replicates = 45 runs).
```
# Protein only - HD
sbatch scripts/Braker_GFF/HD/Protein/protein_rep1.sh ... protein_rep5.sh

# Protein only - HD_Nowak
sbatch scripts/Braker_GFF/HD_Nowak/Protein/Nowak_protein_1.sh ... Nowak_protein_5.sh

# Protein only - HM
sbatch scripts/Braker_GFF/HM/Protein/rep1.sh ... rep5.sh
```
```
# RNA-seq only - HD
sbatch scripts/Braker_GFF/HD/RNA/rna_rep1.sh ... rna_rep5.sh

# RNA-seq only - HD_Nowak
sbatch scripts/Braker_GFF/HD_Nowak/RNA/Nowak_RNA_rep1.sh ... Nowak_RNA_rep5.sh

# RNA-seq only - HM
sbatch scripts/Braker_GFF/HM/RNA/rep1.sh ... rep5.sh
```
```
# RNA-seq + Protein (combined) - HD
sbatch scripts/Braker_GFF/HD/RNA_protein/rep1.sh ... rep5.sh

# RNA-seq + Protein (combined) - HD_Nowak
sbatch scripts/Braker_GFF/HD_Nowak/RNA_protein/rep1.sh ... rep5.sh

# RNA-seq + Protein (combined) - HM
sbatch scripts/Braker_GFF/HM/RNA_protein/rep1.sh ... rep5.sh
```
- Script for extracting stats from all replicates
```
bash scripts/Braker_GFF/braker_summary.sh > braker_summary.txt 2> summary.log
```
- Rscript for getting the boxplot for gene and transcript models
```
Rscript figures_tables/braker_plotting.R braker_summary.txt figures_tables/
```
**Output:** `figures_tables/Braker_gene_comparison.pdf` and `figures_tables/Braker_transcript_comparison.pdf`

#### Functional Annotation
**Tool:** - eggnog-mapper
- eggNOG-mapper annotates the selected BRAKER gene models. Preferred names are then propagated from mRNA features to parent gene and CDS features.
```
sbatch scripts/emapper/emapper_HD.sh 
```
- The next step was to transfer annotations from mRNA to gene and CDS features. Specifically, assigning the preferred name from mRNA to gene and CDS. We decided to use the em_preferred name as an attribute. Python script which was used for trasferring annotation (`scripts/emapper/transfer_annotation.py`)
- Bash script which uses this python script was used to transfer annotation
```
bash scripts/emapper/transfer_annotation.sh
```

#### tRNA Prediction
**Tool:** tRNAscan-SE
```
sbatch scripts/tRNAscan-SE/trna_Pred_E.sh
```
#### BUSCO at Transcriptome Level
**Tools:** BUSCO, AGAT and gffread
- Removed all the features related to mitochondrial seq and tRNA records.
- Selected the longest transcript per gene using
- Note: The script uses the `busco583` conda environment.
```
bash scripts/BUSCO_isoform/agat_isoform.sh
```
- Some issue with `H_dim_no_Mito_tRNA_isoform.gff3` - inconsistancy between parent-child ID. Fixed it using
```
awk -F'\t' 'BEGIN{OFS="\t"}
{
  if($0 ~ /^#/) {print; next}

  # gene - pseudo fix
  if($3=="gene" && $9 ~ /ID=[^;]+,pseudo/) {
    sub(/,pseudo/, "", $9)
    $9 = $9 ";pseudo"
  }

  # Fix mRNA ID comma-suffixes:
  # ID=g1551.t1,anything;Parent=...  ->  ID=g1551.t1;Parent=...
  if($3=="mRNA") {
    split($9, parts, ";Parent")
    sub(/,.*/, "", parts[1])     
    $9 = parts[1]
    if(length(parts) > 1) $9 = $9 ";Parent" parts[2]
  }

  print
}' H_dim_no_Mito_tRNA_isoform.gff3 > H_dim_no_Mito_tRNA_isoform_fixed.gff3
```
- Extracted CDS directly from the genome using the longest isoform gff3
```
bash scripts/BUSCO_isoform/extract_CDS.sh
```
- Running BUSCO at transcriptome level
```
sbatch scripts/BUSCO_isoform/busco_isoform.sh
```
- BUSCO plot at transcriptome level - `figures_tables/busco_isoform.png`

#### Synteny Analysis
**Tool:** Genespace, gffread
- GENESPACE generates a riparian synteny plot between HD and HM. Peptide sequences and BED files are extracted from the longest-isoform GFF3 files.
```
bash scripts/genespace_isoform/extract_pep.sh
```
- Get the bed file
```
awk -F'\t' '
$0 !~ /^#/ && $3=="mRNA" {
    match($9, /ID=([^;]+)/, a);
    print $1 "\t" $4 "\t" $5 "\t" a[1];
}' H_dim_no_Mito_tRNA_isoform_fixed.gff3 > HD.bed

awk -F'\t' ' $0 !~ /^#/ && $3=="mRNA" { match($9, /ID=transcript:([^;]+)/, a); print $1 "\t" $4 "\t" $5 "\t" a[1]; }' HM_WB_no_Mito_tRNA_isoform.gff3 > HM.bed
```
- Run genespace script
```
sbatch scripts/genespace_isoform/genespace.sh
```
**Output:** - `figures_tables/riparian_HD_HM.pdf`

- Inversion breakpoint extraction
```
python scripts/genespace_isoform/makeMappingccords.py syntenicBlock_coordinates.csv GeneSapce_modBEDres.tsv HD HM
```

#### Telomere Search
**Tool:** tidk
- tidk searches for the canonical TTAGGG repeat across all scaffolds.
- Note: The script uses the `tidk_env` conda environment.
```
bash scripts/Telomere_centromere/tidk_search.sh
```
#### Centromere Search 
**Tool:** centroAnno
- centroAnno identifies candidate centromeric regions.
```
sbatch scripts/Telomere_centromere/centroAnno_HD.sh
```
- Python script used to generate the combined figure
```
python scripts/Telomere_centromere/centromere_telomere_plotting.py
```
**Output:** `figures_tables/chrom_repeats_map.pdf`

#### Annotation Stats Comparison
**Tools:** Liftoff GAG AGAT
- Take gene annotations from Nowak genome and map them onto HD genome using liftoff
```
bash scripts/GAG_stats/liftoff_Nowak_on_HD.sh 
```
- Keep features that landed on the 6 chromosomes and fix the phasing issue with the gff3 file
```
bash scripts/GAG_stats/prep_gff3.sh
```
- Modified GAG/src/stats_manager.py to prevent values from being rounded.
```
  def calculate_stat(self, stat):
        dividend_key = self.calc_stats_formulae[stat][0]
        divisor_key = self.calc_stats_formulae[stat][1]
        # Calculate for reference genome
        dividend = self.ref_stats[dividend_key]
        divisor = self.ref_stats[divisor_key]
        if divisor == 0:
            self.ref_stats[stat] = 0
        else:
            raw_value = float(dividend) / float(divisor)
            if "%" in stat:
                self.ref_stats[stat] = round(format_percent(raw_value),2) # edit 1 - added round()
            else:
                self.ref_stats[stat] = round(raw_value,2) # edit 2 - removed int
        # Calculate for modified genome
        dividend = self.alt_stats[dividend_key]
        divisor = self.alt_stats[divisor_key]
        if divisor == 0:
            self.alt_stats[stat] = 0
        else:
            raw_value = float(dividend) / float(divisor)
            if "%" in stat:
                self.alt_stats[stat] = round(format_percent(raw_value),2) # edit 3 - added round()
            else:
                self.alt_stats[stat] = round(raw_value,2) # edit 4 - removed int

    def summary(self):
        for stat in self.calc_stats:
            self.calculate_stat(stat)
        stats_order = [key for keys in [self.increment_stats, self.min_stats, self.max_stats, self.calc_stats] for key
                       in keys]
        if self.alt_is_empty():
            return format_columns(["Genome"], stats_order, [self.ref_stats], 5)
        else:
            return format_columns(["Reference Genome", "Modified Genome"], stats_order,
                                  [self.ref_stats, self.alt_stats], 5)
```
- Running to GAG to generate the stats for all the genomes
```
bash scripts/GAG_stats/gag_at_genome.sh 
```
- Getting the annotation comparison table (genome level)
```
conda activate r_env
Rscript scripts/GAG_stats/table.R HD_stats/genome.stats HD_Nowak_stats/genome.stats Nowak_lifted_6Chr/genome.stats HM_stats/genome.stats Annotation_stats_genome_level.csv
```
**Output:** `figures_tables/Annotation_stats_genome_level.csv`
- Comparing annotation stats at the isoform level for all the genomes
```
bash scripts/GAG_stats/gag_isoform.sh
```
- Getting the annotation comparison table (isoform level)
```
Rscript scripts/GAG_stats/table.R HD_stats_isoform/genome.stats HD_Nowak_stats_isoform/genome.stats Nowak_lifted_6Chr_isoform/genome.stats HM_stats_isoform/genome.stats Annotation_stats_isoform_level.csv
```
**Output:** `figures_tables/Annotation_stats_isoform_level.csv`
- Comparing H.diminuta (this study) with Nowak et al. genome lifted on H.diminuta (this study)
```
bash scripts/GAG_stats/compare_annotation.sh
```
**Output:** `figures_tables/HD_vs_Nowak_genome.txt` and `figures_tables/HD_vs_Nowak_isoform.txt`

