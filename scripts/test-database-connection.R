# Test Database Connection Script
# !!!!  This is an example !!!! Replace with project-specific details
# This script tests connectivity to all database stages and shows available tables

cat("=== AIM 2025 SANDBOX: DATABASE CONNECTION TEST ===\n\n")

# Load common functions
source("scripts/common-functions.R")

# Test all database stages
db_stages <- c("main", "stage_2")
stage_descriptions <- c(
  "main" = "Final analytical database",
  "stage_2" = "Books + admin + custom data"
)

for (stage in db_stages) {
  cat("Testing", stage, "database:", stage_descriptions[stage], "\n")
  cat("----------------------------------------\n")
  
  tryCatch({
    # Connect to database
    db <- connect_books_db(stage)
    
    # List tables
    tables <- DBI::dbListTables(db)
    cat("Available tables (", length(tables), "):\n")
    for (table in sort(tables)) {
      # Get row count for each table
      count <- DBI::dbGetQuery(db, paste("SELECT COUNT(*) as count FROM", table))$count
      cat("  -", table, "(", format(count, big.mark = ","), "rows )\n")
    }
    
    # Close connection
    DBI::dbDisconnect(db)
    cat("✅ Connection test successful!\n\n")
    
  }, error = function(e) {
    cat("❌ Connection failed:", e$message, "\n\n")
  })
}

cat("=== DATABASE CONNECTION TEST COMPLETE ===\n")
cat("\nTo use in your analysis scripts:\n")
cat('  library(DBI)\n')
cat('  source("scripts/common-functions.R")\n')
cat('  db <- connect_books_db("main")  # or stage_2\n')
cat('  data <- dbGetQuery(db, "SELECT * FROM your_table LIMIT 10")\n')
cat('  dbDisconnect(db)\n')
