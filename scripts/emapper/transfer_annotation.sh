#!/bin/bash

## script to transfer the annotation
## files
input_file="/scratch/skc49482/HD_assembly/results/functional_annotation/emapper/eggnog_mapper_HD.emapper.decorated.gff"
output_file="/scratch/skc49482/HD_assembly/results/functional_annotation/emapper/fixed_annotation.gff3"

## running script
python transfer_annotation.py -i $input_file -o $output_file

echo "Job Finished!!!"


