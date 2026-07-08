## Script to plot the Repeat stats for all three genomes (HD,HM,HD_Nowak)
# load library
library(ggplot2)
library(stringr)
library(dplyr)
library(tidyr)
library(flextable)

## write a function to save the cleaned repeat stats output 
clean_repeatmask_summary <- function(input_file,output_file){
  lines <- readLines(input_file)
  eq_line <- grep("^=+$", lines) # find == lines
  
  # extract summary lines
  start_line <- eq_line[2] + 1
  end_line <- eq_line[3] - 1
  summary_lines <- lines[start_line:end_line]
  
  # clean unnecessary lines 
  summary_lines <- summary_lines[!grepl("^[-=]+$", summary_lines)]
  summary_lines <- summary_lines[summary_lines != ""]
  summary_lines <- summary_lines[-c(1, 2)]  # Remove headers
  
  results <- list()
  
  for (line in summary_lines) {
    # Clean "bp", "%" and extra spaces
    line_clean <- gsub("bp", "", line)
    line_clean <- gsub("%", "", line)
    line_clean <- trimws(line_clean)
    
    # Split based on 2 or more spaces
    parts <- strsplit(line_clean, " {2,}")[[1]]
    
    category <- parts[1]
    values <- parts[-1]
    
    results[[length(results) + 1]] <- c(category, values)
  }
  
  # Build the dataframe
  df <- do.call(rbind, results)
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  colnames(df) <- c("Repeat Types", "Number of elements", "Coverage(bp)", "%Genome")
  
  # Clean specific text patterns
  df$`Repeat Types` <- gsub(":", "", df$`Repeat Types`)
  df$`Repeat Types`[df$`Repeat Types` == "Other (Mirage,"] <- "Other (Mirage,P-element, Transib)"
  df <- df[df$`Repeat Types` != "P-element, Transib)", ]
  
  # Set row names and remove the first column
  rownames(df) <- df[[1]]
  df <- df[, -1]
  df$`Coverage(bp)` <- gsub("bp", "", df$`Coverage(bp)`)
  write.csv(df, output_file, row.names = TRUE)
  return(df)
}

## run it for three genomes 
HD <- clean_repeatmask_summary(input_file = "data/Repeat_stats/HD_genome.fasta.tbl",output_file = "data/Repeat_stats/HD_cleaned.csv")
HM <- clean_repeatmask_summary(input_file = "data/Repeat_stats/HM_NCBI_genome.fasta.tbl",output_file = "data/Repeat_stats/HM_cleaned.tbl")
HD_Nowak <- clean_repeatmask_summary(input_file = "data/Repeat_stats/HD_Nowak.fasta.tbl",output_file = "data/Repeat_stats/HD_Nowak_cleaned.csv")

## Manually fixed the "Total interspersed repeats"
HD["Total interspersed repeats",] <- c("-","52400259","28.09")
HM["Total interspersed repeats",] <- c("-","32756615","19.39")
HD_Nowak["Total interspersed repeats",] <- c("-","40617056","22.94")

## get the Total interspersed repeats first column value for HD
rows_to_sum <- c("Retroelements","Unclassified","DNA transposons")
sum_value_HD <- sum(as.numeric(HD[rows_to_sum, 1]), na.rm = TRUE)
HD["Total interspersed repeats", 1] <- sum_value_HD

## get the Total interspersed repeats first column value for HM
rows_to_sum <- c("Retroelements","Unclassified","DNA transposons")
sum_value_HM <- sum(as.numeric(HM[rows_to_sum, 1]), na.rm = TRUE)
HM["Total interspersed repeats", 1] <- sum_value_HM

## get the Total interspersed repeats first column value for HD_Nowak
rows_to_sum <- c("Retroelements","Unclassified","DNA transposons")
sum_value_HD_Nowak <- sum(as.numeric(HD_Nowak[rows_to_sum, 1]), na.rm = TRUE)
HD_Nowak["Total interspersed repeats", 1] <- sum_value_HD_Nowak


