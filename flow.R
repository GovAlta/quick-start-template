# knitr::stitch_rmd(script="flow.R", output="stitched-output/flow.md")
rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# bash: Rscript flow.R

# ---- environment-check ------------------------------------------------------
# Check if environment is properly set up before running the workflow
cat("🔍 Checking project setup...\n")

# Quick validation of critical requirements
setup_ok <- TRUE
setup_messages <- c()

# Check critical packages for analysis
required_packages <- c("dplyr", "tidyr", "magrittr", "ggplot2", "DBI", "RSQLite", "config")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    setup_ok <- FALSE
    setup_messages <- c(setup_messages, paste("❌ Missing package:", pkg))
  }
}

# Check data availability
if (!dir.exists("data-private")) {
  setup_ok <- FALSE
  setup_messages <- c(setup_messages, "❌ Missing: data-private directory")
}

# Report results
if (!setup_ok) {
  cat("\n🚨 SETUP ISSUES DETECTED:\n")
  for (msg in setup_messages) {
    cat("  ", msg, "\n")
  }
  cat("\n⚠️  Flow execution will continue, but may fail.\n")
  cat("=====================================\n\n")
} else {
  cat("✅ Environment check passed!\n")
  cat("=====================================\n\n")
}

# ---- introduction -----------------------------------------------------------
# This script orchestrates the execution of various data manipulation, analysis,
# and reporting tasks for the project. It defines a sequence of operations
# (referred to as `ds_rail`) that are executed in order, using helper functions
# such as `run_r`, `run_sql`, `run_rmd`, and `run_python`.
#
# Key Features:
# - Supports multiple file types and execution modalities (R scripts, SQL files,
#   R Markdown documents, Python scripts).
# - Logs execution details for traceability.
# - Ensures all required source files exist before execution.
#
# Usage:
# - Modify the `ds_rail` tibble to specify the tasks and their corresponding file paths.
# - Run the script to execute the defined workflow.
# - Check the log file for execution details and troubleshooting.
#
# Note:
# - This script is designed to be constant between projects, except for the `ds_rail`
#   section, which should be customized for each project.

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
library(magrittr)
if(requireNamespace("purrr", quietly = TRUE)) {
  requireNamespace("purrr")
} else {
  cat("Note: purrr package not available, using base R alternatives\n")
}
if(requireNamespace("rlang", quietly = TRUE)) {
  requireNamespace("rlang")  
} else {
  cat("Note: rlang package not available, using base R alternatives\n")
}
# Note: OuhscMunge and config packages are optional for basic functionality# ---- declare-globals ---------------------------------------------------------
# Allow multiple files below to have the same chunk name.
#    If the `root.dir` option is properly managed in the Rmd files, no files will be overwritten.
options(knitr.duplicate.label = "allow")

# Simplified configuration - no config package dependency
if(file.exists("config.yml") && requireNamespace("config", quietly = TRUE)) {
  config <- config::get()
  use_logging <- TRUE
} else {
  cat("Note: Using simplified configuration (config.yml or config package not available)\n")
  config <- list(path_log_flow = paste0("logs/flow-", Sys.Date(), ".log"))
  use_logging <- FALSE
}

# open log
if( interactive() ) {
  sink_log <- FALSE
} else if(use_logging) {
  message("Creating flow log file at ", config$path_log_flow)

  if( !dir.exists(dirname(config$path_log_flow)) ) {
    # Create a month-specific directory, so they're easier to find & compress later.
    dir.create(dirname(config$path_log_flow), recursive=T)
  }

  file_log  <- file(
    description   = config$path_log_flow,
    open          = "wt"
  )
  sink(
    file    = file_log,
    type    = "message"
  )
  sink_log <- TRUE
} else {
  sink_log <- FALSE
}

