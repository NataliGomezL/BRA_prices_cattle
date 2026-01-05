#' ---
#' Title: ""
#' Author: "Natali"
#' Date: 2025-12-17
#' ---

library(httr2)
library(rvest)
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(purrr)
library(tidyr)
library(glue)

################################
#'## Read data
################################

if(!dir.exists("data_raw/agrolink")) dir.create("data_raw/agrolink")

#states of interest 
states_all <- c("RO", "AC", "AM", "RR", "PA", "AP", "TO", "MA", "PI", "CE", 
                "RN", "PB", "PE", "AL", "SE", "BA", "MG", "ES", "RJ", "SP", "PR", 
                "SC", "RS", "MS", "MT", "GO", "DF")

# products of interets
product_all <- c("boi-gordo-15kg", "leite-1l", "novilha-gorda-15kg", "soja-em-grao-sc-60kg", "vaca-gorda-15kg")


################################
#'## Clean data
################################

# create a function to download all data of interest 

download_table <- function(state, product) {
  
  url <- glue::glue("https://www.agrolink.com.br/cotacoes/historico/{tolower(state)}/{product}")
  
  resp <- request(url) |>
    req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36") |>
    req_perform()
  
  wp <- read_html(resp_body_string(resp))
  tabs <- html_table(wp, fill = TRUE)
  
  list(state = state,
       product = product,
       url = as.character(url),
       table = if (length(tabs) > 0) tabs[[1]] else NULL)
}

# try with one
raw_obj <- download_table("rs", "vaca-gorda-15kg")
raw_obj

# Create a function to clean data set

clean_table <- function(obj) {
  
  if (is.null(obj$table)) return(NULL)
  
  df <- obj$table
  
  needed <- c("Mês/Ano", "Estadual", "Nacional")
  if (!all(needed %in% names(df))) return(NULL)
  
  df %>%
    dplyr::mutate(
      
      # force consistent types across all pages
      `Mês/Ano` = as.character(`Mês/Ano`),
      Estadual = as.character(Estadual),
      Nacional = as.character(Nacional),
      
      mes_ano_chr = stringr::str_squish(as.character(`Mês/Ano`)),
      date = suppressWarnings(lubridate::dmy(paste0("01/", mes_ano_chr))),
      
      state_value = readr::parse_number(as.character(Estadual),
                                        locale = readr::locale(decimal_mark = ",")),
      
      national_value = readr::parse_number(as.character(Nacional),
                                           locale = readr::locale(decimal_mark = ",")),
      state = obj$state,
      
      product = obj$product,
      
      url = obj$url) %>%
    
    dplyr::select(`Mês/Ano`, date,
                  Estadual, state_value,
                  Nacional, national_value,
                  state, product, url)
}

# try with one 
df1 <- clean_table(raw_obj)
df1

######################
# Run all
#######################

# Apply to all states × products
results <- crossing(state = states_all,
                    product = product_all) %>%
  mutate(raw  = map2(state, product, download_table),
         data = map(raw, clean_table))

# Combine all cleaned tables
all_data <- results %>%
  pull(data) %>%
  discard(is.null) %>%
  bind_rows()

all_data

######################
# Quick checks
#######################

# how many rows per combination
summary_results <- results %>%
  mutate(n = map_int(data, ~ if (is.null(.x)) 0L else nrow(.x))) %>%
  arrange(n)
summary_results

# inspect a zero-row case
one <- results %>% filter(map_int(data, ~ if (is.null(.x)) 0L else nrow(.x)) == 0) %>% slice(1)
one

#########################
# Save outputs
#######################

saveRDS(all_data, "data_intermediary/agrolink_prices.rds", compress = "xz")
