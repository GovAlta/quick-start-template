#' ---
#' title: "Ferry Pattern: Source to Cache"
#' author: "Generic Template"
#' date: "Last Updated: `r Sys.Date()`"
#' description: "Minimal example of ferry pattern: import, process, write to database"
#' ---
#+ echo=F

# The Ferry Pattern: A data transport mechanism that brings data from various 
# sources into a unified database destination with minimal transformation.
#
# Key Principles:
# 1. Import from diverse sources (APIs, files, databases)
# 2. Apply minimal, essential processing only
# 3. Write to standardized destination database
# 4. Maintain data lineage and reproducibility

rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
cat("\014") # Clear the console

#+ mission -------------------------------------------------------------
# Ferry Pattern Implementation:
# 1. Extract data from source systems (files, APIs, databases)
# 2. Apply minimal transformations (cleaning, standardization)
# 3. Load into destination database (MSSQL Server or SQLite)
# 
# This template demonstrates both MSSQL and SQLite destinations

#+ load-packages -----------------------------------------------------------
# Core packages for ferry pattern implementation
library(magrittr)    # For pipe operations
library(dplyr)       # For data manipulation
library(DBI)         # Database interface
library(odbc)        # MSSQL connectivity
library(RSQLite)     # SQLite connectivity
library(readr)       # File reading (CSV, etc.)
library(httr)        # API calls
library(jsonlite)    # JSON processing
library(janitor)     # Data cleaning utilities

#+ load-sources ------------------------------------------------------------
# Load helper functions if available
if(file.exists("./scripts/common-functions.R")) {
  base::source("./scripts/common-functions.R")
}

#+ declare-globals ---------------------------------------------------------
# Configuration for data sources and destinations
SOURCE_DATABASE_DSN <- "source_db"           # ODBC DSN for source database
CACHE_DATABASE_DSN  <- "cache_db"            # ODBC DSN for MSSQL cache
SQLITE_PATH         <- "./data/cache.sqlite" # SQLite cache file path
TARGET_SCHEMA       <- "ferry_cache"         # Target schema name

# Date boundaries for data extraction
extract_date_start <- as.Date("2020-01-01")
extract_date_end   <- as.Date(Sys.Date())

#+ declare-functions -------------------------------------------------------
# Standardize column names and handle common data quality issues
clean_ferry_data <- function(df, max_string_length = 255) {
  df %>%
    janitor::clean_names() %>%                    # Standardize column names
    mutate(
      across(where(is.character), ~trimws(.)),    # Trim whitespace
      across(where(is.character), ~ifelse(       # Truncate long strings
        nchar(.) > max_string_length, 
        substr(., 1, max_string_length), 
        .
      ))
    )
}

# Generic database connection helper
get_db_connection <- function(type = "mssql", dsn = NULL, path = NULL) {
  switch(type,
    "mssql" = DBI::dbConnect(odbc::odbc(), dsn = dsn),
    "sqlite" = DBI::dbConnect(RSQLite::SQLite(), dbname = path),
    stop("Unsupported database type. Use 'mssql' or 'sqlite'")
  )
}

# Generic table writer with error handling
write_to_cache <- function(data, table_name, connection, schema = NULL, overwrite = TRUE) {
  tryCatch({
    # For MSSQL with schema
    if(!is.null(schema) && inherits(connection, "Microsoft SQL Server")) {
      full_table_name <- paste(schema, table_name, sep = ".")
    } else {
      full_table_name <- table_name
    }
    
    DBI::dbWriteTable(
      conn = connection,
      name = full_table_name,
      value = data,
      overwrite = overwrite,
      append = !overwrite
    )
    
    cat("✓ Successfully wrote", nrow(data), "rows to", full_table_name, "\n")
    return(TRUE)
    
  }, error = function(e) {
    cat("✗ Error writing to", table_name, ":", e$message, "\n")
    return(FALSE)
  })
}

#+ define-data-sources ------------------------------------------------------
# Example 1: Source Database Query
sql_customers <- "
  SELECT 
    customer_id,
    customer_name,
    registration_date,
    last_activity_date,
    customer_type
  FROM customers 
  WHERE registration_date >= ?
    AND registration_date <= ?
