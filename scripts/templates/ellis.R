#' ---
#' title: "Ellis Pattern: Transform Ferry Data for Analysis"
#' author: "Generic Template"
#' date: "Last Updated: `r Sys.Date()`"
#' description: "Transform raw ferry data into analysis-ready datasets with cleaned variables"
#' ---
#+ echo=F

# The Ellis Pattern: A data transformation mechanism that takes ferry data
# and prepares it for analysis through systematic cleaning and standardization.
#
# Key Principles:
# 1. Load data from ferry cache (standardized intermediate storage)
# 2. Apply business logic and domain-specific transformations
# 3. Create analysis-ready variables with consistent coding
# 4. Generate summary statistics and validation checks
# 5. Output clean datasets for downstream analysis

rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run.
cat("\014") # Clear the console

cat("Working directory: ", getwd()) # Verify root location

#+ mission -------------------------------------------------------------
# Ellis Pattern Implementation:
# 1. Extract data from ferry cache database
# 2. Apply domain-specific business logic and transformations
# 3. Create standardized analysis variables (demographics, categories, etc.)
# 4. Validate data quality and generate summary statistics
# 5. Export clean datasets for analysis pipelines
#
# This template demonstrates transformation of customer/transaction data
# from ferry cache into analysis-ready format
# ---- load-packages -----------------------------------------------------------
# Core packages for ellis pattern implementation
library(magrittr)    # For pipe operations
library(ggplot2)     # Visualization
library(forcats)     # Factor manipulation
library(stringr)     # String processing
library(lubridate)   # Date handling
library(labelled)    # Variable labels
library(dplyr)       # Data manipulation
library(tidyr)       # Data reshaping
library(scales)      # Formatting
library(DBI)         # Database interface
library(RSQLite)     # SQLite connectivity
library(odbc)        # MSSQL connectivity (if available)

# Import specific functions to avoid namespace conflicts
requireNamespace("readr")      # Data import/export
requireNamespace("janitor")    # Data cleaning
requireNamespace("tableone")   # Summary tables

# ---- load-sources ------------------------------------------------------------
# Load helper functions if available
if(file.exists("./scripts/common-functions.R")) {
  base::source("./scripts/common-functions.R")
}

# ---- declare-globals ---------------------------------------------------------
# Configuration for Ellis transformation
CACHE_DATABASE_DSN  <- "cache_db"            # ODBC DSN for cache database
SQLITE_PATH         <- "./data/cache.sqlite" # SQLite cache file path
TARGET_SCHEMA       <- "ferry_cache"         # Source schema from ferry

# Analysis parameters
analysis_window_start <- as.Date("2020-01-01")
analysis_window_end   <- as.Date(Sys.Date())

# Output directories
local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/")
output_data <- "./data-public/derived/"

# Create directories if they don't exist
if (!dir.exists(local_data)) {dir.create(local_data, recursive = TRUE)}
if (!dir.exists(output_data)) {dir.create(output_data, recursive = TRUE)}
# ---- declare-functions -------------------------------------------------------
# Generic database connection helper
get_db_connection <- function(type = "sqlite", dsn = NULL, path = "./data/cache.sqlite") {
  switch(type,
    "mssql" = DBI::dbConnect(odbc::odbc(), dsn = dsn),
    "sqlite" = DBI::dbConnect(RSQLite::SQLite(), dbname = path),
    stop("Unsupported database type. Use 'mssql' or 'sqlite'")
  )
}

# Standardize demographic variables
wrangle_customer_demographics <- function(d_in) {
  d_out <- d_in %>%
    mutate(
      # Age categories
      age_group_3 = case_when(
        age >= 18 & age <= 34 ~ "18-34",
        age >= 35 & age <= 54 ~ "35-54", 
        age >= 55 ~ "55+",
        TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "18-34", "35-54", "55+")),
      
      age_group_5 = case_when(
        age >= 18 & age <= 29 ~ "18-29",
        age >= 30 & age <= 39 ~ "30-39",
        age >= 40 & age <= 49 ~ "40-49",
        age >= 50 & age <= 59 ~ "50-59",
        age >= 60 ~ "60+",
        TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "18-29", "30-39", "40-49", "50-59", "60+")),
      
      # Clean age values (remove outliers)
      age_clean = case_when(
        age >= 18 & age <= 100 ~ age,
        TRUE ~ NA_integer_
      )
    )
  return(d_out)
}

