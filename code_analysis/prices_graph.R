#' ---
#' Title: ""
#' Author: "Natali"
#' Date: 2026-01-05
#' ---

library(tidyverse)

###############
## Read data
##############

# From 0_5
all_data <- readRDS("data_intermediary/agrolink_prices.rds")

###############
## prep data
##############


all_data_prep <- all_data %>% 
  complete(product, state, date) %>%
  group_by(state, product) %>% 
  filter(!all(is.na(state_value))) %>% 
  ungroup()

all_data_prep


## check which outliers?
all_data_prep %>% 
  filter(product == "boi-gordo-15kg") %>% 
  group_by(state) %>% 
  summarise(min_value = min(state_value, na.rm = TRUE)) %>% 
  arrange(min_value)

all_data_prep %>% 
  filter(product == "boi-gordo-15kg") %>% 
  filter(state %in% c("RS", "PE", "CE")) %>% 
  ggplot(aes(x = date, y = state_value, color=state)) +
  geom_line() +
  geom_line(aes(y = national_value),
            color= "black",
            linewidth = 1.2)


## remove outliers 
all_data_prep_final <- all_data_prep %>% 
  filter(!state %in% c("RS", "PE", "CE") & product == "boi-gordo-15kg") %>% 
  group_by(product, date) %>%
  filter(!all(is.na(state_value))) %>%
  ungroup()
  
all_data_prep_final

mean_boi_gordo <- all_data_prep_final %>% 
  group_by(product, date) %>% 
  summarise(national_mean = mean(state_value, na.rm = TRUE)) %>% 
  ungroup()
mean_boi_gordo

###############
## Visu data
##############

plot <- ggplot() +
  geom_line(data = all_data_prep_final, 
            aes(x = date, y = state_value, group = state, color = "Other states"),
            linewidth = 0.5) +
  geom_line(data = mean_boi_gordo, 
            aes(x = date, y = national_mean, color = "Monthly mean"),
            linewidth = 1.1) +
  geom_line(data = all_data_prep_final %>% 
              filter(state == "PA"),
            aes(x = date, y = state_value, color = "Pará State"),
            linewidth = 1.1) +
  scale_color_manual(name = NULL,
                     breaks = c("Pará State", "Monthly mean", "Other states"),
                     values = c("Other states"  = "grey35",
                                "Monthly mean"  = "black",
                                "Pará State"    = "red"))+
  labs(y = 'State price (R$)',
       x = 'Date',
       title = 'Average monthly price of Boi gordo (15 kg) in the State of Pará, Brazil') +
  theme_minimal() +
  theme(legend.position = "bottom")

plot

