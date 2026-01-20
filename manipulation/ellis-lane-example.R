#' ---
#' title: "Ellis Pattern Example"
#' author: "First Last"
#' date: "YYYY-MM-DD"
#' ---
#'
#' ============================================================================
#' ELLIS PATTERN: Data Transformation for Analysis-Ready Datasets
#' ============================================================================
#'
#' **Purpose**: Transform raw/staged data into clean, analysis-ready datasets.
#' Ellis is the "immigration processing center" - data arrives from many sources,
#' gets inspected, documented, standardized, and only then released for analysis.
#'
#' **The Ellis Island Metaphor**:
#' - Raw data = immigrants arriving from various origins
#' - Inspection = data validation and quality checks
#' - Processing = standardization and transformation
#' - Documentation = metadata, data dictionaries, CACHE-manifest
#' - Entry into system = analysis-ready datasets for downstream use
#'
#' **When to use Ellis Pattern**:
#' - After Ferry has staged data in CACHE
#' - When data needs semantic transformation before analysis
#' - When standardization across sources is required
#' - When data documentation (CACHE-manifest) is needed
#'
#' **Required Transformations**:
#' ✅ Column name standardization (janitor::clean_names)
#' ✅ Factor recoding with taxonomy (categorical standardization)
#' ✅ Data type/class standardization (numerics, dates, characters)
#' ✅ Missing data handling (explicit NA, imputation rules)
#' ✅ Derived analytical variables (calculated fields)
#' ✅ EDA-informed validation (minimal exploration to inform wrangling)
#'
#' **Input**: CACHE database (ferry staging), flat files, or parquet backups
#' **Output**: CACHE database (project schema), WAREHOUSE (archive), parquet files
#'
#' **Naming Convention**: {order}-ellis-{domain}.R
#' Example: 1-ellis-IS.R, 3-ellis-customer.R, 5-ellis-combined.R
#'
#' ============================================================================
#' THIS EXAMPLE: Transform mtcars from Ferry staging to analysis-ready
#' - Source: RESEARCH_PROJECT_CACHE_UAT._TEST.mtcars_raw (ferry output)
#' - Destination: RESEARCH_PROJECT_CACHE_UAT._TEST.mtcars_clean
#' - Parquet: ./data-private/derived/ellis/mtcars_analysis_ready.parquet
#' ============================================================================

#+ echo=F
# rmarkdown::render(input = "./manipulation/ellis-lane-example.R") # run to knit
# ---- setup -------------------------------------------------------------------
rm(list = ls(all.names = TRUE)) # Clear memory
cat("\014") # Clear console
cat("Working directory:", getwd(), "\n") # Verify root

# ---- load-packages -----------------------------------------------------------
# Ellis pattern: load what's needed for transformation and validation
library(magrittr)  # pipes
library(ggplot2)   # graphs for validation
library(dplyr)     # data wrangling
library(tidyr)     # data reshaping
library(forcats)   # factor handling
library(stringr)   # string manipulation
library(janitor)   # name cleaning
library(scales)    # formatting
library(fs)        # file system
requireNamespace("DBI")
requireNamespace("odbc")
requireNamespace("OuhscMunge")  # remotes::install_github("OuhscBbmc/OuhscMunge")
requireNamespace("arrow")
requireNamespace("lubridate") # dates (if needed)

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------
# Source (Ferry output in CACHE staging)
dsn_cache <- "RESEARCH_PROJECT_CACHE_UAT"
schema_source <- "_TEST"
table_source <- "mtcars_raw"

# Destination (CACHE project schema)
schema_dest <- "_TEST"
table_dest <- "mtcars_clean"

# File outputs
output_dir <- "./data-private/derived/ellis/"
if (!fs::dir_exists(output_dir)) fs::dir_create(output_dir, recursive = TRUE)

# Prints folder for diagnostic graphs
prints_folder <- "./manipulation/ellis-prints/"
if (!fs::dir_exists(prints_folder)) fs::dir_create(prints_folder, recursive = TRUE)

# Timing
report_render_start_time <- Sys.time()

