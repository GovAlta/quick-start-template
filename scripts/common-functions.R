# Functions loaded by EVERY script in the project
baseSize <- 10
print_all <- function(d){ print(d,n=nrow(d) )}

`%not in%` <- Negate(`%in%`)

# Null-coalesce helper
`%||%` <- function(a, b) if (!is.null(a)) a else b

library(ggplot2)
ggplot2::theme_set(
  ggplot2::theme_bw(
  )+
    theme(
      strip.background = element_rect(fill="grey95", color = NA)
      ,panel.grid = element_line(color = "grey95")
      ,panel.border = element_rect(color = "grey80")
      ,axis.ticks = element_blank()
      ,text=element_text(size=baseSize)
    )
)
quick_save <- function(g,name,...){
  ggplot2::ggsave(
    filename = paste0(name,".jpg"),
    plot     = g,
    device   = "jpg",
    path     = prints_folder,
    # width    = width,
    # height   = height,
    # units = "cm",
    dpi      = 'retina',
    limitsize = FALSE,
    ...
  )
}

# adds neat styling to your knitr table
neat <- function(x, output_format = "html"){
  # knitr.table.format = output_format
  if(output_format == "pandoc"){
    x_t <- knitr::kable(x, format = "pandoc")
  }else{
    x_t <- x %>%
      # x %>%
      # knitr::kable() %>%
      knitr::kable(format=output_format) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed","responsive"),
        # bootstrap_options = c( "condensed"),
        full_width = F,
        position = "left"
      )
  }
  return(x_t)
}


# ----- data-utility-functions -----------------------------------------------



# Function to safely convert numeric values 
safe_numeric_convert <- function(x) {
  cleaned <- as.character(x)
  cleaned <- gsub("[^0-9.\\s-]", "", cleaned)
  cleaned <- gsub("\\s+", "", cleaned)
  cleaned[cleaned == "" | cleaned == "-" | cleaned == "NULL" | 
          cleaned == "NA" | cleaned == "n/a" | is.na(cleaned)] <- "0"
  cleaned <- gsub("\\.{2,}", ".", cleaned)
  result <- suppressWarnings(as.numeric(cleaned))
  result[is.na(result)] <- 0
  return(result)
}



# ---- Database Connection Functions ----

#' Connect to Books of Ukraine Database
#' 
#' Connects to the specified stage of the Books of Ukraine database.
#' This replaces the outdated config::get() approach that was causing issues.
#' 
#' @param db_type Character. Database type to connect to:
#'   - "main" (default): Final analytical database (books-of-ukraine.sqlite)
#'   - "stage_2": Books + admin + custom data (books-of-ukraine-2.sqlite)
#' @param config_path Character. Path to config.yml file. Default: "config.yml"
#' 
#' @return DBI database connection object
#' 
#' @examples
#' # Standard connection for analysis
#' db <- connect_books_db()
#' 
#' # Connect to comprehensive database
#' db <- connect_books_db("stage_2")
#' 
#' # Connect to comprehensive database with all data
#' db <- connect_books_db("stage_2")
#' 
#' # Always close connection when done
#' DBI::dbDisconnect(db)
connect_books_db <- function(db_type = "main", config_path = "config.yml") {
  
  # Check if config package is available
  if (!requireNamespace("config", quietly = TRUE)) {
    stop("The 'config' package is required but not installed. Please install it with: install.packages('config')")
  }
  
  # Check if DBI package is available  
  if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("The 'DBI' package is required but not installed. Please install it with: install.packages('DBI')")
  }
  
  # Check if RSQLite package is available
  if (!requireNamespace("RSQLite", quietly = TRUE)) {
    stop("The 'RSQLite' package is required but not installed. Please install it with: install.packages('RSQLite')")
  }
  
  # Validate db_type parameter
  valid_types <- c("main", "stage_2")
  if (!db_type %in% valid_types) {
    stop("Invalid db_type '", db_type, "'. Must be one of: ", paste(valid_types, collapse = ", "))
  }
  
  # Check if config file exists
  if (!file.exists(config_path)) {
    stop("Configuration file not found: ", config_path)
  }
  
  # Load configuration
  tryCatch({
    config <- config::get(file = config_path)
  }, error = function(e) {
    stop("Failed to load configuration from ", config_path, ": ", e$message)
  })
  
  # Get database path
  if (is.null(config$database$books_of_ukraine[[db_type]])) {
    stop("Database configuration not found for type '", db_type, "' in ", config_path)
  }
  
  db_path <- config$database$books_of_ukraine[[db_type]]
  
  # Check if database file exists
  if (!file.exists(db_path)) {
    stop("Database file not found: ", db_path, 
         "\nNote: This database should have been created by the books-of-ukraine ETL pipeline.")
  }
  
  # Create connection
  tryCatch({
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    
    # Verify connection by listing tables
    tables <- DBI::dbListTables(con)
    if (length(tables) == 0) {
      DBI::dbDisconnect(con)
      stop("Database appears to be empty (no tables found): ", db_path)
    }
    
    message("✓ Connected to ", db_type, " database: ", basename(db_path))
    message("✓ Available tables: ", paste(tables, collapse = ", "))
    
    return(con)
    
  }, error = function(e) {
    stop("Failed to connect to database ", db_path, ": ", e$message)
  })
}

# ---- Silent Mini-EDA Integration ----
# Load silent mini-EDA functions for behind-the-scenes data analysis
source_silent_mini_eda <- function() {
  silent_eda_path <- "./scripts/silent-mini-eda.R"
  if (file.exists(silent_eda_path)) {
    source(silent_eda_path, local = TRUE)
    return(TRUE)
  } else {
    warning("Silent mini-EDA script not found at: ", silent_eda_path)
    return(FALSE)
  }
}

# Smart plotting assistant wrapper - loads silent mini-EDA if needed
smart_plot <- function(dataset_name, plot_intent = "explore", verbose = FALSE) {
  # Ensure silent mini-EDA functions are loaded
  if (!exists("silent_mini_eda")) {
    if (!source_silent_mini_eda()) {
      stop("Cannot load silent mini-EDA functions")
    }
  }
  
  # Source the functions into current environment
  source("./scripts/silent-mini-eda.R", local = FALSE)
  
  # Run the smart assistant
  result <- smart_ggplot_assistant(dataset_name, plot_intent)
  
  if (verbose) {
    cat("=== SMART PLOT ASSISTANT ===\n")
    cat("Dataset:", dataset_name, "\n")
    cat("Intent:", plot_intent, "\n\n")
    
    if (!is.null(result$plot_suggestions)) {
      cat("SUGGESTED PLOTS:\n")
      for (name in names(result$plot_suggestions)) {
        cat("\n", toupper(name), ":\n")
        cat(result$plot_suggestions[[name]], "\n")
      }
    }
    
    if (!is.null(result$recommended_aesthetics$color)) {
      cat("\nCOLOR MAPPING RECOMMENDATION:\n")
      if (!is.null(result$recommended_aesthetics$color$variable)) {
        cat("Use", result$recommended_aesthetics$color$variable, "for color aesthetic\n")
        cat("Reason:", result$recommended_aesthetics$color$rationale, "\n")
      } else {
        cat("Warning:", result$recommended_aesthetics$color$warning, "\n")
      }
    }
    
    if (length(result$data_preprocessing_needed) > 0) {
      cat("\nDATA PREPROCESSING SUGGESTIONS:\n")
      for (suggestion in result$data_preprocessing_needed) {
        cat("- ", suggestion, "\n")
      }
    }
  }
  
  # Return the assistant's raw result (informational list). Do not attach ggplot objects.
  return(result)
}

 