# Standardize transaction patterns
wrangle_transaction_patterns <- function(d_in) {
  d_out <- d_in %>%
    group_by(customer_id) %>%
    mutate(
      # Transaction sequence
      transaction_order = row_number(transaction_date),
      first_transaction_date = min(transaction_date, na.rm = TRUE),
      days_since_first = as.numeric(transaction_date - first_transaction_date),
      
      # Amount categories
      amount_category = case_when(
        amount <= 50 ~ "Low (≤$50)",
        amount <= 200 ~ "Medium ($51-$200)",
        amount <= 500 ~ "High ($201-$500)",
        amount > 500 ~ "Very High (>$500)",
        TRUE ~ "(Missing)"
      ) %>% factor(levels = c("(Missing)", "Low (≤$50)", "Medium ($51-$200)", 
                             "High ($201-$500)", "Very High (>$500)")),
      
      # Customer activity level
      total_transactions = n(),
      activity_level = case_when(
        total_transactions == 1 ~ "One-time",
        total_transactions <= 5 ~ "Low activity",
        total_transactions <= 20 ~ "Medium activity", 
        total_transactions > 20 ~ "High activity"
      ) %>% factor(levels = c("One-time", "Low activity", "Medium activity", "High activity"))
    ) %>%
    ungroup()
  
  return(d_out)
}