# ---- declare-functions -------------------------------------------------------
# Helper: Summary of missing values
summarize_missing <- function(df) {
  df %>%
    summarise(across(everything(), ~sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    mutate(missing_pct = round(missing_count / nrow(df) * 100, 1)) %>%
    filter(missing_count > 0) %>%
    arrange(desc(missing_count))
}

# Helper: Factor distribution summary
summarize_factors <- function(df) {
  df %>%
    select(where(is.factor)) %>%
    # Convert all factors to character to avoid type incompatibility between factor and ordered
    mutate(across(everything(), as.character)) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "level") %>%
    count(variable, level) %>%
    arrange(variable, desc(n))
}

# ==============================================================================
# SECTION 1: DATA IMPORT
# ==============================================================================

# ---- load-data ---------------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 1: DATA IMPORT\n")
cat(strrep("=", 60), "\n")

# Primary: Load from Ferry output in CACHE
cnn <- DBI::dbConnect(odbc::odbc(), dsn = dsn_cache)

sql <- paste0("SELECT * FROM [", schema_source, "].[", table_source, "]")
ds0 <- DBI::dbGetQuery(cnn, sql)

DBI::dbDisconnect(cnn)

cat("📥 Loaded from CACHE:", nrow(ds0), "rows,", ncol(ds0), "columns\n")
cat("   Source:", paste(dsn_cache, schema_source, table_source, sep = "."), "\n")

# ---- load-data-parquet-alternative -------------------------------------------
# ALTERNATIVE: Load from parquet backup (if database unavailable)
# 
# parquet_source <- "./data-private/derived/ferry/mtcars_raw.parquet"
# ds0 <- arrow::read_parquet(parquet_source)
# cat("📥 Loaded from parquet:", nrow(ds0), "rows\n")

# ---- inspect-data-0 ----------------------------------------------------------
cat("\n📊 Initial Data Inspection:\n")
cat("  - Dimensions:", nrow(ds0), "x", ncol(ds0), "\n")
cat("  - Columns:", paste(names(ds0), collapse = ", "), "\n")
glimpse(ds0)

# ==============================================================================
# SECTION 2: ELLIS TRANSFORMATIONS
# ==============================================================================

# ---- tweak-data-1-names ------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 2: ELLIS TRANSFORMATIONS\n")
cat(strrep("=", 60), "\n")

# Step 1: Standardize column names
cat("\n🔧 Step 1: Column name standardization\n")
ds1 <- ds0 %>%
  janitor::clean_names()

cat("   Before:", paste(names(ds0)[1:5], collapse = ", "), "...\n")
cat("   After: ", paste(names(ds1)[1:5], collapse = ", "), "...\n")

# ---- tweak-data-2-factors ----------------------------------------------------
# Step 2: Factor recoding with taxonomy
cat("\n🔧 Step 2: Factor recoding (taxonomy application)\n")

ds2 <- ds1 %>%
  mutate(
    # Transmission type: am (0 = automatic, 1 = manual)
    transmission = factor(am, 
                          levels = c(0, 1), 
                          labels = c("Automatic", "Manual")),
    
    # Engine type: vs (0 = V-shaped, 1 = straight)
    engine_type = factor(vs, 
                         levels = c(0, 1), 
                         labels = c("V-shaped", "Straight")),
    
    # Cylinder count: as ordered factor
    cylinder_count = factor(cyl, 
                            levels = c(4, 6, 8), 
                            labels = c("4-cyl", "6-cyl", "8-cyl"),
                            ordered = TRUE),
    
    # Gear count: as ordered factor
    gear_count = factor(gear,
                        levels = c(3, 4, 5),
                        labels = c("3-gear", "4-gear", "5-gear"),
                        ordered = TRUE)
  )

cat("   Created factors: transmission, engine_type, cylinder_count, gear_count\n")

# ---- tweak-data-3-derived ----------------------------------------------------
# Step 3: Derived analytical variables
cat("\n🔧 Step 3: Derived analytical variables\n")

ds3 <- ds2 %>%
  mutate(
    # Power-to-weight ratio (performance metric)
    power_to_weight = round(hp / wt, 2),
    
    # Efficiency category based on mpg
    efficiency_category = case_when(
      mpg >= 25 ~ "High",
      mpg >= 18 ~ "Medium",
      mpg >= 15 ~ "Low",
      TRUE ~ "Very Low"
    ) %>% factor(levels = c("Very Low", "Low", "Medium", "High"), ordered = TRUE),
    
    # Displacement per cylinder
    disp_per_cyl = round(disp / cyl, 1)
  )

cat("   Created: power_to_weight, efficiency_category, disp_per_cyl\n")

# ---- tweak-data-4-missing ----------------------------------------------------
# Step 4: Missing data handling
# (mtcars has no missing values, but showing the pattern)
cat("\n🔧 Step 4: Missing data assessment\n")

missing_summary <- summarize_missing(ds3)
if (nrow(missing_summary) == 0) {
  cat("   ✅ No missing values detected\n")
} else {
  cat("   ⚠️  Missing values found:\n")
  print(missing_summary)
  # Example handling (uncomment if needed):
  # ds3 <- ds3 %>%
  #   mutate(
  #     some_var = replace_na(some_var, median(some_var, na.rm = TRUE))
  #   )
}

# ---- tweak-data-5-types ------------------------------------------------------
# Step 5: Data type verification
cat("\n🔧 Step 5: Data type verification\n")

ds4 <- ds3 %>%
  mutate(
    # Ensure numeric types are correct
    across(c(mpg, disp, hp, drat, wt, qsec), as.numeric),
    # Ensure integer types
    across(c(cyl, vs, am, gear, carb), as.integer)
  )

# Final analysis-ready dataset
ds_clean <- ds4
cat("   ✅ Data types verified\n")
cat("   Final dataset:", nrow(ds_clean), "rows,", ncol(ds_clean), "columns\n")

# ==============================================================================
# SECTION 3: VALIDATION (Minimal EDA)
# ==============================================================================

# ---- validate-summary --------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 3: VALIDATION (Minimal EDA)\n")
cat(strrep("=", 60), "\n")

# Factor distributions
cat("\n📋 Factor Distributions:\n")
factor_summary <- summarize_factors(ds_clean)
print(factor_summary)

# Numeric summary for key variables
cat("\n📋 Key Variable Summary:\n")
ds_clean %>%
  select(mpg, hp, wt, power_to_weight) %>%
  summary() %>%
  print()

# ---- g1-data-prep ------------------------------------------------------------
# Graph family g1: Efficiency distribution validation
# Purpose: Verify efficiency_category assignment makes sense with mpg distribution
cat("\n📊 Preparing validation graph family (g1)...\n")

g1_data <- ds_clean %>%
  group_by(efficiency_category) %>%
  summarise(
    n = n(),
    avg_mpg = mean(mpg),
    min_mpg = min(mpg),
    max_mpg = max(mpg),
    .groups = "drop"
  )

# ---- g1 ----------------------------------------------------------------------
# g1: Histogram showing mpg distribution with efficiency category cutoffs
g1_mpg_distribution <- ds_clean %>%
  ggplot(aes(x = mpg, fill = efficiency_category)) +
  geom_histogram(bins = 12, alpha = 0.8, color = "white") +
  geom_vline(xintercept = c(15, 18, 25), linetype = "dashed", alpha = 0.5) +
  scale_fill_viridis_d(option = "plasma", end = 0.9) +
  labs(
    title = "MPG Distribution by Efficiency Category",
    subtitle = "Validation: Verify category cutoffs align with distribution",
    x = "Miles per Gallon",
    y = "Count",
    fill = "Category"
  ) +
  theme_minimal()

ggsave(paste0(prints_folder, "g1_mpg_efficiency_validation.png"),
       g1_mpg_distribution, width = 8.5, height = 5.5, dpi = 300)
cat("   Saved: g1_mpg_efficiency_validation.png\n")

# ---- g1a ---------------------------------------------------------------------
# g1a: Boxplot variant showing category ranges
g1a_efficiency_boxplot <- ds_clean %>%
  ggplot(aes(x = efficiency_category, y = mpg, fill = efficiency_category)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, size = 2) +
  scale_fill_viridis_d(option = "plasma", end = 0.9) +
  labs(
    title = "MPG Range by Efficiency Category",
    subtitle = "Validation: Check for outliers and category overlap",
    x = "Efficiency Category",
    y = "Miles per Gallon"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(paste0(prints_folder, "g1a_efficiency_boxplot.png"),
       g1a_efficiency_boxplot, width = 8.5, height = 5.5, dpi = 300)
cat("   Saved: g1a_efficiency_boxplot.png\n")

# ---- validate-integrity ------------------------------------------------------
cat("\n✅ Validation Summary:\n")
cat("   - Records transformed:", nrow(ds_clean), "\n")
cat("   - New factors created:", sum(sapply(ds_clean, is.factor)), "\n")
cat("   - Derived variables: power_to_weight, efficiency_category, disp_per_cyl\n")
cat("   - Diagnostic plots saved to:", prints_folder, "\n")

# ==============================================================================
# SECTION 4: SAVE TO CACHE (Database)
# ==============================================================================

# ---- save-to-cache-mssql -----------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 4: SAVE TO CACHE\n")
cat(strrep("=", 60), "\n")

# Write analysis-ready data to CACHE (project schema)
OuhscMunge::upload_sqls_odbc(
  d = ds_clean,
  schema_name = schema_dest,     # _TEST for demonstration; P{YYYYMMDD} for projects
  table_name = table_dest,       # mtcars_clean (analysis-ready)
  dsn_name = dsn_cache,          # RESEARCH_PROJECT_CACHE_UAT
  clear_table = TRUE,            # TRUE = delete if exists
  create_table = TRUE            # TRUE = create if not exists
)
cat("✅ Saved to CACHE:", paste(dsn_cache, schema_dest, table_dest, sep = "."), "\n")

# ---- save-to-cache-sqlite ----------------------------------------------------
# ALTERNATIVE: SQLite output
# 
# sqlite_path <- "./data-private/derived/ellis/cache.sqlite"
# cnn_sqlite <- DBI::dbConnect(RSQLite::SQLite(), sqlite_path)
# DBI::dbWriteTable(cnn_sqlite, "mtcars_clean", ds_clean, overwrite = TRUE)
# DBI::dbDisconnect(cnn_sqlite)
# cat("✅ SQLite saved to:", sqlite_path, "\n")

# ---- save-to-warehouse -------------------------------------------------------
# OPTIONAL: Archive to WAREHOUSE (long-term storage)
# Uncomment when Ellis is stabilized and verified
#
# dsn_warehouse <- "RESEARCH_PROJECT_WAREHOUSE"
# cnn_wh <- DBI::dbConnect(odbc::odbc(), dsn = dsn_warehouse)
# DBI::dbWriteTable(cnn_wh, 
#                   DBI::Id(schema = schema_dest, table = table_dest),
#                   ds_clean, 
#                   overwrite = TRUE)
# DBI::dbDisconnect(cnn_wh)
# cat("✅ Archived to WAREHOUSE\n")

# ==============================================================================
# SECTION 5: SAVE TO PARQUET
# ==============================================================================

# ---- save-to-parquet ---------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 5: SAVE TO PARQUET\n")
cat(strrep("=", 60), "\n")

parquet_path <- file.path(output_dir, "mtcars_analysis_ready.parquet")
arrow::write_parquet(ds_clean, parquet_path)
cat("✅ Parquet saved:", parquet_path, "\n")

# ==============================================================================
# SECTION 6: CACHE-MANIFEST (AI Generation)
# ==============================================================================

# ---- cache-manifest-placeholder ----------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SECTION 6: CACHE-MANIFEST\n")
cat(strrep("=", 60), "\n")

# TO AI COPILOT: Generate CACHE-manifest.md for this Ellis output.
# 
# Include in the manifest:
# - Dataset name and location (CACHE table + parquet path)
# - Source data (Ferry origin)
# - Record count and column inventory
# - Transformations applied (name cleaning, factors, derived vars)
# - Factor levels with descriptions (taxonomy)
# - Data types for each column
# - Data quality notes (missing values, validation results)
# - Usage notes for downstream analysts
# - Generation timestamp and script reference

cat("📝 CACHE-manifest generation: Invoke AI with prompt above\n")
cat("   Target: ./data-public/metadata/CACHE-manifest.md\n")

# ==============================================================================
# SECTION 7: SESSION INFO
# ==============================================================================

# ---- session-info ------------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SESSION INFO\n")
cat(strrep("=", 60), "\n")

report_duration <- difftime(Sys.time(), report_render_start_time, units = "secs")
cat("\n⏱️  Ellis completed in", round(as.numeric(report_duration), 1), "seconds\n")
cat("📅 Executed:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("👤 User:", Sys.info()["user"], "\n")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::session_info()
} else {
  sessionInfo()
}

# ---- publish -----------------------------------------------------------------
# OPTIONAL: Render as HTML report for documentation
# Uncomment to generate standalone report from this R script
#
# rmarkdown::render(
#   input = "./manipulation/ellis-lane-example.R",
#   output_format = "html_document",
#   output_dir = "./manipulation/",
#   clean = TRUE
# )

