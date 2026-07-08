#!/usr/bin/env Rscript

## Script for generating a gfastats summary table from multiple stats.txt files
## Usage:
##   Rscript gfastats_table.R <output.csv> <names> <file1> <file2> ...


suppressPackageStartupMessages(library(dplyr))

## function to parse a single gfastats file 
parse_gfastats_table <- function(file_path) {
  lines <- readLines(file_path)[-1]
  split_data <- strsplit(lines, ":\\s*")
  clean_table <- do.call(rbind, lapply(split_data, function(x) {
    key <- x[1]
    value <- paste(x[-1], collapse = ":")
    c(Metric = trimws(key), Value = trimws(value))
  })) %>% as.data.frame(stringsAsFactors = FALSE)
  colnames(clean_table) <- c("Metric", "Value")
  return(clean_table)
}

## Main function
generate_gfastats_table <- function(file_paths, output_file, sample_names = NULL) {

  if (length(file_paths) < 1) stop("Please provide at least one gfastats file path.")

  if (is.null(sample_names) || length(sample_names) == 0 || all(sample_names == "")) {
    sample_names <- tools::file_path_sans_ext(basename(file_paths))
  }
  if (length(sample_names) != length(file_paths)) {
    stop("Number of sample names must match number of input files.")
  }

  ## Parse each file
  parsed_list <- lapply(seq_along(file_paths), function(i) {
    tbl <- parse_gfastats_table(file_paths[i])
    colnames(tbl) <- c("Metric", sample_names[i])
    tbl
  })

  ## Combine all tables by Metric
  combined <- Reduce(function(x, y) full_join(x, y, by = "Metric"), parsed_list)
  combined <- combined %>% tibble::column_to_rownames(var = "Metric")

  ## Select important rows
  rows_to_select <- c("# scaffolds", "Total scaffold length", "Average scaffold length",
                      "Scaffold N50", "Scaffold auN", "Largest scaffold", "Smallest scaffold",
                      "# contigs", "Total contig length", "Average contig length",
                      "Contig N50", "Contig auN", "Contig L50", "Largest contig",
                      "Smallest contig", "# gaps in scaffolds", "Total gap length in scaffolds",
                      "Average gap length in scaffolds", "Largest gap in scaffolds","GC content %")

  rows_present <- rows_to_select[rows_to_select %in% rownames(combined)]
  gfstats_table <- combined[rows_present, , drop = FALSE]

  ## Convert bp to Mb for selected rows
  rows_to_divide <- c("Total scaffold length", "Average scaffold length", "Scaffold N50",
                      "Scaffold auN", "Largest scaffold", "Total contig length",
                      "Average contig length", "Contig N50", "Contig auN",
                      "Largest contig")

  gfstats_table[] <- lapply(gfstats_table, as.numeric)
  div_rows <- rownames(gfstats_table) %in% rows_to_divide
  gfstats_table[div_rows, ] <- gfstats_table[div_rows, ] / 1e6
  gfstats_table <- round(gfstats_table, 2)

  ## Add (bp) / (Mb) suffixes
  add_bp <- c("Smallest scaffold", "Smallest contig", "Total gap length in scaffolds",
              "Average gap length in scaffolds", "Largest gap in scaffolds")
  add_Mb <- c("Total scaffold length", "Average scaffold length", "Scaffold N50",
              "Scaffold auN", "Largest scaffold", "Total contig length",
              "Average contig length", "Contig N50", "Contig auN",
              "Largest contig")

  rn <- rownames(gfstats_table)
  rn[rn %in% add_bp] <- paste0(rn[rn %in% add_bp], " (bp)")
  rn[rn %in% add_Mb] <- paste0(rn[rn %in% add_Mb], " (Mb)")
  rownames(gfstats_table) <- rn

  ## better row renames
  rename_map <- c("# scaffolds" = "Scaffolds",
                  "# contigs"   = "Contigs",
                  "# gaps in scaffolds" = "Gaps in scaffolds")
  for (old in names(rename_map)) {
    rownames(gfstats_table)[rownames(gfstats_table) == old] <- rename_map[[old]]
  }

  ## Write output
  out_dir <- dirname(output_file)
  if (nzchar(out_dir) && !dir.exists(out_dir)) {
    dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  }
  write.csv(gfstats_table, output_file)
  message("Wrote table to: ", output_file)

  invisible(gfstats_table)
}

## interface
if (sys.nframe() == 0) {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) < 3) {
    cat("Usage: Rscript gfastats_table.R <output.csv> <names> <file1> <file2> ...\n")
    cat('  <names> is a comma-separated string, or "" to auto-use filenames.\n')
    quit(status = 1)
  }

  output_file  <- args[1]
  names_arg    <- args[2]
  file_paths   <- args[-(1:2)]

  sample_names <- if (nzchar(names_arg)) trimws(strsplit(names_arg, ",")[[1]]) else NULL

  generate_gfastats_table(
    file_paths   = file_paths,
    output_file  = output_file,
    sample_names = sample_names
  )
}
