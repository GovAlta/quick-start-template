# silent-mini-eda.R
# Silent mini-EDA function for behind-the-scenes data structure analysis
# Returns structured information to inform intelligent ggplot design decisions

#' Silent Mini-EDA for Dataset Structure Analysis
#' 
#' Performs a comprehensive but silent analysis of a dataset to inform
#' intelligent plotting decisions. Returns structured information instead
#' of printing to console.
#' 
#' @param dataset_name Character string name of the dataset to analyze
#' @param .env Environment to look for the dataset (default: .GlobalEnv)
#' @param include_samples Logical, whether to include sample data rows
#' @param verbose Logical, whether to print analysis to console (default: FALSE)
#' 
#' @return List with structured information about the dataset
silent_mini_eda <- function(dataset_name, .env = .GlobalEnv, include_samples = TRUE, verbose = FALSE) {
  
  # Check if dataset exists
  if (!base::exists(dataset_name, envir = .env)) {
    warning(paste("Dataset", dataset_name, "not found in specified environment"))
    return(list(
      dataset_name = dataset_name,
      exists = FALSE,
      error = paste("Dataset", dataset_name, "not found")
    ))
  }
  
  # Get the dataset
  df <- base::get(dataset_name, envir = .env)
  
  if (!is.data.frame(df)) {
    warning(paste("Object", dataset_name, "is not a data frame"))
    return(list(
      dataset_name = dataset_name,
      exists = TRUE,
      is_dataframe = FALSE,
      error = paste("Object", dataset_name, "is not a data frame")
    ))
  }
  
  # Basic structure
  structure_info <- list(
    dataset_name = dataset_name,
    exists = TRUE,
    is_dataframe = TRUE,
    dimensions = list(
      rows = nrow(df),
      cols = ncol(df)
    ),
    column_names = names(df)
  )
  
  # Column analysis
  column_analysis <- list()
  categorical_vars <- character(0)
  continuous_vars <- character(0)
  date_vars <- character(0)
  
  for (col in names(df)) {
    col_data <- df[[col]]
    col_info <- list(
      name = col,
      class = class(col_data)[1],
      n_unique = length(unique(col_data)),
      n_missing = sum(is.na(col_data)),
      pct_missing = round(sum(is.na(col_data)) / nrow(df) * 100, 2)
    )
    
    # Determine variable type for plotting
    if (is.numeric(col_data) || is.integer(col_data)) {
      if (col_info$n_unique <= 10 && col_info$n_unique < nrow(df) * 0.5) {
        col_info$plot_type <- "categorical_numeric"
        categorical_vars <- c(categorical_vars, col)
      } else {
        col_info$plot_type <- "continuous"
        continuous_vars <- c(continuous_vars, col)
        col_info$range <- range(col_data, na.rm = TRUE)
        col_info$summary <- summary(col_data)
      }
    } else if (is.character(col_data) || is.factor(col_data)) {
      col_info$plot_type <- "categorical"
      categorical_vars <- c(categorical_vars, col)
      if (col_info$n_unique <= 20) {  # Only show frequencies for manageable number of categories
        col_info$value_counts <- sort(table(col_data, useNA = "ifany"), decreasing = TRUE)
      }
    } else if (inherits(col_data, c("Date", "POSIXct", "POSIXt"))) {
      col_info$plot_type <- "date"
      date_vars <- c(date_vars, col)
      col_info$date_range <- range(col_data, na.rm = TRUE)
    } else {
      col_info$plot_type <- "other"
    }
    
    column_analysis[[col]] <- col_info
  }
  
  # Variable type summary
  variable_types <- list(
    categorical = categorical_vars,
    continuous = continuous_vars,
    date = date_vars,
    n_categorical = length(categorical_vars),
    n_continuous = length(continuous_vars),
    n_date = length(date_vars)
  )
  
  # Data samples
  samples <- NULL
  if (include_samples) {
    samples <- list(
      head = head(df, 6),
      tail = tail(df, 3)
    )
    if (nrow(df) > 20) {
      samples$random_sample <- df[sample(nrow(df), min(5, nrow(df))), ]
    }
  }
  
  # Plotting recommendations
  plotting_recommendations <- generate_plotting_recommendations(df, variable_types, column_analysis)
  
  # Compile results
  result <- list(
    structure = structure_info,
    columns = column_analysis,
    variable_types = variable_types,
    samples = samples,
    plotting_recommendations = plotting_recommendations,
    timestamp = Sys.time()
  )
  
  # Optional verbose output
  if (verbose) {
    print_mini_eda_summary(result)
  }
  
  return(result)
}

