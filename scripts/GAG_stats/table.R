#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop(
    "Usage:\n",
    "  Rscript make_annotation_table.R <stats1> <stats2> ... <output.csv>\n\n"
  )
}

# Last argument is output file
output_csv <- tail(args, 1)

# All others are input stats files
stats_paths <- args[-length(args)]

# Function to read a single stats file
read_stats_file <- function(filepath) {
  lines <- readLines(filepath)
  data_lines <- lines[-c(1, 2)]
  
  split_lines <- strsplit(trimws(data_lines), "\\s{2,}")
  descriptions <- sapply(split_lines, `[`, 1)
  descriptions <- gsub(",", "", descriptions)
  values <- sapply(split_lines, `[`, 2)
  
  df <- data.frame(values, row.names = descriptions, stringsAsFactors = FALSE)
  return(df)
}

# Read and merge all stats files
df_list <- lapply(stats_paths, read_stats_file)
merged_stats <- do.call(cbind, df_list)

# Set column names from file names
colnames(merged_stats) <- basename(dirname(stats_paths))

# Write output
write.csv(merged_stats, output_csv, quote = FALSE)

message("Annotation comparison table written to: ", output_csv)
