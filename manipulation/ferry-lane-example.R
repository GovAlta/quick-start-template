#' ---
#' title: "Ferry Pattern Example"
#' author: "First Last"
#' date: "YYYY-MM-DD"
#' ---
#'
#' ============================================================================
#' FERRY PATTERN: Data Transport with Minimal Transformation
#' ============================================================================
#'
#' **Purpose**: Transport data between storage locations with minimal/zero 
#' semantic transformation. Ferry is a "cargo ship" that moves data intact.
#'
#' **When to use Ferry Pattern**:
#' - Moving data from external databases to project CACHE
#' - Consolidating tables from multiple servers into one location
#' - Creating staging area for Ellis processing
#' - When source data needs to be preserved as-is before transformation
#'
#' **Three Modalities**:
#' 1. FULL TRANSPORT: SELECT * → R → CACHE (when source size is manageable)
#' 2. FILTERED/AGGREGATED TRANSPORT: SQL-side reduction → R → CACHE (when source needs reduction)
#'    - Aggregated columns use snake_case to signal they are derived
#'    - Original columns retain source naming (often UPPERCASE)
#' 3. DIRECT DB-TO-DB: SQL INSERT INTO ... SELECT FROM (bypass R for very large datasets)
#'
#' **Transformations Allowed**:
#' ✅ SQL filtering (WHERE clauses) for scope reduction
#' ✅ SQL aggregation (GROUP BY) for size reduction  
#' ✅ Column selection (exclude unnecessary columns)
#' ❌ Column renaming (that's Ellis territory - janitor::clean_names)
#' ❌ Factor recoding or taxonomy application
#' ❌ Business logic or derived analytical variables
#'
#' **Input**: External databases, APIs, flat files (original sources)
#' **Output**: CACHE database (staging schema) + parquet backup
#'
#' **Naming Convention**: {order}-ferry-{source}.R
#' Example: 0-ferry-IS.R, 2-ferry-LMTA.R, 4-ferry-external.R
#'
#' ============================================================================
#' THIS EXAMPLE: Transport mtcars from WAREHOUSE to CACHE
#' - Source: RESEARCH_PROJECT_WAREHOUSE_UAT._TEST.mtcars
#' - Modality 1: RESEARCH_PROJECT_CACHE_UAT._TEST.mtcars_raw (full transport via R)
#' - Modality 2: RESEARCH_PROJECT_CACHE_UAT._TEST.mtcars_agg (aggregated via R)
#' - Modality 3: RESEARCH_PROJECT_CACHE_UAT._TEST.mtcars_direct (direct SQL transfer)
#' ============================================================================

#+ echo=F
# rmarkdown::render(input = "./manipulation/ferry-lane-example.R") # run to knit
# ---- setup -------------------------------------------------------------------
rm(list = ls(all.names = TRUE)) # Clear memory
cat("\014") # Clear console
cat("Working directory:", getwd(), "\n") # Verify root

# ---- load-packages -----------------------------------------------------------
# Ferry pattern: conservative loading, avoid namespace conflicts
library(magrittr) # for %>% pipe
requireNamespace("DBI")
requireNamespace("odbc")
requireNamespace("OuhscMunge")  # remotes::install_github("OuhscBbmc/OuhscMunge")
requireNamespace("arrow")
requireNamespace("readr")
requireNamespace("dplyr") # for glimpse only

# ---- declare-globals ---------------------------------------------------------
# Source database (WAREHOUSE - long-term storage)
dsn_source <- "RESEARCH_PROJECT_WAREHOUSE_UAT"
schema_source <- "_TEST"
table_source <- "mtcars"

# Destination database (CACHE - staging for Ellis)
dsn_cache <- "RESEARCH_PROJECT_CACHE_UAT"
schema_cache <- "_TEST"
table_full <- "mtcars_raw"      # Full transport output (Modality 1)
table_agg <- "mtcars_agg"       # Aggregated transport output (Modality 2)
table_direct <- "mtcars_direct" # Direct SQL transfer output (Modality 3)

# File outputs
output_dir <- "./data-private/derived/ferry/"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Timing
report_render_start_time <- Sys.time()

# ---- declare-functions -------------------------------------------------------
# Helper: Log record counts for validation
log_transport <- function(stage, dataset, source_info = NULL) {
  cat(sprintf("📊 [%s] %d rows, %d cols", stage, nrow(dataset), ncol(dataset)))
  if (!is.null(source_info)) cat(" from", source_info)
  cat("\n")
}

# ==============================================================================
# SECTION 1: DATA EXTRACTION
# ==============================================================================

# ---- load-data-full ----------------------------------------------------------
# MODALITY 1: Full Transport
# Use when source table size is manageable and all records needed
cat("\n", strrep("=", 60), "\n")
cat("MODALITY 1: Full Transport (SELECT *)\n")
cat(strrep("=", 60), "\n")