#' Generate intelligent plotting recommendations based on data structure
generate_plotting_recommendations <- function(df, var_types, col_analysis) {
  
  recommendations <- list()
  
  # Time series detection
  if (any(grepl("year|date|time", names(df), ignore.case = TRUE))) {
    time_vars <- names(df)[grepl("year|date|time", names(df), ignore.case = TRUE)]
    if (length(var_types$continuous) > 0 || length(var_types$categorical) > 0) {
      recommendations$time_series <- list(
        suitable = TRUE,
        time_var = time_vars[1],
        y_vars = var_types$continuous,
        grouping_vars = var_types$categorical[var_types$categorical != time_vars[1]]
      )
    }
  }
  
  # Categorical analysis recommendations
  if (length(var_types$categorical) > 0 && length(var_types$continuous) > 0) {
    recommendations$categorical_continuous <- list(
      suitable = TRUE,
      categorical_vars = var_types$categorical,
      continuous_vars = var_types$continuous,
      suggested_plots = c("boxplot", "violin", "bar_chart", "point_plot")
    )
  }
  
  # Multiple categorical variables
  if (length(var_types$categorical) >= 2) {
    recommendations$multiple_categorical <- list(
      suitable = TRUE,
      vars = var_types$categorical,
      suggested_plots = c("stacked_bar", "grouped_bar", "alluvial", "heatmap")
    )
  }
  
  # Continuous variables relationships
  if (length(var_types$continuous) >= 2) {
    recommendations$continuous_relationships <- list(
      suitable = TRUE,
      vars = var_types$continuous,
      suggested_plots = c("scatter", "line", "smooth", "correlation_matrix")
    )
  }
  
  # Long-format data detection (common in tidy data)
  if ("measure" %in% names(df) && "value" %in% names(df)) {
    recommendations$long_format <- list(
      detected = TRUE,
      measure_var = "measure",
      value_var = "value",
      grouping_vars = setdiff(var_types$categorical, "measure"),
      suggested_approach = "Pivot wider for some analyses, or use measure as grouping variable"
    )
  }
  
  return(recommendations)
}

#' Print summary of mini-EDA results (for verbose mode)
print_mini_eda_summary <- function(eda_result) {
  cat("=== SILENT MINI-EDA SUMMARY ===\n")
  cat("Dataset:", eda_result$structure$dataset_name, "\n")
  cat("Dimensions:", eda_result$structure$dimensions$rows, "rows x", eda_result$structure$dimensions$cols, "columns\n\n")
  
  cat("Variable Types:\n")
  cat("  Categorical (", eda_result$variable_types$n_categorical, "):", paste(eda_result$variable_types$categorical, collapse = ", "), "\n")
  cat("  Continuous (", eda_result$variable_types$n_continuous, "):", paste(eda_result$variable_types$continuous, collapse = ", "), "\n")
  cat("  Date (", eda_result$variable_types$n_date, "):", paste(eda_result$variable_types$date, collapse = ", "), "\n\n")
  
  if (!is.null(eda_result$plotting_recommendations$time_series)) {
    cat("Time Series Potential: YES\n")
  }
  
  if (!is.null(eda_result$plotting_recommendations$long_format)) {
    cat("Long Format Detected: YES\n")
  }
  
  cat("Analysis completed at:", format(eda_result$timestamp), "\n")
}

