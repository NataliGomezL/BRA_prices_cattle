#' ---
#' Title: "Merge all prices into one large series"
#' Author: "Natali"
#' Date: 2025-12-17
#' ---

library(tidyverse)

################################
#'## Read data
################################

all_files <- list.files("data_raw/agrolink", full.names = TRUE)

all_files_df <- tibble(filename=basename(all_files),
                       full_path=all_files) %>% 
  mutate(data = map(all_files, read_csv))

read_csv(all_files_df$full_path)
################################
#'## Prepare data
################################

all_files_df

################################
#'## Visualize data
################################

################################
#'## Export data
################################

#write_rds(..., "data_intermediary/")

## save plots  
# ggsave(..., height = 5, width = 8,
#        filename = "output/figures/xxx")