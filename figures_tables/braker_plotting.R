#!/usr/bin/env Rscript

# This script reads a Braker summary table and generates two separate plots:
# one for the number of predicted gene models, and one for transcript models.

## load all the packages 
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(ggbeeswarm)
})

## cli argument
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1){
  stop("Usage: Rscript braker_gene_transcript.R <input_file.txt> <output_dir>")
}

## extract inputs from terminal
input_file <- args[1]
output_dir <- args[2]

## load data 
braker_summary <- read.table(input_file,header = TRUE)

# Replace RNA_protein with RNA+protein in Input column
braker_summary$Input <- gsub("RNA_protein", "RNA+Protein", braker_summary$Input)

## check columns exist
required_cols <- c("Genome", "Input", "gene", "transcript")
missing_cols <- setdiff(required_cols, colnames(braker_summary))
if (length(missing_cols) > 0) {
  stop(paste("Missing columns in input file:", paste(missing_cols, collapse = ", ")))
}

## re-labeling the genome to match the table 1 naming

braker_summary$Genome[braker_summary$Genome == "HD"] <- "HD (this study)"
braker_summary$Genome[braker_summary$Genome == "HM"] <- "HM (Olson)"
braker_summary$Genome[braker_summary$Genome == "HD_Nowak"] <- "HD (Nowak)"


# Convert to factors
braker_summary$Genome <- as.factor(braker_summary$Genome)
braker_summary$Input <- as.factor(braker_summary$Input)

# Round functions
round_up <- function(x, base = 100) ceiling(x / base) * base
round_down <- function(x, base = 100) floor(x / base) * base

plot_metric <- function(metric_col) {
  y_min <- round_down(min(braker_summary[[metric_col]], na.rm = TRUE) - 200)
  y_max <- round_up(max(braker_summary[[metric_col]], na.rm = TRUE) + 200)
  
  # desired order
  desired_genome_order <- c("HD (this study)","HD (Nowak)","HM (Olson)")  
  braker_summary$Genome <- factor(braker_summary$Genome, levels = desired_genome_order)
  
  p <- ggplot(braker_summary, aes(x = Input, y = .data[[metric_col]], fill = Input)) +
    geom_boxplot() +
    geom_beeswarm(size = 2, color = "black", cex = 1, alpha = 0.8) +
    facet_grid(~Genome) +
    scale_fill_brewer(palette = "Set1") +
    scale_color_brewer(palette = "Set3") +
    scale_y_continuous(limits = c(y_min, y_max), breaks = seq(y_min, y_max, by = 300)) +
    labs(
      x = "Input Data Type",
      y = paste("Number of Predicted", tools::toTitleCase(metric_col), "Models")
    ) +
    theme_minimal(base_size = 16) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, color = "black"),
      axis.text.x = element_text(angle = 45, hjust = 1, color = "black"),
      axis.text.y = element_text(color = "black"),
      axis.title = element_text(color = "black"),
      legend.position = "top",
      legend.text = element_text(color = "black"),
      legend.title = element_text(color = "black"),
      strip.background = element_rect(fill = "skyblue", color = "gray70"),
      strip.text = element_text(face = "bold", color = "black")
    )
    
  
  base_name <- file.path(output_dir, paste0("Braker_", metric_col, "_comparison"))
  ggsave(paste0(base_name, ".pdf"), p, dpi = 600, width = 12, height = 10)
  ggsave(paste0(base_name, ".png"), p, dpi = 600, width = 12, height = 10)
  
  cat("Saved plots for:", metric_col, "\n")
}

# Plot for gene and transcript
plot_metric("gene")
plot_metric("transcript")