cnn_source <- DBI::dbConnect(odbc::odbc(), dsn = dsn_source)

sql_full <- paste0("
  SELECT *
  FROM [", schema_source, "].[", table_source, "]
")

ds_full <- DBI::dbGetQuery(cnn_source, sql_full)
log_transport("Extracted (full)", ds_full, paste(dsn_source, schema_source, table_source, sep = "."))

DBI::dbDisconnect(cnn_source)

# ---- load-data-aggregated ----------------------------------------------------
# MODALITY 2: Filtered/Aggregated Transport
# Use when source table is too large - reduce with SQL-side operations
# NOTE: Aggregated columns use snake_case (Ellis standard) to signal derivation
cat("\n", strrep("=", 60), "\n")
cat("MODALITY 2: Aggregated Transport (GROUP BY)\n")
cat(strrep("=", 60), "\n")

cnn_source <- DBI::dbConnect(odbc::odbc(), dsn = dsn_source)

sql_agg <- paste0("
  SELECT 
    cyl,                              -- Original column (source naming)
    COUNT(*) AS car_count,            -- Aggregated: snake_case signals derived
    AVG(mpg) AS avg_mpg,              -- Aggregated: snake_case
    AVG(hp) AS avg_hp,                -- Aggregated: snake_case
    AVG(wt) AS avg_wt,                -- Aggregated: snake_case
    MIN(mpg) AS min_mpg,              -- Aggregated: snake_case
    MAX(mpg) AS max_mpg               -- Aggregated: snake_case
  FROM [", schema_source, "].[", table_source, "]
  GROUP BY cyl
")

ds_agg <- DBI::dbGetQuery(cnn_source, sql_agg)
log_transport("Extracted (aggregated)", ds_agg, "GROUP BY cyl")

DBI::dbDisconnect(cnn_source)

# ---- load-data-direct --------------------------------------------------------
# MODALITY 3: Direct Database-to-Database Transfer
# Use when dataset is too large to fit in R memory - bypass R entirely
# SQL server does the work directly between databases
cat("\n", strrep("=", 60), "\n")
cat("MODALITY 3: Direct SQL Transfer (No R Intermediary)\n")
cat(strrep("=", 60), "\n")

# Connect to CACHE (destination)
cnn_cache <- DBI::dbConnect(odbc::odbc(), dsn = dsn_cache)

# Ensure schema exists in CACHE
schema_sql <- paste0("IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '", 
                     schema_cache, "') EXEC('CREATE SCHEMA [", schema_cache, "]')")
DBI::dbExecute(cnn_cache, schema_sql)

# Drop table if exists (for clean re-run)
drop_sql <- paste0("IF OBJECT_ID('[", schema_cache, "].[", table_direct, "]', 'U') IS NOT NULL ",
                   "DROP TABLE [", schema_cache, "].[", table_direct, "]")
DBI::dbExecute(cnn_cache, drop_sql)

# Direct transfer via linked server or database reference
# NOTE: This assumes both WAREHOUSE and CACHE are on same SQL Server instance
#       For different servers, configure linked server first
sql_direct <- paste0("
  SELECT * 
  INTO [", dsn_cache, "].[", schema_cache, "].[", table_direct, "]
  FROM [", dsn_source, "].[", schema_source, "].[", table_source, "]
")

DBI::dbExecute(cnn_cache, sql_direct)

# Verify transfer
row_count <- DBI::dbGetQuery(cnn_cache, 
  paste0("SELECT COUNT(*) as n FROM [", schema_cache, "].[", table_direct, "]"))$n

DBI::dbDisconnect(cnn_cache)

cat("✅ Direct transfer completed:", row_count, "rows\n")
cat("   No data passed through R - SQL Server handled entire transfer\n")
cat("   Use this modality for datasets > 1GB to avoid R memory limits\n")

# ---- load-data-file-alternative ----------------------------------------------
# ALTERNATIVE: Flat file source (CSV)
# Uncomment this section if sourcing from files instead of database
# 
# cat("\n--- ALTERNATIVE: Flat File Source ---\n")
# source_file <- "./data-public/raw/mtcars.csv"
# ds_full <- readr::read_csv(source_file, show_col_types = FALSE)
# log_transport("Loaded from CSV", ds_full, source_file)

# ==============================================================================
# SECTION 2: VALIDATION
# ==============================================================================

# ---- validate-transport ------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("VALIDATION\n")
cat(strrep("=", 60), "\n")

# Full transport validation
cat("\n📋 Full Transport Summary:\n")
cat("  - Records:", nrow(ds_full), "\n")
cat("  - Columns:", ncol(ds_full), "\n")
cat("  - Column names:", paste(names(ds_full), collapse = ", "), "\n")

# Aggregated transport validation
cat("\n📋 Aggregated Transport Summary:\n")
cat("  - Records:", nrow(ds_agg), "(", length(unique(ds_full$cyl)), "cylinder groups)\n")
cat("  - Columns:", ncol(ds_agg), "\n")
cat("  - Total cars represented:", sum(ds_agg$car_count), "\n")

# Integrity check
if (sum(ds_agg$car_count) != nrow(ds_full)) {
  warning("⚠️  Aggregation count mismatch! Check source data.")
} else {
  cat("  ✅ Aggregation integrity verified\n")
}

# Direct transfer validation
cat("\n📋 Direct Transfer Summary:\n")
cat("  - Records:", row_count, "(transferred without touching R memory)\n")
cat("  - Method: SQL Server-side INSERT INTO ... SELECT FROM\n")
cat("  - Memory efficient: TRUE\n")

# ---- inspect-data ------------------------------------------------------------
cat("\n📊 Data Inspection:\n")
cat("\n--- Full Transport (first 6 rows) ---\n")
print(head(ds_full))

cat("\n--- Aggregated Transport ---\n")
print(ds_agg)

# ==============================================================================
# SECTION 3: LOAD TO CACHE (Database)
# ==============================================================================

# ---- save-to-cache-mssql -----------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SAVE TO CACHE (MSSQL)\n")
cat(strrep("=", 60), "\n")

# Write full transport to CACHE
OuhscMunge::upload_sqls_odbc(
  d = ds_full,
  schema_name = schema_cache,    # _TEST for demonstration
  table_name = table_full,       # mtcars_raw (full transport)
  dsn_name = dsn_cache,          # RESEARCH_PROJECT_CACHE
  clear_table = TRUE,            # TRUE = delete if exists
  create_table = TRUE            # TRUE = create if not exists
)
cat("✅ Full transport saved to:", paste(dsn_cache, schema_cache, table_full, sep = "."), "\n")

# Write aggregated transport to CACHE
OuhscMunge::upload_sqls_odbc(
  d = ds_agg,
  schema_name = schema_cache,    # _TEST for demonstration
  table_name = table_agg,        # mtcars_agg (aggregated transport)
  dsn_name = dsn_cache,          # RESEARCH_PROJECT_CACHE_UAT
  clear_table = TRUE,            # TRUE = delete if exists
  create_table = TRUE            # TRUE = create if not exists
)
cat("✅ Aggregated transport saved to:", paste(dsn_cache, schema_cache, table_agg, sep = "."), "\n")

# Direct transfer already in CACHE (written by SQL in load-data-direct chunk)
cat("✅ Direct transfer saved to:", paste(dsn_cache, schema_cache, table_direct, sep = "."), "\n")
cat("   (Written directly by SQL - no R-based upload needed)\n")

# ---- save-to-cache-sqlite ----------------------------------------------------
# ALTERNATIVE: SQLite output (for projects without MSSQL infrastructure)
# Uncomment this section if using SQLite as CACHE
#
# sqlite_path <- "./data-private/derived/ferry/cache.sqlite"
# cnn_sqlite <- DBI::dbConnect(RSQLite::SQLite(), sqlite_path)
# 
# DBI::dbWriteTable(cnn_sqlite, "mtcars_raw", ds_full, overwrite = TRUE)
# DBI::dbWriteTable(cnn_sqlite, "mtcars_agg", ds_agg, overwrite = TRUE)
# 
# cat("✅ SQLite CACHE saved to:", sqlite_path, "\n")
# DBI::dbDisconnect(cnn_sqlite)

# ==============================================================================
# SECTION 4: BACKUP TO PARQUET
# ==============================================================================

# ---- save-to-parquet ---------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("BACKUP TO PARQUET\n")
cat(strrep("=", 60), "\n")

# Full transport backup
parquet_full <- file.path(output_dir, "mtcars_raw.parquet")
arrow::write_parquet(ds_full, parquet_full)
cat("✅ Full transport backup:", parquet_full, "\n")

# Aggregated transport backup
parquet_agg <- file.path(output_dir, "mtcars_agg.parquet")
arrow::write_parquet(ds_agg, parquet_agg)
cat("✅ Aggregated transport backup:", parquet_agg, "\n")

# ==============================================================================
# SECTION 5: SESSION INFO
# ==============================================================================

# ---- session-info ------------------------------------------------------------
cat("\n", strrep("=", 60), "\n")
cat("SESSION INFO\n")
cat(strrep("=", 60), "\n")

report_duration <- difftime(Sys.time(), report_render_start_time, units = "secs")
cat("\n⏱️  Ferry completed in", round(as.numeric(report_duration), 1), "seconds\n")
cat("📅 Executed:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("👤 User:", Sys.info()["user"], "\n")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::session_info()
} else {
  sessionInfo()
}