#' Smart ggplot design assistant using silent mini-EDA
#' 
#' Analyzes dataset structure and provides intelligent ggplot code suggestions
#' 
#' @param dataset_name Name of the dataset
#' @param plot_intent Character describing what kind of plot is desired
#' @param .env Environment containing the dataset
smart_ggplot_assistant <- function(dataset_name, plot_intent = "explore", .env = .GlobalEnv) {
  
  # Run silent mini-EDA
  eda <- silent_mini_eda(dataset_name, .env = .env, verbose = FALSE)
  # Support two possible return shapes from silent_mini_eda():
  # 1) error case returns top-level fields: list(dataset_name=..., exists=FALSE, error=...)
  # 2) normal case returns nested structure: list(structure=list(exists=TRUE, is_dataframe=TRUE), ...)
  exists_flag <- NULL
  is_df_flag <- NULL
  err_msg <- NULL

  if (!is.null(eda$exists)) {
    exists_flag <- eda$exists
  } else if (!is.null(eda$structure) && !is.null(eda$structure$exists)) {
    exists_flag <- eda$structure$exists
  }

  if (!is.null(eda$is_dataframe)) {
    is_df_flag <- eda$is_dataframe
  } else if (!is.null(eda$structure) && !is.null(eda$structure$is_dataframe)) {
    is_df_flag <- eda$structure$is_dataframe
  }

  if (!is.null(eda$error)) err_msg <- eda$error
  if (is.null(err_msg) && !is.null(eda$structure) && !is.null(eda$structure$error)) err_msg <- eda$structure$error

  # Defensive defaults: assume dataset exists & is a dataframe unless explicitly false
  if (is.null(exists_flag)) exists_flag <- TRUE
  if (is.null(is_df_flag)) is_df_flag <- TRUE

  if (!exists_flag || !is_df_flag) {
    return(paste("Cannot analyze dataset:", if (!is.null(err_msg)) err_msg else dataset_name))
  }
  
  # Generate smart recommendations based on intent and data structure
  suggestions <- list()
  
  # Time series suggestions
  if (!is.null(eda$plotting_recommendations$time_series) && 
      grepl("time|trend|dynamic|year|temporal", plot_intent, ignore.case = TRUE)) {
    
    time_rec <- eda$plotting_recommendations$time_series
    suggestions$time_series <- paste0(
      "# Time series plot detected:\n",
      "ggplot(", dataset_name, ", aes(x = ", time_rec$time_var, ", y = value)) +\n",
      "  geom_line() +\n",
      "  geom_point()",
      if (length(time_rec$grouping_vars) > 0) paste0(" +\n  # Consider grouping by: ", paste(time_rec$grouping_vars, collapse = ", ")) else ""
    )
  }
  
 
  return(list(
    dataset_analysis = eda,
    plot_suggestions = suggestions,
    recommended_aesthetics = get_aesthetic_recommendations(eda),
    data_preprocessing_needed = get_preprocessing_suggestions(eda)
  ))
}

#' Get aesthetic recommendations based on data structure
get_aesthetic_recommendations <- function(eda) {
  aesthetics <- list()
  
  # Color recommendations
  if (eda$variable_types$n_categorical > 0) {
    cat_var <- eda$variable_types$categorical[1]
    n_categories <- eda$columns[[cat_var]]$n_unique
    
    if (n_categories <= 8) {
      aesthetics$color <- list(
        variable = cat_var,
        palette = "viridis_d",
        rationale = paste("Categorical variable with", n_categories, "categories - suitable for color mapping")
      )
    } else {
      aesthetics$color <- list(
        warning = paste("Variable", cat_var, "has", n_categories, "categories - consider filtering or grouping")
      )
    }
  }
  
  return(aesthetics)
}

#' Get data preprocessing suggestions
get_preprocessing_suggestions <- function(eda) {
  suggestions <- character(0)
  
  # Missing data
  missing_vars <- sapply(eda$columns, function(x) x$pct_missing > 0)
  if (any(missing_vars)) {
    suggestions <- c(suggestions, "Consider handling missing values in variables with NA data")
  }
  
  # Long format detection
  if (!is.null(eda$plotting_recommendations$long_format)) {
    suggestions <- c(suggestions, "Data appears to be in long format - consider pivot_wider() for some analyses")
  }
  
  return(suggestions)
}

