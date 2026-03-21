# nolint start
# AI agents must consult ./analysis/eda-1/eda-style-guide.md before making changes to this file.
# Composing Orchestra template — customize all {PLACEHOLDERS} before use.
# Mode: {TYPE} (EDA = explore with open mind | Report = synthesize prior findings)
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# ---- load-packages -----------------------------------------------------------
library(magrittr)    # pipes
library(ggplot2)     # graphs
library(forcats)     # factors
library(stringr)     # strings
library(lubridate)   # dates
library(labelled)    # labels
library(dplyr)       # data wrangling
library(tidyr)       # data reshaping
library(scales)      # format
library(janitor)     # tidy data
library(testit)      # assertions
library(fs)          # file system
library(arrow)       # parquet I/O

# ---- httpgd (VS Code interactive plots) ------------------------------------
if (requireNamespace("httpgd", quietly = TRUE)) {
  tryCatch({
    if (is.function(httpgd::hgd)) {
      httpgd::hgd()
    } else if (is.function(httpgd::httpgd)) {
      httpgd::httpgd()
    } else {
      httpgd::hgd()
    }
    message("httpgd started. Configure VS Code R extension to use it for plots.")
  }, error = function(e) {
    message("httpgd detected but failed to start: ", conditionMessage(e))
  })
} else {
  message("httpgd not installed. Install with: install.packages('httpgd')")
}

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R")      # project-level
base::source("./scripts/operational-functions.R")  # project-level
# base::source("./scripts/graphing/graph-presets.R") # Alberta Corporate Visual Identity colors

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/{NAME}/"
local_data <- paste0(local_root, "data-local/")

if (!fs::dir_exists(local_data)) { fs::dir_create(local_data) }

data_private_derived <- "./data-private/derived/{NAME}/"
if (!fs::dir_exists(data_private_derived)) { fs::dir_create(data_private_derived) }

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) { fs::dir_create(prints_folder) }

# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root, "local-functions.R")) # uncomment when needed

# ---- load-data ---------------------------------------------------------------
# Load Ellis parquet outputs
# Adjust paths based on which tables your report-contract.prompt.md specifies

# ds_client <- arrow::read_parquet("./data-private/derived/manipulation/client_roster.parquet")
# ds_support <- arrow::read_parquet("./data-private/derived/manipulation/support_by_year.parquet")
# ds_training <- arrow::read_parquet("./data-private/derived/manipulation/training_by_year.parquet")
# ds_assessment <- arrow::read_parquet("./data-private/derived/manipulation/assessment_by_year.parquet")

message("Data loaded. Uncomment the tables needed for this analysis.")

# ---- tweak-data-0 -----------------------------------------------------------
# General data transformations shared across all graph families

# ---- inspect-data-0 ---------------------------------------------------------
# Basic structure of loaded datasets
# ds_support %>% glimpse()
# ds_support %>% dim()

# ---- inspect-data-1 ---------------------------------------------------------
# Grain verification: confirm the unit of analysis
# ds_support %>%
#   group_by(person_oid, year) %>%
#   summarise(n = n(), .groups = "drop") %>%
#   filter(n > 1) %>%
#   nrow() # should be 0 if grain is person-year

# ---- data-context-tables -----------------------------------------------------
# Which tables and variables this analysis uses (from contract Data Sources)
# Populate during interview to make the Data Context section analysis-specific.
# cat("This analysis uses:\n")
# cat("  - support_by_year.parquet: person-year of financial support\n")
# cat("  - client_roster.parquet: person-level demographics\n")
# cat("\nKey variables: person_oid, year, client_type_code, program_class1\n")

# ---- data-context-person -----------------------------------------------------
# What the data looks like for a representative individual (1-2 people)
# example_oid <- ds_support %>%
#   count(person_oid) %>%
#   filter(n >= 3, n <= 8) %>%
#   slice_sample(n = 1) %>%
#   pull(person_oid)
# cat("Example person_oid:", example_oid, "\n\n")
# ds_support %>% filter(person_oid == example_oid) %>% print()

# ---- data-context-distributions ----------------------------------------------
# Distributions of key variables relevant to this analysis
# ds_support %>% count(program_class1) %>% arrange(desc(n))

# ---- g1-data-prep -----------------------------------------------------------
# Data preparation for first graph family
# Research question: {RQ1 from contract}

# g1_data <- ds_support %>%
#   # your data prep here

# ---- g1 ---------------------------------------------------------------------
# Primary visualization for first graph family
# g1_{descriptive_name} <- g1_data %>%
#   ggplot(aes(x = , y = )) +
#   geom_*() +
#   labs(
#     title = "",
#     subtitle = "Data source: {table_name}",
#     x = "",
#     y = ""
#   ) +
#   theme_minimal()
#
# ggsave(paste0(prints_folder, "g1_{descriptive_name}.png"),
#        g1_{descriptive_name}, width = 8.5, height = 5.5, dpi = 300)
# print(g1_{descriptive_name})

# ---- g2-data-prep -----------------------------------------------------------
# Data preparation for second graph family
# Research question: {RQ2 from contract}

# ---- g2 ---------------------------------------------------------------------
# Primary visualization for second graph family

# ---- g3-data-prep -----------------------------------------------------------
# Data preparation for third graph family
# Research question: {RQ3 from contract}

# ---- g3 ---------------------------------------------------------------------
# Primary visualization for third graph family

# ---- save-to-disk ------------------------------------------------------------
# Save any derived datasets for downstream use
# arrow::write_parquet(derived_data, paste0(data_private_derived, "descriptive_name.parquet"))