"

# Example 2: API Endpoint (hypothetical)
api_endpoint_transactions <- "https://api.example.com/v1/transactions"

# Example 3: File path (CSV/Excel)
file_path_products <- "./data-raw/products.csv"

#+ extract-data ------------------------------------------------------------
cat("🚢 Starting Ferry Operation: Extract Phase\n")

# SOURCE 1: Database extraction
cat("📊 Extracting from source database...\n")
if(file.exists("odbc.ini") || !is.null(getOption("odbc.dsn"))) {
  tryCatch({
    source_conn <- get_db_connection("mssql", dsn = SOURCE_DATABASE_DSN)
    
    ds_customers <- DBI::dbGetQuery(
      source_conn, 
      sql_customers, 
      params = list(extract_date_start, extract_date_end)
    )
    
    DBI::dbDisconnect(source_conn)
    cat("✓ Extracted", nrow(ds_customers), "customer records\n")
    
  }, error = function(e) {
    cat("⚠ Database source unavailable, using sample data\n")
    # Fallback to sample data for demonstration
    ds_customers <- data.frame(
      customer_id = 1:100,
      customer_name = paste("Customer", 1:100),
      registration_date = seq(extract_date_start, extract_date_end, length.out = 100),
      last_activity_date = Sys.Date() - sample(1:365, 100, replace = TRUE),
      customer_type = sample(c("Individual", "Business"), 100, replace = TRUE)
    )
  })
} else {
  # Sample data when no database connection available
  ds_customers <- data.frame(
    customer_id = 1:100,
    customer_name = paste("Customer", 1:100),
    registration_date = seq(extract_date_start, extract_date_end, length.out = 100),
    last_activity_date = Sys.Date() - sample(1:365, 100, replace = TRUE),
    customer_type = sample(c("Individual", "Business"), 100, replace = TRUE)
  )
}

# SOURCE 2: API extraction (example)
cat("🌐 Extracting from API...\n")
tryCatch({
  # Example API call (would need real endpoint)
  # response <- httr::GET(api_endpoint_transactions, 
  #                      query = list(start_date = extract_date_start))
  # ds_transactions <- jsonlite::fromJSON(httr::content(response, "text"))
  
  # Sample data for demonstration
  ds_transactions <- data.frame(
    transaction_id = 1:200,
    customer_id = sample(1:100, 200, replace = TRUE),
    transaction_date = sample(seq(extract_date_start, extract_date_end, by = "day"), 200, replace = TRUE),
    amount = round(runif(200, 10, 1000), 2),
    transaction_type = sample(c("Purchase", "Refund", "Payment"), 200, replace = TRUE)
  )
  cat("✓ Extracted", nrow(ds_transactions), "transaction records\n")
  
}, error = function(e) {
  cat("⚠ API unavailable, using sample data\n")
  ds_transactions <- data.frame(
    transaction_id = 1:200,
    customer_id = sample(1:100, 200, replace = TRUE),
    transaction_date = sample(seq(extract_date_start, extract_date_end, by = "day"), 200, replace = TRUE),
    amount = round(runif(200, 10, 1000), 2),
    transaction_type = sample(c("Purchase", "Refund", "Payment"), 200, replace = TRUE)
  )
})

# SOURCE 3: File extraction
cat("📁 Extracting from files...\n")
if(file.exists(file_path_products)) {
  ds_products <- readr::read_csv(file_path_products)
  cat("✓ Extracted", nrow(ds_products), "product records\n")
} else {
  # Sample data when file doesn't exist
  ds_products <- data.frame(
    product_id = 1:50,
    product_name = paste("Product", 1:50),
    category = sample(c("Electronics", "Clothing", "Books", "Home"), 50, replace = TRUE),
    price = round(runif(50, 5, 500), 2),
    in_stock = sample(c(TRUE, FALSE), 50, replace = TRUE)
  )
  cat("✓ Generated", nrow(ds_products), "sample product records\n")
}