# Typically, only `ds_rail` changes.  Everything else in this file is constant between projects.
ds_rail  <- tibble::tribble(
  ~fx         , ~path,

  # ===============================
  # PHASE 1: DATA IMPORT & PREPARATION  
  # ===============================
  
  # Main ETL (Extract-Transform-Load) from Google Sheets to local formats
  # "run_r"     , "manipulation/0-ellis.R",              # Core data import and prep - creates long and wide format datasets
  # "run_r"     , "manipulation/1-ellis-ua-admin.R",              # Enhance geography data with bookstore infrastructure - creates enhanced datasets
  # "run_r"     , "manipulation/2-ellis-extra.R",              # Adding extra custom data in future developments
  # "run_r"     , "manipulation/last-ellis.R",              
  
  # ===============================
  # PHASE 2: ANALYSIS SCRIPTS
  # ===============================
  
  # Core analysis scripts that depend on the manipulated data
  #"run_r"     , "analysis/eda-1/eda-1.R",              # Main exploratory data analysis script
  #"run_r"     , "analysis/Data-visualization/Data-visual.R",  # Data visualization script
  # "run_r"     , "analysis/report-example-2/1-scribe.R", # Scribe script for analysis-ready data
  
  # ===============================
  # PHASE 3: REPORTS & DOCUMENTATION
  # ===============================
  
  # Primary analysis reports (Quarto format) - WITH IMPROVED ERROR HANDLING
  "run_qmd"   , "analysis/eda-1/eda-1.qmd",            # Main exploratory data analysis report
  #"run_qmd"   , "analysis/Data-visualization/Data-visual.qmd", # Data visualization report
  # "run_qmd"   , "analysis/report-example-2/eda-1.qmd", # Analysis report example
  
  # Documentation and template examples
  # "run_qmd"   , "analysis/analysis-templatization/README.qmd" # Analysis documentation template
  
  # ===============================
  # PHASE 4: ADVANCED REPORTS (OPTIONAL)
  # ===============================  
  # Commented out by default - uncomment as needed
  
  # "run_qmd"   , "analysis/report-example-3/eda-1.qmd",        # Additional EDA report
  # "run_qmd"   , "analysis/report-example/annotation-layer-quarto.qmd", # Annotation layer example
  # "run_qmd"   , "analysis/report-example/combined-in-quarto.qmd",      # Combined report example  
  # "run_qmd"   , "analysis/report-example/combined-in-quarto-alt.qmd"   # Alternative combined report

)

run_r <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  base::source(minion, local=new.env())
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_sql <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  if(requireNamespace("OuhscMunge", quietly = TRUE) && exists("config", envir = .GlobalEnv)) {
    config_obj <- get("config", envir = .GlobalEnv)
    if(!is.null(config_obj$dsn_staging)) {
      OuhscMunge::execute_sql_file(minion, config_obj$dsn_staging)
    } else {
      warning("No dsn_staging configuration found. Skipping: ", minion)
    }
  } else {
    warning("SQL execution requires OuhscMunge package and configuration. Skipping: ", minion)
  }
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}
run_rmd <- function( minion ) {
  message("Pandoc available: ", rmarkdown::pandoc_available())
  message("Pandoc version: ", rmarkdown::pandoc_version())

  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  path_out <- rmarkdown::render(minion, envir=new.env())
  Sys.sleep(3) # Sleep for three secs, to let pandoc finish
  message(path_out)

  # Uncomment to save a dated version to a different location.
  #   Do this before the undated version, in case someone left it open (& locked it)
  # path_out_archive <- strftime(Sys.Date(), config$path_report_screen_archive)
  # if( !dir.exists(dirname(path_out_archive)) ) {
  #   # Create a month-specific directory, so they're easier to find & compress later.
  #   message("Creating subdirectory for archived eligibility reports: `", dirname(path_out_archive), "`.")
  #   dir.create(dirname(path_out_archive), recursive=T)
  # }
  # archive_successful <- file.copy(path_out, path_out_archive, overwrite=TRUE)
  # message("Archive success: ", archive_successful, " at `", path_out_archive, "`.")
  
  # Uncomment to copy the undated version to a different location.
  # If saving to a remote drive, this works better than trying to save directly from `rmarkdown::render()`.
  # To use this, you'll need a version of `run_rmd()` that's specialized for the specific rmd.
  # fs::file_copy(path_out, config$path_out_remote, overwrite = TRUE)

  return( TRUE )
}