#' Write mini-EDA object as JSON into a local-ai-context subfolder
#'
#' Saves the list produced by `silent_mini_eda()` into JSON under
#' `file.path(script_dir, local_folder, <dataset_name>)` so analytic
#' scripts can persist context for AI helpers.
#'
#' @param eda_obj The list produced by `silent_mini_eda()`.
#' @param script_dir Directory of the analytic script (default: current working directory)
#' @param local_folder Name of the top-level folder to store AI context (default: "local-ai-context")
#' @param subfolder Optional subfolder name (defaults to dataset name from `eda_obj`)
#' @param filename Optional filename (defaults to "<dataset>_mini_eda.json")
#' @param pretty Logical passed to json writing for readability (default: TRUE)
#' @param overwrite Logical whether to overwrite an existing file (default: TRUE)
#' @return Invisibly returns the full path to the written JSON file.
write_mini_eda_json <- function(eda_obj, script_dir = ".", local_folder = "local-ai-context",
                                subfolder = NULL, filename = NULL, pretty = TRUE, overwrite = TRUE) {
  # Basic validation
  if (is.null(eda_obj) || !is.list(eda_obj)) {
    stop("eda_obj must be a list as returned by silent_mini_eda()")
  }

  # Determine subfolder (dataset name preferred)
  if (is.null(subfolder)) {
    subfolder <- NULL
    if (!is.null(eda_obj$structure) && !is.null(eda_obj$structure$dataset_name)) {
      subfolder <- as.character(eda_obj$structure$dataset_name)
    }
    if (is.null(subfolder) || nchar(subfolder) == 0) subfolder <- "unknown_dataset"
  }

  # Ensure safe names (no path separators)
  subfolder <- gsub("[\\/:*?\"<>|]+", "_", subfolder)

  # Build directories
  target_dir <- file.path(script_dir, local_folder, subfolder)
  if (!fs::dir_exists(target_dir)) {
    fs::dir_create(target_dir, recurse = TRUE)
  }

  # Default filename
  if (is.null(filename)) {
    filename <- paste0(subfolder, "_mini_eda.json")
  }
  filename <- gsub("[\\/:*?\"<>|]+", "_", filename)

  file_path <- file.path(target_dir, filename)

  if (fs::file_exists(file_path) && !overwrite) {
    stop("File already exists and overwrite = FALSE: ", file_path)
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required to write JSON. Please install it with install.packages('jsonlite').")
  }

  # Sanitize the object for JSON: convert tables, factors, and POSIXt to plain types
  sanitize_for_json <- function(x) {
    # Handle NULL
    if (is.null(x)) return(NULL)

    # Tables -> named lists of counts
    if (inherits(x, "table")) {
      vals <- as.integer(x)
      nms <- names(x)
      if (is.null(nms)) return(as.list(vals))
      out <- as.list(vals)
      names(out) <- nms
      return(out)
    }

    # Factors -> character vector
    if (is.factor(x)) return(as.character(x))

    # POSIXt/Date -> ISO8601 strings
    if (inherits(x, "POSIXt")) return(format(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
    if (inherits(x, "Date")) return(format(x, "%Y-%m-%d"))

    # Data frames -> convert each column
    if (is.data.frame(x)) {
      return(lapply(x, sanitize_for_json))
    }

    # Lists -> recurse
    if (is.list(x)) {
      return(lapply(x, sanitize_for_json))
    }

    # Matrices/arrays -> convert to list of rows
    if (is.matrix(x) || is.array(x)) {
      # convert to list of row-lists for simplicity
      return(apply(x, 1, function(r) as.list(r)))
    }

    # Default: return atomic vectors as-is
    return(x)
  }

  eda_clean <- sanitize_for_json(eda_obj)

  # Write JSON with sensible defaults: auto_unbox, ISO8601 for POSIXt
  jsonlite::write_json(eda_clean, file_path, pretty = pretty, auto_unbox = TRUE, POSIXt = "ISO8601")

  message("Wrote mini-EDA JSON to: ", file_path)
  invisible(file_path)
}

# Compatibility wrapper: older scripts may call save_mini_eda_as_json
save_mini_eda_as_json <- function(...) {
  write_mini_eda_json(...)
}
