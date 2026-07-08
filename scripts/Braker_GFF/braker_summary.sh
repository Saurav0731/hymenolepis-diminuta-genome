#!/usr/bin/env bash
printf "Genome\tInput\tReplicate\tgene\ttranscript\n"
for genome in HD HD_Nowak HM; do
  [[ -d $genome ]] || continue
  for input in Protein RNA RNA_protein; do
    [[ -d $genome/$input ]] || continue
    for rep in "$genome/$input"/rep_*; do
      [[ -d $rep ]] || continue
      file="$rep/braker_run.txt"
      g="NA"; t="NA"
      if [[ -f $file ]]; then
        g=$(awk '$2=="gene" {print $1; exit}' "$file")
        t=$(awk '$2=="transcript" {print $1; exit}' "$file")
        [[ -z $g ]] && g="NA"
        [[ -z $t ]] && t="NA"
      fi
      printf "%s\t%s\t%s\t%s\t%s\n" "$genome" "$input" "$(basename $rep)" "$g" "$t"
    done
  done
done
