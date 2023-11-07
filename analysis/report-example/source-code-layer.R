rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(scales)    # format
library(dplyr)     # loading dplyr explicitly is my guilty pleasure
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(magrittr)
# -- 2.Import only certain functions of a package into the search path.
import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("tidyr"    )# tidy data
requireNamespace("janitor"  )# tidy data
requireNamespace("dplyr"    )# Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"   )# For asserting conditions meet expected patterns.

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
# printed figures will go here:
prints_folder <- paste0("./analysis/report-example/prints/")
if(!file.exists(prints_folder)){dir.create(file.path(prints_folder))}

# ---- declare-functions -------------------------------------------------------


# ---- load-data ---------------------------------------------------------------
ds0 <- readr::read_rds("./data-public/raw/example-prosthetic-2.rds")
# ---- inspect-data-0 ------------------------------------------------------------
# ds0 %>% View() #
# ds0 %>% glimpse()
explore::describe_all(ds0)
# labelled::look_for(ds0)
# tableone::CreateTableOne(data = ds0)
ds0 %>% select(-id,-weight,-date) %>% tableone::CreateTableOne(data=.)
ds0 %>% select(-id,-weight,-date) %>% tableone::CreateTableOne(data=., strata = c("employed","gender"))

# ---- inspect-data-local -----------------------------------------------------
# this chunk is not sourced by the annotation layer, use a scratch pad
ds0 %>% glimpse() # notice it does not show up in the report

# ---- tweak-data-1 --------------------------------------------------------------
# derive data of state `ds1`
ds1 <-
  ds0 %>%
  rename(
    sex = gender # less biased term
  ) %>%
  mutate(
    male    = sex == "male"
    ,female = sex == "female"
    # ,caucasian  = race == "caucasian"
    # ,minority   = race == "minority"
    # ,aboriginal = race == "aboriginal"
    # ,employed_at_survey = employed == "employed"
  ) %>%
  mutate(
    year                = lubridate::year(date) %>% as.integer(),
    # yearmon             = tsibble::yearmonth, # not supported by look_for()
    # year_fiscal         = compute_fiscal_year(date),
    # quarter             = lubridate::quarter(date), # custom function, load from ./scripts/operational-functions.R
    # quarter_fiscal      = (quarter - 1),
    # quarter_fiscal      = ifelse(quarter_fiscal==0,4,quarter_fiscal)%>% as.integer(),
    # year_date           = as.Date(paste0(year,"-01-01")),
    # year_fiscal_date    = as.Date(paste0(year_fiscal,"-04-01")),
    # quarter_date        = paste(year,(quarter*3-1),"15", sep="-") %>% as.Date(),
    # quarter_fiscal_date = quarter_date,
  )

# ---- inspect-data-1 ----------------------------------------------------------
ds1 %>% select(sex) %>% labelled::lookfor()

# ---- tweak-data-2 ------------------------------------------------------------
ds2 <- 
  ds1 %>% 
  mutate(
    sex = factor(sex,c("male","female"),c("Men","Women"))
  )

labelled::var_label(ds2$sex) <- "Sex"

# ---- inspect-data-2 ----------------------------------------------------------
ds2 %>% select(sex) %>% labelled::lookfor()
# ---- table-1 -----------------------------------------------------------------
ds2 %>% 
  select(sex, employed) %>% 
  tableone::CreateTableOne(data=.,strata = "sex")

# ---- graph-1 -----------------------------------------------------------------
ds2 %>% 
  ggplot(aes(x=date,y = earnings, color=sex)) +
  geom_point()

# ---- graph-2 -----------------------------------------------------------------
ds2 %>% 
  ggplot(aes(x=employed,fill=sex)) +
  geom_bar()
# ---- save-to-disk ------------------------------------------------------------

# ---- publish ------------------------------------------------------------
path <- "./analysis/report-example/annotation-layer-Rmarkdown.Rmd"
rmarkdown::render(
  input = path ,
  output_format=c(
    "html_document"
    # "word_document"
    # "pdf_document"
  ),
  clean=TRUE
)
