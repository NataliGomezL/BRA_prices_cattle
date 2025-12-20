
# Template for Rstudio projects

This is a suggested template for working with Rstudio projects. 

To use this:
1. Do not git clone this project!
2. Rather, click on the green `Code` button, and `Download ZIP`:
3. Eventually, make it a new git repository  using `git init`


## folder organization

- Raw data should always be in `data_raw`. The origin of the data should be clearly stated:
   - if the data was manually downloaded or copy/pasted, include  a `SOURCE.txt` file stating the origin url, downlaod method, download time, etc
   - Ideally, R code should be used to download data. Such R code should be saved in `code_setup`, and numbered with a small number like `0_1_download_admin_boundaries.R`
- Any data created, transformed with the project should go either in `data_intermediary` or `data_final`
- Any figures or tables created within the project should go in `output/figures` or `output/tables`

## script organization

- scripts should be numbered:
  - `0_1`, `0_2`: scripts downlaoding data
  - `1_1`: scripts cleaning a dataset
  - `2_1`: scripts merging multiple datasets
  - `3_1`, `4_1`: scripts conducting exploratory analysis, visualization, etc
  - `888_aux_functions.R`: script containing only functions to be used repeatedlt in multiple scripts. Every function should start with an acronym taken from the script name:  `aux_extract_number` etc
 
Scripts should be:
 - in `code_setup` if they are mainly for downloading, cleaning, merging data
 - in `code_analysis` if they are mainly to visualize data, analyse data
 - exceptions: often, cleaning & merging data will require visualizing data (outliers, etc), the scripts should then rather be in `code_setup`

## coding principles

- whenever possible, use `tidyverse` tools rather than `base` tools: use `readr::read_csv()` rather than `read.csv()`
- follow the [`tidyverse` style guide: Tidyverse style guide](https://style.tidyverse.org/), in particular:
   - functions should use `lower_case_name()`
   - always add a newline after using the pipe `%>%` or the base pipe `|>`
   - the tidyverse pipe should be preferred to the `%>%` base pipe `|>`

## code organizaion snippets

Please format your document following the structure below. To ease this, add the so-called "snippets" below: you just need now to type `head_start` at the beginning of the document, eventually adding section headers by typing `section`. To add the Rstudio snippets below, instructions in https://docs.posit.co/ide/user/ide/guide/productivity/snippets.html say:

> Users can edit the built-in snippet definitions and even add snippets of their own via the `Edit Snippets` button in `Global Options -> Code`



```
snippet head_start
	#' ---
	#' Title: "A short description"
	#' Author: "Your name"
	#' Date: `r paste(Sys.Date())`
	#' ---
	
	library(tidyverse)

	################################
	#'## Read data
	################################

	dat1 <- read_rds("data_intermediary/...")

	################################
	#'## Prepare data
	################################

	################################
	#'## Visualization of data
	################################

	################################
	#'## Export data
	################################

	#write_rds(..., "data_intermediary/...")

	## save plots	
	# ggsave(..., height = 5, width = 8,
	#        filename = "output/figures/xxx")
```

```
snippet section
	################################
	#'## ${1:TITLE}
	################################
```
### git commands

1. Make sure to download this repo as zip, not with `git clone`!
2. Rename the folder name, and the .Rroj file to the local project name
3. Then locally, run:
   1. `git init --initial-branch=main`
   2. `git add .gitignore`
   3. `git add -f output/figures/.git_please_add_this_empty_folder output/tables/.git_please_add_this_empty_folder code_analysis/.git_please_add_this_empty_folder code_setup/.git_please_add_this_empty_folder data_raw/.git_please_add_this_empty_folder data_intermediary/.git_please_add_this_empty_folder data_final/.git_please_add_this_empty_folder`
   4. `git commit . -m "Initialize project: add main files and empty folders"`
   5. `git add *.Rproj`
   6. `git commit *.Rproj -m "Add Rstudio .Rproj file"`