## Select only relevant rows
selected_repeat_types <- c("Total interspersed repeats","Unclassified","Retroelements","DNA transposons")
HD_selected <- HD[rownames(HD) %in% selected_repeat_types, ]
HM_selected <- HM[rownames(HM) %in% selected_repeat_types, ]
HD_Nowak_selected <- HD_Nowak[rownames(HD_Nowak) %in% selected_repeat_types, ]


## for plotting the bar chart
HD_plot <- HD_selected %>% 
  select("%Genome") %>% 
  mutate(Dataset = "HD (this study)", Type = rownames(HD_selected))

HM_plot <- HM_selected %>% 
  select("%Genome") %>% 
  mutate(Dataset = "HM (Olson)", Type = rownames(HM_selected))

HD_Nowak_plot <- HD_Nowak_selected %>% 
  select("%Genome") %>% 
  mutate(Dataset = "HD (Nowak)",Type = rownames(HD_Nowak_selected))


combined_df <- bind_rows(HD_Nowak_plot,HD_plot,HM_plot)
combined_df$`%Genome` <- as.numeric(combined_df$`%Genome`)
combined_df$Dataset <- factor(combined_df$Dataset, levels = c("HD (this study)","HD (Nowak)","HM (Olson)"))
combined_df$Type <- factor(combined_df$Type, levels = c("Total interspersed repeats","Unclassified","Retroelements","DNA transposons"))
# plot
repeat_barPlot <- ggplot(combined_df, aes(x = Type, y = `%Genome`, fill = Dataset)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Bar Plot of %Genome", x = "Repeat Type", y = "%Genome") +
  theme_minimal() +
  scale_y_continuous(
    breaks = scales::pretty_breaks(n = 5),   
    labels = scales::number_format(accuracy = 1)  
  ) +
  theme(axis.text.x = element_text(angle = 30,hjust = 1, vjust = 1, size = 12,color = "black"),
        axis.text.y = element_text(size = 12,color = "black"),
        axis.title = element_text(size = 14, face = "bold",color = "black"),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5,color = "black"),
        legend.title = element_text(size = 12, face = "bold",color = "black"),
        legend.text = element_text(size = 12,color = "black"),
        panel.grid.major.x = element_blank(),  
        panel.grid.minor = element_blank()
  ) +
  geom_text(aes(label = round(`%Genome`, 2)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 5)

ggsave("scripts/final_table_plots/Repeat_plot.pdf",repeat_barPlot, dpi = 600, width = 12, height = 10)



### making final table 
HD_selected$Type <- rownames(HD_selected)
HD_Nowak_selected$Type <- rownames(HD_Nowak_selected)
HM_selected$Type <- rownames(HM_selected)

combined_table <- HD_selected %>% 
  left_join(HD_Nowak_selected,by = "Type",suffix = c("A", "B")) %>% 
  left_join(HM_selected,by = "Type")

combined_table <- combined_table %>% relocate(Type)
combined_table$Type <- factor(combined_table$Type,levels = c("Total interspersed repeats","Unclassified","Retroelements","DNA transposons"))
combined_table <- combined_table %>% arrange(Type)

header_df <- tibble(
  col_keys = names(combined_table),
  MainHeader = c("Type", "HD (this study)", "HD (this study)", "HD (this study)", "HD (Nowak)", "HD (Nowak)", "HD (Nowak)", "HM (Olson)", "HM (Olson)","HM (Olson)"),
  SubHeader = c("Type", "# of elements","Coverage (bp)","% Genome","# of elements","Coverage (bp)","% Genome","# of elements","Coverage (bp)","% Genome")
)

flextable(combined_table) %>%
  set_header_df(mapping = header_df, key = "col_keys") %>%
  merge_v(part = "header") %>%
  merge_h(part = "header") %>%
  theme_box() %>%
  align(align = "center", part = "header") %>%
  autofit()

write.csv(combined_table, file = "scripts/final_table_plots/combined_table_repeatStats.csv", row.names = FALSE)