# Create customer summary metrics
create_customer_summary <- function(transactions_df, customers_df) {
  customer_metrics <- transactions_df %>%
    group_by(customer_id) %>%
    summarise(
      total_amount = sum(amount, na.rm = TRUE),
      transaction_count = n(),
      avg_transaction_amount = mean(amount, na.rm = TRUE),
      first_transaction = min(transaction_date, na.rm = TRUE),
      last_transaction = max(transaction_date, na.rm = TRUE),
      customer_lifetime_days = as.numeric(last_transaction - first_transaction) + 1,
      purchase_count = sum(transaction_type == "Purchase", na.rm = TRUE),
      refund_count = sum(transaction_type == "Refund", na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      # Customer value segments
      value_segment = case_when(
        total_amount <= 100 ~ "Low Value",
        total_amount <= 500 ~ "Medium Value",
        total_amount <= 2000 ~ "High Value", 
        total_amount > 2000 ~ "Premium Value"
      ) %>% factor(levels = c("Low Value", "Medium Value", "High Value", "Premium Value")),
      
      # Activity recency
      days_since_last = as.numeric(Sys.Date() - last_transaction),
      recency_category = case_when(
        days_since_last <= 30 ~ "Recent (≤30 days)",
        days_since_last <= 90 ~ "Moderate (31-90 days)", 
        days_since_last <= 365 ~ "Distant (91-365 days)",
        days_since_last > 365 ~ "Inactive (>365 days)"
      ) %>% factor(levels = c("Recent (≤30 days)", "Moderate (31-90 days)", 
                             "Distant (91-365 days)", "Inactive (>365 days)"))
    )
  
  # Join with customer demographics
  customer_summary <- customers_df %>%
    left_join(customer_metrics, by = "customer_id") %>%
    mutate(
      # Handle customers with no transactions
      transaction_count = coalesce(transaction_count, 0L),
      total_amount = coalesce(total_amount, 0),
      value_segment = coalesce(value_segment, factor("Low Value", levels = levels(customer_metrics$value_segment)))
    )
  
  return(customer_summary)
}

# ---- load-ferry-data ---------------------------------------------------------
cat("🏗️ Ellis Pattern: Loading ferry data for transformation\n")

# Try SQLite first (most likely to be available)
cache_conn <- get_db_connection("sqlite", path = SQLITE_PATH)

# Load core datasets from ferry cache
cat("📊 Loading customers...\n")
ds_customers_raw <- DBI::dbReadTable(cache_conn, "customers")

cat("📊 Loading transactions...\n") 
ds_transactions_raw <- DBI::dbReadTable(cache_conn, "transactions")

cat("📊 Loading products...\n")
ds_products_raw <- DBI::dbReadTable(cache_conn, "products")

DBI::dbDisconnect(cache_conn)

# Data quality checks
cat("✅ Data loaded successfully:\n")
cat("   - Customers:", nrow(ds_customers_raw), "records\n")
cat("   - Transactions:", nrow(ds_transactions_raw), "records\n") 
cat("   - Products:", nrow(ds_products_raw), "records\n")

# ---- transform-step-1 --------------------------------------------------------
cat("\n🔄 Step 1: Basic data cleaning and standardization\n")

# Clean and standardize base datasets
ds_customers_clean <- ds_customers_raw %>%
  janitor::clean_names() %>%
  mutate(
    # Standardize dates
    registration_date = ymd(registration_date),
    last_activity_date = ymd(last_activity_date),
    
    # Clean text fields
    customer_name = str_trim(customer_name),
    customer_type = str_trim(customer_type),
    
    # Add analysis metadata
    ellis_processed_date = Sys.Date(),
    analysis_cohort = case_when(
      registration_date >= analysis_window_start ~ "Analysis Period",
      TRUE ~ "Pre-Analysis"
    )
  ) %>%
  # Apply demographic transformations
  wrangle_customer_demographics()

ds_transactions_clean <- ds_transactions_raw %>%
  janitor::clean_names() %>%
  mutate(
    # Standardize dates  
    transaction_date = ymd(transaction_date),
    
    # Clean transaction types
    transaction_type = str_trim(transaction_type),
    
    # Add analysis metadata
    ellis_processed_date = Sys.Date(),
    in_analysis_window = transaction_date >= analysis_window_start & 
                        transaction_date <= analysis_window_end
  ) %>%
  # Apply transaction pattern transformations
  wrangle_transaction_patterns()

ds_products_clean <- ds_products_raw %>%
  janitor::clean_names() %>%
  mutate(
    # Clean text fields
    product_name = str_trim(product_name),
    category = str_trim(category),
    
    # Price categories
    price_tier = case_when(
      price <= 25 ~ "Budget",
      price <= 100 ~ "Standard", 
      price <= 300 ~ "Premium",
      price > 300 ~ "Luxury",
      TRUE ~ "(Missing)"
    ) %>% factor(levels = c("(Missing)", "Budget", "Standard", "Premium", "Luxury")),
    
    # Add analysis metadata
    ellis_processed_date = Sys.Date()
  )

cat("✅ Basic cleaning completed\n")  

# ---- transform-step-2 --------------------------------------------------------
cat("\n🔄 Step 2: Business logic and cohort definition\n")

# Define analysis cohort with specific business rules
# Example: Focus on customers who registered during analysis period 
# and had meaningful engagement (multiple transactions)

analysis_cohort_customers <- ds_customers_clean %>%
  filter(
    analysis_cohort == "Analysis Period",
    !is.na(age_clean),
    age_clean >= 18  # Adult customers only
  ) %>%
  # Add customer sequence number within registration month
  group_by(year(registration_date), month(registration_date)) %>%
  mutate(
    registration_month = floor_date(registration_date, "month"),
    customer_sequence = row_number()
  ) %>%
  ungroup()

# Filter transactions to analysis cohort and time window
analysis_transactions <- ds_transactions_clean %>%
  filter(
    customer_id %in% analysis_cohort_customers$customer_id,
    in_analysis_window == TRUE,
    !is.na(amount),
    amount > 0  # Positive transaction amounts only
  )

# Create customer summary with business metrics
customer_analysis_summary <- create_customer_summary(
  transactions_df = analysis_transactions,
  customers_df = analysis_cohort_customers
)

cat("✅ Analysis cohort defined:\n")
cat("   - Cohort customers:", nrow(analysis_cohort_customers), "\n")
cat("   - Analysis transactions:", nrow(analysis_transactions), "\n")
cat("   - Customers with transactions:", sum(customer_analysis_summary$transaction_count > 0), "\n")



# ---- transform-step-3 --------------------------------------------------------
cat("\n🔄 Step 3: Advanced analytics variables and validation\n")

# Create final analysis-ready dataset with comprehensive variables
ds_final_customers <- customer_analysis_summary %>%
  mutate(
    # Customer lifecycle stage
    lifecycle_stage = case_when(
      transaction_count == 0 ~ "Registered Only",
      transaction_count == 1 ~ "Trial Customer", 
      transaction_count <= 5 & days_since_last <= 90 ~ "New Active",
      transaction_count > 5 & days_since_last <= 30 ~ "Loyal Active",
      transaction_count > 5 & days_since_last > 90 ~ "At Risk",
      TRUE ~ "Other"
    ) %>% factor(levels = c("Registered Only", "Trial Customer", "New Active", 
                           "Loyal Active", "At Risk", "Other")),
    
    # Engagement score (composite metric)
    engagement_score = case_when(
      transaction_count == 0 ~ 0,
      TRUE ~ pmin(100, 
        (transaction_count * 10) + 
        (total_amount / 10) + 
        pmax(0, 30 - days_since_last)
      )
    ),
    
    # Analysis flags
    high_value_customer = total_amount >= 1000,
    recent_customer = days_since_last <= 30,
    analysis_ready = !is.na(age_clean) & transaction_count > 0
  )

# Create enhanced transaction dataset with customer context
ds_final_transactions <- analysis_transactions %>%
  left_join(
    ds_final_customers %>% select(customer_id, value_segment, lifecycle_stage, engagement_score),
    by = "customer_id"
  ) %>%
  mutate(
    # Transaction context variables
    transaction_month = floor_date(transaction_date, "month"),
    transaction_quarter = quarter(transaction_date, with_year = TRUE),
    
    # Seasonal patterns
    season = case_when(
      month(transaction_date) %in% c(12, 1, 2) ~ "Winter",
      month(transaction_date) %in% c(3, 4, 5) ~ "Spring", 
      month(transaction_date) %in% c(6, 7, 8) ~ "Summer",
      month(transaction_date) %in% c(9, 10, 11) ~ "Fall"
    ) %>% factor(levels = c("Spring", "Summer", "Fall", "Winter"))
  )

# ---- validate-data -----------------------------------------------------------
cat("\n🔍 Step 4: Data validation and quality checks\n")

# Create summary table for analysis-ready customers
if(requireNamespace("tableone", quietly = TRUE)) {
  cat("📊 Customer Demographics Summary:\n")
  
  customer_summary_vars <- ds_final_customers %>%
    filter(analysis_ready == TRUE) %>%
    select(
      customer_type,
      age_group_3,
      age_group_5,
      lifecycle_stage,
      value_segment,
      recency_category,
      high_value_customer,
      recent_customer
    )
  
  summary_table <- tableone::CreateTableOne(data = customer_summary_vars)
  print(summary_table)
  
  # Stratified analysis by customer type
  if(nrow(customer_summary_vars) > 10) {
    cat("\n📊 Summary by Customer Type:\n")
    stratified_table <- tableone::CreateTableOne(
      data = customer_summary_vars, 
      strata = "customer_type"
    )
    print(stratified_table)
  }
}

# Transaction patterns validation
cat("\n📈 Transaction Patterns Summary:\n")
transaction_summary <- ds_final_transactions %>%
  summarise(
    total_transactions = n(),
    unique_customers = n_distinct(customer_id),
    avg_transaction_amount = round(mean(amount, na.rm = TRUE), 2),
    median_transaction_amount = round(median(amount, na.rm = TRUE), 2),
    date_range_start = min(transaction_date, na.rm = TRUE),
    date_range_end = max(transaction_date, na.rm = TRUE),
    .groups = "drop"
  )

print(transaction_summary)

# Data quality flags
cat("\n⚠️ Data Quality Checks:\n")
quality_checks <- list(
  missing_customer_ages = sum(is.na(ds_final_customers$age_clean)),
  zero_amount_transactions = sum(ds_final_transactions$amount == 0, na.rm = TRUE),
  future_transactions = sum(ds_final_transactions$transaction_date > Sys.Date(), na.rm = TRUE),
  customers_no_transactions = sum(ds_final_customers$transaction_count == 0),
  negative_amounts = sum(ds_final_transactions$amount < 0, na.rm = TRUE)
)

for(check_name in names(quality_checks)) {
  cat("   -", check_name, ":", quality_checks[[check_name]], "\n")
}

# ---- export-results ----------------------------------------------------------
cat("\n💾 Step 5: Export analysis-ready datasets\n")

# Export to multiple formats for different use cases

# 1. CSV files for general use
readr::write_csv(ds_final_customers, file.path(output_data, "customers_analysis_ready.csv"))
readr::write_csv(ds_final_transactions, file.path(output_data, "transactions_analysis_ready.csv"))

# 2. Parquet files for efficient storage and R/Python interop
if(requireNamespace("arrow", quietly = TRUE)) {
  arrow::write_parquet(ds_final_customers, file.path(output_data, "customers_analysis_ready.parquet"))
  arrow::write_parquet(ds_final_transactions, file.path(output_data, "transactions_analysis_ready.parquet"))
}

# 3. Write back to cache database for other processes
tryCatch({
  cache_conn <- get_db_connection("sqlite", path = SQLITE_PATH)
  
  # Write analysis-ready tables
  DBI::dbWriteTable(cache_conn, "customers_analysis_ready", ds_final_customers, overwrite = TRUE)
  DBI::dbWriteTable(cache_conn, "transactions_analysis_ready", ds_final_transactions, overwrite = TRUE)
  
  # Create an ellis processing log
  ellis_log <- data.frame(
    processing_timestamp = Sys.time(),
    customers_processed = nrow(ds_final_customers),
    transactions_processed = nrow(ds_final_transactions),
    analysis_window_start = analysis_window_start,
    analysis_window_end = analysis_window_end,
    quality_checks_passed = all(unlist(quality_checks) == 0)
  )
  
  DBI::dbWriteTable(cache_conn, "ellis_processing_log", ellis_log, append = TRUE)
  DBI::dbDisconnect(cache_conn)
  
  cat("✅ Data written to cache database\n")
  
}, error = function(e) {
  cat("⚠ Cache database write failed:", e$message, "\n")
})

# 4. Summary report
cat("\n📋 Ellis Processing Summary:\n")
cat("=====================================\n")
cat("📊 Final Datasets:\n")
cat("   - Analysis-ready customers:", nrow(ds_final_customers), "\n")
cat("   - Analysis-ready transactions:", nrow(ds_final_transactions), "\n")
cat("   - Date range:", analysis_window_start, "to", analysis_window_end, "\n")

cat("\n📁 Output Files Created:\n")
cat("   - CSV files:", output_data, "\n")
if(requireNamespace("arrow", quietly = TRUE)) {
  cat("   - Parquet files:", output_data, "\n")
}
cat("   - Cache database:", SQLITE_PATH, "\n")

cat("\n🎯 Key Analysis Variables Created:\n")
cat("   - Customer lifecycle stages\n")
cat("   - Value segments\n") 
cat("   - Engagement scores\n")
cat("   - Demographic categories\n")
cat("   - Transaction patterns\n")
cat("   - Seasonal indicators\n")

cat("\n✅ Ellis pattern processing completed successfully!\n")
cat("🚀 Data is now ready for downstream analysis pipelines.\n")

# ---- session-info -----------------------------------------------------------
cat("\n📋 Session Information:\n")
print(sessionInfo())