#+ transform-data ----------------------------------------------------------
cat("🔄 Transform Phase: Minimal processing\n")

# Apply consistent cleaning to all datasets
ds_customers_clean <- ds_customers %>% 
  clean_ferry_data() %>%
  # Add ferry metadata
  mutate(
    ferry_load_timestamp = Sys.time(),
    ferry_source = "source_database"
  )

ds_transactions_clean <- ds_transactions %>% 
  clean_ferry_data() %>%
  # Add ferry metadata  
  mutate(
    ferry_load_timestamp = Sys.time(),
    ferry_source = "api_endpoint"
  )

ds_products_clean <- ds_products %>% 
  clean_ferry_data() %>%
  # Add ferry metadata
  mutate(
    ferry_load_timestamp = Sys.time(),
    ferry_source = "file_system"
  )

cat("✓ Applied standard transformations to all datasets\n")

#+ load-to-cache ----------------------------------------------------------
cat("🚢 Load Phase: Writing to cache databases\n")

# OPTION 1: MSSQL Server Cache
cat("\n📊 Loading to MSSQL Cache...\n")
tryCatch({
  mssql_conn <- get_db_connection("mssql", dsn = CACHE_DATABASE_DSN)
  
  # Write all tables to MSSQL cache
  write_to_cache(ds_customers_clean, "customers", mssql_conn, TARGET_SCHEMA)
  write_to_cache(ds_transactions_clean, "transactions", mssql_conn, TARGET_SCHEMA)
  write_to_cache(ds_products_clean, "products", mssql_conn, TARGET_SCHEMA)
  
  DBI::dbDisconnect(mssql_conn)
  cat("✅ MSSQL cache update complete\n")
  
}, error = function(e) {
  cat("⚠ MSSQL unavailable:", e$message, "\n")
})

# OPTION 2: SQLite Cache (Always available)
cat("\n💾 Loading to SQLite Cache...\n")
# Ensure directory exists
if(!dir.exists(dirname(SQLITE_PATH))) {
  dir.create(dirname(SQLITE_PATH), recursive = TRUE)
}

sqlite_conn <- get_db_connection("sqlite", path = SQLITE_PATH)

# Write all tables to SQLite cache
write_to_cache(ds_customers_clean, "customers", sqlite_conn, overwrite = TRUE)
write_to_cache(ds_transactions_clean, "transactions", sqlite_conn, overwrite = TRUE)
write_to_cache(ds_products_clean, "products", sqlite_conn, overwrite = TRUE)

# Create a ferry log table for tracking loads
ferry_log <- data.frame(
  load_timestamp = Sys.time(),
  tables_loaded = paste(c("customers", "transactions", "products"), collapse = ", "),
  records_total = nrow(ds_customers_clean) + nrow(ds_transactions_clean) + nrow(ds_products_clean),
  extract_date_range = paste(extract_date_start, "to", extract_date_end)
)

write_to_cache(ferry_log, "ferry_log", sqlite_conn, overwrite = FALSE)

DBI::dbDisconnect(sqlite_conn)
cat("✅ SQLite cache update complete\n")

#+ validate-results --------------------------------------------------------
cat("\n🔍 Validation Phase\n")

# Quick validation - reconnect and check record counts
sqlite_conn <- get_db_connection("sqlite", path = SQLITE_PATH)

tables <- DBI::dbListTables(sqlite_conn)
cat("📋 Tables in cache:", paste(tables, collapse = ", "), "\n")

for(table in tables) {
  count <- DBI::dbGetQuery(sqlite_conn, paste("SELECT COUNT(*) as count FROM", table))$count
  cat("📊", table, ":", count, "records\n")
}

DBI::dbDisconnect(sqlite_conn)

cat("\n🎉 Ferry operation completed successfully!\n")
cat("📍 Cache locations:\n")
cat("   - MSSQL:", TARGET_SCHEMA, "schema on", CACHE_DATABASE_DSN, "\n")
cat("   - SQLite:", SQLITE_PATH, "\n")

#+ session-info -----------------------------------------------------------
cat("\n📋 Session Information:\n")
print(sessionInfo())