run_qmd <- function( minion ) {
  # Check if quarto is available
  if (!requireNamespace("quarto", quietly = TRUE)) {
    stop("The 'quarto' package is required to render .qmd files. Please install it with: install.packages('quarto')")
  }
  
  message("Quarto available: ", quarto::quarto_path() != "")
  if (quarto::quarto_path() != "") {
    message("Quarto version: ", system2(quarto::quarto_path(), "--version", stdout = TRUE))
  }

  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  
  # Try-catch for better error handling
  tryCatch({
    path_out <- quarto::quarto_render(minion, execute_dir = dirname(minion))
    Sys.sleep(3) # Sleep for three secs, to let quarto finish
    message(path_out)
  }, error = function(e) {
    message("Error rendering ", basename(minion), ": ", e$message)
    message("Attempting fallback to direct CLI...")
    
    # Fallback to direct CLI call
    tryCatch({
      old_wd <- getwd()
      setwd(dirname(minion))
      result <- system2(quarto::quarto_path(), c("render", basename(minion)), 
                       stdout = TRUE, stderr = TRUE)
      setwd(old_wd)
      message("CLI render result: ", paste(result, collapse = "\n"))
    }, error = function(e2) {
      warning("Both R package and CLI rendering failed for ", basename(minion))
      message("Error details: ", e2$message)
    })
  })

  return( TRUE )
}
run_python <- function( minion ) {
  message("\nStarting `", basename(minion), "` at ", Sys.time(), ".")
  # reticulate::use_python(Sys.which("python3"))
  reticulate::source_python(minion)
  # reticulate::source_python(minion, envir = NULL)
  message("Completed `", basename(minion), "`.")
  return( TRUE )
}

# Check if all files exist before execution
file_found <- sapply(ds_rail$path, file.exists)
if( !all(file_found) ) {
  warning("--Missing files-- \n", paste0(ds_rail$path[!file_found], collapse="\n"))
  stop("All source files to be run should exist.")
}

# ---- load-data ---------------------------------------------------------------

# ---- tweak-data --------------------------------------------------------------

# ---- run ---------------------------------------------------------------------
message("Starting flow of `", basename(base::getwd()), "` at ", Sys.time(), ".")

warn_level_initial <- as.integer(options("warn"))
# options(warn=0)  # warnings are stored until the top–level function returns
# options(warn=2)  # treat warnings as errors

elapsed_duration <- system.time({
  if(requireNamespace("purrr", quietly = TRUE) && requireNamespace("rlang", quietly = TRUE)) {
    # Use purrr if available
    purrr::map2_lgl(
      ds_rail$fx,
      ds_rail$path,
      function(fn, args) rlang::exec(fn, !!!args)
    )
  } else {
    # Use base R alternative
    results <- logical(nrow(ds_rail))
    for(i in seq_len(nrow(ds_rail))) {
      fn_name <- ds_rail$fx[i]
      path <- ds_rail$path[i]
      
      # Execute the function by name
      fn <- get(fn_name)
      results[i] <- fn(path)
    }
    results
  }
})

message("Completed flow of `", basename(base::getwd()), "` at ", Sys.time(), "")
elapsed_duration
options(warn=warn_level_initial)  # Restore the whatever warning level you started with.

# ---- close-log ---------------------------------------------------------------
# close(file_log)
if( sink_log ) {
  sink(file = NULL, type = "message") # ends the last diversion (of the specified type).
  if(exists("config") && !is.null(config$path_log_flow)) {
    message("Closing flow log file at ", gsub("/", "\\\\", config$path_log_flow))
  } else {
    message("Closing flow log file")
  }
}

# bash: Rscript flow.R
# radian: source("flow.R")

# ---- introduction -----------------------------------------------------------
# This script orchestrates the execution of various data manipulation, analysis,
# and reporting tasks for the project. It defines a sequence of operations
# (referred to as `ds_rail`) that are executed in order, using helper functions
# such as `run_r`, `run_sql`, `run_rmd`, and `run_python`.
#
# Key Features:
# - Supports multiple file types and execution modalities (R scripts, SQL files,
#   R Markdown documents, Python scripts).
# - Logs execution details for traceability.
# - Ensures all required source files exist before execution.
#
# Usage:
# - Modify the `ds_rail` tibble to specify the tasks and their corresponding file paths.
# - Run the script to execute the defined workflow.
# - Check the log file for execution details and troubleshooting.
#
# Note:
# - This script is designed to be constant between projects, except for the `ds_rail`
#   section, which should be customized for each project.

# Load the copilot context automation
if (file.exists("scripts/update-copilot-context.R")) {
  source("scripts/update-copilot-context.R")
  message("✓ Copilot context automation loaded. Use: add_to_instructions('mission', 'glossary', ...)")
}
